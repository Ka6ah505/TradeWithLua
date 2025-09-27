import datetime
import enum
from typing import Dict, List


class PositionDirection(enum.Enum):
    buy = 'buy'
    sell = 'sell'
    cash = 'cash'

    def __str__(self):
        return str(self.value)


class Position:
    def __init__(
        self,
        direction: PositionDirection,
        open_time: datetime,
        open: float,
        take_profit: float,
        stop_loss: float,
        close: float = None,
        close_time: datetime = None
    ):
        self._direction = direction
        self._open_time = open_time
        self._open = open
        self._take_profit = take_profit
        self._stop_loss = stop_loss
        self._close = close
        self._close_time = close_time

    @property
    def open_weekday(self):
        return self.open_time.weekday()
    
    @property
    def direction(self):
        return self._direction

    @property
    def open(self):
        return self._open
    
    @property
    def open_time(self):
        return self._open_time
    
    @property
    def take_profit(self):
        return self._take_profit
    
    @property
    def stop_loss(self):
        return self._stop_loss
    
    @property
    def close(self):
        return self._close
    
    @close.setter
    def close(self, value):
        self._close = value
    
    @property
    def close_time(self):
        return self._close_time
    
    @close_time.setter
    def close_time(self, value):
        self._close_time = value
    
    @property
    def fee_open(self):
        """
        Коммисионные 0.0004 = 0.04%
        """
        return self._open * 0.0004
    
    @property
    def fee_close(self):
        if self._close:
            return self._close * 0.0004
        return 0.0
    
    @property
    def clear_cash(self):
        if self._close:
            if self._direction == PositionDirection.buy:
                return self._close - self._open - (self.fee_open + self.fee_close)
            return self._open - self._close - (self.fee_open + self.fee_close)
        return 0.0
    
    def __str__(self):
        return f'{self._direction.value} ->\n' \
            f'\tresult: {self.clear_cash}\n' \
            f'\topen: {self._open}\n\tclose: {self._close}\n' \
            f'\ttake: {self._take_profit}\n\tloss: {self._stop_loss}\n' \
            f'\topen_time: {self._open_time.strftime("%Y-%m-%d %H:%M")}\n' \
            f'\tclose_time: {self._close_time.strftime("%Y-%m-%d %H:%M")}'


def calculate_cumulative_pnl(positions: List[Position]):
    # Фильтруем только закрытые позиции (у которых есть close_time и close)
    closed_positions = [p for p in positions if p.close_time is not None and p.close is not None]
    
    # Сортируем по времени закрытия
    closed_positions.sort(key=lambda x: x.close_time)
    
    # Рассчитываем PnL для каждой сделки
    pnl = []
    dates = []
    cumulative = 0
    
    for position in closed_positions:
        # if position.direction == PositionDirection.buy:
        #     trade_pnl = position.close - position.open
        # elif position.direction == PositionDirection.sell:
        #     trade_pnl = position.open - position.close
        # else:  # cash
        #     trade_pnl = 0
        
        # cumulative += trade_pnl
        cumulative += position.clear_cash
        pnl.append(cumulative)
        dates.append(position.close_time)
    
    return dates, pnl


def select_best_model(results: Dict):
    best = (0, 0)
    for k, v in results.items():
        d, pnl = calculate_cumulative_pnl(v)
        if len(pnl) > 0 and pnl[-1] > best[1]:
            best = (k, pnl[-1])
    
    return best


def select_top_n_models(results: Dict, n: int=5):
    """
    Модели с лучшим доходом
    """

    models = []
    for k, v in results.items():
        d, pnl = calculate_cumulative_pnl(v)
        if len(pnl) > 0:
            models.append((k, pnl[-1]))
    
    # Сортируем модели по PnL в порядке убывания и берем топ-5
    models.sort(key=lambda x: x[1], reverse=True)
    return models[:n]


def _calc_rate(deal):
    pl = 0
    ll = 0
    for i in deal:
        if i.direction == PositionDirection.buy and ((i.close - i.open) > 0):
            pl += 1
        elif i.direction == PositionDirection.sell and ((i.open - i.close) > 0):
            pl += 1
        else:
            ll += 1
    rate_result = 0
    try:
        rate_result = pl/(pl+ll)
    except:
        pass
    return pl, ll, rate_result


def select_best_winrate(data: Dict):
    best_rate = (0, 0)
    for k, v in data.items():
        _, _, rate = _calc_rate(v)
        if rate > best_rate[1]:
            best_rate = (k, rate)
        elif rate == best_rate[1]:
            cur_rate = calculate_cumulative_pnl(v)
            other_rate = calculate_cumulative_pnl(data.get(best_rate[0], []))
            if cur_rate > other_rate:
                best_rate = (k, rate)

    return best_rate


def select_top_n_best_winrate(data: Dict, n: int=5):
    models = []
    for k, v in data.items():
        _, _, rate = _calc_rate(v)
        # if rate > 0.2:
        models.append((k, rate))
    
    models.sort(key=lambda x: x[1], reverse=True)
    return models[:n]


def select_top_n_profit_by_trades(results: Dict, n: int=5):
    """
    Модели с наилучшими показателями соотношения итог к кол-ву сделок
    """
    models = []
    for k, v in results.items():
        _, pnl = calculate_cumulative_pnl(v)
        if len(pnl) > 0:
            models.append((k, pnl[-1], pnl[-1]/len(pnl)))
    
    # Сортируем модели по PnL в порядке убывания и берем топ-5
    models.sort(key=lambda x: x[2], reverse=True)
    return [(x1, x2) for x1, x2, _ in models[:n]]
