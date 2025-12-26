-- Минимальный скрипт с таблицей

local S = 0  -- SBER сумма
local V = 0  -- VTBR сумма
local Sid = 0  -- SBER последний ID
local Vid = 0  -- VTBR последний ID
local tid = 0  -- ID таблицы
local run = true

function main()
    run = true
    
    -- Создаем таблицу
    tid = AllocTable()
    if tid == 0 then return end
    
    -- Колонки
    AddColumn(tid, 0, "Тикер", true, QTABLE_STRING_TYPE, 10)
    AddColumn(tid, 1, "Сумма", true, QTABLE_INT_TYPE, 15)
    
    -- Окно
    CreateWindow(tid)
    SetWindowCaption(tid, "Сделки SBER/VTBR")
    SetWindowPos(tid, 100, 100, 250, 100)
    
    -- Загружаем историю
    loadHist()
    
    -- Создаем строки
    Clear(tid)
    local r1 = InsertRow(tid, -1)  -- SBER строка
    local r2 = InsertRow(tid, -1)  -- VTBR строка
    
    -- Основной цикл
    while run do
        checkNew()
        updateTable(r1, r2)
        delay(2000)  -- 200 мс
    end
end

function loadHist()
    local cnt = getNumberOf("all_trades")
    for i = 0, cnt-1 do
        local t = getItem("all_trades", i)
        if t then add(t, true) end
    end
end

function add(t, hist)
    local sec = t.sec_code
    if sec ~= "SBER" and sec ~= "VTBR" then return false end
    
    local id = tonumber(t.trade_num) or 0
    local q = tonumber(t.qty) or 0
    
    -- Проверка ID
    if sec == "SBER" then
        if not hist and id <= Sid then return false end
    else
        if not hist and id <= Vid then return false end
    end
    
    -- Операция
    local sell = false
    if t.flags and tostring(t.flags):find("S") then sell = true end
    
    -- Суммируем
    if sec == "SBER" then
        if sell then
            S = S - q
        else
            S = S + q
        end
        Sid = id
    else -- VTBR
        if sell then
            V = V - q
        else
            V = V + q
        end
        Vid = id
    end
    
    return true
end

function checkNew()
    local cnt = getNumberOf("all_trades")
    if cnt == 0 then return end
    
    for i = cnt-1, math.max(0, cnt-10), -1 do
        local t = getItem("all_trades", i)
        add(t, false)
    end
end

function updateTable(r1, r2)
    if tid == 0 then return end
    
    -- Заголовок
    SetWindowCaption(tid, os.date("%H:%M:%S"))
    
    -- SBER
    SetCell(tid, r1, 0, "SBER")
    local s1 = tostring(S)
    if S > 0 then s1 = "+" .. s1 end
    SetCell(tid, r1, 1, s1)
    
    -- Цвет SBER
    if S > 0 then
        SetColor(tid, r1, 1, RGB(0,255,0), RGB(0,0,0))
    elseif S < 0 then
        SetColor(tid, r1, 1, RGB(255,0,0), RGB(0,0,0))
    end
    
    -- VTBR
    SetCell(tid, r2, 0, "VTBR")
    local s2 = tostring(V)
    if V > 0 then s2 = "+" .. s2 end
    SetCell(tid, r2, 1, s2)
    
    -- Цвет VTBR
    if V > 0 then
        SetColor(tid, r2, 1, RGB(0,255,0), RGB(0,0,0))
    elseif V < 0 then
        SetColor(tid, r2, 1, RGB(255,0,0), RGB(0,0,0))
    end
end

function delay(ms)
    local s = os.clock()
    while (os.clock() - s) * 1000 < ms do end
end

function OnStop()
    run = false
    
    if tid ~= 0 then
        DestroyTable(tid)
    end
    
    message("SBER: " .. S .. "\nVTBR: " .. V)
    
    return 1000
end

main()