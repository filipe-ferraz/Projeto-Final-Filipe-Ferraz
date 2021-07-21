local worldMap=
{
  {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
  {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,0,0,0,0,0,2,2,2,2,2,0,0,0,0,4,0,4,0,4,0,0,0,1},
  {1,0,0,0,0,0,2,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,0,0,0,0,0,2,0,0,0,2,0,0,0,0,4,0,0,0,4,0,0,0,1},
  {1,0,0,0,0,0,2,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,0,0,0,0,0,2,2,0,2,2,0,0,0,0,4,0,4,0,4,0,0,0,1},
  {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,8,8,8,8,8,8,8,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,8,0,8,0,0,0,0,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,8,0,0,0,0,1,0,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,8,0,8,0,0,0,0,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,8,0,8,8,8,8,8,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,8,8,8,8,8,8,8,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}
}


function keyboardFunction()
   --move forward if no wall in front of you
    if love.keyboard.isDown("up") or love.keyboard.isDown("w") then
      if(worldMap[math.floor(posX + dirX * moveSpeed)][math.floor(posY)] == 0) then
        posX = posX + dirX * moveSpeed
      end
      if(worldMap[math.floor(posX)][math.floor(posY + dirY * moveSpeed)] == 0) then
        posY = posY + dirY * moveSpeed
      end
    end
    --move backwards if no wall in front of you
    if love.keyboard.isDown("down") or love.keyboard.isDown("s") then
      if(worldMap[math.floor(posX - dirX * moveSpeed)][math.floor(posY)] == 0) then
        posX = posX - dirX * moveSpeed
      end
      if(worldMap[math.floor(posX)][math.floor(posY - dirY * moveSpeed)] == 0) then
        posY = posY - dirY * moveSpeed
      end
    end
    --rotate to the right
    if love.keyboard.isDown("right") or love.keyboard.isDown("d") then
      --both camera direction and camera plane must be rotated
      oldDirX = dirX;
      dirX = dirX * math.cos(-rotSpeed) - dirY * math.sin(-rotSpeed);
      dirY = oldDirX * math.sin(-rotSpeed) + dirY * math.cos(-rotSpeed)
      oldPlaneX = planeX
      planeX = planeX * math.cos(-rotSpeed) - planeY * math.sin(-rotSpeed)
      planeY = oldPlaneX * math.sin(-rotSpeed) + planeY * math.cos(-rotSpeed)
    end
    --rotate to the left
    if love.keyboard.isDown("left") or love.keyboard.isDown("a") then
      --both camera direction and camera plane must be rotated
      oldDirX = dirX
      dirX = dirX * math.cos(rotSpeed) - dirY * math.sin(rotSpeed)
      dirY = oldDirX * math.sin(rotSpeed) + dirY * math.cos(rotSpeed)
      oldPlaneX = planeX
      planeX = planeX * math.cos(rotSpeed) - planeY * math.sin(rotSpeed)
      planeY = oldPlaneX * math.sin(rotSpeed) + planeY * math.cos(rotSpeed)
    end
    
end

function love.load()
  width, height = love.graphics.getDimensions( )
  posX, posY = 22.5, 12.5 --x and y start position
  dirX, dirY = -1, 0 --initial direction vector
  planeX, planeY = 0, 0.66 --the 2d raycaster version of camera plane
  time = 0
  oldTime = 0
  drawStart = {}
  drawEnd = {}
  colorX, colorY = {}, {}
  love.keyboard.setKeyRepeat(true)
  moveSpeed = 0.1
  rotSpeed = 0.01
  side ={} --was a NS or a EW wall hit?
end

function love.draw()
  for x=1,width do
    if colorX[x] and colorY[x] then
      local c=worldMap[colorX[x]][colorY[x]]
      if c==1 then r,g,b=255,0,0 --red
      elseif c==2 then r,g,b=0,255,0 --green
      elseif c==4 then r,g,b=0,0,255 --blue
      elseif c==8 then r,g,b=255,255,255 --white
      else r,g,b=255,255,0 end --yellow
      --give x and y sides different brightness
      if side[x] == 1 then r,g,b=r/2,g/2,b/2 end
      love.graphics.setColor(r,g,b)
      --draw the pixels of the stripe as a vertical line
      love.graphics.line(x,drawStart[x],x,drawEnd[x])
    end
  end
  love.graphics.setColor(255,255,255)
  love.graphics.print("FPS: "..tostring(love.timer.getFPS( )).." posX= "..posX.." posY= "..posY.." dirX= "..(math.floor(dirX*100)/100).." dirY= "..(math.floor(dirY*100)/100).." planeX= "..(math.floor(planeX*100)/100).." planeY= "..(math.floor(planeY*100)/100), 10, 10)
end

function love.update()
  keyboardFunction()
  for x=1,width do
    --calculate ray position and direction
    local cameraX = 2*x/width -1
    local rayDirX = dirX + planeX * cameraX
    local rayDirY = dirY + planeY * cameraX
    --which box of the map we're in
    mapX = math.floor(posX)
    mapY = math.floor(posY)
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
      if(worldMap[mapX][mapY] > 0) then hit = 1 end
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
    if (drawStart[x] < 0) then drawStart[x] = 0 end
    drawEnd[x] = lineHeight / 2 + height / 2
    if (drawEnd[x] >= height) then drawEnd[x] = height - 1 end
    colorX[x] = mapX
    colorY[x] = mapY    
  end
end