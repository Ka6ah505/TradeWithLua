-- Настройки инструментов (фьючерс + спот)
local instruments = {
    -- {fut = "SiZ4", spot = "USDRUB_TOM"},   -- USD/RUB
    -- {fut = "RIZ4", spot = "RTSI"},         -- Индекс RTS
    {fut = "VBM5", spot = "VTBR"},         -- Сбербанк
}

-- Параметры временных окон (в минутах)
local intervals = {5, 10, 60}

-- Создаем таблицу для вывода
function CreateWindow()
    basis_table = AllocTable()
    AddColumn(basis_table, 0, "Пара", true, QTABLE_STRING_TYPE, 20)
    AddColumn(basis_table, 0, "Текущий", true, QTABLE_DOUBLE_TYPE, 10)
    for _, interval in ipairs(intervals) do
        AddColumn(basis_table, 0, interval.." мин", true, QTABLE_DOUBLE_TYPE, 10)
    end
    CreateWindow(basis_table)
    SetWindowCaption(basis_table, "Базис фьючерс-спот")
    SetWindowPos(basis_table, 100, 100, 500, 200)
end

-- Получение текущей цены через getParamEx
function GetCurrentPrice(ticker)
    local param = getParamEx("TQBR", ticker, "LAST")
    return tonumber(param.param_value) or 0
end

-- Получение свечей через getCandles (корректный метод)
function GetCandles(ticker, interval, count)
    if ticker == 'VTBR' then
        local ds = CreateDataSource("TQBR", ticker, interval)
    else
        local ds = CreateDataSource("SPBFUT", ticker, interval)
    end
    if ds:Size() == 0 then return nil end

    local candles = {}
    for i = 0, math.min(count-1, ds:Size()-1) do
        candles[i+1] = {
            close = ds:C(i).close
        }
    end
    return candles
end

-- Расчет среднего базиса
function CalculateAverageBasis(fut_ticker, spot_ticker, minutes)
    local fut_candles = GetCandles(fut_ticker, INTERVAL_M1, minutes)
    local spot_candles = GetCandles(spot_ticker, INTERVAL_M1, minutes)

    if not fut_candles or not spot_candles then return 0 end

    local sum = 0
    for i = 1, #fut_candles do
        sum = sum + (fut_candles[i].close - spot_candles[i].close)
    end
    return sum / #fut_candles
end

-- Основной цикл обновления
function main()
    CreateWindow()

    while not _G['__QUIK_SCRIPT_STOP__'] do
        for row, instr in ipairs(instruments) do
            local current_basis = GetCurrentPrice(instr.fut) - GetCurrentPrice(instr.spot)

            local basis_5m = CalculateAverageBasis(instr.fut, instr.spot, 5)
            local basis_10m = CalculateAverageBasis(instr.fut, instr.spot, 10)
            local basis_60m = CalculateAverageBasis(instr.fut, instr.spot, 60)

            if row > GetTableSize(basis_table) then
                InsertRow(basis_table, -1)
            end

            SetCell(basis_table, row-1, 0, instr.fut.."/"..instr.spot)
            SetCell(basis_table, row-1, 1, string.format("%.2f", current_basis))
            SetCell(basis_table, row-1, 2, string.format("%.2f", basis_5m))
            SetCell(basis_table, row-1, 3, string.format("%.2f", basis_10m))
            SetCell(basis_table, row-1, 4, string.format("%.2f", basis_60m))
        end
        sleep(5000) -- Обновление каждые 5 секунд
    end
end

-- Обработчик остановки
function OnStop()
    DestroyTable(basis_table)
end
