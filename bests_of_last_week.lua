dofile(getScriptPath() .. "\\QuikTable.lua")
dofile(getScriptPath() .. "\\Logging.lua")
dofile(getScriptPath() .. "\\Logic_module.lua")


IsRun = false
main_table = QTable.new()
logger = QLogger.init(getScriptPath() .. "\\logs\\your_log.txt")
logic = QLogicModule
BLACK_COLOR = RGB(0, 0, 0)
RED_COLOR = RGB(250, 128, 114)
GREEN_COLOR = RGB(34, 139, 34)
BLUE_COLOR = RGB(0, 0, 255)
YELLOW_COLOR = RGB(255, 228, 181)
translate = {
    close = '\xc7\xe0\xea\xf0\xfb\xf2\xe8\xe5',
    instrument = '\xc8\xed\xf1\xf2\xf0\xf3\xec\xe5\xed\xf2',
    prev_week_chn = '\xcf\xf0\xee\xf8\xeb\xe0\xff\x20\xed\xe5\xe4\xe5\xeb\xff\x20\x25',
    prev_prev_week_chn = '\xcf\xee\xe7\xe0\xef\xf0\xee\xf8\xeb\xe0\xff\x20\xed\xe5\xe4\xe5\xeb\xff\x20\x25',
    title = '\xd2\xee\xef\x20\xeb\xf3\xf7\xf8\xe8\xf5'
}

secCode = 'TQBR'
classCodes = {
    'MSNG', 'GAZP', 'LKOH', 'SIBN', 'ROSN', 'SBER', 'TATN', 'NVTK',
    'IRAO', 'SBERP', 'PHOR', 'SNGS', 'TRNFP', 'VTBR', 'FEES', 'MVID',
    'RASP', 'AFLT', 'MAGN', 'ALRS', 'MTSS', 'MOEX', 'RTKM', 'MGNT',
    'NLMK', 'SNGSP', 'CHMF', 'MTLR', 'HYDR'
}
-- classCodes = {}
store_classCode = {}


function OnInit()
    -- инициализация функции main

    main_table:AddColumn(translate.instrument, QTABLE_STRING_TYPE, 12)
    main_table:AddColumn(translate.close, QTABLE_DOUBLE_TYPE, 10)
    main_table:AddColumn("Week Day", QTABLE_STRING_TYPE, 12)
    main_table:AddColumn(translate.prev_week_chn, QTABLE_DOUBLE_TYPE, 20)
    main_table:AddColumn(translate.prev_prev_week_chn, QTABLE_DOUBLE_TYPE, 20)

    main_table:SetCaption(translate.title)
    main_table:Show()
    logger:add("Логгер открыт для записи")

    -- classCodes = Mysplit(getClassSecurities("TQBR"), ", ")
    -- classCodes = ReadLinesFromFile(getScriptPath() .. "\\download_data\\temp.txt")
end

function OnStop()
    -- остановка скрипта руками
    IsRun = false
    main_table:Clear()
    main_table:delete()
    logger:add("Логгер закрыт - терминал закрыт руками")
    logger:close()
    logger = nil
end

function OnClose()
    -- закрытие терминала
    main_table:delete()
    logger:add("Логгер закрыт - терминал крашнулся")
    logger:close()
    logger = nil
end

function main()
    -- основной поток управления
    if not main_table then
        message("error!", 3)
        return
    end
    for _, code in pairs(classCodes) do
        local data_flow = ConnectToData(secCode, code, INTERVAL_D1)
        -- пропускаем если не смогли получить данные
        if data_flow == nil then
            logger:add("не получены данные по " .. code)
            goto continue
        else
            store_classCode[code] = data_flow
            logger:add("получены данные по " .. code)
        end
        ::continue::
    end

    local table_old_perform = {}
    for code, _ in pairs(store_classCode) do
        local size = store_classCode[code]:Size()
        local limit_size = size - 13
        local close_wensday = 0
        local close_thusday = 0
        local cnt = 0
        for i = size, limit_size, -1 do
            local week_day = store_classCode[code]:T(i).week_day
            -- находим первую ближайшую среду
            if tonumber(week_day) == 3 and close_wensday == 0 then
                close_wensday = store_classCode[code]:C(i)
            end
            -- находим первый ближайший четверг после первой найденной среды
            if tonumber(week_day) == 4 and close_wensday > 0 then
                close_thusday = store_classCode[code]:C(i)
            end
            if close_wensday > 0 and close_thusday > 0 then
                break
            end
            cnt = cnt + 1
        end

        local close_wensday_1 = 0
        local close_thusday_1 = 0
        for i = size - cnt, limit_size - cnt, -1 do
            local week_day = store_classCode[code]:T(i).week_day
            -- находим первую ближайшую среду
            if tonumber(week_day) == 3 and close_wensday_1 == 0 then
                close_wensday_1 = store_classCode[code]:C(i)
            end
            -- находим первый ближайший четверг после первой найденной среды
            if tonumber(week_day) == 4 and close_wensday_1 > 0 then
                close_thusday_1 = store_classCode[code]:C(i)
            end
            if close_wensday_1 > 0 and close_thusday_1 > 0 then
                break
            end
        end

        local data = {}
        -- data['prev_week'] = (close_wensday - close_thusday) / close_thusday * 100
        data['prev_week'] = (close_wensday - close_thusday) / close_thusday * 100
        data['prev_prev_week'] = (close_wensday_1 - close_thusday_1) / close_thusday_1 * 100
        table_old_perform[code] = data
    end

    -- Получаем отсортированные ключи
    local sorted_prev_keys = SortInstrumentsByLastWeek(table_old_perform, 'prev_week', false)  -- по убыванию
    local sorted_prev_prev_keys = SortInstrumentsByLastWeek(table_old_perform, 'prev_prev_week', false)
    logger:add("Главный цикл")

    local best_prev_five = { table.unpack(sorted_prev_keys, 1, 8) }
    local best_prev_prev_five = { table.unpack(sorted_prev_prev_keys, 1, 8) }
    local colored_stocks = CompareAndColor(best_prev_five, best_prev_prev_five)

    while not IsRun do
        main_table:Clear()
        if main_table:IsClosed() then
            main_table:Show()
        end
        local count_line = 0
        for _, code in ipairs(sorted_prev_keys) do
            local size = store_classCode[code]:Size()
            local close = store_classCode[code]:C(size)
            local time_date = store_classCode[code]:T(size)
            local color = colored_stocks[code]

            count_line = count_line + 1
            main_table:AddLine()
            main_table:SetValue(count_line, translate.instrument, code)
            main_table:SetValue(count_line, translate.close, close)
            main_table:SetValue(count_line, "Week Day", time_date.week_day)
            main_table:SetValue(
                count_line,
                translate.prev_week_chn,
                tostring(
                    string.format("%.2f", table_old_perform[code]['prev_week'])
                )
            )
            main_table:SetValue(
                count_line,
                translate.prev_prev_week_chn,
                tostring(
                    string.format("%.2f", table_old_perform[code]['prev_prev_week'])
                )
            )

            main_table:SetColor(count_line, translate.instrument, color, BLACK_COLOR, true)
        end
        sleep(10000) -- 10 сек - 10_000ms
    end
end

-- Функция подключения к данным инструмента
function ConnectToData(secCode, classCode, interval)
    -- body
    Error = nil
    local ds, Error = CreateDataSource(secCode, classCode, interval);
    local cnt_reconnect = 0
    while (Error == "" or Error == nil) and ds:Size() == 0 do
        sleep(500)
        cnt_reconnect = cnt_reconnect + 1
        if cnt_reconnect > 10 then
            return nil
        end
    end
    if Error ~= "" and Error ~= nil then
        message("Connect error to chart: " .. Error, 3)
        return
    end
    -- Чтобы получать новые данные без использования функции обратного вызова, а просто получать новые данные в ds и брать их оттуда по необходимости существует функция:
    ds:SetEmptyCallback();
    return ds
end

-- Функция разделения строки по разделителю
function Mysplit(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end

-- Функция для сортировки таблицы инструментов по last_week
function SortInstrumentsByLastWeek(instruments_table, parameter, ascending)
    local keys = {}

    -- Собираем все ключи
    for key, value in pairs(instruments_table) do
        if value[parameter] then  -- проверяем наличие поля
            table.insert(keys, key)
        end
    end

    -- Сортируем
    if ascending then
        table.sort(keys, function(a, b)
            return instruments_table[a][parameter] < instruments_table[b][parameter]
        end)
    else
        table.sort(keys, function(a, b)
            return instruments_table[a][parameter]  > instruments_table[b][parameter]
        end)
    end

    return keys
end

-- Пересечения массивов
-- Элементы, только в первом массиве — 'green'
-- Элементы, только во втором массиве — 'red'
-- Элементы, в обоих массивах — 'yellow'
function CompareAndColor(prev_week, prev_prev_week)
    local result = {}

    -- Преобразуем второй массив в хэш для быстрой проверки
    local set2 = {}
    for _, v in ipairs(prev_prev_week) do
        set2[v] = true
    end

    -- Проходим по первому массиву
    for _, v in ipairs(prev_week) do
        if set2[v] then
            result[v] = YELLOW_COLOR  -- в обоих
        else
            result[v] = GREEN_COLOR   -- только в первом
        end
    end

    -- Проходим по второму массиву
    for _, v in ipairs(prev_prev_week) do
        if not result[v] then
            result[v] = RED_COLOR     -- только во втором
        end
    end

    return result
end

-- Чтение файла в котором тикеты на каждой строке
function ReadLinesFromFile(filePath)
    local file = io.open(filePath, "r")
    if not file then
        print("Ошибка: не удалось открыть файл " .. filePath)
        return nil
    end

    local lines = {}
    for line in file:lines() do
        table.insert(lines, line)
    end

    file:close()
    return lines
end
