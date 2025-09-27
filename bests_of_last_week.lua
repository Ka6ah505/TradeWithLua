dofile(getScriptPath() .. "\\QuikTable.lua")
dofile(getScriptPath() .. "\\Logging.lua")
dofile(getScriptPath() .. "\\Logic_module.lua")


IsRun = false
main_table = QTable.new()
logger = QLogger.init(getScriptPath() .. "\\logs\\your_log.txt")
logic = QLogicModule
BLACK_COLOR = RGB(0, 0, 0)
RED_COLOR = RGB(255, 0, 0)
GREEN_COLOR = RGB(0, 255, 0)
BLUE_COLOR = RGB(0, 0, 255)

secCode = "TQBR"
classCodes = { 'GAZP', 'LKOH', 'ROSN', 'ALRS', 'CHMF' }
store_classCode = {}

function OnInit()
    -- инициализация функции main

    main_table:AddColumn("Ticker", QTABLE_STRING_TYPE, 12)
    main_table:AddColumn("Close", QTABLE_DOUBLE_TYPE, 10)
    main_table:AddColumn("Week Day", QTABLE_STRING_TYPE, 12)
    main_table:AddColumn("Wednesday Close", QTABLE_DOUBLE_TYPE, 16)
    main_table:AddColumn("Thursday Close", QTABLE_DOUBLE_TYPE, 16)

    main_table:SetCaption("Week best")
    main_table:Show()
    logger:add("Логгер открыт для записи")

    -- classCodes = Mysplit(getClassSecurities("TQBR"), ", ")
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
        end
        -- message(code..":"..week_day.."<->"..close_wensday.."--"..close_thusday)
        local data = {}
        data['wednesday'] = close_wensday
        data['thursday'] = close_thusday
        table_old_perform[code] = data
    end

    logger:add("Главный цикл")
    while not IsRun do
        main_table:Clear()
        if main_table:IsClosed() then
            main_table:Show()
        end
        local count_line = 0
        for code, _ in pairs(store_classCode) do
            local size = store_classCode[code]:Size()
            local close = store_classCode[code]:C(size)
            local time_date = store_classCode[code]:T(size)

            count_line = count_line + 1
            main_table:AddLine()
            main_table:SetValue(count_line, "Ticker", code)
            main_table:SetValue(count_line, "Close", close)
            main_table:SetValue(count_line, "Week Day", time_date.week_day)
            main_table:SetValue(count_line, "Wednesday Close", table_old_perform[code]['wednesday'])
            main_table:SetValue(count_line, "Thursday Close", table_old_perform[code]['thursday'])
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
