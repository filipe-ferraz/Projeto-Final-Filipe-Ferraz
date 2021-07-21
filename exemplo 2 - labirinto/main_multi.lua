local map = require "map"
local M    -- map
local nx = 101 --31
local ny = 101 --21

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

function love.load ()
  x, y = 2, ny-1
  math.randomseed(1)
  M = map.create(nx,ny,true,0.0)
  math.randomseed(os.time())
  love.graphics.setBackgroundColor(255,255,255)
  p=0
  caminho = {}
  tempo = 0
  thread = {}
  numThreads = 8
  canal1 = love.thread.getChannel("canal1")
  canal2 = love.thread.getChannel("canal2")
  canal3 = love.thread.getChannel("canal3")
  for i=1,numThreads do
    canal3:push(math.random())
    thread[i]= love.thread.newThread("thread.lua")
  end
  canal1:push({M,x,y,0,caminho,nx,ny})
end

function love.update (dt)
  if y == 1 and x == nx - 1 then
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
    for i=1,numThreads do
      thread[i]:start()
    end
    caminho = canal2:demand()
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
  love.graphics.translate((w/(nx+8))*4,(h/(ny+8))*4)
  love.graphics.scale(w/(nx+8),h/(ny+8))
  
  love.graphics.setColor(0,0,0)
  map.draw(M)
  love.graphics.setColor(255,0,0)
  love.graphics.circle("fill",x-r,y-r,r)
  love.graphics.pop()
end

