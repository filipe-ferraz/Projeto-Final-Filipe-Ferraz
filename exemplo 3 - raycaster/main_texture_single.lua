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

function raycast()
  for x=1,width do
    --calculate ray position and direction
    local cameraX = 2*x/width -1
    local rayDirX = dirX + planeX * cameraX
    local rayDirY = dirY + planeY * cameraX
    --which box of the map we're in
    local mapX = math.floor(posX)
    local mapY = math.floor(posY)
    --length of ray from current position to next x or y-side
    local sideDistX
    local sideDistY
    --length of ray from one x or y-side to next x or y-side
    local deltaDistX = math.abs(1 / rayDirX)
    local deltaDistY = math.abs(1 / rayDirY)
    local perpWallDist
     --what direction to step in x or y-direction (either +1 or -1)
    local stepX
    local stepY
    local drawStart = {}
    local drawEnd = {}
    
    local hit = 0 --was there a wall hit?
    --calculate step and initial sideDist
    if (rayDirX < 0) then
      stepX = -1
      sideDistX = (posX - mapX) * deltaDistX
    else
      stepX = 1
      sideDistX = (mapX + 1.0 - posX) * deltaDistX
    end
    if (rayDirY < 0) then
      stepY = -1
      sideDistY = (posY - mapY) * deltaDistY
    else
       stepY = 1
       sideDistY = (mapY + 1.0 - posY) * deltaDistY
    end
    
    --perform DDA
    while (hit == 0) do
      --jump to next map square, OR in x-direction, OR in y-direction
      if (sideDistX < sideDistY) then
        sideDistX = sideDistX + deltaDistX
        mapX = mapX + stepX
        side[x] = 0
      else
        sideDistY = sideDistY + deltaDistY
        mapY = mapY + stepY
        side[x] = 1
      end
      --Check if ray has hit a wall
      if(mapX == 0) then hit =2 elseif worldMap[mapX][mapY] > 0 then hit = 1 end
    end
    --Calculate distance projected on camera direction (Euclidean distance will give fisheye effect!)
    if (side[x] == 0) then
      perpWallDist = (mapX - posX + (1 - stepX) / 2) / rayDirX
    else
      perpWallDist = (mapY - posY + (1 - stepY) / 2) / rayDirY
    end

    --Calculate height of line to draw on screen
    local lineHeight = math.floor(height / perpWallDist);

    --calculate lowest and highest pixel to fill in current stripe
    drawStart[x] = -lineHeight / 2 + height / 2
    trueStart[x] = drawStart[x]
    if (drawStart[x] < 0) then drawStart[x] = 0 end
    drawEnd[x] = lineHeight / 2 + height / 2
    trueEnd[x] = drawEnd[x]
    if (drawEnd[x] >= height) then drawEnd[x] = height - 1 end
    
    --calculate value of wallX
    local wallX --where exactly the wall was hit
    if(side[x] == 0) then wallX = posY + perpWallDist * rayDirY
    else wallX = posX + perpWallDist * rayDirX end
    wallX = wallX - math.floor((wallX))
    
    --x coordinate on the texture
    local texX = math.floor(wallX * texWidth)
    if(side[x] == 0 and rayDirX > 0) then texX = texWidth - texX - 1 end
    if(side[x] == 1 and rayDirY < 0) then texX = texWidth - texX - 1 end
    --How much to increase the texture coordinate per screen pixel
    local step = 1.0 * texHeight / lineHeight
    -- Starting texture coordinate
    texPos[x] = (trueStart[x] - height / 2 + lineHeight / 2) * step
    for y = drawStart[x], drawEnd[x] do
      --Cast the texture coordinate to integer, and mask with (texHeight - 1) in case of overflow
      local texY = bit.band(math.floor(texPos[x]), (texHeight - 1))
      texPos[x] = texX --texPos[x] + step
      --color = texture[texNum][texHeight * texY + texX]
    end
    --texPos[x] = (trueStart[x] - height / 2 + lineHeight / 2) * step
    
    colorX[x] = mapX
    colorY[x] = mapY    
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
  love.window.setTitle("Raycaster single")
  mx = 21
  my = 31
  worldMap = map.create(mx,my,true,0.0)
  worldMap.x = mx
  worldMap.y = my
  --x and y start position
  --posX = mx/2
  posX = mx-0.5
  --posY = my/2
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
  minimap = fixedMinimap or false
  auto = startAuto or false
  thread = {}
  numThreads = 8
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
  for x=1,width do
    --if colorX[x] and colorY[x] then
      local trueLength = trueEnd[x]-trueStart[x]
      --local drawLength = drawEnd[x]-drawStart[x]
      local c
      if colorX[x] > 0 then
        c= worldMap[colorX[x]][colorY[x]]
      else
        c = 0
      end
      if c >= 0 then
        tx=math.floor(texPos[x])
        --if tx > trueLength then tx = tx - trueLength end
        --draw the pixels of the stripe as a vertical line
        quad = love.graphics.newQuad(tx, 0, 1, trueLength, texture[c]:getWidth(), trueLength) --love.graphics.newQuad(tx, 0, 1, trueLength, trueLength, trueLength)
        if(side[x] == 1) then love.graphics.setColor(0.5,0.5,0.5,0.5) else love.graphics.setColor(1,1,1) end
        love.graphics.draw(texture[c], quad, x, trueStart[x])
      end
  end
  love.graphics.setColor(1,1,1)
  love.graphics.print("FPS: "..tostring(love.timer.getFPS( )).." posX= "..posX.." posY= "..posY.." dirX= "..(math.floor(dirX*100)/100).." dirY= "..(math.floor(dirY*100)/100).." planeX= "..(math.floor(planeX*100)/100).." planeY= "..(math.floor(planeY*100)/100), 10, 10)
  --love.graphics.print("FPS: "..tostring(love.timer.getFPS( )).." posX= "..posX.." posY= "..posY.." dirX= "..dirX.." dirY= "..dirY.." planeX= "..planeX.." planeY= "..planeY, 10, 10)
  love.graphics.print("cos(dirX) "..tostring(math.cos(math.pi*dirX)).." sen(dirY) "..tostring(math.sin(math.pi*dirY)).." tan(dirX) "..tostring(math.tan(math.pi*dirX)).." auto: "..tostring(auto), 10, 50)
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
    --if (dirX == 1 or dirX == 0 or dirX == -1) and (dirY == 1 or dirY == 0 or dirY == -1) then
    love.graphics.translate(64*(posY-2*r),64*(posX-2*r))
    --love.graphics.rotate((math.pi/2)*converteDirecao(dirX,dirY))
    love.graphics.rotate(sinal(dirY)*math.acos(-dirX))
    love.graphics.translate(-64*(posY-2*r),-64*(posX-2*r))
    --end
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
    love.load()
  end
  movementFunction()
  if auto then
    posX, posY, dirX, dirY, planeX, planeY = pathfinder.update(posX, posY, dirX, dirY, planeX, planeY, moveSpeed)
    --love.timer.sleep(moveSpeed*0.05)
  end
  time = love.timer.getTime()
  raycast()
  time = love.timer.getTime() - time
  f.printFile(tostring(time).."\n","tempo_single.txt")
end