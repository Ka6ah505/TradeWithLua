function SendOrder(account, class_code, sec_code, operation, qty, price)
	local Transaction = {
		['TRANS_ID']  = "213",--os.time().tostring(),	--идентификатор транзакции
		['ACCOUNT']   = account, 			   			--код счета
		['CLASSCODE'] = class_code, 			   		--код инструмента
		['SECCODE']  = sec_code,
		['ACTION'] 	  = 'NEW_ORDER',		   			--тип транзакции
		['OPERATION'] = operation,			   			--операция 'B' — покупка, 'S' — продажа
		['TYPE'] 	  = 'L',				   			--тип заявки 'L' — лимитированная, 'M' — рыночная
		['QUANTITY']  = qty,				   			--количество лотов
		['PRICE'] 	  = tostring(price)					--цена выставления заявки
	}

	local result = sendTransaction(Transaction);
	--local res;
	if result ~= '' then 
		-- res = "Ошибка транзакции".. результат;
		file:write(getInfoParam("LOCALTIME").."  Ошибка транзакции\n");
	else
		--res = "Выставлено по цене "..цена;
		--file:write(getInfoParam("LOCALTIME").." Выставлено на продажу по "..цена.."\n");
	end;
	message(result, 3);
	return result;
end;

function transformDate(typeData)
	varReturn=nil;
	dt = {};
	dt.hour,dt.min,dt.sec = string.match(getInfoParam('SERVERTIME'),"(%d*):(%d*):(%d*)");
	if (typeData == 'hour') then 
		varReturn = transformToNumber(dt.hour);
	elseif (typeData =='min') then
		varReturn = transformToNumber(dt.min);
	elseif (typeData == 'sec') then
		varReturn = transformToNumber(dt.sec);
	end;
	return varReturn;
end;

function transformToNumber(varData)
	if (string.find(varData,"0") == 1) then
		varData = string.sub(varData, 1,2);
	else
		varData = varData;
	end;
	return varData*1;
end;

function checkTimeForBusinesOpen()
	h = transformDate("hour");
	m = transformDate("min");
	s = transformDate("sec");

	varData = nil;

	if (( h> 10 and h < 23) and m == 0 and (s>1 and s<10)) then
		varData = true;
	else
		varData = false;
	end;
	return varData;
end;

function checkTimeForBusinesClose()
	h = transformDate("hour");
	m = transformDate("min");
	s = transformDate("sec");

	varData = nil;

	if (( h> 10 and h < 23) and m == 59 and (s>50 and s<59)) then
		varData = true;
	else 
		varData = false;
	end;
	return varData;
end;

function checkStrategyByOpen()
	--local ds = CreateDataSource("SPBFUT", "BRJ6", INTERVAL_H1);

	histryOpen = ds:O(ds:Size()-1); --цена открытия предыдущей свечи
	historyClose = ds:C(ds:Size()-1); --цена закрытия предыдущей свечи

	actualOpen = ds:O(ds:Size()); --текущая цена открытия свечи
	actualClose = ds:C(ds:Size()); --изменение размера

	CandlesCount = getNumCandles(indication)
	t, n, l = getCandlesByIndex (indication, 0, CandlesCount-2, 2);
	p1 = tonumber(t[0].close) --значение параметра
	p2 = tonumber(t[1].close) -- значение параметра

	--message("имя файла "..tostring(histryOpen).." например "..tostring(historyClose).."\n ввод в действие \n".." ввод в действие "..tostring(actualOpen).."\n ввод в действие \n "..tostring(p1).." "..tostring(p2),1)
	if ((histryOpen < p1 and p1 < historyClose) and (p2 < actualOpen)) then -- полное раскрытие информации
		--îòêðûòèå ïîçèöèè (çàïîìèíàíèå id ïîçèöèè)
		--price = tonumber(getParamEx(secCode, classCode, "last").param_value);
		--SendOrder(tradeAcount, secCode, classCode, "B", "10", price);
		flag = false;
		--SendOrder(tradeAcount, secCode, classCode, "B", m_qty, actualOpen);
		typePosition = "short";
		file:write(getInfoParam("SERVERTIME").." îòêðûò ëîíã "..tostring(actualOpen).."\n");
		countCandle = ds:Size(); --íîìåð ñâå÷è íà êîòîðîé ïðîèçîøëà ñäåëêà
	elseif ((historyClose < p1 and p1 < histryOpen) and (p2 > actualOpen) ) then --ñèãíàë ê îòêðûòèþ êîðîòêîé ïèçèöèè
		--îòêðûòèå êîðîòêîé ïîçèöèè(çàïîìèíàíèå id ïîçèöèè)
		--price = tonumber(getParamEx(secCode, classCode, "last").param_value);
		--SendOrder(tradeAcount, secCode, classCode, "S", "10", price);
		flag = false;
		--SendOrder(tradeAcount, secCode, classCode, "S", m_qty, actualOpen);
		typePosition = "long";
		file:write(getInfoParam("SERVERTIME").." îòêðûò øîðò "..tostring(actualOpen).."\n");
		countCandle = ds:Size(); --íîìåð ñâå÷è íà êîòîðîé ïðîèçîøëà ñäåëêà
	end;
	--sleep(2000);
end;

function checkStrategyByClose()
	--local ds = CreateDataSource("SPBFUT", "BRJ6", INTERVAL_H1);

	actualOpen = ds:O(ds:Size()); --òåêóùàÿ öåíà îòêðûòèÿ ñâå÷è
	actualClose = ds:C(ds:Size()); --òåêóùàÿ öåíà íà ðûíêå

	local CandlesCount = getNumCandles(indication)

	t, n, l = getCandlesByIndex (indication, 0, CandlesCount-2, 2);
	p2 = tonumber(t[1].close) --òåêóùåå çíà÷åíèå

	if ((p2 < actualOpen) or (ds:Size() - countCandle == longPosition)) and (typePosition == "long") then --ñèãíàë îòêðûòèþ äëèííîé ïîçèöèè
		--çàêðûòèå øîðò ïîçèöèè
		--price = tonumber(getParamEx(secCode, classCode, "last").param_value);
		--SendOrder(tradeAcount, secCode, classCode, "B", "10", price);
		flag = true;
		--SendOrder(tradeAcount, secCode, classCode, "B", m_qty, actualOpen);
		countCandle = 0;
		typePosition = "";
		file:write(getInfoParam("SERVERTIME").." çàêðûò øîðò "..tostring(actualOpen).."\n");
		checkStrategyByOpen();
	elseif ((p2 > actualOpen) or (ds:Size() - countCandle == longPosition)) and (typePosition == "short") then --ñèãíàë ê îòêðûòèþ êîðîòêîé ïèçèöèè
		--çàêðûòèå äëèííîé ïîçèöèè
		--price = tonumber(getParamEx(secCode, classCode, "last").param_value);
		--SendOrder(tradeAcount, secCode, classCode, "S", "10", price);
		flag = true;
		--SendOrder(tradeAcount, secCode, classCode, "S", m_qty, actualOpen);
		countCandle = 0;
		typePosition = "";
		file:write(getInfoParam("SERVERTIME").." çàêðûò ëîíã "..tostring(actualOpen).."\n");
		checkStrategyByOpen();
	end;
	--sleep(2000);
end;

function MyFuncName()
	if ds:Size()-candlePosition == 1 then
		candlePosition = ds:Size();
		--message(tostring(candlePosition), 1);
		if flag then
			checkStrategyByOpen();
			--message("otkritie",1);
		else
			checkStrategyByClose();
		--message("zakrytie",1);
		end;
		--message("1111",1);
	end;
end;

--открытие лог файла и внесение в него времени сервера
function OpenFile(path)
	file = io.open(path, "a"); --открытие файла лога
	if file == nil then
		file = io.open(path, "w"); --если файл не существовал, то создаем¸
		file:close();
		file = io.open(path, "a");
		f:seek("end",0);
	end;
	file:write(getInfoParam("SERVERTIME").." START\n");
	file:flush();
end;

-- Сохраняет таблицу в файл
function SaveTable(Params, FilePath)
 	message("close", 2)
    local Lines = {}
    --сохранение типа ключ=значение (без пробелов)
   	for key, val in pairs(Params) do
		table.insert(Lines, tostring(key).."="..tostring(val));
	end
    local f = io.open(FilePath, 'w')
    for i=1, #Lines do
       f:write(Lines[i]..'\n')
       f:flush()
    end
    f:close()
end;

--загрузка переменных из файла
function LoadTable(FilePath)
	message("open", 2)
    -- Пытается открыть файл текущего инструмента в режиме "чтения"
	TradesFile = io.open(FilePath,"r");
	-- Встает в начало файла
	TradesFile:seek('set', 0);
	-- Перебирает строки файла
	local Count = 0; -- Счетчик строк
	Params = {}; -- обнуление перед записью
	for line in TradesFile:lines() do
		key, value = line:match("%s*([^=]*)%s*%=%s*(.-)%s*$");
		Params[tostring(key)] = value;
		Count = Count+1;
	end;
end;
