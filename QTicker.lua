QTicker = {}

QTicker.__index = QTicker


function QTicker.init(classCode, source)
    q_ticker = {}
    setmetatable(q_ticker, QTicker)

    q_ticker.name = classCode
    q_ticker.source = source
    q_ticker.cur_candle = 0
    q_ticker.idicators = {}
    return q_ticker
end


function QTicker:setCurCandle(n)
    self.cur_candle = n
end


function QTicker:InitNewIndicator(name, period)
    self.indicators[name] = {
        period = period,
        values = {}
    }
end


function QTicker:GetValuesByIndicator(name_indicator)
    return self.indicators[name_indicator]["values"]
end


function QTicker:CalcIndicator(name_indicator, func)
    local values = self.indicators[name_indicator]["values"]
    local period = self.indicators[name_indicator]["period"]
    if #values < period then
        values = func(self.source, period) -- TODO: описать
    else
        --TODO: сдвиг на 1 значение + расчет последнего показателя
    end

    -- return 0
end