local secs = {}


function OnInit()
    do_it = true
    progname = "simple advisor v.3.2 : "
    sum = 0
    msum = {}
    secs["AFKS"] = 0
    secs["AFLT"] = 0
    secs["ALRS"] = 0
    secs["CHMF"] = 0
    secs["CNRU"] = 0
    secs["ENPG"] = 0
    secs["FLOT"] = 0
    secs["LKOH"] = 0
    secs["MOEX"] = 0
    secs["RASP"] = 0
    secs["ROSN"] = 0
    secs["RTKM"] = 0
    secs["RUAL"] = 0
    secs["SMLT"] = 0
    secs["VTBR"] = 0
end

function OnStop()
    message(progname .. "завершение работы")
    do_it = false
end

function OnAllTrade(alltrade)
    if alltrade.sec_code == "AFKS" then
        sum = secs["AFKS"]
        currency_volume = alltrade.value
        if bit.test(alltrade.flags, 0) then direction = -1 end -- направление сделки: продажа
        if bit.test(alltrade.flags, 1) then direction = 1 end  -- направление сделки: покупка

        sum = sum + direction * currency_volume
        secs["AFKS"] = sum
    end
    if alltrade.sec_code == "AFLT" then
        sum = secs["AFLT"]
        currency_volume = alltrade.value
        if bit.test(alltrade.flags, 0) then direction = -1 end -- направление сделки: продажа
        if bit.test(alltrade.flags, 1) then direction = 1 end  -- направление сделки: покупка

        sum = sum + direction * currency_volume
        secs["AFLT"] = sum
    end
    if alltrade.sec_code == "ALRS" then
        sum = secs["ALRS"]
        currency_volume = alltrade.value
        if bit.test(alltrade.flags, 0) then direction = -1 end -- направление сделки: продажа
        if bit.test(alltrade.flags, 1) then direction = 1 end  -- направление сделки: покупка

        sum = sum + direction * currency_volume
        secs["ALRS"] = sum
    end
    if alltrade.sec_code == "CHMF" then
        sum = secs["CHMF"]
        currency_volume = alltrade.value
        if bit.test(alltrade.flags, 0) then direction = -1 end -- направление сделки: продажа
        if bit.test(alltrade.flags, 1) then direction = 1 end  -- направление сделки: покупка

        sum = sum + direction * currency_volume
        secs["CHMF"] = sum
    end
    if alltrade.sec_code == "CNRU" then
        sum = secs["CNRU"]
        currency_volume = alltrade.value
        if bit.test(alltrade.flags, 0) then direction = -1 end -- направление сделки: продажа
        if bit.test(alltrade.flags, 1) then direction = 1 end  -- направление сделки: покупка

        sum = sum + direction * currency_volume
        secs["CNRU"] = sum
    end
    if alltrade.sec_code == "ENPG" then
        sum = secs["ENPG"]
        currency_volume = alltrade.value
        if bit.test(alltrade.flags, 0) then direction = -1 end -- направление сделки: продажа
        if bit.test(alltrade.flags, 1) then direction = 1 end  -- направление сделки: покупка

        sum = sum + direction * currency_volume
        secs["ENPG"] = sum
    end
    if alltrade.sec_code == "FLOT" then
        sum = secs["FLOT"]
        currency_volume = alltrade.value
        if bit.test(alltrade.flags, 0) then direction = -1 end -- направление сделки: продажа
        if bit.test(alltrade.flags, 1) then direction = 1 end  -- направление сделки: покупка

        sum = sum + direction * currency_volume
        secs["FLOT"] = sum
    end
    if alltrade.sec_code == "LKOH" then
        sum = secs["LKOH"]
        currency_volume = alltrade.value
        if bit.test(alltrade.flags, 0) then direction = -1 end -- направление сделки: продажа
        if bit.test(alltrade.flags, 1) then direction = 1 end  -- направление сделки: покупка

        sum = sum + direction * currency_volume
        secs["LKOH"] = sum
    end
    if alltrade.sec_code == "MOEX" then
        sum = secs["MOEX"]
        currency_volume = alltrade.value
        if bit.test(alltrade.flags, 0) then direction = -1 end -- направление сделки: продажа
        if bit.test(alltrade.flags, 1) then direction = 1 end  -- направление сделки: покупка

        sum = sum + direction * currency_volume
        secs["MOEX"] = sum
    end
    if alltrade.sec_code == "RASP" then
        sum = secs["RASP"]
        currency_volume = alltrade.value
        if bit.test(alltrade.flags, 0) then direction = -1 end -- направление сделки: продажа
        if bit.test(alltrade.flags, 1) then direction = 1 end  -- направление сделки: покупка

        sum = sum + direction * currency_volume
        secs["RASP"] = sum
    end
    if alltrade.sec_code == "ROSN" then
        sum = secs["ROSN"]
        currency_volume = alltrade.value
        if bit.test(alltrade.flags, 0) then direction = -1 end -- направление сделки: продажа
        if bit.test(alltrade.flags, 1) then direction = 1 end  -- направление сделки: покупка

        sum = sum + direction * currency_volume
        secs["ROSN"] = sum
    end
    if alltrade.sec_code == "RTKM" then
        sum = secs["RTKM"]
        currency_volume = alltrade.value
        if bit.test(alltrade.flags, 0) then direction = -1 end -- направление сделки: продажа
        if bit.test(alltrade.flags, 1) then direction = 1 end  -- направление сделки: покупка

        sum = sum + direction * currency_volume
        secs["RTKM"] = sum
    end
    if alltrade.sec_code == "RUAL" then
        sum = secs["RUAL"]
        currency_volume = alltrade.value
        if bit.test(alltrade.flags, 0) then direction = -1 end -- направление сделки: продажа
        if bit.test(alltrade.flags, 1) then direction = 1 end  -- направление сделки: покупка

        sum = sum + direction * currency_volume
        secs["RUAL"] = sum
    end
    if alltrade.sec_code == "SMLT" then
        sum = secs["SMLT"]
        currency_volume = alltrade.value
        if bit.test(alltrade.flags, 0) then direction = -1 end -- направление сделки: продажа
        if bit.test(alltrade.flags, 1) then direction = 1 end  -- направление сделки: покупка

        sum = sum + direction * currency_volume
        secs["SMLT"] = sum
    end
    if alltrade.sec_code == "VTBR" then
        sum = secs["VTBR"]
        currency_volume = alltrade.value
        if bit.test(alltrade.flags, 0) then direction = -1 end -- направление сделки: продажа
        if bit.test(alltrade.flags, 1) then direction = 1 end  -- направление сделки: покупка

        sum = sum + direction * currency_volume
        secs["VTBR"] = sum
    end
end

function main()
    message(progname .. "\xf1\xf2\xe0\xf0\xf2\x20\xf0\xe0\xe1\xee\xf2\xfb") -- старт работы

    if m_t == nil then
        m_t = AllocTable()
        AddColumn(m_t, 1, "tiker", true, QTABLE_STRING_TYPE, 12)
        AddColumn(m_t, 2, "#msum", true, QTABLE_INT_TYPE, 15)

        CreateWindow(m_t)
        SetWindowPos(m_t, 500, 447, 200, 110)
        SetWindowCaption(m_t, progname .. " \xe0\xed\xe0\xeb\xe8\xe7") -- анализ
        InsertRow(m_t, -1)
        InsertRow(m_t, -1)
        InsertRow(m_t, -1)
        InsertRow(m_t, -1)
        InsertRow(m_t, -1)
        InsertRow(m_t, -1)
        InsertRow(m_t, -1)
        InsertRow(m_t, -1)
        InsertRow(m_t, -1)
        InsertRow(m_t, -1)
        InsertRow(m_t, -1)
        InsertRow(m_t, -1)
        InsertRow(m_t, -1)
        InsertRow(m_t, -1)
        InsertRow(m_t, -1)
    end


    while do_it do
        SetCell(m_t, 1, 1, "AFKS")
        SetCell(m_t, 1, 2, format_number(secs["AFKS"]))
        SetCell(m_t, 2, 1, "AFLT")
        SetCell(m_t, 2, 2, format_number(secs["AFLT"]))
        SetCell(m_t, 3, 1, "ALRS")
        SetCell(m_t, 3, 2, format_number(secs["ALRS"]))
        SetCell(m_t, 4, 1, "CHMF")
        SetCell(m_t, 4, 2, format_number(secs["CHMF"]))
        SetCell(m_t, 5, 1, "CNRU")
        SetCell(m_t, 5, 2, format_number(secs["CNRU"]))
        SetCell(m_t, 6, 1, "ENPG")
        SetCell(m_t, 6, 2, format_number(secs["ENPG"]))
        SetCell(m_t, 7, 1, "FLOT")
        SetCell(m_t, 7, 2, format_number(secs["FLOT"]))
        SetCell(m_t, 8, 1, "LKOH")
        SetCell(m_t, 8, 2, format_number(secs["LKOH"]))
        SetCell(m_t, 9, 1, "MOEX")
        SetCell(m_t, 9, 2, format_number(secs["MOEX"]))
        SetCell(m_t, 10, 1, "RASP")
        SetCell(m_t, 10, 2, format_number(secs["RASP"]))
        SetCell(m_t, 11, 1, "ROSN")
        SetCell(m_t, 11, 2, format_number(secs["ROSN"]))
        SetCell(m_t, 12, 1, "RTKM")
        SetCell(m_t, 12, 2, format_number(secs["RTKM"]))
        SetCell(m_t, 13, 1, "RUAL")
        SetCell(m_t, 13, 2, format_number(secs["RUAL"]))
        SetCell(m_t, 14, 1, "SMLT")
        SetCell(m_t, 14, 2, format_number(secs["SMLT"]))
        SetCell(m_t, 15, 1, "VTBR")
        SetCell(m_t, 15, 2, format_number(secs["VTBR"]))
        sleep(1000)
    end
end

function format_number(num)
    local formatted = tostring(math.floor(num))
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1 %2")
        if k == 0 then break end
    end
    return formatted
end