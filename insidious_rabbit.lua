dofile (getScriptPath() .. "\\MFrameWork.lua")
IsRun = true;
FileName = "log1.txt";
file=nil;
flag = true;
typePosition="";
candlePosition = 0;
countCandle = 0;
m_qty = "2";
longPosition = 5; --кол-во свечей до закрытия позиции
ds = {};
--t = nil;

-------------------
--secCode = "QJSIM";
secCode="SPBFUT";
--classCode = "SBER";
classCode = "BRX4";
--tradeAcount = "NL0011100043";     -- Торговый счет
tradeAcount = "SPBFUT00f91";
clientCode = "SPBFUT00f91";     -- Код клиента
--indication = "ema1";
indication = "tt";

function main()
	while IsRun do
		--PrintDbgStr("test1")
		--price = getParamEx("SPBFUT", "BRJ6", "last").param_value;

		if ((candlePosition == 0) and (ds ~= nil)) then
			candlePosition = ds:Size();
			-- message(tostring(candlePosition),2);
		end;

		if (ds ~= nil) then
			CandlesCount = getNumCandles(indication)
			local tab, n, l = getCandlesByIndex(indication, 0, CandlesCount-2, 2);
			DeleteRow(t, 1);
			InsertRow(t, -1);
			SetCell(t, 1, 0, tostring(IsRun));
			SetCell(t, 1, 1, tostring(ds:C(ds:Size())));
			-- SetCell(t, 1, 2, tostring(getInfoParam("SERVERTIME")));
			if (tab ~= nil) and (n > 0) then
				SetCell(t, 1, 2, tostring(tab[1].close));
			else
				SetCell(t, 1, 2, tostring(0));
			end;
		end;
		sleep(3000);
	end;
end;

function tables()
	InsertRow(t, -1);
end;

function OnStop()
	--IsRun = false;
	--file:close();
	Clear(t);
	DestroyTable(t);
end;

function OnInit()
	message("Start...",2);
	OpenFile();
	--ds = CreateDataSource("SPBFUT", "BRJ6", INTERVAL_H1);
	ds = CreateDataSource(secCode, classCode, INTERVAL_M5);
	--ds:SetUpdateCallback(MyFuncName);
	t = AllocTable();
	AddColumn(t, 0, "Script status", true, QTABLE_STRING_TYPE, 15);
	AddColumn(t, 1, "Price", true, QTABLE_STRING_TYPE, 15);
	AddColumn(t, 2, "EMA", true, QTABLE_STRING_TYPE, 15);
	--AddColumn(t, 1, "2", true, QTABLE_INT_TYPE, 15);
	--AddColumn(t, 2, "3", true, QTABLE_INT_TYPE, 15);
	--AddColumn(t, 3, "4", true, QTABLE_INT_TYPE, 15);
	tab = CreateWindow(t);
	SetWindowCaption(t, "Testing table");
	InsertRow(t, -1);
	SetCell(t, 1, 0, tostring(IsRun));
	SetCell(t, 1, 1, "0");
	SetCell(t, 1, 2, "0");
	--InsertRow(t, -1);
	--DeleteRow(t, 1);

end;

function OpenFile()
	file = io.open(getScriptPath().."\\"..FileName, "a"); --???????? ?????
	if file == nil then
		file = io.open(getScriptPath().."\\"..FileName, "w"); --???????? ????? ??? ??????
		file:close();
		file = io.open(getScriptPath().."\\"..FileName, "a");
		file:seek("end",0);
	end;
	file:write(getInfoParam("SERVERTIME").." START\n");
	file:flush();
end;

function OnTrade(tabTr)
	--if 
end;

function OnConnected()
	IsRun = true;
	ds = CreateDataSource(secCode, classCode, INTERVAL_M5);
	candlePosition = 0;
end;
