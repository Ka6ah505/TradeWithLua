isRun = true
delay = 10000
ds = nil

-- Функция запуска главного потока
function main()
	ConnectToData();
	while isRun do
		message("loop")
		if ds ~= nil then
			message(tostring(ds:O(ds:Size()))); --os.date(), 
		else 
			message("no data")
		end
		sleep(delay)
	end
end;

-- Функция подключения к данным инструмента
function ConnectToData()
	-- body
	Error = nil
	ds, Error = CreateDataSource("SPBFUT", "BRQ8", INTERVAL_M2)
	while (Error == "" or Error == nil) and ds:Size() == 0 do sleep(1000) message('додж') end
	if Error ~= "" and Error ~= nil then message("Ошибка подключения к графику: "..Error) return end
	-- Чтобы получать новые данные без использования функции обратного вызова, а просто получать новые данные в ds и брать их оттуда по необходимости существует функция:
	ds:SetEmptyCallback();
end

-- функция инициализации переменных
function OnInit()
	isRun = true
	message("START SCRIPT");
end;

-- функция остановки скрипта
function OnStop()
	isRun = false;
end;
