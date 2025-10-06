dofile (getScriptPath().."\\QuikTable.lua")
dofile (getScriptPath().."\\Logging.lua")
dofile (getScriptPath().."\\Logic_module.lua")


IsRun = false
main_table = QTable.new()
logger = QLogger.init(getScriptPath().."\\logs\\main_log.txt")
logic = QLogicModule
BLACK_COLOR = RGB(0, 0, 0)
-- RED_COLOR = RGB(255, 204, 255)
RED_COLOR = RGB(255, 0, 0)
GREEN_COLOR = RGB(0, 255, 0)
BLUE_COLOR = RGB(0, 0, 255)

secCode = "SPBFUT"
classCodes = {"BRX4", "GDZ4", "SiZ4", "SRZ4", "SVZ4", "CRZ4", "EuZ4", "SFZ4", "GZZ4"}
store_classCode = {}
period = 20

function OnInit()
-- инициализация функции main

    main_table:AddColumn("Ticker", QTABLE_STRING_TYPE, 12)
    main_table:AddColumn("Close", QTABLE_DOUBLE_TYPE, 10)
    main_table:AddColumn("LR3", QTABLE_DOUBLE_TYPE, 15)
    main_table:AddColumn("LR2", QTABLE_DOUBLE_TYPE, 15)
    main_table:AddColumn("LR1", QTABLE_DOUBLE_TYPE, 15)
    main_table:AddColumn("LR0", QTABLE_DOUBLE_TYPE, 15)

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
        -- main_table:Clear()
        if main_table:IsClosed() then
            main_table:Show()
        end
        count_line = 0
        for i, code in pairs(classCodes) do
            if i > main_table:GetSize() then
                main_table:AddLine()
            end
            -- инфо для вычисления индикаторов 
            local close = store_classCode[code]:C(store_classCode[code]:Size())
            local closeArr0 = getValues(store_classCode[code], period, 0)
            local closeArr1 = getValues(store_classCode[code], period, 1)
            local closeArr2 = getValues(store_classCode[code], period, 2)
            local closeArr3 = getValues(store_classCode[code], period, 3)
            local closeArr4 = getValues(store_classCode[code], period, 4)
            local closeArr5 = getValues(store_classCode[code], period, 5)
            local rl0 = round(logic:LinearRegress(closeArr0), -5)
            local rl1 = round(logic:LinearRegress(closeArr1), -5)
            local rl2 = round(logic:LinearRegress(closeArr2), -5)
            local rl3 = round(logic:LinearRegress(closeArr3), -5)
            local rl4 = round(logic:LinearRegress(closeArr4), -5)
            local rl5 = round(logic:LinearRegress(closeArr5), -5)

            -- красим клетки
            main_table:SetColor(i, "LR3",
                rising(rl5, rl4, rl3),
                BLACK_COLOR,
                false
            )
            main_table:SetColor(i, "LR2",
                rising(rl4, rl3, rl2),
                BLACK_COLOR,
                false
            )
            main_table:SetColor(i, "LR1",
                rising(rl3, rl2, rl1),
                BLACK_COLOR,
                false
            )
            main_table:SetColor(i, "LR0",
                rising(rl2, rl1, rl0),
                BLACK_COLOR,
                false
            )

            -- заполняем строку данными
            main_table:SetValue(i, "Ticker", code)
            main_table:SetValue(i, "Close", close)
            main_table:SetValue(i, "LR3", rl3)
            main_table:SetValue(i, "LR2", rl2)
            main_table:SetValue(i, "LR1", rl1)
            main_table:SetValue(i, "LR0", rl0)
        end

        sleep(3000)
    end
end


-- Функция подключения к данным инструмента
function ConnectToData(secCode, classCode)
	-- body
	Error = nil
	local ds, Error = CreateDataSource(secCode, classCode, INTERVAL_M5);
	while (Error == "" or Error == nil) and ds:Size() == 0 do
        sleep(1000)
        -- message('No source for '..secCode.." "..classCode)
    end
	if Error ~= "" and Error ~= nil then
        message("Connect error to chart: "..Error, 3)
        return
    end
	-- Чтобы получать новые данные без использования функции обратного вызова, а просто получать новые данные в ds и брать их оттуда по необходимости существует функция:
	ds:SetEmptyCallback();
    return ds
end


-- вычисление среднего значения тел свечек за n-периодов
function getValues(source, n, shift)
    if shift==nil or type(shift) ~= "number" then
        shift=0
    end
	local start = source:Size()-n-shift;
	local valuesArr = {};
	for i=1, n do
		valuesArr[i] = source:C(start+i);
	end;
	return valuesArr;
end;


function round(number, digit_position) 
    local precision = 10^digit_position
    number = number + (precision / 2); -- this causes value #.5 and up to round up
                                        -- and #.4 and lower to round down.
    return math.floor(number / precision) * precision
end


function rising(v0, v1, v2)
    if v0 > v1 and v1 > v2 then
        return RED_COLOR
    end
    if v0 < v1 and v1 < v2 then
        return GREEN_COLOR
    end
    return BLUE_COLOR
end


-- максимум из "прозрачный бизнес"
-- массовость адресов
-- долги
-- арбитражки
