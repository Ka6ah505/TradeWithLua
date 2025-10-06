local secs = {}


function OnInit()
    do_it = true
    progname = "simple advisor v.3.2 : "
    sum = 0
    msum = {}
    secs["SBER"] = 0
    secs["T"] = 0
end

function OnStop()
    message(progname .. "завершение работы")
    do_it = false
end

function OnAllTrade(alltrade)
    if alltrade.sec_code == "SBER" then
        sum = secs["SBER"]
        lastprice = alltrade.price                             -- цена
        lastvolume = alltrade.qty                              -- количество

        if bit.test(alltrade.flags, 0) then direction = -1 end -- направление сделки: продажа
        if bit.test(alltrade.flags, 1) then direction = 1 end  -- направление сделки: покупка

        sum = sum + direction * lastprice * lastvolume
        secs["SBER"] = sum
    end
    if alltrade.sec_code == "T" then
        sum = secs["T"]
        lastprice = alltrade.price                             -- цена
        lastvolume = alltrade.qty                              -- количество

        if bit.test(alltrade.flags, 0) then direction = -1 end -- направление сделки: продажа
        if bit.test(alltrade.flags, 1) then direction = 1 end  -- направление сделки: покупка

        sum = sum + direction * lastprice * lastvolume
        secs["T"] = sum
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
    end


    while do_it do
        SetCell(m_t, 1, 1, "SBER")
        SetCell(m_t, 1, 2, tostring(string.format("%.0f", secs["SBER"])))
        SetCell(m_t, 2, 1, "T")
        SetCell(m_t, 2, 2, tostring(string.format("%.0f", secs["T"])))
        sleep(1000)
    end
end
