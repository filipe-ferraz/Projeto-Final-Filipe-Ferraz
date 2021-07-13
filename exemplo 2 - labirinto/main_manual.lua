local map = require "map"
local M    -- map
local nx = 31
local ny = 21

local x, y
local r = 0.5

function love.keypressed(key)
  if key == "left" then
    if M[y][x-1] then
      x = x - 1
    end
  elseif key == "right" then
    if M[y][x+1] then
      x = x + 1
    end
  elseif key == "up" then
    if M[y-1][x] then
      y = y - 1
    end
  elseif key == "down" then
    if M[y+1][x] then
      y = y + 1
    end
  end
end

function love.load ()
  x, y = 2, ny-1
  math.randomseed(os.time())
  M = map.create(nx,ny,true,0.0)
  love.graphics.setBackgroundColor(255,255,255)
end

function love.update ()
  if y == 1 and x == nx - 1 then
    love.load()
  end
end

function love.draw ()
  local w,h = love.graphics.getDimensions()
  love.graphics.push()
  love.graphics.print("FPS: "..love.timer.getFPS(),0,0) 
  love.graphics.translate((w/(nx+8))*4,(h/(ny+8))*4)
  love.graphics.scale(w/(nx+8),h/(ny+8))
  
  love.graphics.setColor(0,0,0)
  map.draw(M)
  love.graphics.setColor(255,0,0)
  love.graphics.circle("fill",x-r,y-r,r)
  love.graphics.pop()
end

