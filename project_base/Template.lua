dofile (getScriptPath().."\\QuikTable.lua")
dofile (getScriptPath().."\\Logging.lua")

IsRun = false
main_table = QTable.new()
logger = QLogger.init(getScriptPath().."\\main_log.txt")
BLACKE_COLOR = RGB(0, 0, 0)
RED_COLOR = RGB(255, 204, 255)

secCode = "TQBR"
classCodes = {"MSNG", "FEES", "YDEX"}
store_classCode = {}

function OnInit()
-- инициализация функции main

    main_table:AddColumn("Tiker", QTABLE_STRING_TYPE, 15)
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
    for _, code in pairs (classCodes) do
        store_classCode[code] = ConnectToData(secCode, code)
    end

    logger:add("Главный цикл")
    while not IsRun do
        if main_table:IsClosed() then
            main_table:Show()
        end

        for i, code in pairs(classCodes) do
            if i > main_table:GetSize() then
                main_table:AddLine()
            end
            local close = store_classCode[code]:C(store_classCode[code]:Size())
            main_table:SetValue(i, "Tiker", code)
            main_table:SetValue(i, "Close", close)
        end

        sleep(3000)
    end
end


-- Функция подключения к данным инструмента
function ConnectToData(secCode, classCode)
	Error = nil
	local ds, Error = CreateDataSource(secCode, classCode, INTERVAL_H4);
	while (Error == "" or Error == nil) and ds:Size() == 0 do
        sleep(1000)
        message('No source for '..secCode.." "..classCode, 2)
    end
	if Error ~= "" and Error ~= nil then
        message("Connect error to chart: "..Error)
        return
    end
	-- Чтобы получать новые данные без использования функции обратного вызова, а просто получать новые данные в ds и брать их оттуда по необходимости существует функция:
	ds:SetEmptyCallback();
    return ds
end
