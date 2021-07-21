local map = require "map"
local pathfinder = require "pathfinder"
local f = require "printfile"

function converteDirecao (x,y)
  if x == -1 and y == 0 then
    return 0
  elseif x == 0 and y == 1 then
    return 1
  elseif x == 1 and y == 0 then
    return 2
  elseif x == 0 and y == -1 then
    return 3
  end
end

function sinal (num)
  if num < 0 then
    return -1
  else
    return 1
  end
end

function round (num)
  if num > 0 and ((10*num)%10)/10 >= 0.5 then
    return math.ceil(num)
  elseif num > 0 and ((10*num)%10)/10 < 0.5 then
    return math.floor(num)
  elseif num < 0 and ((10*num)%10)/10 <= 0.5 then
    return math.floor(num)
  elseif num < 0 and ((10*num)%10)/10 > 0.5 then
    return math.ceil(num)
  else
    return num
  end
end

function centralizaCamera()
  if math.abs(dirX) > math.abs(dirY) then
    dirX = round(dirX)
    dirY = 0
    planeX = 0
    planeY = -dirX*0.66
  else
    dirX = 0
    dirY = round(dirY)
    planeX = dirY*0.66
    planeY = 0
  end
end


function love.mousemoved( x, y, dx, dy, istouch )
  if dx > 10 and not auto then --clockwise
    --both camera direction and camera plane must be rotated
    oldDirX = dirX;
    dirX = dirX * math.cos(-rotSpeed) - dirY * math.sin(-rotSpeed);
    dirY = oldDirX * math.sin(-rotSpeed) + dirY * math.cos(-rotSpeed)
    oldPlaneX = planeX
    planeX = planeX * math.cos(-rotSpeed) - planeY * math.sin(-rotSpeed)
    planeY = oldPlaneX * math.sin(-rotSpeed) + planeY * math.cos(-rotSpeed)
  end
  if dx < -10 and not auto then --counterclockwise
    --both camera direction and camera plane must be rotated
    oldDirX = dirX
    dirX = dirX * math.cos(rotSpeed) - dirY * math.sin(rotSpeed)
    dirY = oldDirX * math.sin(rotSpeed) + dirY * math.cos(rotSpeed)
    oldPlaneX = planeX
    planeX = planeX * math.cos(rotSpeed) - planeY * math.sin(rotSpeed)
    planeY = oldPlaneX * math.sin(rotSpeed) + planeY * math.cos(rotSpeed)
  end
end

function love.keypressed(key)
  if key == "c" then --center camera
    centralizaCamera()
  elseif key == "e" then --turn clockwise
    local sin45 = math.sin(math.pi/4)
    if dirX <= -sin45 and dirY < 0 and dirY >= -sin45 then --North
      dirX = -1
      dirY = 0
      planeX = 0
      planeY = 0.66
    elseif dirX <= 0 and dirY <= -sin45 then -- Northwest
      dirX = -sin45
      dirY = -sin45
      planeX = -0.66*sin45
      planeY = 0.66*sin45
    elseif dirX <= sin45 and dirY < 0 and dirY <= -sin45 then --West
      dirX = 0
      dirY = -1
      planeX = -0.66
      planeY = 0
    elseif dirX >= 0 and dirY >= -sin45 and dirY <= 0 then --Southwest
      dirX = sin45
      dirY = -sin45
      planeX = -0.66*sin45
      planeY = -0.66*sin45
    elseif dirX >= sin45  and dirY >= 0 then --South
      dirX = 1
      dirY = 0
      planeX = 0
      planeY = -0.66
    elseif dirX >= 0 and dirY >= sin45 then --Southeast
      dirX = sin45
      dirY = sin45
      planeX = 0.66*sin45
      planeY = -0.66*sin45
    elseif dirX <= sin45  and dirY >= 0 and dirY >= sin45 then --East
      dirX = 0
      dirY = 1
      planeX = 0.66
      planeY = 0
    elseif dirX <= 0 and dirY <= sin45 then --Northeast
      dirX = -sin45
      dirY = sin45
      planeX = 0.66*sin45
      planeY = 0.66*sin45
    end
  elseif key == "q" then --turn counterclockwise
    local sin45 = math.sin(math.pi/4)
    if dirX <= -sin45 and dirY <= 0 and dirY > -sin45 then -- Northwest
      dirX = -sin45
      dirY = -sin45
      planeX = -0.66*sin45
      planeY = 0.66*sin45
    elseif dirX <= 0 and dirY <= -sin45 and dirY > -1 then -- West
      dirX = 0
      dirY = -1
      planeX = -0.66
      planeY = 0
    elseif dirX <= sin45 and dirY <= 0 and dirY < -sin45 then --SouthWest
      dirX = sin45
      dirY = -sin45
      planeX = -0.66*sin45
      planeY = -0.66*sin45
    elseif dirX >= 0 and dirY >= -sin45 and dirY < 0 then --South
      dirX = 1
      dirY = 0
      planeX = 0
      planeY = -0.66
    elseif dirX >= sin45  and dirY >= 0 and dirY < sin45 then --Southeast
      dirX = sin45
      dirY = sin45
      planeX = 0.66*sin45
      planeY = -0.66*sin45
    elseif dirX >= 0 and dirY >= sin45 and dirY < 1 then --East
      dirX = 0
      dirY = 1
      planeX = 0.66
      planeY = 0
    elseif dirX <= sin45  and dirY >= 0 and dirY > sin45 then --Northeast
      dirX = -sin45
      dirY = sin45
      planeX = 0.66*sin45
      planeY = 0.66*sin45
    elseif dirX <= 0 and dirY <= sin45 then --North
      dirX = -1
      dirY = 0
      planeX = 0
      planeY = 0.66
    end
  elseif key == "escape" then -- close the program
    love.event.quit(0)
  elseif key == "r" then -- restart
    for i=1,numThreads do canal2:push(false) end
    love.load()
  elseif key == "p" then -- resolve automaticamente
    auto = not auto
    if auto then pathfinder.load(worldMap) end
    love.mouse.setRelativeMode( not auto )
  end
end

function movementFunction()
   --move forward if no wall is in that direction
    if (love.keyboard.isDown("up") or love.keyboard.isDown("w")) and not auto then
      if(worldMap[math.floor(posX + dirX * 2 * moveSpeed)][math.floor(posY)] == 0) and (worldMap[math.floor(posX + dirX * moveSpeed)][math.floor(posY)] == 0) then
        posX = posX + dirX * moveSpeed
      end
      if(worldMap[math.floor(posX)][math.floor(posY + dirY * 2 * moveSpeed)] == 0) and (worldMap[math.floor(posX)][math.floor(posY + dirY * moveSpeed)] == 0) then
        posY = posY + dirY * moveSpeed
      end
    end
    --move backwards if no wall is in that direction
    if (love.keyboard.isDown("down") or love.keyboard.isDown("s")) and not auto then
      if(worldMap[math.floor(posX - dirX * 2 * moveSpeed)][math.floor(posY)] == 0) and (worldMap[math.floor(posX - dirX * moveSpeed)][math.floor(posY)] == 0) then
        posX = posX - dirX * moveSpeed
      end
      if(worldMap[math.floor(posX)][math.floor(posY - dirY * 2 * moveSpeed)] == 0) and (worldMap[math.floor(posX)][math.floor(posY - dirY * moveSpeed)] == 0) then
        posY = posY - dirY * moveSpeed
      end
    end
    --move to the left if no wall is in that direction
    if (love.keyboard.isDown("left") or love.keyboard.isDown("a")) and not auto then
      if(worldMap[math.floor(posX + dirY * 2 * moveSpeed)][math.floor(posY)] == 0) and (worldMap[math.floor(posX + dirY * moveSpeed)][math.floor(posY)] == 0) then
        posX = posX - dirY * moveSpeed/2
      end
      if(worldMap[math.floor(posX)][math.floor(posY + dirX * 2 * moveSpeed)] == 0) and (worldMap[math.floor(posX)][math.floor(posY + dirX * moveSpeed)] == 0) then
        posY = posY + dirX * moveSpeed/2
      end
    end
    --move to the right if no wall is in that direction
    if (love.keyboard.isDown("right") or love.keyboard.isDown("d")) and not auto then
      if(worldMap[math.floor(posX - dirY * 2 * moveSpeed)][math.floor(posY)] == 0) and (worldMap[math.floor(posX - dirY * moveSpeed)][math.floor(posY)] == 0) then
        posX = posX + dirY * moveSpeed/2
      end
      if(worldMap[math.floor(posX)][math.floor(posY - dirX * 2 * moveSpeed)] == 0) and (worldMap[math.floor(posX)][math.floor(posY - dirX * moveSpeed)] == 0) then
        posY = posY - dirX * moveSpeed/2
      end
    end
    if love.keyboard.isDown("lshift") or fixedMinimap then
      minimap = true
    else
      minimap = false
    end
end

function love.load()
  love.window.setMode(854,480)--, {fullscreen=true})
  love.mouse.setRelativeMode( true )
  width, height = love.graphics.getDimensions( )
  love.window.setTitle("Raycaster multi")
  mx = 21
  my = 31
  worldMap = map.create(mx,my,true,0.0)
  worldMap.x = mx
  worldMap.y = my
  --x and y start position
  posX = mx-0.5
  posY = 1.5
  if worldMap[math.floor(posX+1)][math.floor(posY+1)] == 0 then
    posX = posX + 1
    posY = posY + 1
  elseif worldMap[math.floor(posX)][math.floor(posY+1)] == 0 then
    posY = posY +1
  elseif worldMap[math.floor(posX+1)][math.floor(posY)] == 0 then
    posX = posX +1
  end
  
  dirX, dirY = -1, 0 --initial direction vector
  planeX, planeY = 0, 0.66 --the 2d raycaster version of camera plane
  time = 0
  oldTime = 0
  drawStart = {}
  drawEnd = {}
  trueStart = {}
  trueEnd = {}
  colorX, colorY = {}, {}
  moveSpeed = 0.1
  rotSpeed = math.pi/100
  texture = {}
  texWidth, texHeight = 128, 128
  buffer = {}
  side = {} --was a NS or a EW wall hit?
  texPos = {}
  ind = {}
  minimap = fixedMinimap or false
  auto = startAuto or false
  thread = {}
  numThreads = 3
  w = math.floor(width/numThreads)
  canal1 = love.thread.getChannel("canal1")
  canal2 = love.thread.getChannel("canal2")
  canal3 = love.thread.getChannel("canal3")
  canal1:pop()
  canal1:push({worldMap,height,width,texHeight,texWidth})
  for i=1,numThreads do
    thread[i]= love.thread.newThread("thread.lua")
    thread[i]:start()
  end
  
  --generate some textures
  texture[0]=love.graphics.newImage("pics/greenlight"..tostring(texWidth)..".png")
  texture[1]=love.graphics.newImage("pics/redbrick"..tostring(texWidth)..".png")
  texture[2]=love.graphics.newImage("pics/purplestone"..tostring(texWidth)..".png")
  texture[3]=love.graphics.newImage("pics/greystone"..tostring(texWidth)..".png")
  texture[4]=love.graphics.newImage("pics/bluestone"..tostring(texWidth)..".png")
  texture[5]=love.graphics.newImage("pics/mossy"..tostring(texWidth)..".png")
  texture[6]=love.graphics.newImage("pics/wood"..tostring(texWidth)..".png")
  texture[7]=love.graphics.newImage("pics/colorstone"..tostring(texWidth)..".png")
  texture[8]=love.graphics.newImage("pics/door"..tostring(texWidth)..".png")
  if auto then pathfinder.load(worldMap) end
end

function love.draw()
  love.graphics.setColor(1,1,1)
  local tx = 0
  for i=1, numThreads do
    for x = 1, w do
        local trueLength = trueEnd[i][x]-trueStart[i][x]
        local c
        if colorX[i][x] > 0 then
          c= worldMap[colorX[i][x]][colorY[i][x]]
        else
          c = 0
        end
        if c >= 0 then
          tx=math.floor(texPos[i][x])
          --draw the pixels of the stripe as a vertical line
          quad = love.graphics.newQuad(tx, 0, 1, trueLength, texture[c]:getWidth(), trueLength) --love.graphics.newQuad(tx, 0, 1, trueLength, trueLength, trueLength)
          if(side[i][x] == 1) then love.graphics.setColor(0.5,0.5,0.5,0.5) else love.graphics.setColor(1,1,1) end
          love.graphics.draw(texture[c], quad, x+width/numThreads*(ind[i]-1), trueStart[i][x])
        end
    end
  end
  love.graphics.setColor(1,1,1)
  love.graphics.print("FPS: "..tostring(love.timer.getFPS( )).." posX= "..posX.." posY= "..posY.." dirX= "..(math.floor(dirX*100)/100).." dirY= "..(math.floor(dirY*100)/100).." planeX= "..(math.floor(planeX*100)/100).." planeY= "..(math.floor(planeY*100)/100), 10, 10)
  if minimap then
    local w,h = love.graphics.getDimensions()
    local r  = 0.5
    love.graphics.push()
    if fixedMinimap then
      love.graphics.translate(10,height-128)
      love.graphics.scale(w/(5*64*(worldMap.y+8)),h/(5*64*(worldMap.x+8)))
    else
      love.graphics.translate((w/(worldMap.y+8))*4,(h/(worldMap.x+8))*4)
      love.graphics.scale(w/(64*(worldMap.y+8)),h/(64*(worldMap.x+8)))
    end
    love.graphics.setColor(0,0,0,0.5)
    map.draw(worldMap,texture)
    love.graphics.setColor(1,0,0,0.5)
    love.graphics.circle("fill",64*(posY-2*r),64*(posX-2*r),64*r)
    love.graphics.translate(64*(posY-2*r),64*(posX-2*r))
    love.graphics.rotate(sinal(dirY)*math.acos(-dirX))
    love.graphics.translate(-64*(posY-2*r),-64*(posX-2*r))
    love.graphics.setColor(0,1,0,0.5)
    love.graphics.polygon("fill",64*(posY-1.5),64*(posX-2.0),64*(posY-0.5),64*(posX-2.0),64*(posY-1.0),64*(posX-1.0))
    love.graphics.pop()
  end
end

function love.update()
  if posX <=1.6 and posY >= worldMap.y-0.6 then
    if contMap == 10 then 
      love.event.quit(0)
    end
    contMap = contMap + 1
    for i=1,numThreads do canal2:push(false) end
    love.load()
  end
  movementFunction()
  if auto then
    posX, posY, dirX, dirY, planeX, planeY = pathfinder.update(posX, posY, dirX, dirY, planeX, planeY, moveSpeed)
  end
  local time = love.timer.getTime()
  for i=1,numThreads do
    canal2:push({posX,posY,dirX,dirY,planeX,planeY,i,w})
  end
  for i=1,numThreads do
    message = canal3:demand()
    colorX[i] = message[1]
    colorY[i] = message[2]
    side[i] = message[3]
    trueStart[i] = message[4]
    trueEnd[i] = message[5]
    texPos[i] = message[6]
    ind[i] = message[7]
  end
  time = love.timer.getTime() - time
  f.printFile(tostring(time).."\n","tempo_multi.txt")
end