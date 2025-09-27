-- filename: @correlytion_portfolio.lua
-- version: lua54
-- line: [0, 0] id: 0
OnInit = function()
    -- line: [2, 52] id: 1
    IsRun = true
    count_candles = 250
    stopgame = false
    interval = INTERVAL_D1
    r_del = 0
    c_del = 0
    sec_code = {}
    DepoLimit()
    first = true
    first_but = true
    tickers_comparison = ""
    TableCorel()
    green = RGB(0, 255, 0)
    red = RGB(255, 55, 0)
    black = RGB(0, 0, 0)
    yelow = RGB(255, 255, 0)
    blue = RGB(96, 147, 172)
    greyblue = RGB(112, 128, 144)
    white = RGB(255, 255, 255)
end
OnStop = function()
    -- line: [54, 57] id: 2
    IsRun = false
    DestroyTable(t1_corel)
end

main = function()
    -- line: [59, 78] id: 3
    while IsRun do
        local r0_3 = first
        if r0_3 == true then
            r0_3 = {}
            dataCandle = r0_3
            k = 1
            for r3_3 = 1, #sec_code, 1 do
                if stopgame == false then
                    CreateDs(sec_code[r3_3])
                else
                    break
                end
            end
            Print()
            first = false
        end
        SetWindowCaption(t1_corel,
            "   \xca\xee\xf0\xf0\xe5\xeb\xff\xf6\xe8\xff     \\     Beta" .. "        " .. tickers_comparison)
        collectgarbage()
        sleep(250)
    end
end

DepoLimit = function()
    -- line: [80, 100] id: 4
    count = 2
    sec_code[1] = "IMOEX"
    n = getNumberOf("depo_limits")
    for r3_4 = 0, n + -1, 1 do
        depolimit = getItem("depo_limits", r3_4)
        if depolimit.currentbal ~= 0 and depolimit.limit_kind == 365 and getSecurityInfo("TQBR", depolimit.sec_code) ~= nil and depolimit.sec_code ~= "UPRO" then
            sec_code[count] = depolimit.sec_code
            count = count + 1
        end
    end
end
CreateDs = function(r0_5)
    -- line: [114, 156] id: 5
    if r0_5 ~= "IMOEX" then
        class_code = "TQBR"
    else
        class_code = "INDX"
    end
    ds, err = CreateDataSource(class_code, r0_5, interval)
    indexload = 0
    countZero = count_candles + -1
    while true do
        sleep(100)
        indexload = indexload + 1
        if ds:Size() == 0 then
            local r1_5 = indexload
            if r1_5 == 20 then
                break
            end
        else
            break
        end
    end
    number_of_candles = ds:Size()
    if countZero <= number_of_candles then
        countZero = number_of_candles - countZero
    else
        countZero = 2
    end
    local r1_5 = {}
    local r2_5 = {}
    Tm = {}
    Cl_bet = r2_5
    Cl_cor = r1_5
    d = 1
    for r4_5 = number_of_candles, countZero, -1 do
        Cl_cor[d] = ds:C(r4_5)
        Cl_bet[d] = ds:C(r4_5)
        Tm[d] = DataTime(ds:T(r4_5))
        d = d + 1
    end
    ds:Close()
    dataCandle[k] = {
        r0_5,
        Cl_cor,
        Tm,
        Cl_bet
    }
    k = k + 1
end
Print = function()
    -- line: [158, 202] id: 6
    for r3_6 = 1, #dataCandle, 1 do
        for r7_6 = r3_6, #dataCandle, 1 do
            if r3_6 ~= r7_6 then
                q = 1
                k1 = {}
                b1 = {}
                k2 = {}
                b2 = {}
                for r11_6 = 1, #dataCandle[r3_6][3], 1 do
                    for r15_6 = 1, #dataCandle[r7_6][3], 1 do
                        if dataCandle[r3_6][3][r11_6] == dataCandle[r7_6][3][r15_6] and dataCandle[r3_6][2][r11_6] ~= nil and dataCandle[r7_6][2][r11_6] ~= nil and stopgame == false then
                            table.insert(k1, q, dataCandle[r3_6][2][r11_6])
                            table.insert(k2, q, dataCandle[r7_6][2][r11_6])
                            table.insert(b1, q, dataCandle[r3_6][4][r11_6])
                            table.insert(b2, q, dataCandle[r7_6][4][r11_6])
                            q = q + 1
                            break
                        end
                    end
                end
                k1 = log_return(k1)
                k2 = log_return(k2)
                b1 = log_return(b1)
                b2 = log_return(b2)
                correlation = calculate_correlation(k1, k2)
                beta = calculate_beta(b1, b2)
                get_rgb_color(math.abs(correlation))
                SetCell(t1_corel, r7_6 + 2, r3_6 + 1, tostring(round(correlation, 2)))
                SetCell(t1_corel, r3_6 + 2, r7_6 + 1, tostring(round(beta, 2)))
                SetColor(t1_corel, r7_6 + 2, r3_6 + 1, RGB(r_int, g_int, b_int), RGB(0, 0, 0), QTABLE_DEFAULT_COLOR,
                    QTABLE_DEFAULT_COLOR)
            end
        end
    end
end
TableCorel = function()
    -- line: [204, 230] id: 7
    t1_corel = AllocTable()
    AddColumn(t1_corel, 1, "", true, QTABLE_STRING_TYPE, 7)
    for r3_7 = 2, #sec_code + 1, 1 do
        AddColumn(t1_corel, r3_7, "", true, QTABLE_STRING_TYPE, 7)
    end
    SetTableNotificationCallback(t1_corel, OnTablePanel)
    CreateWindow(t1_corel)
    SetWindowPos(t1_corel, 10, 500, #sec_code * 50, #sec_code * 22)
    SetWindowCaption(t1_corel, "                     \xcf \xce \xc4 \xd1 \xd7 \xa8 \xd2 . . . ")
    InsertRow(t1_corel, -1)
    InsertRow(t1_corel, -1)
    for r3_7 = 1, #sec_code, 1 do
        InsertRow(t1_corel, -1)
        SetCell(t1_corel, r3_7 + 2, 1, tostring(sec_code[r3_7]))
        SetColor(t1_corel, r3_7 + 2, 1, QTABLE_DEFAULT_COLOR, RGB(0, 51, 234), QTABLE_DEFAULT_COLOR,
            QTABLE_DEFAULT_COLOR)
        SetCell(t1_corel, 2, r3_7 + 1, tostring(sec_code[r3_7]))
        SetColor(t1_corel, 2, r3_7 + 1, QTABLE_DEFAULT_COLOR, RGB(0, 51, 234), QTABLE_DEFAULT_COLOR,
            QTABLE_DEFAULT_COLOR)
    end
    SetCell(t1_corel, 1, 1, tostring("1 \xe3\xee\xe4"))
    SetCell(t1_corel, 1, 2, tostring("3 \xe3\xee\xe4\xe0"))
    SetCell(t1_corel, 1, 3, tostring("5 \xeb\xe5\xf2"))
    SetColor(t1_corel, 1, 1, RGB(255, 255, 0), RGB(0, 0, 0), QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
end
round = function(r0_8, r1_8)
    -- line: [232, 238] id: 8
    local r2_8 = 10 ^ (r1_8 and 0)
    if r0_8 ~= nil then
        return math.floor((r0_8 * r2_8 + 0.5)) / r2_8
    else
        return 0
    end
end
OnTablePanel = function(r0_9, r1_9, r2_9, r3_9)
    -- line: [240, 338] id: 9
    if r1_9 == QTABLE_CLOSE and r2_9 == 0 and r3_9 == 0 then
        stopgame = true
        OnStop()
    end
    if r1_9 == QTABLE_LBUTTONUP and r2_9 == 1 and r3_9 == 1 and first == false then
        SetWindowCaption(r0_9, "                     \xcf \xce \xc4 \xd1 \xd7 \xa8 \xd2 . . . ")
        SetColor(r0_9, 1, 2, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
        SetColor(r0_9, 1, 3, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
        SetColor(r0_9, 1, 1, RGB(255, 255, 0), RGB(0, 0, 0), QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
        SetColor(r0_9, c_del + -1 + 2, r_del + 1, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR,
            QTABLE_DEFAULT_COLOR)
        count_candles = 250
        interval = INTERVAL_D1
        tickers_comparison = ""
        first = true
    end
    if r1_9 == QTABLE_LBUTTONUP and r2_9 == 1 and r3_9 == 2 and first == false then
        SetWindowCaption(r0_9, "                     \xcf \xce \xc4 \xd1 \xd7 \xa8 \xd2 . . . ")
        SetColor(r0_9, 1, 1, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
        SetColor(r0_9, 1, 3, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
        SetColor(r0_9, 1, 2, RGB(255, 255, 0), RGB(0, 0, 0), QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
        SetColor(r0_9, c_del + -1 + 2, r_del + 1, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR,
            QTABLE_DEFAULT_COLOR)
        count_candles = 750
        interval = INTERVAL_D1
        tickers_comparison = ""
        first = true
    end
    if r1_9 == QTABLE_LBUTTONUP and r2_9 == 1 and r3_9 == 3 and first == false then
        SetWindowCaption(r0_9, "                     \xcf \xce \xc4 \xd1 \xd7 \xa8 \xd2 . . . ")
        SetColor(r0_9, 1, 2, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
        SetColor(r0_9, 1, 1, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
        SetColor(r0_9, 1, 3, RGB(255, 255, 0), RGB(0, 0, 0), QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
        SetColor(r0_9, c_del + -1 + 2, r_del + 1, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR,
            QTABLE_DEFAULT_COLOR)
        count_candles = 1250
        interval = INTERVAL_D1
        tickers_comparison = ""
        first = true
    end
    for r7_9 = 1, #dataCandle, 1 do
        for r11_9 = 1, #dataCandle - #dataCandle - r7_9, 1 do
            if r1_9 == QTABLE_LBUTTONUP and r2_9 == r7_9 + 2 and r3_9 == r11_9 and r3_9 ~= 1 then
                stopgame = true
                if first_but == false then
                    SetColor(r0_9, c_del + -1 + 2, r_del + 1, QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR,
                        QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
                end
                first_but = false
                if r_del ~= 0 then
                    get_rgb_color(tonumber(GetCell(r0_9, r_del + 2, c_del).image))
                    SetColor(r0_9, r_del + 2, c_del, RGB(r_int, g_int, b_int), RGB(0, 0, 0), QTABLE_DEFAULT_COLOR,
                        QTABLE_DEFAULT_COLOR)
                end
                SetColor(r0_9, r11_9 + -1 + 2, r7_9 + 1, RGB(255, 255, 0), RGB(0, 0, 0), QTABLE_DEFAULT_COLOR,
                    QTABLE_DEFAULT_COLOR)
                SetColor(r0_9, r7_9 + 2, r11_9, RGB(255, 255, 0), RGB(0, 0, 0), QTABLE_DEFAULT_COLOR,
                    QTABLE_DEFAULT_COLOR)
                tickers_comparison = "(" ..
                tostring(GetCell(r0_9, r7_9 + 2, 1).image) ..
                " / " .. tostring(GetCell(r0_9, r11_9 + -1 + 2, 1).image) .. ")"
                r_del = r7_9
                c_del = r11_9
                stopgame = false
            end
        end
    end
end
DataTime = function(r0_10)
    -- line: [340, 361] id: 10
    local r1_10 = r0_10.day
    if r1_10 < 10 then
        r1_10 = "0" .. r1_10
    end
    local r2_10 = r0_10.month
    if r2_10 < 10 then
        r2_10 = "0" .. r2_10
    end
    local r3_10 = r0_10.year
    local r4_10 = r0_10.hour
    if r4_10 < 10 then
        r4_10 = "0" .. r4_10
    end
    local r5_10 = r0_10.min
    if r5_10 < 10 then
        r5_10 = "0" .. r5_10
    end
    local r6_10 = r0_10.sec
    if r6_10 < 10 then
        r6_10 = "0" .. r6_10
    end
    return r1_10 .. r2_10 .. r3_10 .. r4_10 .. r5_10 .. r6_10
end
get_rgb_color = function(r0_11)
    -- line: [379, 391] id: 11
    local r1_11 = math.abs(r0_11)
    local r2_11 = math.abs(r0_11)
    r_int = math.floor(r1_11 * 255)
    g_int = math.floor((1 - r2_11) * 255)
    b_int = math.floor(0 * 255)
end
log_return = function(r0_12)
    -- line: [394, 401] id: 12
    local r1_12 = {}
    for r5_12 = 2, #r0_12, 1 do
        table.insert(r1_12, math.log(r0_12[r5_12] / r0_12[(r5_12 + -1)]))
    end
    return r1_12
end
calculate_correlation = function(r0_13, r1_13)
    -- line: [403, 434] id: 13
    if #r0_13 ~= #r1_13 then
        return nil
    end
    local r2_13 = 0
    local r3_13 = 0
    for r7_13 = 1, #r0_13, 1 do
        r2_13 = r2_13 + r0_13[r7_13]
        r3_13 = r3_13 + r1_13[r7_13]
    end
    r2_13 = r2_13 / #r0_13
    r3_13 = r3_13 / #r1_13
    local r4_13 = 0
    local r5_13 = 0
    local r6_13 = 0
    for r10_13 = 1, #r0_13, 1 do
        local r11_13 = r0_13[r10_13] - r2_13
        local r12_13 = r1_13[r10_13] - r3_13
        r4_13 = r4_13 + r11_13 * r12_13
        r5_13 = r5_13 + r11_13 * r11_13
        r6_13 = r6_13 + r12_13 * r12_13
    end
    return r4_13 / math.sqrt(r5_13 * r6_13)
end
calculate_beta = function(r0_14, r1_14)
    -- line: [436, 465] id: 14
    if #r0_14 ~= #r1_14 then
        return nil
    end
    local r2_14 = 0
    local r3_14 = 0
    for r7_14 = 1, #r0_14, 1 do
        r2_14 = r2_14 + r0_14[r7_14]
        r3_14 = r3_14 + r1_14[r7_14]
    end
    r2_14 = r2_14 / #r0_14
    r3_14 = r3_14 / #r1_14
    local r4_14 = 0
    local r5_14 = 0
    for r9_14 = 1, #r0_14, 1 do
        local r11_14 = r1_14[r9_14] - r3_14
        r4_14 = r4_14 + (r0_14[r9_14] - r2_14) * r11_14
        r5_14 = r5_14 + r11_14 * r11_14
    end
    return r4_14 / r5_14
end
