--���������������� ����������
shares="ALRS,CHMF,FEES,GAZP,GMKN,HYDR,LKOH,MGNT,MOEX,MTSS,NLMK,NVTK,ROSN,RTKM,SBER,SBERP,SNGS,SNGSP,TATN,VTBR"
futures="MIX,RTS,Si,GOLD"--����� ������ ������� ������ �� �������� ������� ����� � ������� �������.
porog=100 --����� � ���������. �� ������� ������ ���� ������ ���������/����������� ����� ������������ ����-������� ��� ����-�������.
best_number=5--������� ������ ��������� � ������� �������������.
kto_begemot=0.005 --���� �� �������������� ������.ʊ���� ����� ������� ���������?
---
function GetFut(ba,days)
if sec_list==nil then sec_list = getClassSecurities("SPBFUT") end
DAYS_TO_MAT_DATE=100000000000
	for fut_code in string.gmatch(sec_list, "([^,]+)") do
	   local OPTIONBASE=getParamEx("SPBFUT",fut_code,"OPTIONBASE").param_image
	   if OPTIONBASE==ba then
			if 1*getParamEx("SPBFUT",fut_code,"DAYS_TO_MAT_DATE").param_value<1*DAYS_TO_MAT_DATE and 1*getParamEx("SPBFUT",fut_code,"DAYS_TO_MAT_DATE").param_value>days then
				DAYS_TO_MAT_DATE=1*getParamEx("SPBFUT",fut_code,"DAYS_TO_MAT_DATE").param_value
				closest_fut=fut_code
			end
		end
	end 
	return closest_fut
end

for f in string.gmatch(futures,"%w+") do
	if futures_list==nil then
		futures_list=GetFut(f,3)
	else
		futures_list=futures_list..","..GetFut(f,3)
	end
end
ticker_list=futures_list..","..shares
is_run = true
send_order=false
--������� �������
t_id = AllocTable()	
AddColumn (t_id, 0, 'Security',true,QTABLE_STRING_TYPE,10)
AddColumn (t_id, 1, 'Nazvanie', true, QTABLE_STRING_TYPE,15) 
AddColumn (t_id, 2, 'Lotov BUY | SELL | Raznitsa %', true, QTABLE_STRING_TYPE,40) 
AddColumn (t_id, 4, 'Razmer Begemota', true, QTABLE_STRING_TYPE,22)
AddColumn (t_id, 5, 'Lotov BUY '..best_number, true, QTABLE_STRING_TYPE,20)  
AddColumn (t_id, 6, 'Lotov SELL '..best_number, true, QTABLE_STRING_TYPE,20) 
AddColumn (t_id, 8, 'Zayavok BUY | SELL | Raznitsa %', true, QTABLE_STRING_TYPE,40)
CreateWindow(t_id)	 
SetWindowCaption(t_id, "Poisk Begemota")
InsertRow(t_id, i)

line_count=0
line_count_table={}
class_code={}
sum_bid={}
sum_offer={}
ds={}
avr_vol={}
begemot={}

function OnStop(s)
  is_run = false
  DestroyTable (t_id)
  return 100
end

function sum(t)
    local sum = 0
    for k,v in pairs(t) do
        sum = sum + v
    end
    return sum
end

function OnQuote(class, sec )
	if line_count_table[sec]~=nil and (class =="SPBFUT" or class=="TQBR") and string.find(ticker_list,sec)~=nil and 1*getParamEx(class,sec,"tradingstatus").param_value==1 then  
		qt = getQuoteLevel2(class, sec)
		if qt~=nil then
			if qt.bid_count==nil or qt.bid_count==0 then
					SetCell(t_id, line_count_table[sec], 5, "!!! PUSTO")
					Highlight(t_id, line_count_table[sec], 5, 0,16777215,20000)
			else
				if tonumber(qt.bid_count)>=best_number  then
						local best_bids={}
						for i=1,best_number do
							best_bids[i]=qt.bid[tonumber(qt.bid_count)-i+1].quantity
						end
					sum_bid[sec]=sum(best_bids)
					if sum_bid[sec]>(begemot[sec] or 10000000) then
						SetCell(t_id, line_count_table[sec], 5, sum_bid[sec].." BEGEMOT!")
						Highlight(t_id, line_count_table[sec], 5, 32768,16777215,20000)
					else
						SetCell(t_id, line_count_table[sec], 5, sum_bid[sec].."")
					end
				else
						SetCell(t_id, line_count_table[sec], 5, "!!! MALO BIDOV")
						Highlight(t_id, line_count_table[sec], 5, 0,16777215,20000)
				end
			end

			if qt.offer_count==nil or qt.offer_count==0 then
					SetCell(t_id, line_count_table[sec], 6, "!!! PUSTO")		
					Highlight(t_id, line_count_table[sec], 6, 0,16777215,20000)	
			else
				if tonumber(qt.offer_count)>=best_number then
					local best_offers={}
						for i=1,best_number do
							best_offers[i]=tonumber(qt.offer[i].quantity)
						end
					sum_offer[sec]=sum(best_offers)						
					if sum_offer[sec]>(begemot[sec] or 10000000) then
						SetCell(t_id, line_count_table[sec], 6, sum_offer[sec].." BEGEMOT!")
						Highlight(t_id, line_count_table[sec], 6, 255,16777215,20000)
					else
						SetCell(t_id, line_count_table[sec], 6, sum_offer[sec].."")
					end
				else
						SetCell(t_id, line_count_table[sec], 6, "!!! MALO ASKOV")
						Highlight(t_id, line_count_table[sec], 6, 0,16777215,20000)
				end
			end
		end
	end
end

function OnParam (class, sec)
	if line_count_table[sec]~=nil then
		if string.find(ticker_list,sec)~=nil and (class=="TQBR" or class=="SPBFUT") and 1*getParamEx(class,sec,"tradingstatus").param_value==1 then

			BIDDEPTHT_T = getParamEx(class,  sec, "BIDDEPTHT")
			BIDDEPTHT=tonumber(BIDDEPTHT_T.param_value)
			OFFERDEPTHT_T = getParamEx(class,  sec, "OFFERDEPTHT")
			OFFERDEPTHT=tonumber(OFFERDEPTHT_T.param_value)
			if BIDDEPTHT-OFFERDEPTHT>0 then
				mark_o="+"
				raznitsa_lotov=math.floor((BIDDEPTHT-OFFERDEPTHT)*100/OFFERDEPTHT)
				if raznitsa_lotov>porog then
					Highlight(t_id, line_count_table[sec], 2, 32768,65535,20000)
				else
					Highlight(t_id, line_count_table[sec], 2, 8454016,0,20000)
				end
			elseif BIDDEPTHT-OFFERDEPTHT<0 then
				mark_o="-"
				raznitsa_lotov=math.floor((OFFERDEPTHT-BIDDEPTHT)*100/BIDDEPTHT)
				if raznitsa_lotov>porog then
					Highlight(t_id, line_count_table[sec], 2, 255,65535,20000)
				else
					Highlight(t_id, line_count_table[sec], 2, 8421631,0,20000)
				end
			else
				mark_o=""
				raznitsa_lotov=math.floor((BIDDEPTHT-OFFERDEPTHT)*100/OFFERDEPTHT)
			end

			NUMBIDS_T = getParamEx(class,  sec, "NUMBIDS")
			NUMBIDS=tonumber(NUMBIDS_T.param_value)		
			NUMOFFERS_T = getParamEx(class,  sec, "NUMOFFERS")
			NUMOFFERS=tonumber(NUMOFFERS_T.param_value)			
			if NUMBIDS-NUMOFFERS>0 then				
			mark_z="+"
				raznitsa_zayavok=math.floor((NUMBIDS-NUMOFFERS)*100/NUMOFFERS)
				if raznitsa_zayavok>porog then
					Highlight(t_id, line_count_table[sec], 8, 32768,65535,20000)
				else
					Highlight(t_id, line_count_table[sec], 8, 8454016,0,20000)
				end
			elseif NUMBIDS-NUMOFFERS<0 then
				mark_z="-"
				raznitsa_zayavok=math.floor((NUMOFFERS-NUMBIDS)*100/NUMBIDS)
				if raznitsa_zayavok>porog then
					Highlight(t_id, line_count_table[sec], 8, 255,65535,20000)
				else
					Highlight(t_id, line_count_table[sec], 8, 8421631,0,20000)
				end
			else
				mark_z=""
			raznitsa_zayavok=math.floor((NUMBIDS-NUMOFFERS)*100/NUMOFFERS)
			end

			SetCell(t_id, line_count_table[sec], 8, string.format(NUMBIDS).." | "..string.format(NUMOFFERS).." | "..mark_z..raznitsa_zayavok)
			SetCell(t_id, line_count_table[sec], 2, string.format(BIDDEPTHT).." | "..string.format(OFFERDEPTHT).." | "..mark_o..raznitsa_lotov)
		end
	end
end

function main()
	for sec in string.gmatch(ticker_list,"%w+") do
		if getSecurityInfo("",sec).class_code=="SPBFUT" then
			class_code[sec]="SPBFUT"
		else 
			class_code[sec]="TQBR"
		end
		line_count=line_count+1
		line_count_table[sec]=line_count
		InsertRow(t_id, line_count)
		SetCell(t_id, line_count, 0, sec)			
		Highlight(t_id, line_count, 0, math.random(1,1000000), math.random(1,1000000), 5000)
		string_name=getParamEx("TQBR",sec,"SHORTNAME").param_image
		if string.len(string_name)==0 then 
			string_name=getParamEx("SPBFUT",sec,"SHORTNAME").param_image
		end
		SetCell(t_id, line_count, 1, string_name)			
		Subscribe_Level_II_Quotes(class_code[sec], sec)
		ds[sec] = CreateDataSource(class_code[sec],sec,INTERVAL_D1)
		while ds[sec]:Size()==nil or ds[sec]:C(ds[sec]:Size())==nil or ds[sec]:Size()==0 or ds[sec]:C(ds[sec]:Size())==0 do
			sleep (100)
		end				
		num_candles=ds[sec]:Size()
		volume={}
		 for i=1,5 do
			volume[i]=ds[sec]:V(num_candles-i)
		 end
		sum_vol=0
		for k,v in pairs (volume) do
			sum_vol=sum_vol+v
		end
		avr_vol[sec]=sum_vol/5
		begemot[sec]=avr_vol[sec]*kto_begemot
		SetCell(t_id, line_count, 4, string.format("%.0f",begemot[sec]))
		ds[sec]:Close()
	end
	string_name=nil
	while is_run do
		sleep (1000)
	end --����� ����� while is_run
end --����� main
