local pathfinder = {}
local M    -- map
local passo-- 1-cima 2-direita 3-baixo 4-esquerda
local caminho
local p

function comparaDirecao (dir, dirX, dirY)
  if dir == 1 and dirX ==0 and dirY == -1 then
    return true
  elseif dir == 2 and dirX == 1 and dirY == 0 then
    return true
  elseif dir == 3 and dirX == 0 and dirY == 1 then
    return true
  elseif dir == 4 and dirX == -1 and dirY == 0 then
    return true
  else
    return false
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

function rotacionaCamera()
  if math.abs(dx) > math.abs(dy) then
    dx = round(dx)
    dy = 0
    px = 0
    py = -dx*0.66
  else
    dx = 0
    dy = round(dy)
    px = dy*0.66
    py = 0
  end
end

function transformaDirecao (dir)
  angle4d5 = math.pi/40
  if (dir == 1 and dx >= 0) or (dir == 2 and dy >= 0) or (dir == 3 and dx < 0) or (dir == 4 and dy < 0) then --sentido horário
    if direction == 2 then
      rotacionaCamera()
    else      
      oldDirX = dx;
      dx = dx * math.cos(-angle4d5) - dy * math.sin(-angle4d5);
      dy = oldDirX * math.sin(-angle4d5) + dy * math.cos(-angle4d5)
      oldPlaneX = px
      px = px * math.cos(-angle4d5) - py * math.sin(-angle4d5)
      py = oldPlaneX * math.sin(-angle4d5) + py * math.cos(-angle4d5)
      direction = 1
    end
  elseif (dir == 1 and dx < 0) or (dir == 2 and dy < 0) or (dir == 3 and dx >= 0) or (dir == 4 and dy >= 0) then --sentido anti-horário
    if direction == 1 then
      rotacionaCamera()
    else
      oldDirX = dx
      dx = dx * math.cos(angle4d5) - dy * math.sin(angle4d5)
      dy = oldDirX * math.sin(angle4d5) + dy * math.cos(angle4d5)
      oldPlaneX = px
      px = px * math.cos(angle4d5) - py * math.sin(angle4d5)
      py = oldPlaneX * math.sin(angle4d5) + py * math.cos(angle4d5)
      direction = 2
    end
  end
  return dx, dy, px, py
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

function caminhoTotal(xc, yc, goalX, goalY, passo, caminho)
  local dir = {1,2,3,4}
  --shuffle(dir)
  if xc < goalX and yc >= goalY then
    table.insert(caminho, 0)
    return caminho
  end
  for i=1,4 do
    if dir[i] ~= oposto(passo) then
      local xn = math.floor(xc - math.cos((dir[i])*math.pi/2))
      local yn = math.floor(yc - math.cos((dir[i]-1)*math.pi/2))
      if M[xn][yn] == 0 then
        caminho = caminhoTotal(xn, yn, goalX, goalY, dir[i], caminho)
        if #caminho ~= 0 then
          table.insert(caminho,dir[i])
          return caminho
        end
      end
    end
  end
  return {}
end

function pathfinder.load (map)
  passo = 0
  caminho = {}
  p = 0
  tempo = 0
  M = map
  index = 0
  direction = 0
end

function pathfinder.update (posX, posY, dirX, dirY, planeX, planeY, moveSpeed)
  y = posX
  x = posY
  dx = dirX
  dy = dirY
  px = planeX
  py = planeY
  if #caminho > 0 then
    p = caminho[math.ceil(index)] or 0
    if p~=0 then
      if comparaDirecao(caminho[math.ceil(index)],dx,dy) then
        x = x + moveSpeed*math.floor((math.cos((oposto(p)-1)*math.pi/2))+0.1)
        y = y + moveSpeed*math.floor((math.cos((oposto(p))*math.pi/2))+0.1)
        index=index-moveSpeed
        direction = 0
      else
        dx, dy, px, py = transformaDirecao(caminho[math.ceil(index)])
      end
    end
  else
    caminho = caminhoTotal(math.floor(y),math.floor(x), 2, M.y-1, 0, caminho)
    --caminho = Astar(math.floor(y),math.floor(x), 2, M.y-1, 0)
    index = #caminho
  end
  return y, x, dx, dy, px, py
end

return pathfinder