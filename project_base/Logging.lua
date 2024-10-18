QLogger = {}

QLogger.__index = QLogger


function QLogger.init(path)
    local file = io.open(path, "a")
    if file == nil then
        file = io.open(path, "w")
        file:close()
    end
    file = io.open(path, "r+")
    file:seek("end", 0);
    logger = {}
    setmetatable(logger, QLogger)
    logger.file = file
    return logger
end


function QLogger:close()
    self.file:flush()
    self.file:close()
end


function QLogger:add(data)
    local date = getInfoParam("TRADEDATE")
    local time = getInfoParam("SERVERTIME")
    self.file:write(date.." "..time.." - "..tostring(data))
    self.file:write("\n")
    self.file:flush()
end
