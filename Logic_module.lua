QLogicModule = {}

QLogicModule.__index = QLogicModule


function QLogicModule:MA(data)
    if #data < 1 then
        return 0.0
    end
    local avarage = 0.0
    for _, value in pairs(data) do
        avarage = avarage + value
    end
    return avarage / #data
end


function QLogicModule:LinearRegress(data)
    local XSum = 0
    local YSum = 0
    local XYSum = 0
    local XXSum = 0
    local YYSum = 0

    for i, v in pairs(data) do
        XSum = XSum + i
        XXSum = XXSum + i^2

        YSum = YSum + v
        YYSum = YYSum + v^2

        XYSum = XYSum + i*v
    end

    local div = (#data*XXSum)-(XSum^2)
    local a = ((YSum*XXSum)-( XSum*XYSum )) / div
    local b = (( #data*XYSum ) - ( XSum*YSum )) / div

    return a+b*#data
end