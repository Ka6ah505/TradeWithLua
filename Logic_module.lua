QLogicModule = {}

QLogicModule.__index = QLogicModule


function QLogicModule:MA(data)
    if #data < 1 then
        return 0.0
    end
    local avarage = 0.0
    for _, value in pairs(data) do
        avarage = avarage + value
    end
    return avarage / #data
end


function QLogicModule:LinearRegress(data)
    local XSum = 0
    local YSum = 0
    local XYSum = 0
    local XXSum = 0
    local YYSum = 0

    for i, v in pairs(data) do
        XSum = XSum + i
        XXSum = XXSum + i^2

        YSum = YSum + v
        YYSum = YYSum + v^2

        XYSum = XYSum + i*v
    end

    local div = (#data*XXSum)-(XSum^2)
    local a = ((YSum*XXSum)-( XSum*XYSum )) / div
    local b = (( #data*XYSum ) - ( XSum*YSum )) / div

    return a+b*#data
end


function QLogicModule:parabolic_sar(high, low, af_start, af_step, af_max)
    --[[ 
    Рассчитывает Parabolic SAR (SAR)
    
    Параметры:
        high (table): Таблица с ценами high (например, {high[0], high[1], ...}).
        low (table): Таблица с ценами low (например, {low[0], low[1], ...}).
        af_start (number): Начальный AF (по умолчанию 0.02).
        af_step (number): Шаг увеличения AF (по умолчанию 0.02).
        af_max (number): Максимальный AF (по умолчанию 0.2).
    
    Возвращает:
        table: Таблица с рассчитанными значениями SAR.
    --]]

    -- Установка значений по умолчанию, если они не переданы
    af_start = af_start or 0.02
    af_step = af_step or 0.02
    af_max = af_max or 0.2

    local length = #high
    if length == 0 then
        return {} -- Вернуть пустую таблицу, если входные данные пусты
    end

    -- Инициализация таблиц для SAR, тренда, EP и AF
    local sar = {}
    local trend = {}
    local ep = {}
    local af = {}

    -- Инициализация первого элемента
    -- (В оригинальном Python коде используется low[0], что не совсем стандартно для инициализации SAR)
    -- Для большей стабильности часто инициализируют SAR[1] = low[0] или high[0] в зависимости от направления.
    -- Для соответствия оригиналу:
    sar[1] = low[1] -- Lua использует индексацию с 1
    trend[1] = 1
    ep[1] = high[1]
    af[1] = af_start

    -- Цикл начинается с i=2, так как i=1 уже инициализирован
    for i = 2, length do
        -- Рассчитываем SAR для текущего бара (i) на основе данных предыдущего (i-1)
        sar[i] = sar[i-1] + af[i-1] * (ep[i-1] - sar[i-1])

        -- Определяем, произошел ли разворот
        if trend[i-1] == 1 then -- Восходящий тренд
            if low[i] < sar[i] then
                -- Разворот вниз
                trend[i] = -1
                sar[i] = ep[i-1] -- SAR нового тренда равен последнему EP
                ep[i] = low[i]
                af[i] = af_start
            else
                -- Тренд не изменился
                trend[i] = 1
                if high[i] > ep[i-1] then
                    ep[i] = high[i]
                    af[i] = math.min(af[i-1] + af_step, af_max)
                else
                    ep[i] = ep[i-1]
                    af[i] = af[i-1]
                end
            end
        else -- Нисходящий тренд (trend[i-1] == -1)
            if high[i] > sar[i] then
                -- Разворот вверх
                trend[i] = 1
                sar[i] = ep[i-1] -- SAR нового тренда равен последнему EP
                ep[i] = high[i]
                af[i] = af_start
            else
                -- Тренд не изменился
                trend[i] = -1
                if low[i] < ep[i-1] then
                    ep[i] = low[i]
                    af[i] = math.min(af[i-1] + af_step, af_max)
                else
                    ep[i] = ep[i-1]
                    af[i] = af[i-1]
                end
            end
        end
    end

    -- Возвращаем таблицу с рассчитанными значениями SAR
    return sar
end
