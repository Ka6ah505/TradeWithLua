-- Таблица обезличенных сделок для QLUA с проверками GetCell
local tbl = {}

-- Глобальные переменные
local instruments = {}
local trade_data = {}

function main()
    -- Создаем таблицу
    create_table()

    -- Запускаем мониторинг инструментов
    start_monitoring()

    -- Основной цикл
    -- while isWindowClosed(tbl) == 0 do
    while true do
        sleep(1000)
        update_table()
    end

    message("Таблица закрыта")
end

function create_table()
    -- Создаем окно таблицы
    tbl = AllocTable()

    -- Добавляем колонки
    AddColumn(tbl, 0, "Инструмент", true, QTABLE_STRING_TYPE, 15)
    AddColumn(tbl, 1, "Код", true, QTABLE_STRING_TYPE, 10)
    AddColumn(tbl, 2, "Класс", true, QTABLE_STRING_TYPE, 8)
    AddColumn(tbl, 3, "Покупки (руб)", true, QTABLE_DOUBLE_TYPE, 15)
    AddColumn(tbl, 4, "Продажи (руб)", true, QTABLE_DOUBLE_TYPE, 15)
    AddColumn(tbl, 5, "Нетто (руб)", true, QTABLE_DOUBLE_TYPE, 15)
    AddColumn(tbl, 6, "Последняя цена", true, QTABLE_DOUBLE_TYPE, 12)
    AddColumn(tbl, 7, "Объем", true, QTABLE_INT_TYPE, 10)
    AddColumn(tbl, 8, "Время обновления", true, QTABLE_STRING_TYPE, 12)

    -- Создаем окно
    CreateWindow(tbl)
    SetWindowCaption(tbl, "Обезличенные сделки - Денежные объемы")

    -- Инициализируем данные
    init_instruments()
end

function init_instruments()
    -- Список инструментов для мониторинга
    instruments = {
        { class = "TQBR", code = "SBER", name = "Сбербанк" },
        { class = "TQBR", code = "GAZP", name = "Газпром" },
        { class = "TQBR", code = "LKOH", name = "Лукойл" },
        { class = "TQBR", code = "ROSN", name = "Роснефть" },
        { class = "TQBR", code = "VTBR", name = "ВТБ" },
        { class = "TQBR", code = "MGNT", name = "Магнит" },
        { class = "TQBR", code = "NLMK", name = "НЛМК" }
    }

    -- Инициализируем структуру данных для каждого инструмента
    for i, instr in ipairs(instruments) do
        local key = instr.class .. ":" .. instr.code
        trade_data[key] = {
            name = instr.name,
            class = instr.class,
            code = instr.code,
            buy_money = 0,
            sell_money = 0,
            last_price = 0,
            volume = 0,
            update_time = "",
            row_index = i - 1 -- Сохраняем индекс строки
        }

        -- Добавляем строку в таблицу
        local row = InsertRow(tbl, -1)
        SetCell(tbl, row, 0, instr.name)
        SetCell(tbl, row, 1, instr.code)
        SetCell(tbl, row, 2, instr.class)
        SetCell(tbl, row, 3, "0")
        SetCell(tbl, row, 4, "0")
        SetCell(tbl, row, 5, "0")
        SetCell(tbl, row, 6, "0")
        SetCell(tbl, row, 7, "0")
        SetCell(tbl, row, 8, "")

        -- Запускаем мониторинг сделок для инструмента
        start_trade_monitoring(instr.class, instr.code)
    end
end

function start_trade_monitoring(class_code, sec_code)
    -- Создаем источник данных для сделок
    local ds = CreateDataSource("TRADES", class_code, sec_code, INTERVAL_TICK)

    if ds then
        ds:OnData(function(data)
            process_trades(data, class_code, sec_code)
        end)

        message("Мониторинг запущен: " .. class_code .. ":" .. sec_code)
    else
        message("Ошибка создания источника: " .. class_code .. ":" .. sec_code)
    end
end

function process_trades(data, class_code, sec_code)
    local key = class_code .. ":" .. sec_code
    local data_size = data:Size()

    for i = 1, data_size do
        local trade = data[i]
        classify_and_process_trade(trade, class_code, sec_code)
    end

    -- Обновляем время последнего обновления
    trade_data[key].update_time = os.date("%H:%M:%S")
end

function classify_and_process_trade(trade, class_code, sec_code)
    local key = class_code .. ":" .. sec_code
    local price = trade.price
    local volume = trade.quantity
    local money_value = price * volume

    -- Получаем последнюю цену для сравнения
    local last_param = getParamEx(class_code, sec_code, "LAST")
    local last_price = last_param and tonumber(last_param.param_value) or 0

    -- Простая логика классификации
    if last_price > 0 then
        if price > last_price then
            -- Цена выше последней - считаем покупкой
            trade_data[key].buy_money = trade_data[key].buy_money + money_value
        elseif price < last_price then
            -- Цена ниже последней - считаем продажей
            trade_data[key].sell_money = trade_data[key].sell_money + money_value
        else
            -- Та же цена - распределяем поровну
            trade_data[key].buy_money = trade_data[key].buy_money + money_value / 2
            trade_data[key].sell_money = trade_data[key].sell_money + money_value / 2
        end
    else
        -- Если нет последней цены, используем упрощенную логику
        trade_data[key].buy_money = trade_data[key].buy_money + money_value / 2
        trade_data[key].sell_money = trade_data[key].sell_money + money_value / 2
    end

    -- Обновляем последнюю цену и объем
    trade_data[key].last_price = price
    trade_data[key].volume = volume
end

function update_table()
    -- Обновляем данные в таблице для всех строк
    local table_size = GetTableSize(tbl)
    if not table_size then return end

    for row = 0, table_size - 1 do
        -- Безопасное получение значения ячейки с проверкой на nil
        local code_cell = safe_get_cell(tbl, row, 1)
        local class_cell = safe_get_cell(tbl, row, 2)

        if code_cell and class_cell then
            local code = code_cell.image
            local class = class_cell.image
            local key = class .. ":" .. code

            if trade_data[key] then
                local data = trade_data[key]
                local net_flow = data.buy_money - data.sell_money

                -- Форматируем значения для отображения
                local buy_str = format_money(data.buy_money)
                local sell_str = format_money(data.sell_money)
                local net_str = format_money(net_flow)
                local price_str = string.format("%.2f", data.last_price)

                -- Устанавливаем значения ячеек
                SetCell(tbl, row, 3, buy_str)
                SetCell(tbl, row, 4, sell_str)
                SetCell(tbl, row, 5, net_str)
                SetCell(tbl, row, 6, price_str)
                SetCell(tbl, row, 7, tostring(data.volume))
                SetCell(tbl, row, 8, data.update_time)

                -- Раскрашиваем нетто-поток
                color_net_flow(row, net_flow)
            end
        end
    end
end

-- Безопасный GetCell с проверкой на nil
function safe_get_cell(table_handle, row, col)
    local success, result = pcall(function()
        return GetCell(table_handle, row, col)
    end)

    if success and result then
        return result
    else
        return nil
    end
end

-- Альтернативная версия безопасного GetCell
function safe_get_cell_value(table_handle, row, col)
    local cell = safe_get_cell(table_handle, row, col)
    if cell and cell.image then
        return cell.image
    end
    return nil
end

function format_money(value)
    if value >= 1000000 then
        return string.format("%.1fм", value / 1000000)
    elseif value >= 1000 then
        return string.format("%.1fт", value / 1000)
    else
        return string.format("%.0f", value)
    end
end

function color_net_flow(row, value)
    if value > 0 then
        SetColor(tbl, row, 5, RGB(0, 100, 0), RGB(200, 255, 200)) -- Зеленый
    elseif value < 0 then
        SetColor(tbl, row, 5, RGB(100, 0, 0), RGB(255, 200, 200)) -- Красный
    else
        SetColor(tbl, row, 5, RGB(0, 0, 0), RGB(255, 255, 255))   -- Белый
    end
end

function start_monitoring()
    message("Запуск мониторинга обезличенных сделок...")
end
