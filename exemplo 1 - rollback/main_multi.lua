local socket = require("socket")

function decodificarString(inputStr)
  local t={}
  for str in string.gmatch(inputStr, "([^"..",".."]+)") do
          table.insert(t, str)
  end
  return t[2],t[3],t[4]
end


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
  elseif key == "z" then
    prediction = not prediction
  end
end

function love.load()
  cont = 0
  --tcp = assert(socket.tcp())
  posX, posY = 300, 300
  cpuX, cpuY = 300, 400
  dir = 0
  thread = love.thread.newThread("thread.lua")
  channelSend = love.thread.getChannel("socketSend")
  channelReceive = love.thread.getChannel("socketReceive")
  echo = "-1"
  prediction = true
  
  thread:start()  
  love.keyboard.setKeyRepeat(true)
end

function love.update()
  channelSend:clear() --necessario para pegar apenas o último valor
  channelSend:push(tostring(cont))
  
  s = channelReceive:pop()
  if s ~= "" and s then --porque s de vez em quando é uma string vazia?
    echo = s --or echo
    cpuX, cpuY, dir = decodificarString(echo)
  else if tonumber(dir) > 0 and prediction then
      cpuX = (cpuX + math.sin((dir-1)*math.pi/2))%800
      cpuY = (cpuY + math.cos((dir-1)*math.pi/2))%600
    end
  end
  cont=cont+1
end

function love.draw()
  love.graphics.print("echo: "..echo.." CPUX: "..cpuX.." CPUY: "..cpuY.." dir: "..dir.. " prediction: "..tostring(prediction),0,0)
  love.graphics.rectangle("line", posX, posY, 20, 20)
  love.graphics.circle("line", cpuX, cpuY,10)
end

function love.quit()
  channelSend:clear()
  channelSend:push("quitCode")
  thread:wait()
end