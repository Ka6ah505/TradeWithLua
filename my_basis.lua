dofile (getScriptPath().."\\QuikTable.lua")
dofile (getScriptPath().."\\Logging.lua")
dofile (getScriptPath().."\\Logic_module.lua")


IsRun = false
main_table = QTable.new()
logger = QLogger.init(getScriptPath().."\\logs\\basis_log.txt")
logic = QLogicModule
BLACK_COLOR = RGB(0, 0, 0)
RED_COLOR = RGB(255, 0, 0)
GREEN_COLOR = RGB(0, 255, 0)
BLUE_COLOR = RGB(0, 0, 255)


pairs_ = {
    {fut='VBM5', market_fut='SPBFUT', spot='VTBR', market_spot='TQBR'},
    {fut='TBM5', market_fut='SPBFUT', spot='T', market_spot='TQBR'},
    {fut='CRM5', market_fut='SPBFUT', spot='CNYRUB_TOM', market_spot='CETS'},
}
store_classCode = {}

function OnInit()
-- инициализация функции main

    main_table:AddColumn("Pairs", QTABLE_STRING_TYPE, 20)
    main_table:AddColumn("Basis", QTABLE_DOUBLE_TYPE, 20)

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
    for _, data in pairs(pairs_) do
        local data_flow_fut = ConnectToData(data.market_fut, data.fut)
        local data_flow_spot = ConnectToData(data.market_spot, data.spot)
        -- пропускаем если не смогли получить данные
        if data_flow_fut == nil then
            logger:add("не получены данные по "..data.fut)
            -- goto continue
        end
        if data_flow_spot == nil then
            logger:add("не получены данные по "..data.fut)
            -- goto continue
        end
        store_classCode[data.fut.."/"..data.spot] = { fut=data_flow_fut, spot=data_flow_spot }
        -- ::continue::
    end

    logger:add("Главный цикл")
    while not IsRun do
        main_table:Clear()
        if main_table:IsClosed() then
            main_table:Show()
        end
        count_line = 0
        for p, data in pairs(store_classCode) do
            local close_fut = data.fut:C(data.fut:Size())
            local close_spot = data.spot:C(data.spot:Size())
            count_line = count_line + 1
            main_table:AddLine()
            main_table:SetValue(count_line, "Pairs", p)
            -- string.format("%.2f", current_basis)
            main_table:SetValue(count_line, "Basis", close_fut-close_spot)
        end
        sleep(3000)
    end
end


-- Функция подключения к данным инструмента
function ConnectToData(secCode, classCode)
	-- body
	Error = nil
	local ds, Error = CreateDataSource(secCode, classCode, INTERVAL_M1);
    local cnt_reconnect = 0
	while (Error == "" or Error == nil) and ds:Size() == 0 do
        sleep(500)
        cnt_reconnect = cnt_reconnect + 1
        if cnt_reconnect > 10 then
            return nil
        end
    end
	if Error ~= "" and Error ~= nil then
        message("Connect error to chart: "..Error, 3)
        return
    end
	-- Чтобы получать новые данные без использования функции обратного вызова, а просто получать новые данные в ds и брать их оттуда по необходимости существует функция:
	ds:SetEmptyCallback();
    return ds
end
