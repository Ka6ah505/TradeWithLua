dofile (getScriptPath().."\\QuikTable.lua")
dofile (getScriptPath().."\\Logging.lua")
dofile (getScriptPath().."\\Logic_module.lua")


IsRun = false
local main_table = QTable.new()
local logger = QLogger.init(getScriptPath().."\\logs\\main_bonds_log.txt")
local logic = QLogicModule
BLACK_COLOR = RGB(0, 0, 0)
RED_COLOR = RGB(250, 128, 114)
GREEN_COLOR = RGB(34, 139, 34)
BLUE_COLOR = RGB(65, 105, 225)
YELLOW_COLOR = RGB(255, 228, 181)

-- TQOB - ОФЗ
-- TQCB - корпоративные облигации + региональные
local classCode = "TQCB"
-- "SU26212RMFS9" - ОФЗ 26212
-- RU000A1092T7 -- RU000A109L72
local secCode = "SU26212RMFS9"
local list_all_bonds = {}

function OnInit()
-- инициализация функции main

    main_table:AddColumn("Ticker", QTABLE_STRING_TYPE, 15)
    main_table:AddColumn("Ask", QTABLE_DOUBLE_TYPE, 10)
    main_table:AddColumn("Mat day", QTABLE_INT_TYPE, 10)
    main_table:AddColumn("Face value", QTABLE_INT_TYPE, 15)
    main_table:AddColumn("Coupon", QTABLE_DOUBLE_TYPE, 12)
    main_table:AddColumn("NKD", QTABLE_DOUBLE_TYPE, 15)
    main_table:AddColumn("YY_%", QTABLE_DOUBLE_TYPE, 10)
    main_table:AddColumn("cYY_%", QTABLE_DOUBLE_TYPE, 10)
    main_table:AddColumn("PROFIT_RUB", QTABLE_DOUBLE_TYPE, 15)
    main_table:AddColumn("Fee_RUB", QTABLE_DOUBLE_TYPE, 12)
    main_table:AddColumn("+Profit", QTABLE_DOUBLE_TYPE, 15)
    main_table:AddColumn("Rating", QTABLE_STRING_TYPE, 6)

    main_table:SetCaption("Bond Screener")
    main_table:Show()
    logger:add("Логгер открыт для записи")
    -- Получам список доступных облигаций
    local list__bonds_corp = mysplit(getClassSecurities("TQCB"), ", ")
    list__bonds_corp = getOnlyNecval(list__bonds_corp, "TQCB")
    list_all_bonds["TQCB"] = list__bonds_corp
    -- list__bonds_corp = {}
    logger:add(tostring(#list_all_bonds["TQCB"]))
    local list__bonds_fed = mysplit(getClassSecurities("TQOB"), ", ")
    list__bonds_fed = getOnlyNecval(list__bonds_fed, "TQOB")
    list_all_bonds["TQOB"] = list__bonds_fed

    -- mergeTables(list__bonds_corp, list__bonds_fed)
    logger:add(tostring(#list_all_bonds["TQOB"]))
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

    logger:add("Главный цикл")
    while not IsRun do
        main_table:Clear()
        if main_table:IsClosed() then
            main_table:Show()
        end

        count_line = 0
        for classCode, list_sec in pairs(list_all_bonds) do

            for i, v in pairs(list_sec) do
                local shortname, _ask, _mat_day, _face_value, _coupon, _nkd, _prev, _code = getDataByBond(classCode, v)

                _profit_rub, _profit_percent = calcProfit(_mat_day, _face_value, _ask, _prev)
                _profit_coupon_percent = round(
                    (_coupon - _nkd)*100/(_face_value)*(365/_mat_day),
                    2
                )
                commission = round(
                    (tonumber(_face_value) * tonumber(_ask) / 100 + tonumber(_nkd)) * 0.04 / 100, -- суффикс для 0.04%
                    2
                )
                _all_profit = _profit_rub + (_coupon - _nkd) - commission

                if (
                    tonumber(_mat_day) > 7.0 and tonumber(_mat_day) < 100.0
                    and (_coupon >= _nkd)
                    and (_profit_percent > 0 and _profit_percent < 50)
                    and ((_profit_percent + _profit_coupon_percent) > 15)
                ) then
                    count_line = count_line + 1
                    main_table:AddLine()
                    main_table:SetValue(count_line, "Ticker", shortname)
                    main_table:SetValue(count_line, "Ask", _ask)
                    main_table:SetValue(count_line, "Mat day", _mat_day)
                    main_table:SetValue(count_line, "Face value", _face_value)
                    main_table:SetValue(count_line, "Coupon", _coupon)
                    main_table:SetValue(count_line, "NKD", _nkd)
                    main_table:SetValue(count_line, "YY_%", _profit_percent)
                    main_table:SetValue(count_line, "cYY_%", _profit_coupon_percent)
                    main_table:SetValue(count_line, "PROFIT_RUB", _profit_rub)
                    main_table:SetValue(count_line, "Fee_RUB", commission)
                    main_table:SetValue(count_line, "+Profit", _all_profit)
                    main_table:SetValue(count_line, "Rating", getRaiting(_code))

                    local color = getColor(_profit_percent, 5, 10, 15)
                    main_table:SetColor(count_line, "YY_%", color, BLACK_COLOR, color, BLACK_COLOR)
                    color = getColor(_profit_coupon_percent, 5, 10, 15)
                    main_table:SetColor(count_line, "cYY_%", color, BLACK_COLOR, color, BLACK_COLOR)
                end

            end
        end


        -- IsRun = true
        sleep(30000)
    end
end

function getDataByBond(classCode, secCode)
    shortname = getParamEx(classCode, secCode, "SHORTNAME").param_image
    _mat_day = getParamEx(classCode, secCode, 'DAYS_TO_MAT_DATE').param_value
    _ask = getParamEx(classCode, secCode, 'OFFER').param_value
    _face_value = getParamEx(classCode, secCode, 'SEC_FACE_VALUE').param_value
    _coupon = getParamEx(classCode, secCode, 'COUPONVALUE').param_value
    _nkd = getParamEx(classCode, secCode, 'ACCRUEDINT').param_value
    _prev = getParamEx(classCode, secCode, 'PREVPRICE').param_value
    _code = getParamEx(classCode, secCode, 'CODE').param_image

    return shortname, round(_ask, 1), round(_mat_day, 1), round(_face_value, 1), round(_coupon ,1), round(_nkd, 1), _prev, _code
end


function calcProfit(mat_day, face_value, ask, _prev)
    local t_ask = ask
    if t_ask == 0 and tonumber(_prev) > 0 then
        t_ask = _prev
    end

    _profit_rub = round( -- профит в рублях к закрытию
        (face_value * (100 - t_ask)) / 100,
        3
    )
    _profit_percent = round( -- профит в процентах годовых
        365 / mat_day * (100 - t_ask),
        3
    )
    return _profit_rub, _profit_percent
end

function round(num, idp)
    local mult = 10^(idp or 0)
    return math.floor(num * mult + 0.5) / mult
end


function mysplit(inputstr, sep)
    if sep == nil then
      sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
      table.insert(t, str)
    end
    return t
end


function getOnlyNecval(list_bonds, clsCode)
    new_list = {}
    for _, v in pairs(list_bonds) do
        local complex = getParamEx(clsCode, v, "COMPLEXPRODUCT").param_image
        if complex == "-100" or complex == "6" then --or complex == "8" then
            table.insert(new_list, v)
        end
        -- table.insert(new_list, v)
    end
    return new_list
end


function mergeTables(table1, table2)
    new_table = {}
    for _, v in pairs(table1) do
        table.insert(new_table, v)
    end
    for _, v in pairs(table2) do
        table.insert(new_table, v)
    end
    return new_table
end


function getColor(value, low, mid, high)
    if (value > 15) then
        return BLUE_COLOR
    elseif value > mid and value <= high then
        return GREEN_COLOR
    elseif value > low and value <= mid then
        return YELLOW_COLOR
    else
        return RED_COLOR
    end
end


function getRaiting(ticker)
    ticker = string.lower(ticker)
    data = {
        {'RU000A100EG3','AAA'},
        {'RU000A105FS4','BBB'},
        {'RU000A105K85','AA'},
        {'RU000A105B03','AA'},
        {'RU000A106AJ2','AA'},
        {'RU000A105HN1','A'},
        {'RU000A102H91','AA'},
        {'RU000A102GC3','B'},
        {'RU000A102G50','A'},
        {'RU000A109ZK1','AA'},
        {'RU000A109X45','A'},
        {'RU000A101WE8','AA'},
        {'RU000A105M83','AA'},
        {'RU000A107XF0','AA'},
        {'RU000A102B97','BB'},
        {'RU000A0JVUN2','A'},
        {'RU000A0JVUP7','A'},
        {'RU000A105Q89','BBB'},
        {'RU000A100Z91','BBB'},
        {'RU000A0JVWD9','BBB'},
        {'RU000A0JVWJ6','BBB'},
        {'RU000A0JW1P8','BBB'},
        {'RU000A105KP0','AA'},
        {'RU000A105GE2','AA'},
        {'RU000A105JN7','CCC'},
        {'RU000A105EP3','B'},
        {'RU000A1098W8','AA'},
        {'RU000A105MP6','BB-'},
        {'RU000A0JVZB6','A'},
        {'RU000A105PP9','BB'},
        {'RU000A105PR5','BB'},
        {'RU000A105FU0','BB'},
        {'RU000A0ZZZV1','B+'},
        {'RU000A0ZZXZ7','BB'},
        {'RU000A1029G6','BBB'},
        {'RU000A102KT9','BBB'},
        {'RU000A0ZYCD1','BBB'},
        {'KG000A3LSJ06',''},
        {'RU000A0ZZR33','A'},
        {'RU000A10AA02','B+'},
        {'RU000A101228','AA'},
        {'RU000A106BQ5','AA'},
        {'RU000A105KQ8','AA'},
        {'RU000A102GU5','A'},
        {'RU000A102895','A'},
        {'RU000A102DR8','BB'},
        {'RU000A105AX5','B+'},
        {'RU000A1047S3','BB'},
        {'RU000A0JW0S4','A'},
        {'RU000A108AC3','A'},
        {'RU000A104735','BB'},
        {'RU000A105JG1','A'},
        {'RU000A102M37',''},
        {'RU000A0JVUS1','BBB'},
        {'RU000A0JVXS5','BBB'},
        {'RU000A1010M4','AA'},
        {'RU000A0JVW71','AA'},
        {'RU000A1089T3','AA'},
        {'RU000A0JVYG8','AA'},
        {'RU000A0JUAG0','B'},
        {'RU000A0JVWB3','AA'},
        {'RU000A105L01','AA'},
        {'RU000A102H83','B+'},
        {'RU000A0JVWA5','BBB'},
        {'RU000A0JVUY9','BBB'},
        {'RU000A1029A9','AA'},
        {'RU000A1077Y8','AA'},
        {'RU000A101541','AA'},
        {'RU000A1028G8','AA'},
        {'RU000A10A3R1','AA'},
        {'RU000A105HC4','AA'},
        {'RU000A105CL6','B'},
        {'RU000A105BW5','CCC'},
        {'RU000A102FQ5','AA'},
        {'RU000A1040J7','AA'},
        {'RU000A1040Y6','AA'},
        {'RU000A0ZYDU3','A'},
        {'RU000A105CS1','BBB'},
        {'RU000A105C93','B'},
        {'RU000A0JVUK8','BBB'},
        {'RU000A0JVXZ0','BBB'},
        {'RU000A105P07','CCC'},
        {'RU000A0ZYJ18','BB'},
        {'RU000A102LR1','BB-'},
        {'RU000A0ZYDD9','AA'},
        {'RU000A102CX8','B+'},
        {'RU000A105Q63','BBB'},
        {'RU000A0ZZQQ0','BB'},
        {'RU000A104TG3','CCC'},
        {'RU000A102LD1','A'},
        {'RU000A105C28','A'},
        {'RU000A107D74','BB-'},
        {'RU000A106656','A'},
        {'RU000A105PK0','BB'},
        {'RU000A10AUY6','AA'},
        {'RU000A10ATB6','B'},
        {'RU000A10BJH2','AA'},
        {'RU000A10BSV4','AA'},
    }
    for _, r in pairs(data) do
        if string.lower(r[1]) == ticker then
            return r[2]
        end
    end
    return '---'
    -- return ticker
end
