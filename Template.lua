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

secCode = "TQBR"
classCodes = {'SBER','T','RNFT','GAZP','LKOH','X5','SMLT','PIKK','ROSN',
'MTLR','NVTK','VTBR','MOEX','GMKN','AFKS','YDEX','VKCO','TRNFP','ALRS','CHMF'
}
-- {
--     'FESH','FLOT','SOFL','NVTK','HEAD','RTKM','SNGS','MAGN','TRNFP','SVCB','RTKMP','SGZH','SPBE','MDMG',
-- 'ELFV','VKCO','MSNG','PRMD','LEAS','POSI','RENI','ASTR','WUSH','MVID','PIKK','ENPG','CHMF','PLZL','AFKS','BSPB','ABIO',
-- 'UPRO','VTBR','CBOM','IRAO','MTLR','HYDR','EUTR','MOEX','SNGSP','MTLRP','T','TGKA','SELG','UGLD','RAGR','KMAZ','ROSN',
-- 'SVAV','SFIN','AQUA','LENT','NLMK','YDEX','LSRG','TGKN','GAZP','MRKV','MRKP','VSEH','PHOR','CNRU','MRKS','AFLT','DIAS',
-- 'OGKB','SBERP','FEES','TATNP','SBER','TRMK','MRKC','ALRS','X5','RUAL','LKOH','ELMT','RNFT','OZPH','DATA','MTSS','TATN',
-- 'IVAT','SMLT','MSRS','MRKU','APTK','GMKN','HNFG','MRKZ','RASP','GEMC','MBNK','AKRN','BELU','DELI'
-- }
store_classCode = {}

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
        local data_flow = ConnectToData(secCode, code)
        -- пропускаем если не смогли получить данные
        if data_flow == nil then
            logger:add("не получены данные по "..code)
            goto continue
        else
            store_classCode[code] = data_flow
            logger:add("получены данные по "..code)
        end
        ::continue::
    end

    logger:add("Главный цикл")
    while not IsRun do
        main_table:Clear()
        if main_table:IsClosed() then
            main_table:Show()
        end
        count_line = 0
        for code, _ in pairs(store_classCode) do
            -- if i > main_table:GetSize() then
            --     main_table:AddLine()
            -- end
            -- инфо для вычисления индикаторов
            local close = store_classCode[code]:C(store_classCode[code]:Size())
            local closeArr0 = getValues(store_classCode[code], 25, 0)
            local closeArr1 = getValues(store_classCode[code], 25, 1)
            local closeArr2 = getValues(store_classCode[code], 25, 2)
            local closeArr3 = getValues(store_classCode[code], 25, 3)
            local closeArr4 = getValues(store_classCode[code], 25, 4)
            local closeArr5 = getValues(store_classCode[code], 25, 5)
            local rl0 = round(logic:LinearRegress(closeArr0), -5)
            local rl1 = round(logic:LinearRegress(closeArr1), -5)
            local rl2 = round(logic:LinearRegress(closeArr2), -5)
            local rl3 = round(logic:LinearRegress(closeArr3), -5)
            local rl4 = round(logic:LinearRegress(closeArr4), -5)
            local rl5 = round(logic:LinearRegress(closeArr5), -5)

            if (rising(rl2, rl1, rl0) == GREEN_COLOR and rising(rl3, rl2, rl1) == BLUE_COLOR) or (rising(rl2, rl1, rl0) == RED_COLOR and rising(rl3, rl2, rl1) == BLUE_COLOR) then
                main_table:AddLine()
                count_line = count_line + 1

                -- красим клетки
                -- main_table:SetColor(i, "LR3",
                --     raise(rl5, rl4, rl3),
                --     BLACK_COLOR,
                --     raise(rl5, rl4, rl3),
                --     BLACK_COLOR
                -- )
                -- main_table:SetColor(i, "LR2",
                --     raise(rl4, rl3, rl2),
                --     BLACK_COLOR,
                --     raise(rl4, rl3, rl2),
                --     BLACK_COLOR
                -- )
                -- main_table:SetColor(i, "LR1",
                --     raise(rl3, rl2, rl1),
                --     BLACK_COLOR,
                --     raise(rl3, rl2, rl1),
                --     BLACK_COLOR
                -- )
                -- main_table:SetColor(i, "LR0",
                --     raise(rl2, rl1, rl0),
                --     BLACK_COLOR,
                --     raise(rl2, rl1, rl0),
                --     BLACK_COLOR
                -- )
                main_table:SetColor(count_line, "LR3",
                    rising(rl5, rl4, rl3),
                    BLACK_COLOR,
                    rising(rl5, rl4, rl3),
                    BLACK_COLOR
                )
                main_table:SetColor(count_line, "LR2",
                    rising(rl4, rl3, rl2),
                    BLACK_COLOR,
                    rising(rl4, rl3, rl2),
                    BLACK_COLOR
                )
                main_table:SetColor(count_line, "LR1",
                    rising(rl3, rl2, rl1),
                    BLACK_COLOR,
                    rising(rl3, rl2, rl1),
                    BLACK_COLOR
                )
                main_table:SetColor(count_line, "LR0",
                    rising(rl2, rl1, rl0),
                    BLACK_COLOR,
                    rising(rl2, rl1, rl0),
                    BLACK_COLOR
                )
                -- заполняем строку данными
                -- main_table:SetValue(i, "Ticker", code)
                -- main_table:SetValue(i, "Close", close)
                -- main_table:SetValue(i, "LR3", rl3)
                -- main_table:SetValue(i, "LR2", rl2)
                -- main_table:SetValue(i, "LR1", rl1)
                -- main_table:SetValue(i, "LR0", rl0)
                main_table:SetValue(count_line, "Ticker", code)
                main_table:SetValue(count_line, "Close", close)
                main_table:SetValue(count_line, "LR3", rl3)
                main_table:SetValue(count_line, "LR2", rl2)
                main_table:SetValue(count_line, "LR1", rl1)
                main_table:SetValue(count_line, "LR0", rl0)
            end
        end
        -- if i > 20 then
        --     main_table:SetColor(id_row, "test1",RED_COLOR, BLACK_COLOR, RED_COLOR, BLACK_COLOR)
        -- end

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
