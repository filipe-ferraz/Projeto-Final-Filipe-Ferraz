local map = require "map"
local M={}    -- map
M.x = 101 --31
M.y = 101 --21

local x, y
local r = 0.5
local passo = 0 -- 1-cima 2-direita 3-baixo 4-esquerda
local caminho = {}
local fileCount = 0

function printFile(text,filename)
  if fileCount < 100 then
    local f = io.open(filename,"a")
    f:write("\n"..text)
    io.close(f)
    fileCount=fileCount+1
  end
end

function oposto(dir)
  if dir == 1 then
    return 3
  elseif dir == 2 then
    return 4
  elseif dir == 3 then
    return 1
  elseif dir == 4 then
    return 2
  else
    return 0
  end
end

function shuffle(list)
	for i = #list, 2, -1 do
		local j = math.random(i)
		list[i], list[j] = list[j], list[i]
	end
end

function caminhoTotal(xc, yc, passo, caminho)
  local i = {1,2,3,4}
  shuffle(i)
  if yc == 2 and xc == M.x - 1 then
    table.insert(caminho, 0)
    return caminho
  end
  for j=1,4 do
    if i[j] ~= oposto(passo) then
      local xn = math.floor(xc - math.cos(i[j]*math.pi/2))
      local yn = math.floor(yc - math.cos((i[j]-1)*math.pi/2))
      if M[yn][xn] then
        caminho = caminhoTotal(xn, yn, i[j], caminho)
        if #caminho ~= 0 then
          table.insert(caminho,i[j])
          return caminho
        end
      end
    end
  end
  return {}
end
  

function caminhoIterado()
  local dirVal = {}
  local xc, yc
  for i=1,4,1 do
    if i ~= passo then
      xc = math.floor(x - math.cos(i*math.pi/2))
      yc = math.floor(y - math.cos((i-1)*math.pi/2))
      if M[yc][xc] then
        table.insert(dirVal, i)
      end
    end
  end
  if #dirVal == 0 then
    table.insert(dirVal, passo)
  end
  while true do
    local direcao = dirVal[math.random(1,#dirVal)]
    xc = math.floor(x - math.cos(direcao*math.pi/2))
    yc = math.floor(y - math.cos((direcao-1)*math.pi/2))
    if M[yc][xc] then
      x = xc
      y = yc
      passo = oposto(direcao)
      return
    end
  end
end

function love.load ()
  x, y = 2, M.y-1
  math.randomseed(1)
  M = map.create(M.x,M.y,true,0.0)
  M.x = 101
  M.y = 101
  math.randomseed(os.time())
  love.graphics.setBackgroundColor(255,255,255)
  p=0
  caminho = {}
  tempo = 0
end

function love.update (dt)
  if y == 2 and x == M.x - 1 then
    love.load()
  end
  if #caminho > 0 then
    --love.load()
    p = caminho[i] or 0
    if p~=0 then
      x = math.floor(x - math.cos(p*math.pi/2))
      y = math.floor(y - math.cos((p-1)*math.pi/2))
      i=i-1
    end
  else
    tempo = love.timer.getTime()
    caminho = caminhoTotal(x,y,0,caminho)
    tempo = love.timer.getTime() - tempo
    i=#caminho
  end
end

function love.draw ()
  local w,h = love.graphics.getDimensions()
  love.graphics.push()
  love.graphics.print("FPS: "..love.timer.getFPS(),0,0)
  love.graphics.print("tempo: "..string.format("%.20f",tempo),0,10)
  love.graphics.print("passo: "..p,0,20)
  love.graphics.translate((w/(M.x+8))*4,(h/(M.y+8))*4)
  love.graphics.scale(w/(M.x+8),h/(M.y+8))
  
  love.graphics.setColor(0,0,0)
  map.draw(M)
  love.graphics.setColor(255,0,0)
  love.graphics.circle("fill",x-r,y-r,r)
  love.graphics.pop()
end

