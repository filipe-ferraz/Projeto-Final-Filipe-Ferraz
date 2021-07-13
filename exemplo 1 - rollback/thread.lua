local socket = require("socket")
local ip, port = "127.0.0.1"
local tcp = assert(socket.tcp())
local f = io.open("port.txt","r")
port = f:read()
io.close(f)  
channelSend = love.thread.getChannel("socketSend")
channelReceive = love.thread.getChannel("socketReceive")
channelCPU = love.thread.getChannel("socketCPU")
tcp:connect(ip, port);

while true do
  local message = channelSend:pop()
  if message ~="" and message then
    tcp:send(message.."\n")
    if message == "quitCode" then
      tcp:close()
      break
    end
    local s, status, partial = tcp:receive()
    if s then
      channelReceive:push(s)
    end
    if status == "closed" then break end
  end
end