isRun = true;
delay = 10000;
ds = nil;
lastCandlePosition = 0; -- порядковый номер последней свечи

-- Функция запуска главного потока
function main()
	ConnectToData();
	while isRun do
		if mainCalculate() then
		else
		end;
		sleep(delay);
	end
end;

-- Функция подключения к данным инструмента
function ConnectToData()
	-- body
	Error = nil
	ds, Error = CreateDataSource("SPBFUT", "BRQ8", INTERVAL_M2);
	while (Error == "" or Error == nil) and ds:Size() == 0 do sleep(1000) message('додж') end
	if Error ~= "" and Error ~= nil then message("Ошибка подключения к графику: "..Error) return end
	-- Чтобы получать новые данные без использования функции обратного вызова, а просто получать новые данные в ds и брать их оттуда по необходимости существует функция:
	lastCandlePosition = ds:Size();
	ds:SetEmptyCallback();
end

-- функция инициализации переменных
function OnInit()
	isRun = true;
	message("START SCRIPT");
end;

-- функция остановки скрипта
function OnStop()
	isRun = false;
end;

-- 
function feelingSequence(n)
	size = ds:Size();
	arrCandle = {};
	temp = 0;
	for i=0, n do
		temp = temp + math.abs(ds:O(size-i)-ds:C(size-i));
		--arrCandle[i] = ds:O(size-i)-ds:C(size-i);
	end;
	-- for i=0, n do
	-- 	temp = temp + arrCandle[i]
	-- end;
	return temp / n;
end;

-- проверка на повление следующей свечи
function mainCalculate()
	if ds:Size()-lastCandlePosition == 1 then
		lastCandlePosition = ds:Size();
		return true;
	else 
		return false;
	end;
end;
