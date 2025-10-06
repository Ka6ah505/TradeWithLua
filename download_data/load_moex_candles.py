import os
import requests
import pandas as pd
from datetime import datetime, timedelta
from dateutil.relativedelta import relativedelta
import time


TF = {
    # '': 'тики',
    '1 мин': 1,
    '10 мин': 10,
    '1 час': 60,
    '1 день': 24,
    '1 неделя': 7,
    '1 месяц': 31,
    '1 квартал': 4.
}


class MoexCandlesLoader:
    def __init__(self):
        self.base_url = "https://iss.moex.com/iss/engines/stock/markets/{}/boards/{}/securities/{}/candles.json"
        self.request_delay = 0.1  # Задержка между запросами для избежания лимитов

    def _make_request(self, url, params):
        """Базовый метод для выполнения запроса"""
        time.sleep(self.request_delay)  # Задержка между запросами
        response = requests.get(url, params=params)
        if response.status_code != 200:
            raise Exception(f"Ошибка запроса: {response.status_code}")
        return response.json()

    def _get_candles_chunk(
        self, security, interval, market, board, start, end, count=500
    ):
        """Получение части данных за указанный период"""
        url = self.base_url.format(market, board, security)
        params = {
            'interval': interval,
            'from': start.strftime('%Y-%m-%d %H:%M:%S'),
            'till': end.strftime('%Y-%m-%d %H:%M:%S'),
            'count': count
        }

        data = self._make_request(url, params)
        if 'candles' not in data:
            return pd.DataFrame()
        
        candles = data['candles']['data']
        df = pd.DataFrame(candles, columns=data['candles']['columns'])
        
        if not df.empty:
            df['begin'] = pd.to_datetime(df['begin'])
            df['end'] = pd.to_datetime(df['end'])
            df.set_index('begin', inplace=True)
        
        return df

    def _calculate_chunk_dates(self, interval, start_date, end_date):
        """Вычисление оптимальных периодов для загрузки данных"""
        if interval == 1:  # 1 минута - 1 день
            delta = timedelta(days=1)
        elif interval == 10:  # 10 минут - 3 дня
            delta = timedelta(days=3)
        elif interval == 60:  # 1 час - 2 недели
            delta = timedelta(weeks=2)
        elif interval == 24:  # 1 день - 1 год
            delta = relativedelta(years=1)
        elif interval == 7:  # 1 неделя - 3 года
            delta = relativedelta(years=3)
        elif interval == 31:  # 1 месяц - 10 лет
            delta = relativedelta(years=10)
        else:
            delta = relativedelta(years=1)  # по умолчанию

        return delta

    def load_candles(
        self,
        security,
        interval=1,
        market='shares',
        board='TQBR',
        start_date=None,
        end_date=None,
    ):
        """
        Полная загрузка свечных данных за указанный период

        Параметры:
        security - код ценной бумаги (например, 'SBER')
        interval - интервал свечи в минутах (1, 10, 60, 1440, 10080, 43200)
        market - рынок ('shares' - акции)
        board - режим торгов ('TQBR' - основной режим торгов акциями)
        start_date - дата начала в формате 'YYYY-MM-DD' или datetime
        end_date - дата конца в формате 'YYYY-MM-DD' или datetime

        Возвращает:
        DataFrame с колонками: open, high, low, close, volume, begin, end
        """
        # Преобразование дат
        end_date = pd.to_datetime(end_date or datetime.now())
        start_date = pd.to_datetime(start_date or end_date - relativedelta(years=1))

        # Проверка корректности периода
        if start_date > end_date:
            raise ValueError('Дата начала должна быть раньше даты окончания')

        # Вычисление оптимального размера чанков для загрузки
        chunk_delta = self._calculate_chunk_dates(interval, start_date, end_date)

        all_data = []
        current_start = start_date
        current_end = min(current_start + chunk_delta, end_date)
        max_attempts = (
            1000  # Максимальное количество итераций для защиты от бесконечного цикла
        )
        attempt = 0

        while current_start <= end_date and attempt < max_attempts:
            attempt += 1
            # print(f"Загрузка данных с {current_start.date()} по {current_end.date()}...")
            
            df = self._get_candles_chunk(security, interval, market, board, 
                                       current_start, current_end)
            
            if not df.empty:
                all_data.append(df)
                # Следующий период начинается с даты последней загруженной свечи + 1 интервал
                last_date = df.index.max()
                if interval == 1:  # 1 минута
                    current_start = last_date + timedelta(minutes=1)
                elif interval == 10:  # 10 минут
                    current_start = last_date + timedelta(minutes=10)
                elif interval == 60:  # 1 час
                    current_start = last_date + timedelta(hours=1)
                elif interval == 24:  # 1 день
                    current_start = last_date + timedelta(days=1)
                elif interval == 7:  # 1 неделя
                    current_start = last_date + timedelta(weeks=1)
                elif interval == 31:  # 1 месяц
                    current_start = last_date + relativedelta(months=1)
            else:
                # Если данные не получены, просто сдвигаем период
                current_start = current_end
            
            current_end = min(current_start + chunk_delta, end_date)
            print(current_start, current_end)
            if current_start == current_end:
                break
        if attempt >= max_attempts:
            raise Exception("Превышено максимальное количество попыток. Возможно, проблема с API или в логике загрузки.")
    
        if not all_data:
            return pd.DataFrame()

        result = pd.concat(all_data)
        return result.sort_index()

    @staticmethod
    def reformated_df(df: pd.DataFrame):
        df['begin'] = df.index.strftime('%d.%m.%Y %H:%M:%S')
        df[['date', 'time']] = df['begin'].str.split().values.tolist()
        df.reset_index(drop=True, inplace=True)
        del df['begin']
        del df['end']
        del df['value']
        df.drop_duplicates(inplace=True)
        return df


# Пример использования
if __name__ == "__main__":
    tikers = []
    type_history = '10MIN_history'
    with open("download_data/temp.txt", "r") as file:
        for t in file.readlines():
            t = t[:-1]  # отрываем символ переноса строки
            tikers.append(t)
    trash = []
    loader = MoexCandlesLoader()
    for tiker in tikers:
        try:
            print('Грузим: ', tiker)
            # Загрузка дневных данных за 3 года
            df = loader.load_candles(
                security=tiker,
                interval=TF['10 мин'],
                start_date='2024-01-01',
                end_date='2025-09-30',
            )

            df = loader.reformated_df(df)

            """
            Сохранение в первый раз
            """
            print(f'\nЗагружено {len(df)} свечей')

            if not os.path.exists(f'download_data/{tiker}'):
                os.mkdir(f'download_data/{tiker}')

            if os.path.exists(f'download_data/{tiker}/{tiker}_{type_history}.txt'):
                print('Файл есть. Будем дополнять')
                exist_df = pd.read_csv(
                    f'download_data/{tiker}/{tiker}_{type_history}.txt',
                    sep=';',
                    dtype={
                        'time': 'str',
                        'open': 'float',
                        'high': 'float',
                        'low': 'float',
                        'close': 'float',
                        'volume': 'float',
                    },
                    parse_dates=['date'],
                )
                to_save_df = pd.concat([exist_df, df])
                to_save_df.drop_duplicates(inplace=True)
                to_save_df.sort_values(by=['date', 'time'])
                to_save_df.to_csv(
                    f'download_data/{tiker}/{tiker}_{type_history}.txt',
                    sep=';',
                    index=False,
                )
            else:
                df.to_csv(
                    f'download_data/{tiker}/{tiker}_{type_history}.txt',
                    sep=';',
                    index=False,
                )

        except Exception as err:
            print(err)
            trash.append(tiker)

    if len(trash) > 0:
        print('Не выгрузил: ', trash)
