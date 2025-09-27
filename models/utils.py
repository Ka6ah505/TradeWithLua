import math
import pandas as pd
import numpy as np


def parabolic_sar(high, low, af_start=0.02, af_step=0.02, af_max=0.2):
    """
    Рассчитывает Parabolic SAR (SAR)
    
    Параметры:
        high (pd.Series): Цена high.
        low (pd.Series): Цена low.
        af_start (float): Начальный AF (по умолчанию 0.02).
        af_step (float): Шаг увеличения AF (по умолчанию 0.02).
        af_max (float): Максимальный AF (по умолчанию 0.2).
    
    Возвращает:
        pd.Series: Значения SAR.
    """
    length = len(high)
    sar = np.zeros(length)
    trend = np.zeros(length, dtype=int)
    ep = np.zeros(length)
    af = np.zeros(length)
    
    sar[0] = low.iloc[0]
    trend[0] = 1
    ep[0] = high.iloc[0]
    af[0] = af_start
    
    for i in range(1, length):
        sar[i] = sar[i-1] + af[i-1] * (ep[i-1] - sar[i-1])
        
        if trend[i-1] == 1:
            if low.iloc[i] < sar[i]:
                trend[i] = -1
                sar[i] = ep[i-1]
                ep[i] = low.iloc[i]
                af[i] = af_start
            else:
                trend[i] = 1
                if high.iloc[i] > ep[i-1]:
                    ep[i] = high.iloc[i]
                    af[i] = min(af[i-1] + af_step, af_max)
                else:
                    ep[i] = ep[i-1]
                    af[i] = af[i-1]
        else:
            if high.iloc[i] > sar[i]:
                trend[i] = 1
                sar[i] = ep[i-1]
                ep[i] = high.iloc[i]
                af[i] = af_start
            else:
                trend[i] = -1
                if low.iloc[i] < ep[i-1]:
                    ep[i] = low.iloc[i]
                    af[i] = min(af[i-1] + af_step, af_max)
                else:
                    ep[i] = ep[i-1]
                    af[i] = af[i-1]
    
    return pd.Series(sar, index=high.index) #.shift(1)  # сдвиг на 1 бар



# Предполагаем, что есть CSV с колонками: datetime, open, high, low, close, volume
# df = pd.read_csv('dowload_data/CNYRUBF_1Min.txt', parse_dates=['datetime'], index_col='datetime')
def readQuotes(path):
    try:
        quotes = pd.read_csv(path, sep=';')
        quotes['date'] = quotes['date'] + ' ' + quotes['time']
        del quotes['time']
        quotes['date'] = pd.to_datetime(
            quotes['date'],
            # format=['%d.%m.%Y %H:%M:%S','%d/%m/%y %H:%M:%S','%d/%m/%Y %H:%M:%S'],
            errors='raise',
            dayfirst=True
        )
        quotes.index = quotes['date']
        quotes.index.name = 'Date'
        del quotes['date']
        quotes[quotes.columns].astype(float)
        return quotes
    except pd.errors.EmptyDataError:
        print(f"File {path} is empty")
        return pd.DataFrame()
    except pd.errors.ParserError as e:
        print(f"Error parsing file {path}: {e}")


def EMA(data, period=10):
    """ Экспоненциальная скользящая средняя
    EMA(current) = ( (Price(current) - EMA(prev) ) x Multiplier) + EMA(prev)
    return list<float>
    """
    result = [data[i] for i in range(period)]
    multiple = 2/(period+1)
    for i in range(period, len(data)):
        result.append(((data[i]-result[-1])*multiple)+result[-1])
    return result


def ATR(data: pd.DataFrame, period: int = 14) -> pd.Series:
    high_low = data['high'] - data['low']
    high_close_prev = abs(data['high'] - data['close'].shift(1))
    low_close_prev = abs(data['low'] - data['close'].shift(1))
    
    true_range = pd.concat([high_low, high_close_prev, low_close_prev], axis=1)
    true_range = true_range.max(axis=1)
    
    # Улучшенный расчет ATR
    atr = pd.Series(index=data.index, dtype='float64')
    atr.iloc[period-1] = true_range.iloc[:period].mean()  # Первое значение - простое среднее
    
    for i in range(period, len(data)):
        atr.iloc[i] = (atr.iloc[i-1] * (period-1) + true_range.iloc[i]) / period
    
    return atr


def MEDIAN(data, period=10):
    """ Медиана на периоде
    """
    result = [data[i] for i in range(period)]
    for i in range(period, len(data)):
        window = sorted(data[i - period + 1 : i + 1])
        result.append(window[period//2])
    return result


def PERCENTILE(data, period=10, perc=0.5):
    result = [data[i] for i in range(period)]
    pos = math.ceil(perc * period)
    for i in range(period, len(data)):
        window = sorted(data[i - period + 1 : i + 1])
        if pos>=period:
            result.append(window[pos-1])
        else:
            result.append(window[pos-1])
    return result


# Самый быстрый вариант с использованием rolling и apply
def calculate_linear_regression_rolling(df, period=20, price_column='close'):
    """
    Расчет с использованием rolling window (самый эффективный)
    """
    def linear_regression(y):
        x = np.arange(len(y))
        if len(y) < 2:
            return np.nan
        b = (len(y) * np.sum(x*y) - np.sum(x) * np.sum(y)) / (len(y) * np.sum(x*x) - np.sum(x)**2)
        a = (np.sum(y) - b * np.sum(x)) / len(y)
        return a + b * (len(y) - 1)
    
    return df[price_column].rolling(window=period).apply(linear_regression, raw=True)
