dofile (getScriptPath().."\\QuikTable.lua")
dofile (getScriptPath().."\\Logging.lua")
dofile (getScriptPath().."\\Logic_module.lua")


IsRun = false
main_table = QTable.new()
logger = QLogger.init(getScriptPath().."\\logs\\sar_log.txt")
logic = QLogicModule
BLACK_COLOR = RGB(0, 0, 0)
-- RED_COLOR = RGB(255, 204, 255)
RED_COLOR = RGB(255, 0, 0)
GREEN_COLOR = RGB(0, 255, 0)
BLUE_COLOR = RGB(0, 0, 255)

secCodes = {}
secCodes["TQBR"] = {
    'SBER','T','RNFT','GAZP','LKOH','X5','SMLT','PIKK','ROSN','MTLR','NVTK',
    'VTBR','MOEX','GMKN','AFKS','YDEX','VKCO','TRNFP','ALRS','CHMF'
}
secCodes["SPBFUT"] = {'GLDRUBF', 'IMOEXF', 'CNYRUBF', 'VBZ5', 'NRZ5', 'YDZ5'}
store_classCode = {}
translate = {
    tiker = '\xd2\xe8\xea\xe5\xf0',
    close = '\xc7\xe0\xea\xf0\xfb\xf2\xe8\xe5',
    title = '\x53\x41\x52\x2d\xf2\xf0\xe5\xed\xe4'
}


function OnInit()
-- инициализация функции main

    main_table:AddColumn("Tiker", QTABLE_STRING_TYPE, 17)
    main_table:AddColumn("Close", QTABLE_DOUBLE_TYPE, 10)
    main_table:AddColumn("SAR7", QTABLE_DOUBLE_TYPE, 15)
    main_table:AddColumn("SAR6", QTABLE_DOUBLE_TYPE, 15)
    main_table:AddColumn("SAR5", QTABLE_DOUBLE_TYPE, 15)
    main_table:AddColumn("SAR4", QTABLE_DOUBLE_TYPE, 15)
    main_table:AddColumn("SAR3", QTABLE_DOUBLE_TYPE, 15)
    main_table:AddColumn("SAR2", QTABLE_DOUBLE_TYPE, 15)
    main_table:AddColumn("SAR1", QTABLE_DOUBLE_TYPE, 15)
    main_table:AddColumn("SAR0", QTABLE_DOUBLE_TYPE, 15)

    main_table:SetCaption(translate.title)
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
    for secCode, secCodeList in pairs(secCodes) do
        for _, classCode in pairs(secCodeList) do
            local data_flow = ConnectToData(secCode, classCode, INTERVAL_M10)
            -- пропускаем если не смогли получить данные
            if data_flow == nil then
                logger:add("не получены данные по "..secCode..'.'..classCode)
                goto continue
            else
                store_classCode[secCode..'.'..classCode] = data_flow
                logger:add("получены данные по "..secCode..'.'..classCode)
            end
            ::continue::
        end
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
            local closeArr0 = getValues(store_classCode[code], 'close', 560, 0)
            local highArr0 = getValues(store_classCode[code], 'high', 560, 0)
            local lowArr0 = getValues(store_classCode[code], 'low', 560, 0)

            local ps = logic:parabolic_sar(highArr0, lowArr0, 0.02, 0.02, 0.01)

            main_table:AddLine()
            count_line = count_line + 1

            --[[
            SAR от 1 до 6 должны иметь один цвет и с индексом
            0 тот же цвет - это означает куда входить
            SAR7 должен быть противоположным
            если от 0 до 6 зеленый, а 7 - красный - идем в лонг
            если от 0 до 6 красный, а 7 - зеленый - идем в шорт
            ]]--
            main_table:SetValue(count_line, "Tiker", code)
            main_table:SetValue(count_line, "Close", close)
            main_table:SetValue(count_line, "SAR7", round(ps[553], 4))
            main_table:SetValue(count_line, "SAR6", round(ps[554], 4))
            main_table:SetValue(count_line, "SAR5", round(ps[555], 4))
            main_table:SetValue(count_line, "SAR4", round(ps[556], 4))
            main_table:SetValue(count_line, "SAR3", round(ps[557], 4))
            main_table:SetValue(count_line, "SAR2", round(ps[558], 4))
            main_table:SetValue(count_line, "SAR1", round(ps[559], 4))
            main_table:SetValue(count_line, "SAR0", round(ps[560], 4))

            for i=553, 560 do
                local mark = "SAR"..tostring(560-i)
                if ps[i] < closeArr0[i] then
                    main_table:SetColor(count_line, mark, GREEN_COLOR, BLACK_COLOR, false)
                else
                    main_table:SetColor(count_line, mark, RED_COLOR, BLACK_COLOR, false)
                end
            end
        end
        -- if i > 20 then
        --     main_table:SetColor(id_row, "test1",RED_COLOR, BLACK_COLOR, false)
        -- end

        sleep(10000)
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
        message("Connect error to chart: "..Error, 3)
        return
    end
	-- Чтобы получать новые данные без использования функции обратного вызова, а просто получать новые данные в ds и брать их оттуда по необходимости существует функция:
	ds:SetEmptyCallback();
    return ds
end


-- вычисление среднего значения тел свечек за n-периодов
function getValues(source, part, n, shift)
    if shift==nil or type(shift) ~= "number" then
        shift=0
    end
	local start = source:Size()-n-shift;
	local valuesArr = {};
	for i=1, n do
        if part == 'close' then
		    valuesArr[i] = source:C(start+i);
        end
        if part == 'high' then
            valuesArr[i] = source:H(start+i);
        end
        if part == 'low' then
            valuesArr[i] = source:L(start+i);
        end
        if part == 'open' then
            valuesArr[i] = source:O(start+i);
        end
	end;
	return valuesArr;
end;


-- function round(number, digit_position)
--     local precision = 10^digit_position
--     number = number + (precision / 2); -- this causes value #.5 and up to round up
--                                         -- and #.4 and lower to round down.
--     return math.floor(number / precision) * precision
-- end
function round(num, idp)
    local mult = 10 ^ (idp or 0)
    return math.floor(num * mult + 0.5) / mult
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


function reverseList(t)
    local reversed = {}
    for i = #t, 1, -1 do
        table.insert(reversed, t[i])
    end
    return reversed
end
