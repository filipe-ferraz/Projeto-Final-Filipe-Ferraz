local socket = require("socket")

function love.keypressed(key)
  if key == "up" then
    posY = posY-5
  elseif key == "down" then
    posY = posY+5
  elseif key == "left" then
    posX = posX-5
  elseif key == "right" then
    posX = posX+5
  elseif key == "escape" then
    love.event.quit()
  end
end

function love.load()
  local ip, port = "127.0.0.1"
  cont = 0
  tcp = assert(socket.tcp())
  posX, posY = 300, 300
  local f = io.open("port.txt","r")
  port = f:read()
  io.close(f)  
  love.keyboard.setKeyRepeat(true)
  tcp:connect(ip, port)
end

function love.update()
  tcp:send(tostring(cont).."\n")
  
  s, status, partial = tcp:receive()
  
  cont=cont+1
  
end

function love.draw()
  love.graphics.print("echo: "..(s or ""),0,0)
  love.graphics.rectangle("line", posX, posY, 20, 20)
end

function love.quit()
  tcp:send("quitCode\n")
  tcp:close()
end