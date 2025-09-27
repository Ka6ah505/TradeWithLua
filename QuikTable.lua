QTable = {}

QTable.__index = QTable


-- Конструктор таблицы QTable
function QTable.new()
    local table_id = AllocTable()
    if table_id == nil then
        return nil
    end
    q_table = {}
    setmetatable(q_table, QTable)
    q_table.table_id = table_id
    q_table.caption = ""
    q_table.created = false
    q_table.curr_column = 0
    q_table.columns = {}
    return q_table
end


-- Отобразить окно
function QTable:Show ()
    CreateWindow(self.table_id)
    if self.caption ~= "" then
        SetWindowCaption(self.table_id, self.caption)
    end
    self.created = true
end


function QTable:IsClosed()
    return IsWindowClosed(self.table_id)
end


function QTable:delete()
    res = DestroyTable(self.table_id)
    if not res then
        message("Error during destroy table", 3)
    end
    message("Table is destroyed", 1)
end


--[[ 
Добавить столбец
    name - имя столбца
    c_type - тип столбца (
        QTABLE_INT_TYPE,
        QTABLE_DOUBLE_TYPE,
        QTABLE_INT64_TYPE,
        QTABLE_STRING_TYPE,
        QTABLE_CACHED_STRING_TYPE,
        QTABLE_TIME_TYPE,
        QTABLE_DATE_TYPE
    )
    width - ширина столбца
    <ff> - функция форматирования
]]
function QTable:AddColumn(name, c_type, width, ff)
    local col_desc={}
    self.curr_column=self.curr_column+1
    col_desc.c_type = c_type
    col_desc.format_function = ff
    col_desc.id = self.curr_column
    self.columns[name] = col_desc

    AddColumn(self.table_id, self.curr_column, name, true, c_type, width)
end


function QTable:SetCaption(s)
-- Добавить заголовок
    self.caption = s
    if not IsWindowClosed(self.table_id) then
        SetWindowCaption(self.table_id, tostring(s))
    end
end


function QTable:Clear()
-- очистить таблицу
    Clear(self.table_id)
end


function QTable:AddLine()
-- добавление строки в конец таблицы
    return InsertRow(self.table_id, -1)
end


function QTable:SetValue(row, col_name, data)
-- добавить значение в клетку
    local col_ind = self.columns[col_name].id or nil
    if col_ind == nil then
        return false
    end

    local ff = self.columns[col_name].format_function

    if type(ff) == "function" then
        SetCell(self.table_id, row, col_ind, ff(data), data)
        return true
    end
    if type(data) == "string" then
        SetCell(self.table_id, row, col_ind, data)
    else
        SetCell(self.table_id, row, col_ind, tostring(data), data)
    end
end


function QTable:SetColor(row, col_name, background_color, font_color)
    local col_ind = self.columns[col_name].id or nil
    if col_ind == nil then
        return false
    end

    SetColor(self.table_id, row, col_ind, background_color, font_color, background_color, font_color)
end


function QTable:GetSize()
    return GetTableSize(self.table_id)
end
