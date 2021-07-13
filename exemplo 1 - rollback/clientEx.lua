local ip, port = "127.0.0.1", 64268
local socket = require("socket")
local tcp = assert(socket.tcp())
local texto = "filipe" --arg[1]
tcp:connect(ip, port);
--note the newline below
tcp:send(texto.."\n");

while true do
    local s, status, partial = tcp:receive()
    print(s or partial)
    if status == "closed" then break end
end
tcp:close()