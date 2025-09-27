-- filename: @My_portfolio.lua
-- version: lua54
-- line: [0, 0] id: 0
OnInit = function()
    -- line: [1, 40] id: 1
    top = 0
    green = RGB(0, 255, 0)
    red = RGB(255, 55, 0)
    black = RGB(0, 0, 0)
    yelow = RGB(255, 204, 0)
    blue = RGB(96, 147, 172)
    greyblue = RGB(112, 128, 144)
    white = RGB(178, 178, 178)
    IsRun = true
    stop_name_ID = false
    tqbr = "TQBR"
    tqob = "TQOB"
    tqcb = "TQCB"
    tqrd = "TQRD"
    psau = "PSAU"
    tqtf = "TQTF_F"
    indx = "INDX"
    my_stocks = {}
    my_bonds = {}
    my_etf = {}
    my_portfolio = {}
    CreatingArrays()
    MoneyLimit()
    Depo_Limit()
    sum_pai = rest_of_money + st_sum_p_pr + bnd_sum_p_pr + my_etf[1].qty_cur * my_etf[1].awg_position_price
    e_pai = round(my_etf[1].qty_cur * my_etf[1].awg_position_price / sum_pai * 100, 1)
    sum_profit = st_sum_prof + bnd_sum_prof + my_etf[1].last * my_etf[1].qty_cur -
    my_etf[1].qty_cur * my_etf[1].awg_position_price
    s_pai = round(st_sum_p_pr / sum_pai * 100, 1)
    bnd_pai = round(bnd_sum_p_pr / sum_pai * 100, 1)
    rest_pai = round(rest_of_money / sum_pai * 100, 1)
    Main_table()
end
OnStop = function()
    -- line: [42, 46] id: 2
    IsRun = false
    DestroyTable(t1_main)
end
onTable = function(r0_3, r1_3, r2_3, r3_3)
    -- line: [48, 74] id: 3
    if r1_3 == QTABLE_CLOSE and r2_3 == 0 and r3_3 == 0 then
        OnStop()
    end
    for r7_3 = 1, #my_portfolio[4][1] + -1, 1 do
        if r1_3 == QTABLE_LBUTTONUP and r2_3 == r7_3 + 1 and r3_3 == 1 then
            my_tools = my_portfolio[r7_3][1]
            button = r7_3
            start_update = true
            stop_name_ID = false
        end
    end
    if r1_3 == QTABLE_LBUTTONUP and r2_3 == 1 and r3_3 == 1 then
        os.execute("start https://t.me/+QDATWFWW1d8yM2Iy")
    end
end
main = function()
    -- line: [76, 117] id: 4
    while IsRun do
        MoneyLimit()
        Depo_Limit()
        sum_pai = rest_of_money + st_sum_p_pr + bnd_sum_p_pr + my_etf[1].qty_cur * my_etf[1].awg_position_price
        e_pai = round(my_etf[1].qty_cur * my_etf[1].awg_position_price / sum_pai * 100, 1)
        sum_profit = st_sum_prof + bnd_sum_prof + my_etf[1].last * my_etf[1].qty_cur -
        my_etf[1].qty_cur * my_etf[1].awg_position_price
        s_pai = round(st_sum_p_pr / sum_pai * 100, 1)
        bnd_pai = round(bnd_sum_p_pr / sum_pai * 100, 1)
        rest_pai = round(rest_of_money / sum_pai * 100, 1)
        SetCell(t1_main, 6, 1, "\xcf\xee\xf0\xf2\xf4\xe5\xeb\xfc")
        SetCell(t1_main, 7, 1, tostring(delimiter(round(sum_pai - rest_of_money, 2)) .. " \xf0."))
        SetCell(t1_main, 8, 1, "\xca\xfd\xf8")
        SetCell(t1_main, 9, 1, tostring(delimiter(rest_of_money) .. " \xf0."))
        SetCell(t1_main, 10, 1, "\xcf\xf0\xe8\xe1\xfb\xeb\xfc")
        SetCell(t1_main, 11, 1, tostring(delimiter(round(sum_profit, 2)) .. " \xf0."))
        SetCell(t1_main, 12, 1, tostring(round(sum_profit / (sum_pai - rest_of_money) * 100, 2) .. " %"))
        SetColor(t1_main, 6, 1, QTABLE_DEFAULT_COLOR, yelow, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
        SetColor(t1_main, 8, 1, QTABLE_DEFAULT_COLOR, yelow, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
        SetColor(t1_main, 10, 1, QTABLE_DEFAULT_COLOR, yelow, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
        SetWindowCaption(t1_main,
            tostring("  " ..
            os.date("%d.%m.%Y") ..
            "   " ..
            os.date("%X", os.time()) ..
            "       \xe0\xea\xf6.: " ..
            s_pai ..
            "%      \xee\xe1\xeb.: " .. bnd_pai .. "%      lqdt: " .. e_pai .. "%      \xca\xfd\xf8: " .. rest_pai .. "%"))
        local r0_4 = start_update
        if r0_4 then
            Print(my_tools, button)
        else
            sleep(1000)
            Highlight(t1_main, 2, 1, blue, QTABLE_DEFAULT_COLOR, 300)
            sleep(1000)
            Highlight(t1_main, 3, 1, blue, QTABLE_DEFAULT_COLOR, 300)
            sleep(1000)
            Highlight(t1_main, 4, 1, blue, QTABLE_DEFAULT_COLOR, 300)
        end
        collectgarbage()
        sleep(150)
    end
end
Main_table = function()
    -- line: [119, 161] id: 5
    t1_main = AllocTable()
    AddColumn(t1_main, 1, "", true, QTABLE_STRING_TYPE, 16)
    AddColumn(t1_main, 2, "", true, QTABLE_STRING_TYPE, 4)
    AddColumn(t1_main, 3, "", true, QTABLE_STRING_TYPE, 12)
    AddColumn(t1_main, 4, "", true, QTABLE_STRING_TYPE, 15)
    AddColumn(t1_main, 5, "", true, QTABLE_STRING_TYPE, 10)
    AddColumn(t1_main, 6, "", true, QTABLE_STRING_TYPE, 10)
    AddColumn(t1_main, 7, "", true, QTABLE_STRING_TYPE, 13)
    AddColumn(t1_main, 8, "", true, QTABLE_STRING_TYPE, 9)
    AddColumn(t1_main, 9, "", true, QTABLE_STRING_TYPE, 15)
    AddColumn(t1_main, 10, "", true, QTABLE_STRING_TYPE, 9)
    AddColumn(t1_main, 11, "", true, QTABLE_STRING_TYPE, 9)
    SetTableNotificationCallback(t1_main, onTable)
    CreateWindow(t1_main)
    SetWindowPos(t1_main, 10, top, 800, 450)
    for r3_5 = 1, #my_portfolio[4][1], 1 do
        InsertRow(t1_main, -1)
        SetCell(t1_main, r3_5, 1, tostring(my_portfolio[4][1][r3_5]))
    end
    for r3_5 = 1, 9, 1 do
        InsertRow(t1_main, -1)
    end
    SetColor(t1_main, 1, 1, QTABLE_DEFAULT_COLOR, blue, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
    SetColor(t1_main, 2, 1, QTABLE_DEFAULT_COLOR, white, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
    SetColor(t1_main, 3, 1, QTABLE_DEFAULT_COLOR, white, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
    SetColor(t1_main, 4, 1, QTABLE_DEFAULT_COLOR, white, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
end
Print = function(r0_6, r1_6)
    -- line: [163, 208] id: 6
    if stop_name_ID == false then
        Clear(t1_main)
        if #r0_6 < 13 then
            kolrow = 13
        else
            kolrow = #r0_6 + 2
        end
        for r5_6 = 1, kolrow, 1 do
            InsertRow(t1_main, -1)
        end
        for r5_6 = 1, #my_portfolio[4][1], 1 do
            SetCell(t1_main, r5_6, 1, tostring(my_portfolio[4][1][r5_6]))
        end
        stop_name_ID = true
    end
    for r5_6 = 2, 11, 1 do
        SetColor(t1_main, 1, r5_6, blue, black, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
    end
    if r1_6 == 1 then
        PrintStocks(r0_6)
        SetColor(t1_main, 2, 1, blue, black, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
    elseif r1_6 == 2 then
        PrintBonds(r0_6)
        SetColor(t1_main, 3, 1, blue, black, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
    elseif r1_6 == 3 then
        PrintETF(r0_6)
        SetColor(t1_main, 4, 1, blue, black, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
    end
    SetColor(t1_main, 1, 1, QTABLE_DEFAULT_COLOR, blue, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
end
PrintStocks = function(r0_7)
    -- line: [210, 254] id: 7
    SetCell(t1_main, 1, 2, tostring("\xb9"))
    SetCell(t1_main, 1, 3, tostring("\xd2\xe8\xea\xe5\xf0"))
    SetCell(t1_main, 1, 4, tostring("\xc1\xf3\xec\xe0\xe3\xe0"))
    SetCell(t1_main, 1, 5, tostring("\xd6\xe5\xed\xe0 \xef\xee\xea."))
    SetCell(t1_main, 1, 6, tostring("\xca\xee\xeb-\xe2\xee"))
    SetCell(t1_main, 1, 7, tostring("\xd1\xf2\xee\xe8\xec\xee\xf1\xf2\xfc"))
    SetCell(t1_main, 1, 8, tostring("\xcf\xf0\xe8\xe1%"))
    SetCell(t1_main, 1, 9, tostring("\xcf\xf0\xe8\xe1\xfb\xeb\xfc"))
    SetCell(t1_main, 1, 10, tostring("\xd2\xe5\xea.\xf6\xe5\xed\xe0"))
    for r4_7 = 1, #r0_7, 1 do
        if r0_7[r4_7].sec_code ~= nil then
            my = r0_7[r4_7]
            st_kol_row = r4_7
            SetCell(t1_main, r4_7 + 1, 2, tostring(r4_7))
            SetCell(t1_main, r4_7 + 1, 3, tostring(my.sec_code))
            SetCell(t1_main, r4_7 + 1, 4, tostring(my.shortname))
            SetCell(t1_main, r4_7 + 1, 5, tostring(round(my.awg_position_price, my.sec_scale)))
            SetCell(t1_main, r4_7 + 1, 6,
                tostring("  " ..
                math.floor(my.qty_cur / my.lotsize) .. "                  " .. math.floor(my.qty_cur) .. " \xf8\xf2."))
            SetCell(t1_main, r4_7 + 1, 7, tostring(delimiter(round(my.pur_price, 2))))
            if my.profit_proc > 0 then
                SetColor(t1_main, r4_7 + 1, 8, QTABLE_DEFAULT_COLOR, green, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
            else
                SetColor(t1_main, r4_7 + 1, 8, QTABLE_DEFAULT_COLOR, red, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
            end
            SetCell(t1_main, r4_7 + 1, 8, tostring(round(my.profit_proc, 2)))
            SetCell(t1_main, r4_7 + 1, 9, tostring(delimiter(round(my.profit, 2))))
            SetCell(t1_main, r4_7 + 1, 10, tostring(round(my.last, my.sec_scale)))
        else
            break
        end
    end
    SetColor(t1_main, st_kol_row + 2, 7, greyblue, black, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
    SetColor(t1_main, st_kol_row + 2, 8, greyblue, black, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
    SetColor(t1_main, st_kol_row + 2, 9, greyblue, black, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
    SetCell(t1_main, st_kol_row + 2, 7, tostring(delimiter(round(st_sum_p_pr, 2))))
    SetCell(t1_main, st_kol_row + 2, 8, tostring(round(st_sum_prof / st_sum_p_pr * 100, 2)))
    SetCell(t1_main, st_kol_row + 2, 9, tostring(delimiter(round(st_sum_prof, 2))))
end
PrintBonds = function(r0_8)
    -- line: [256, 293] id: 8
    SetCell(t1_main, 1, 2, tostring("\xb9"))
    SetCell(t1_main, 1, 3, tostring("\xc8\xed\xf1\xf2\xf0\xf3\xec\xe5\xed\xf2"))
    SetCell(t1_main, 1, 4, tostring("\xd1\xf2\xee\xe8\xec\xee\xf1\xf2\xfc \xef\xee\xea."))
    SetCell(t1_main, 1, 5, tostring("\xd6\xe5\xed\xe0 \xef\xee\xea."))
    SetCell(t1_main, 1, 6, tostring("\xca\xee\xeb-\xe2\xee"))
    SetCell(t1_main, 1, 7, tostring("\xc4\xe0\xf2\xe0 \xe2\xfb\xef\xeb. \xea\xf3\xef."))
    SetCell(t1_main, 1, 8, tostring("%\xe3\xee\xe4"))
    SetCell(t1_main, 1, 9, tostring("\xcf\xf0\xe8\xe1\xfb\xeb\xfc"))
    SetCell(t1_main, 1, 10, tostring("\xd2\xe5\xea.\xf6\xe5\xed\xe0"))
    SetCell(t1_main, 1, 11, tostring(" \xc4\xed\xe5\xe9 \xe4\xee \xef\xee\xe3\xe0\xf8\xe5\xed\xe8\xff"))
    for r4_8 = 1, #r0_8, 1 do
        bnd_kol_row = r4_8
        if r0_8[r4_8].sec_code ~= nil and r0_8[r4_8].sec_code ~= "" then
            my = r0_8[r4_8]
            SetCell(t1_main, r4_8 + 1, 2, tostring(r4_8))
            SetCell(t1_main, r4_8 + 1, 3, tostring(my.shortname))
            SetCell(t1_main, r4_8 + 1, 4, tostring(delimiter(round(my.pur_price, 2))))
            SetCell(t1_main, r4_8 + 1, 5, tostring(round(my.awg_position_price, my.sec_scale)))
            SetCell(t1_main, r4_8 + 1, 6, tostring(math.floor(my.qty_cur)))
            SetCell(t1_main, r4_8 + 1, 7, tostring("  " .. DateFormat(tostring(my.nextcoupon), "yyyymmdd", "dd.mm.YYYY")))
            SetCell(t1_main, r4_8 + 1, 8,
                tostring("    " .. round(my.proc_year, 2) .. "           " .. round(my.mycoupon, 2) .. " \xf0\xf3\xe1."))
            SetCell(t1_main, r4_8 + 1, 9,
                tostring("    " ..
                delimiter(round(my.profit, 2)) .. "                " .. round(my.profit_proc, 2) .. " %"))
            SetCell(t1_main, r4_8 + 1, 10, tostring(round(my.last, my.sec_scale)))
            SetCell(t1_main, r4_8 + 1, 11,
                tostring("   " .. math.floor(my.days_to_mat_date) .. "        " .. my.mat_date))
        else
            break
        end
    end
    SetColor(t1_main, bnd_kol_row + 2, 4, greyblue, black, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
    SetColor(t1_main, bnd_kol_row + 2, 9, greyblue, black, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
    SetCell(t1_main, bnd_kol_row + 2, 4, tostring(delimiter(round(bnd_sum_p_pr, 2))))
    SetCell(t1_main, bnd_kol_row + 2, 9,
        tostring("   " ..
        delimiter(round(bnd_sum_prof, 2)) .. "               " .. round(bnd_sum_prof / bnd_sum_p_pr * 100, 2) .. " %"))
end
PrintETF = function(r0_9)
    -- line: [295, 324] id: 9
    SetCell(t1_main, 1, 2, tostring("\xb9"))
    SetCell(t1_main, 1, 3, tostring("\xc8\xed\xf1\xf2\xf0\xf3\xec\xe5\xed\xf2"))
    SetCell(t1_main, 1, 4, tostring("\xd1\xf2\xee\xe8\xec\xee\xf1\xf2\xfc \xef\xee\xea."))
    SetCell(t1_main, 1, 5, tostring("\xd6\xe5\xed\xe0 \xef\xee\xea."))
    SetCell(t1_main, 1, 6, tostring("\xca\xee\xeb-\xe2\xee"))
    SetCell(t1_main, 1, 7, tostring("\xd2\xe5\xea.\xf1\xf2\xee\xe8\xec\xee\xf1\xf2\xfc"))
    SetCell(t1_main, 1, 8, tostring("\xd2\xe5\xea.\xf6\xe5\xed\xe0"))
    SetCell(t1_main, 1, 9, tostring("\xcf\xf0\xe8\xe1\xfb\xeb\xfc"))
    SetCell(t1_main, 1, 10, tostring("\xcf\xf0\xe8\xe1.%"))
    for r4_9 = 1, #r0_9, 1 do
        if r0_9[r4_9].sec_code ~= nil then
            SetCell(t1_main, r4_9 + 1, 2, tostring(r4_9))
            SetCell(t1_main, r4_9 + 1, 3, tostring(r0_9[r4_9].sec_code))
            SetCell(t1_main, r4_9 + 1, 4,
                tostring(delimiter(round(r0_9[r4_9].qty_cur * r0_9[r4_9].awg_position_price, 2))))
            SetCell(t1_main, r4_9 + 1, 5, tostring(r0_9[r4_9].awg_position_price))
            SetCell(t1_main, r4_9 + 1, 6, tostring(delimiter(math.floor(r0_9[r4_9].qty_cur))))
            SetCell(t1_main, r4_9 + 1, 7, tostring(delimiter(round(r0_9[r4_9].last * r0_9[r4_9].qty_cur, 2))))
            SetCell(t1_main, r4_9 + 1, 8, tostring(r0_9[r4_9].last))
            SetCell(t1_main, r4_9 + 1, 9,
                tostring(delimiter(round(
                r0_9[r4_9].last * r0_9[r4_9].qty_cur - r0_9[r4_9].qty_cur * r0_9[r4_9].awg_position_price, 2))))
            SetCell(t1_main, r4_9 + 1, 10,
                tostring(round(
                (r0_9[r4_9].last * r0_9[r4_9].qty_cur - r0_9[r4_9].qty_cur * r0_9[r4_9].awg_position_price) /
                r0_9[r4_9].qty_cur * r0_9[r4_9].awg_position_price * 100, 2)))
        else
            break
        end
    end
end
MoneyLimit = function()
    -- line: [326, 339] id: 10
    n = getNumberOf("money_limits")
    for r3_10 = 1, n, 1 do
        limit = getItem("money_limits", r3_10)
        if limit ~= nil and limit.currcode == "SUR" and limit.limit_kind == 1 then
            rest_of_money = limit.currentbal
        end
    end
end
Depo_Limit = function()
    -- line: [342, 486] id: 11
    st_sum_prof = 0
    bnd_sum_prof = 0
    st_sum_p_pr = 0
    bnd_sum_p_pr = 0
    n = getNumberOf("depo_limits")
    s = 1
    b = 1
    e = 1
    for r3_11 = 0, n + -1, 1 do
        depolimit = getItem("depo_limits", r3_11)
        if depolimit.currentbal ~= 0 and depolimit.limit_kind == 1 and getSecurityInfo(tqbr, depolimit.sec_code) ~= nil then
            local r4_11 = tqbr
            local r5_11 = depolimit.sec_code
            local r6_11 = depolimit.currentbal
            local r7_11 = depolimit.openbal
            local r8_11 = depolimit.awg_position_price
            local r9_11 = getParamEx2(tqbr, depolimit.sec_code, "SHORTNAME").param_image
            local r10_11 = tonumber(getParamEx2(tqbr, depolimit.sec_code, "LOTSIZE").param_value)
            local r11_11 = tonumber(getParamEx2(tqbr, depolimit.sec_code, "SEC_SCALE").param_value)
            local r12_11 = tonumber(getParamEx2(tqbr, depolimit.sec_code, "LAST").param_value)
            local r13_11 = tonumber(getParamEx2(tqbr, depolimit.sec_code, "BID").param_value)
            if r13_11 == nil or r13_11 == 0 then
                r13_11 = r12_11
            end
            local r14_11 = r8_11 * r6_11
            local r15_11 = r13_11 * r6_11 - r14_11
            st_sum_prof = st_sum_prof + r15_11
            st_sum_p_pr = st_sum_p_pr + r14_11
            my_stocks[s] = {
                class_code = r4_11,
                sec_code = r5_11,
                qty_cur = r6_11,
                incoming_qty_cur = r7_11,
                awg_position_price = r8_11,
                shortname = r9_11,
                lotsize = r10_11,
                sec_scale = r11_11,
                last = r12_11,
                bid = r13_11,
                pur_price = r14_11,
                profit = r15_11,
                profit_proc = r15_11 / r14_11 * 100,
            }
            s = s + 1
        end
        if getSecurityInfo(tqob, depolimit.sec_code) ~= nil then
            clscd = "TQOB"
        elseif getSecurityInfo(tqcb, depolimit.sec_code) ~= nil then
            clscd = "TQCB"
        elseif getSecurityInfo(psau, depolimit.sec_code) ~= nil then
            clscd = "PSAU"
        else
            clscd = ""
        end
        if depolimit.awg_position_price > 0 and depolimit.limit_kind == 1 and clscd ~= "" then
            local r4_11 = clscd
            local r5_11 = depolimit.sec_code
            local r6_11 = getParamEx2(clscd, depolimit.sec_code, "SHORTNAME").param_image
            local r7_11 = tonumber(getParamEx2(clscd, depolimit.sec_code, "SEC_SCALE").param_value)
            local r8_11 = depolimit.currentbal
            local r9_11 = depolimit.openbal
            local r10_11 = depolimit.awg_position_price
            local r11_11 = tonumber(getParamEx2(clscd, depolimit.sec_code, "NEXTCOUPON").param_value)
            local r12_11 = string.sub(getParamEx2(clscd, depolimit.sec_code, "NEXTCOUPON").param_value, 5, 6)
            local r13_11 = tonumber(getParamEx2(clscd, depolimit.sec_code, "SEC_FACE_VALUE").param_value)
            local r14_11 = tonumber(getParamEx2(clscd, depolimit.sec_code, "LAST").param_value)
            local r15_11 = tonumber(getParamEx2(clscd, depolimit.sec_code, "BID").param_value)
            if r15_11 == nil or r15_11 == 0 then
                r15_11 = r14_11
            end
            local r16_11 = r13_11 * r10_11 / 100 * r8_11
            local r17_11 = r13_11 * r15_11 / 100 * r8_11 - r16_11
            bnd_sum_prof = bnd_sum_prof + r17_11
            bnd_sum_p_pr = bnd_sum_p_pr + r16_11
            local r19_11 = tonumber(getParamEx2(clscd, depolimit.sec_code, "DAYS_TO_MAT_DATE").param_value)
            local r21_11 = tonumber(getParamEx2(clscd, depolimit.sec_code, "COUPONVALUE").param_value)
            local r22_11 = r21_11 * r8_11
            local r23_11 = tonumber(getParamEx2(clscd, depolimit.sec_code, "COUPONPERIOD").param_value)
            my_bonds[b] = {
                class_code = r4_11,
                sec_code = r5_11,
                qty_cur = r8_11,
                incoming_qty_cur = r9_11,
                awg_position_price = r10_11,
                shortname = r6_11,
                sec_scale = r7_11,
                last = r14_11,
                nextcoupon = r11_11,
                nextcoupon_mes = r12_11,
                sec_face_value = r13_11,
                pur_price = r16_11,
                profit = r17_11,
                profit_proc = r17_11 / r16_11 * 100,
                days_to_mat_date = r19_11,
                mat_date = getParamEx2(clscd, depolimit.sec_code, "MAT_DATE").param_image,
                couponvalue = r21_11,
                mycoupon = r22_11,
                couponperiod = r23_11,
                proc_year = r22_11 / r23_11 * 365 / r16_11 * 100,
            }
            b = b + 1
        end
        if getSecurityInfo(tqtf, depolimit.sec_code) ~= nil and depolimit.limit_kind == 1 and depolimit.currentbal ~= 0 then
            my_etf[e] = {
                class_code = tqtf,
                sec_code = depolimit.sec_code,
                qty_cur = depolimit.currentbal,
                awg_position_price = depolimit.awg_position_price,
                last = tonumber(getParamEx2(tqtf, depolimit.sec_code, "LAST").param_value),
            }
            e = e + 1
        end
    end
    name_ID = {
        "Telegram",
        "\xc0\xca\xd6\xc8\xc8",
        "\xce\xc1\xcb\xc8\xc3\xc0\xd6\xc8\xc8",
        "LQDT"
    }
    my_portfolio = {
        {
            my_stocks
        },
        {
            my_bonds
        },
        {
            my_etf
        },
        {
            name_ID
        }
    }
end
round = function(r0_12, r1_12)
    -- line: [488, 494] id: 12
    local r2_12 = 10 ^ (r1_12 and 0)
    if r0_12 ~= nil then
        return math.floor((r0_12 * r2_12 + 0.5)) / r2_12
    else
        return 0
    end
end
delimiter = function(r0_13)
    -- line: [496, 499] id: 13
    local r1_13, r2_13, r3_13 = string.match(r0_13, "^([^%d]*%d)(%d*)(.-)$")
    return r1_13 .. r2_13:reverse():gsub("(%d%d%d)", "%1 "):reverse() .. r3_13
end
DateFormat = function(r0_14, r1_14, r2_14)
    -- line: [501, 515] id: 14
    local r3_14 = tonumber(r0_14:sub(r1_14:find("([d|D]+)")))
    local r4_14 = tonumber(r0_14:sub(r1_14:find("([m|M]+)")))
    local r5_14 = tonumber(r0_14:sub(r1_14:find("([Y|y]+)")))
    local r6_14, r7_14 = r2_14:find("([d|D]+)")
    local r8_14, r9_14 = r2_14:find("([m|M]+)")
    local r10_14, r11_14 = r2_14:find("([Y|y]+)")
    return r2_14:gsub("([d|D]+)", string.format("%0" .. r7_14 - r6_14 + 1 .. "d", r3_14)):gsub("([m|M]+)",
        string.format("%0" .. r9_14 - r8_14 + 1 .. "d", r4_14)):gsub("([y|Y]+)",
        string.format("%0" .. r11_14 - r10_14 + 1 .. "d", r5_14))
end
CreatingArrays = function()
    -- line: [517, 568] id: 15
    if not my_stocks[1] then
        my_stocks[1] = {}
    end
    my_stocks[1] = {
        class_code = "",
        sec_code = "",
        qty_cur = 0,
        incoming_qty_cur = 0,
        awg_position_price = 0,
        shortname = "",
        lotsize = 0,
        sec_scale = 0,
        last = 0,
        bid = 0,
        pur_price = 0,
        profit = 0,
        profit_proc = 0,
    }
    if not my_bonds[1] then
        my_bonds[1] = {}
    end
    my_bonds[1] = {
        class_code = "",
        sec_code = "",
        qty_cur = 0,
        incoming_qty_cur = 0,
        awg_position_price = 0,
        shortname = "",
        sec_scale = 0,
        last = 0,
        nextcoupon = 0,
        nextcoupon_mes = 0,
        sec_face_value = 0,
        pur_price = 0,
        profit = 0,
        profit_proc = 0,
        days_to_mat_date = 0,
        mat_date = 0,
        couponvalue = 0,
        mycoupon = 0,
        couponperiod = 0,
        proc_year = 0,
    }
    if not my_etf[1] then
        my_etf[1] = {}
    end
    my_etf[1] = {
        class_code = "",
        sec_code = "",
        qty_cur = 0,
        awg_position_price = 0,
        last = 0,
    }
end
