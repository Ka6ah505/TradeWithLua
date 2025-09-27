dofile (getScriptPath().."\\QuikTable.lua")
dofile (getScriptPath().."\\Logging.lua")
dofile (getScriptPath().."\\Logic_module.lua")

classCode = "CNYRUBF"
interval = INTERVAL_M5
IsRun = false
logger = QLogger.init(getScriptPath().."\\"..classCode.."_5Min.txt")
logic = QLogicModule

secCode = "SPBFUT" --"TQBR"
classCodes = {classCode}
store_classCode = {}

function OnInit()
-- инициализация функции main
    -- logger:add("Логгер открыт для записи")
    logger:add("date;time;open;high;low;close;volume", false)
end


function OnStop()
-- остановка скрипта руками
    IsRun = false
    -- logger:add("Логгер закрыт - терминал закрыт руками")
    logger = nil
end


function OnClose()
-- закрытие терминала
    -- logger:add("Логгер закрыт - терминал крашнулся")
    logger:close()
    logger = nil
end


function main()
-- основной поток управления

    while not IsRun do
        for _, code in pairs (classCodes) do
            store_classCode[code] = ConnectToData(secCode, code)
        end
        size = store_classCode[classCode]:Size()
        -- tt_10, n, l = getCandlesByIndex("tt_SPBFUT_10", 0, 0, size)
        -- tt_20, n, l = getCandlesByIndex("tt_SPBFUT_10", 0, 0, size)
        n = store_classCode[classCode]:Size()
        for i = 1, n do -- цикл от 1 до 10 с шагом 1
            local data = {}
            data["open"] = store_classCode[classCode]:O(i)
            data["close"] = store_classCode[classCode]:C(i)
            data["low"] = store_classCode[classCode]:L(i)
            data["high"] = store_classCode[classCode]:H(i)
            data["volume"] = store_classCode[classCode]:V(i)
            local my_time, my_date = concatDate(store_classCode[classCode]:T(i))
            data["time"] = my_time
            data["date"] = my_date
            -- data['linReg10'] = tt_10[i-1].close
            -- data['linReg20'] = tt_20[i-1].close
            local row = createRow(data, ";")
            logger:add(row, false)
         end

        sleep(3000)
        IsRun = true
    end
end


-- Функция подключения к данным инструмента
function ConnectToData(secCode, classCode)
	-- body
	Error = nil
	local ds, Error = CreateDataSource(secCode, classCode, interval);
	while (Error == "" or Error == nil) and ds:Size() == 0 do
        sleep(1000)
        message('No source for '..secCode.." "..classCode)
    end
	if Error ~= "" and Error ~= nil then
        message("Connect error to chart: "..Error, 3)
        return
    end
	-- Чтобы получать новые данные без использования функции обратного вызова, а просто получать новые данные в ds и брать их оттуда по необходимости существует функция:
	ds:SetEmptyCallback();
    return ds
end


function createRow(data, sep)
    -- date, time, open, high, low, close, volume, linReg
    return data.date..sep..data.time..sep..data.open..sep..data.high..sep..data.low..sep..data.close..sep..data.volume --..sep..data.linReg10..sep..data.linReg20
end


function concatDate(time)
    year = time.year
    month = transformToString(time.month)
    day = transformToString(time.day)

    hour = transformToString(time.hour)
    min = transformToString(time.min)
    sec = transformToString(time.sec)
    return hour..":"..min..":"..sec, day.."."..month.."."..year
end


function transformToString(number)
    if number < 10 then
        return "0"..number
    end
    return tostring(number)
end
