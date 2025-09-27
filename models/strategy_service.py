import pickle
from tqdm import tqdm
from typing import Dict, List, Tuple
import pandas as pd
import numpy as np

from backtrader_service import Position, PositionDirection
from utils import MEDIAN, ATR, PERCENTILE


def optimize_df(df):
    # Конвертируем в numpy arrays для быстрого доступа
    return {
        'open': df['open'].values,
        'high': df['high'].values,
        'low': df['low'].values,
        'close': df['close'].values,
        'median': df['median'].values,
        'p99': df['p99'].values,
        'p01': df['p01'].values,
        'atr': df['atr'].values,
        'index': df.index
    }

def save_progress(data: Dict, filename: str = 'progress.pkl'):
    """Сохраняет текущий прогресс в pickle файл"""
    with open(filename, 'wb') as f:
        pickle.dump(data, f)

def load_progress(filename: str = 'progress.pkl') -> Dict:
    """Загружает прогресс из pickle файла"""
    try:
        with open(filename, 'rb') as f:
            return pickle.load(f)
    except FileNotFoundError:
        return {}

def should_open_buy_position(df: Dict, i: int) -> bool:
    """Определяет условия для открытия длинной позиции"""
    return (
        df['p99'][i-3] == df['p99'][i-2] and 
        df['p99'][i-2] < df['p99'][i-1] 
        and (df['index'][i-1].hour >=9 and df['index'][i-1].hour < 19)
        and (df['index'][i-1].weekday not in {5,6})
    )

def should_open_sell_position(df: Dict, i: int) -> bool:
    """Определяет условия для открытия короткой позиции"""
    return (
        df['p01'][i-3] == df['p01'][i-2] and
        df['p01'][i-2] > df['p01'][i-1]
        and (df['index'][i-1].hour >=9 and df['index'][i-1].hour < 19)
        # and (df['index'][i-1].weekday not in {5,6})
    )

def should_close_buy_position(position: Position, df: Dict, i: int) -> bool:
    """Определяет условия для закрытия длинной позиции"""
    return (position.open + position.take_profit < df['high'][i] or
            position.open - position.stop_loss > df['low'][i])

def should_close_sell_position(position: Position, df: Dict, i: int) -> bool:
    """Определяет условия для закрытия короткой позиции"""
    return (position.open - position.take_profit > df['low'][i] or
            position.open + position.stop_loss < df['high'][i])

def process_positions(
        df: Dict[str, np.array],
        coef_prof: float,
        coef_loss: float,
        allow_long: bool = True,
        allow_short: bool = True,
    ) -> List[Position]:
    """Обрабатывает все позиции для текущих параметров"""
    cur_direction = PositionDirection.cash
    list_positions = []
    cur_position = None

    for i in range(2, df['index'].size):
        if cur_direction == PositionDirection.cash:
            if allow_long and should_open_buy_position(df, i):
                cur_direction = PositionDirection.buy
                cur_position = Position(
                    direction=PositionDirection.buy,
                    open=df['open'][i],
                    open_time=df['index'][i],
                    # take_profit=coef_prof*df['atr'][i-1],
                    # stop_loss=coef_loss*df['atr'][i-1],
                    take_profit=coef_prof*df['close'][i-1],
                    stop_loss=coef_loss*df['close'][i-1],
                )
            elif allow_short and should_open_sell_position(df, i):
                cur_direction = PositionDirection.sell
                cur_position = Position(
                    direction=PositionDirection.sell,
                    open=df['open'][i],
                    open_time=df['index'][i],
                    # take_profit=coef_prof*df['atr'][i-1],
                    # stop_loss=coef_loss*df['atr'][i-1],
                    take_profit=coef_prof*df['close'][i-1],
                    stop_loss=coef_loss*df['close'][i-1],
                )
        else:
            if (cur_position.direction == PositionDirection.buy and 
                should_close_buy_position(cur_position, df, i)):
                
                if cur_position.open + cur_position.take_profit < df['high'][i]:
                    cur_position.close = cur_position.open + cur_position.take_profit
                else:
                    cur_position.close = cur_position.open - cur_position.stop_loss
                
                cur_position.close_time = df['index'][i]
                list_positions.append(cur_position)
                cur_position = None
                cur_direction = PositionDirection.cash
            
            elif (cur_position.direction == PositionDirection.sell and 
                  should_close_sell_position(cur_position, df, i)):
                
                if cur_position.open - cur_position.take_profit > df['low'][i]:
                    cur_position.close = cur_position.open - cur_position.take_profit
                else:
                    cur_position.close = cur_position.open + cur_position.stop_loss
                
                cur_position.close_time = df['index'][i]
                list_positions.append(cur_position)
                cur_position = None
                cur_direction = PositionDirection.cash

    return list_positions

def run_backtest(
    df: pd.DataFrame,
    date_start: str,
    median_range: range = range(25, 31, 5),
    atr_range: range = range(4, 6),
    coef_prof_range: range = range(2, 4),
    coef_loss_range: range = range(2, 4),
    filename: str = 'progress.pkl',
    is_save: bool = False,
    direction: Tuple = (True, True),
) -> Dict:
    # period_ema=30:period_atr=5:coef_prof=2:coef_loss=2
    """Основная функция для запуска бэктеста"""
    results = dict()
    if is_save:
        results = load_progress(filename=filename)
    
    try:
        for period_ema in tqdm(median_range, desc="EMA Progress", position=1, leave=False):
            df['median'] = MEDIAN(df['close'], period=period_ema)
            df['p99'] = PERCENTILE(df['close'], period=period_ema, perc=0.99)
            df['p01'] = PERCENTILE(df['close'], period=period_ema, perc=0.01)
            

            for period_atr in atr_range:
                df['atr'] = ATR(df, period=period_atr)
                df_work = df.iloc[period_ema:]  # Убираем первые нерелевантные строки
                if date_start != '':
                    df_work = df_work.loc[date_start:,:]  # начинае с начала периода

                opt_df = optimize_df(df_work)

                for coef_prof in coef_prof_range:
                    for coef_loss in coef_loss_range:
                        if coef_prof/coef_loss > 1.4:
                            key = f'{period_ema=}:{period_atr=}:{coef_prof=}:{coef_loss=}'
                            
                            # Пропускаем уже рассчитанные параметры
                            if key in results:
                                continue
                                
                            positions = process_positions(
                                opt_df,
                                coef_prof,
                                coef_loss,
                                allow_long=direction[0],
                                allow_short=direction[1],
                            )
                            results[key] = positions
                            
                            # Сохраняем прогресс после каждой итерации
                            if is_save:
                                save_progress(results, filename)
    except Exception as e:
        print(f"Произошла ошибка: {str(e)}")
        print("Сохраняем текущий прогресс перед выходом...")
        if is_save:
            save_progress(results, filename)
        raise
    
    return results
