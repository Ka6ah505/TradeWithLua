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
classCodes = { 'SBER', 'T', 'RNFT', 'GAZP', 'LKOH', 'X5', 'SMLT', 'PIKK', 'ROSN',
    'MTLR', 'NVTK', 'VTBR', 'MOEX', 'GMKN', 'AFKS', 'YDEX', 'VKCO', 'TRNFP', 'ALRS', 'CHMF'
}
store_classCode = {}

function OnInit()
    -- инициализация функции main

    main_table:AddColumn("Ticker", QTABLE_STRING_TYPE, 12)
    main_table:AddColumn("Close", QTABLE_DOUBLE_TYPE, 10)

    main_table:SetCaption("TEST TABLE")
    main_table:Show()
    logger:add("Логгер открыт для записи")
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
        local data_flow = ConnectToData(secCode, code)
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

    logger:add("Главный цикл")
    while not IsRun do
        main_table:Clear()
        if main_table:IsClosed() then
            main_table:Show()
        end
        local count_line = 0
        for code, _ in pairs(store_classCode) do
            local close = store_classCode[code]:C(store_classCode[code]:Size())
            count_line = count_line + 1
            main_table:AddLine()
            main_table:SetValue(count_line, "Ticker", code)
            main_table:SetValue(count_line, "Close", close)
        end

        sleep(3000)
    end
end

-- Функция подключения к данным инструмента
function ConnectToData(secCode, classCode)
    -- body
    Error = nil
    local ds, Error = CreateDataSource(secCode, classCode, INTERVAL_M5);
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
