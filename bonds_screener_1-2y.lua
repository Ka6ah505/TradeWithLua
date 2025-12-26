dofile(getScriptPath() .. "\\QuikTable.lua")
dofile(getScriptPath() .. "\\Logging.lua")
dofile(getScriptPath() .. "\\Logic_module.lua")


IsRun = true
main_table = QTable.new()
local logger = QLogger.init(getScriptPath() .. "\\logs\\main_bonds_1-2y_log.txt")
local logic = QLogicModule
local my_bonds = {}
local data_by_bonds = {}
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

    main_table:AddColumn("Ticker", QTABLE_STRING_TYPE, 15)  -- тикер
    main_table:AddColumn("Offer", QTABLE_DOUBLE_TYPE, 9)    -- стоимость
    main_table:AddColumn("Mat day", QTABLE_INT_TYPE, 9)     -- до экспир дни
    main_table:AddColumn("Face value", QTABLE_INT_TYPE, 12) -- номинал
    main_table:AddColumn("C/per", QTABLE_DOUBLE_TYPE, 7)
    main_table:AddColumn("NKD", QTABLE_DOUBLE_TYPE, 7)
    main_table:AddColumn("YTM", QTABLE_DOUBLE_TYPE, 10)
    -- main_table:AddColumn("cYY_%", QTABLE_DOUBLE_TYPE, 10)
    -- main_table:AddColumn("PROFIT_RUB", QTABLE_DOUBLE_TYPE, 15)
    -- main_table:AddColumn("Fee_RUB", QTABLE_DOUBLE_TYPE, 12)
    -- main_table:AddColumn("+Profit", QTABLE_DOUBLE_TYPE, 15)
    main_table:AddColumn("Rating", QTABLE_STRING_TYPE, 8)
    main_table:AddColumn("List level", QTABLE_INT_TYPE, 7)
    main_table:AddColumn("In pack", QTABLE_INT_TYPE, 7)
    main_table:AddColumn("Type Coupon", QTABLE_STRING_TYPE, 10)
    main_table:AddColumn("Offerta", QTABLE_STRING_TYPE, 11)

    main_table:SetCaption("Bond Screener")
    main_table:Show()
    logger:add("Логгер открыт для записи")

    -- Получам список доступных облигаций
    local list__bonds_corp = Mysplit(getClassSecurities("TQCB"), ", ")
    -- list__bonds_corp = getOnlyNecval(list__bonds_corp, "TQCB")
    list_all_bonds["TQCB"] = list__bonds_corp
    logger:add(tostring(#list_all_bonds["TQCB"]))

    local list__bonds_fed = Mysplit(getClassSecurities("TQOB"), ", ")
    -- list__bonds_fed = getOnlyNecval(list__bonds_fed, "TQOB")
    list_all_bonds["TQOB"] = list__bonds_fed
    logger:add(tostring(#list_all_bonds["TQOB"]))

    my_bonds = Bonds_depo_limit()
    data_by_bonds = parse_bonds_file("rating_all.txt")
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
    IsRun = false
    main_table:Clear()
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

    while IsRun do
        main_table:Clear()
        if main_table:IsClosed() then
            main_table:Show()
        end

        local count_line = 0
        for classCode, list_sec in pairs(list_all_bonds) do
            for i, v in pairs(list_sec) do
                local shortname, _offer, _mat_day, _face_value, _coupon_value, _nkd, _couppon_period, _code, _list_level, _curr =
                    getDataByBond(classCode, v)

                YTM = round(
                    (((365 / _couppon_period) * _coupon_value) * 100) / ((_offer * _face_value) / 100) ,
                    3
                ) -- доходность как на смартлабе

                -- _face_value - номинал (в рублях)
                -- _coupon_value - размер купона (в рублях)
                -- _nkd - накопленый купон (в рублях)
                -- _offer - текущая цена (в процентах) для рублей умножаем на 10
                -- _mat_day - до погашения (в днях)

                local N = _face_value                                           -- номинал
                local C = ((_mat_day / _couppon_period) * _coupon_value - _nkd) -- сумма всех оставшихся купонов
                local P = ((_offer * _face_value) / 100) + _nkd                 -- цена покупки (включая НКД)
                local d = _mat_day                                              -- дней до погашения


                -- local YTM = round(
                --     (
                --         (((365 / _couppon_period) - 1) * _coupon_value + (_coupon_value - _nkd)) * 100
                --     ) / ((_offer * _face_value) / 100),
                --     3
                -- )
                -- Простая доходность к погашению
                -- local YTM = round(
                --     ((N + C - P) / P) * 365 / d * 100,
                --     3
                -- )

                _bond = data_by_bonds[_code] --getRaiting(_code)
                _type_coupon = (_bond ~= nil and _bond.type_coupon or '---')
                _offerta = (_bond ~= nil and _bond.offer or '---')
                _rating = (_bond ~= nil and _bond.rating or '---')
                _is_rating = is_cool_rating(_rating)
                _in_pack_count = my_bonds[_code] --in_pack_count(_code)

                if (
                    tonumber(_mat_day) > 100.0 --and tonumber(_mat_day) < 1095.0
                    and (YTM > 13 and YTM < 30)
                    and _offer <= 102
                    and _is_rating
                    and tonumber(_couppon_period) < 190
                    -- and tonumber(_couppon_period) < 100
                    and _curr == 'SUR' -- только рублевые бонды
                ) then
                    count_line = count_line + 1
                    main_table:AddLine()
                    main_table:SetValue(count_line, "Ticker", shortname)
                    main_table:SetValue(count_line, "Offer", _offer)
                    main_table:SetValue(count_line, "Mat day", _mat_day)
                    main_table:SetValue(count_line, "Face value", _face_value)
                    main_table:SetValue(count_line, "C/per", _couppon_period)
                    main_table:SetValue(count_line, "NKD", _nkd)
                    main_table:SetValue(count_line, "YTM", YTM)
                    main_table:SetValue(count_line, "Rating", _rating)
                    main_table:SetValue(count_line, "List level", _list_level)
                    main_table:SetValue(count_line, "In pack", _in_pack_count)
                    main_table:SetValue(count_line, "Type Coupon", _type_coupon)
                    main_table:SetValue(count_line, "Offerta", _offerta)

                    local color = getColor(YTM, 16, 21, 25, false)
                    main_table:SetColor(count_line, "YTM", color, BLACK_COLOR, false)
                    local listing_color = getColor(_list_level, 0, 1, 2, true)
                    main_table:SetColor(count_line, "List level", listing_color, BLACK_COLOR, false)
                    -- color = getColor(_profit_coupon_percent, 5, 10, 15)
                    -- main_table:SetColor(count_line, "cYY_%", color, BLACK_COLOR)
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
    _offer = getParamEx(classCode, secCode, 'OFFER').param_value -- TODO: LAST???
    -- _last = getParamEx(classCode, secCode, 'LAST').param_value
    _face_value = getParamEx(classCode, secCode, 'SEC_FACE_VALUE').param_value
    _coupon_value = getParamEx(classCode, secCode, 'COUPONVALUE').param_value
    _nkd = getParamEx(classCode, secCode, 'ACCRUEDINT').param_value
    _couppon_period = getParamEx(classCode, secCode, 'COUPONPERIOD').param_value
    -- _nkd = getParamEx(classCode, secCode, 'ACCRUEDINT').param_value
    -- _prev = getParamEx(classCode, secCode, 'PREVPRICE').param_value
    _code = getParamEx(classCode, secCode, 'CODE').param_image
    _list_level = getParamEx(classCode, secCode, 'LISTLEVEL').param_value
    _currency = getParamEx(classCode, secCode, 'SEC_FACE_UNIT').param_image

    return shortname,
        round(_offer, 1),
        round(_mat_day, 1),
        round(_face_value, 1),
        round(_coupon_value, 1),
        round(_nkd, 1),
        round(_couppon_period, 1),
        _code,
        round(_list_level, 0),
        _currency
end

function round(num, idp)
    local mult = 10 ^ (idp or 0)
    return math.floor(num * mult + 0.5) / mult
end

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

function getOnlyNecval(list_bonds, clsCode)
    local new_list = {}
    for _, v in pairs(list_bonds) do
        local complex = getParamEx(clsCode, v, "COMPLEXPRODUCT").param_image
        if complex == "-100" or complex == "6" or complex == "8" then
            table.insert(new_list, v)
        end
        -- table.insert(new_list, v)
    end
    return new_list
end

function MergeTables(table1, table2)
    local new_table = {}
    for _, v in pairs(table1) do
        table.insert(new_table, v)
    end
    for _, v in pairs(table2) do
        table.insert(new_table, v)
    end
    return new_table
end

function getColor(value, low, mid, high, invert)
    if invert then
        if (value < low) then
            return BLUE_COLOR
        elseif value > low and value <= mid then
            return GREEN_COLOR
        elseif value > mid and value <= high then
            return YELLOW_COLOR
        else
            return RED_COLOR
        end
    else
        if (value < low) then
            return RED_COLOR
        elseif value > low and value <= mid then
            return YELLOW_COLOR
        elseif value > mid and value <= high then
            return GREEN_COLOR
        else
            return BLUE_COLOR
        end
    end
end

function is_cool_rating(raing)
    local items = { "AAA","AA", "XXX"}--, "",  "---", "A" }
    for _, v in pairs(items) do
        if v == raing then
            return true
        end
    end
    return false
end

function Bonds_depo_limit()
    n = getNumberOf("depo_limits")
    local table_bonds = {}
    for i = 0, n - 1, 1 do
        local depolimit = getItem("depo_limits", i)
        local clscd = ""
        if getSecurityInfo("TQOB", depolimit.sec_code) ~= nil then
            clscd = "TQOB"
        elseif getSecurityInfo("TQCB", depolimit.sec_code) ~= nil then
            clscd = "TQCB"
        end
        if depolimit.awg_position_price > 0 and depolimit.limit_kind == 1 then
            _code = getParamEx(clscd, depolimit.sec_code, 'CODE').param_image
            table_bonds[_code] = depolimit.currentbal
        end
    end
    return table_bonds
end

function parse_bonds_file(filename)
    local bonds = {}

    for line in io.lines(filename) do
        -- Исправленное регулярное выражение - используем [%w%+%-] для type_coupon
        local isin, type_coupon, rating, offer =
            line:match('^(%w+)={type_coupon=([%w%+%-]+), rating=([%w%+%-]+), offer=([^}]+)}')

        if isin then
            bonds[isin] = {
                type_coupon = type_coupon,
                rating = rating,
                offer = (offer ~= "-" and offer or nil)
            }
        else
            message("Не удалось распарсить строку: " .. line, 2)
        end
    end

    return bonds
end
