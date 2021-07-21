message = {}
caminho = {}
canal1 = love.thread.getChannel("canal1")
canal2 = love.thread.getChannel("canal2")

function raycast()
  drawStart = {}
  drawEnd = {}
  trueStart = {}
  trueEnd = {}
  colorX, colorY = {}, {}
  side = {}
  texPos = {}
  i = 1
  for x=widthStart,widthEnd do
    --calculate ray position and direction
    local cameraX = 2*x/width -1--2*x/width -1
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
        side[i] = 0
      else
        sideDistY = sideDistY + deltaDistY
        mapY = mapY + stepY
        side[i] = 1
      end
      --Check if ray has hit a wall
      if(mapX == 0) then hit =2 elseif worldMap[mapX][mapY] > 0 then hit = 1 end
    end
    --Calculate distance projected on camera direction (Euclidean distance will give fisheye effect!)
    if (side[i] == 0) then
      perpWallDist = (mapX - posX + (1 - stepX) / 2) / rayDirX
    else
      perpWallDist = (mapY - posY + (1 - stepY) / 2) / rayDirY
    end

    --Calculate height of line to draw on screen
    lineHeight = math.floor(height / perpWallDist);

    --calculate lowest and highest pixel to fill in current stripe
    drawStart[i] = -lineHeight / 2 + height / 2
    trueStart[i] = drawStart[i]
    if (drawStart[i] < 0) then drawStart[i] = 0 end
    drawEnd[i] = lineHeight / 2 + height / 2
    trueEnd[i] = drawEnd[i]
    if (drawEnd[i] >= height) then drawEnd[i] = height - 1 end
    
    --calculate value of wallX
    local wallX --where exactly the wall was hit
    if(side[i] == 0) then wallX = posY + perpWallDist * rayDirY
    else wallX = posX + perpWallDist * rayDirX end
    wallX = wallX - math.floor((wallX))
    
    --x coordinate on the texture
    local texX = math.floor(wallX * texWidth)
    if(side[i] == 0 and rayDirX > 0) then texX = texWidth - texX - 1 end
    if(side[i] == 1 and rayDirY < 0) then texX = texWidth - texX - 1 end
    --How much to increase the texture coordinate per screen pixel
    local step = 1.0 * texHeight / lineHeight
    -- Starting texture coordinate
    texPos[i] = (trueStart[i] - height / 2 + lineHeight / 2) * step
    for y = drawStart[i], drawEnd[i] do
      --Cast the texture coordinate to integer, and mask with (texHeight - 1) in case of overflow
      local texY = bit.band(math.floor(texPos[i]), (texHeight - 1))
      texPos[i] = texX --texPos[x] + step
      --color = texture[texNum][texHeight * texY + texX]
    end
    --texPos[x] = (trueStart[x] - height / 2 + lineHeight / 2) * step
    
    colorX[i] = mapX
    colorY[i] = mapY
    i=i+1
  end
end

canal1 = love.thread.getChannel("canal1")
canal2 = love.thread.getChannel("canal2")
canal3 = love.thread.getChannel("canal3")
message1=  1
run = true

while message1==1 do
  message1 = canal1:peek()
end

worldMap = message1[1]
height = message1[2]
width = message1[3]
texHeight = message1[4]
texWidth = message1[5]

while run do
  message2 = canal2:demand()
  if message2 then
    posX = message2[1]
    posY = message2[2]
    dirX = message2[3]
    dirY = message2[4]
    planeX = message2[5]
    planeY = message2[6]
    ind =message2[7]
    w = message2[8]
    widthStart = (ind-1)*w+1
    widthEnd = ind*w
    raycast()
    canal3:push({colorX,colorY,side,trueStart,trueEnd,texPos,ind})
  else run = false end
end