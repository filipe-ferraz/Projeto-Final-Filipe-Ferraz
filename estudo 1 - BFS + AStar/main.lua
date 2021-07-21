require "map"
require "player"
require "LimitedBFS"
require "AStar"

function tableEmpty (self)
    for _, _ in pairs(self) do
        return false
    end
    return true
end

function printcmd(text)
  local f = io.open(path.."\\Caminho.txt","a")
  f:write("caminho"..text.."\n")
  for i=1,#path_cmd do
    f:write(path_cmd[#path_cmd-i+1].."\n")
  end
  io.close(f)
end

function printcoordinates(text,curr,t)
  local f = io.open(path.."\\Coordenadas.txt","a")
  f:write("coordenadas"..text.." tempo: "..t.."\n")
  while( curr.father ~= nil ) do
    f:write("x: "..curr.x.." y: "..curr.y.."\n")
    curr = curr.father
  end
  f:write("x: "..curr.x.." y: "..curr.y.."\n")
  io.close(f)
end

function printtime(t)
  local f = io.open(path.."\\Tempo.txt","a")
  f:write("\t"..t)
  io.close(f)
end

function Reconstruct_path(curr)
	local path = {}
	local n = 1
	while( curr.father ~= nil ) do
		path[n] = curr
		curr = curr.father

		n = n + 1
	end
	path[n] = curr
	return reverse_path(path)
  
end

function reverse_path(way)
	local final = {}
	local u = #way
	local s = 1
	while u > 0 do
		final[s] = way[u]
		s = s + 1
		u = u - 1
	end
	 return final
end

function create_path_cmds(path)
	local cmd = {}
	for n=1,#path do
    if (n==#path) then
      --path[n] = nil
		elseif(path[n+1].x == (path[n].x)-1) then
			cmd[n] = 'left'
		elseif(path[n+1].x == (path[n].x)+1) then
			cmd[n] = 'right'
		elseif(path[n+1].y == (path[n].y)-1) then
			cmd[n] = 'up'
		elseif(path[n+1].y == (path[n].y)+1) then
			cmd[n] = 'down'
		end
	end
  return cmd
end

function love.load(arg)
  --Inicialização de variáveis
  local openList1 = {}
  local closedList1 = {}
  local BFSfim = false
  BFSDepth = tonumber(arg[1]) or 5
  path = arg[2] or "."
  thread = {}
  totalcost = 0
  terrain = 'g'
  outside = true
  
  channel0 = love.thread.getChannel("geral")
  channelMap = love.thread.getChannel("mapa")
  channelEnd = love.thread.getChannel("fim")
  
  if BFSDepth == 0 then
    thread[1] = love.thread.newThread("thread.lua")
  else
    for i=1,4*BFSDepth do
              thread[i] = love.thread.newThread("thread.lua")
    end
  end

  startpoint = {}
  goalpoint = {}
  dungeon_goalpoint = {}
  finish = {}

  act = 4
  numact = 4
  dungeon_act = 1
  dungeon_back = false

  for i=1,numact do

    goalpoint[i] = {}
    
  end

  mode = 0 -- 0 -> calculating ; 1 -> moving
  love.graphics.getBackgroundColor(255,255,255)
	
	map.load(path)
	player.load()
	
	--Loading Goal Points
	for i=1,numact do
		goalpoint[i].x = map.goalpoint[i].x
		goalpoint[i].y = map.goalpoint[i].y
	end
	
end

function love.update(dt)
	if (terrain == 'sd1' and outside) then
    mode = 0
		mapa = 1
		outside = false
    bloco.retX = bloco.x
    bloco.retY = bloco.y
    level[bloco.y][bloco.x].terreno='sdc'
		dungeon_goalpoint = load_dungeon(mapa)
    bloco.x = dungeon_goalpoint[2].x
		bloco.y = dungeon_goalpoint[2].y
	elseif (terrain == 'sd2' and outside) then
    mode = 0
		mapa = 2
		outside = false
    bloco.retX = bloco.x
    bloco.retY = bloco.y
    level[bloco.y][bloco.x].terreno='sdc'
		dungeon_goalpoint = load_dungeon(mapa)
		bloco.x = dungeon_goalpoint[2].x
		bloco.y = dungeon_goalpoint[2].y
	elseif (terrain == 'sd3' and outside) then
    mode = 0
		mapa = 3
		outside = false
    bloco.retX = bloco.x
    bloco.retY = bloco.y
    level[bloco.y][bloco.x].terreno='sdc'
		dungeon_goalpoint = load_dungeon(mapa)
		bloco.x = dungeon_goalpoint[2].x
		bloco.y = dungeon_goalpoint[2].y
	elseif terrain == 'vd' and dungeon_back == true then
    bloco.x = bloco.retX
    bloco.y = bloco.retY
    outside = true
		mapa = 0
  elseif terrain == 'vp1' or terrain == 'vp2' or terrain == 'vp3' then
    dungeon[bloco.y][bloco.x].terreno='v'
	end
  
  if mode == 0 then
    channelEnd:clear()
    channelMap:clear()
    player.update()
		--Program end
		if act == 0 then
      printtime("\n")
			love.event.quit()
		end
		
		startpoint.x = bloco.x
		startpoint.y = bloco.y
		
		path_cmd = {}
		if outside == true then
      tempoBFS = love.timer.getTime()
			openList1, closedList1, BFSfim = LimitedBFS(startpoint,goalpoint[act],BFSDepth)
      tempoBFS = love.timer.getTime() - tempoBFS
      if BFSfim then
        finish[1] = openList1[1]
        finish[2] = nil
        finish[3] = 0
      else
        if openList1 then
          channelMap:push({goalpoint[act],outside,0,closedList1,level,levelSize,terrenoG,mapa})
          for index, threadStart in pairs(openList1) do
            path_cmd = create_path_cmds(Reconstruct_path(openList1[index]))
            channel0:push({threadStart,path_cmd})
          end
          for index, _ in pairs(openList1) do
            thread[index]:start()
          end
        end
      end
		else
      tempoBFS = love.timer.getTime()
			openList1, closedList1, BFSfim = LimitedBFS(startpoint,dungeon_goalpoint[dungeon_act],BFSDepth)
      tempoBFS = love.timer.getTime() - tempoBFS
      if BFSfim then
        finish[1] = openList1[1]
        finish[2] = nil
        finish[3] = 0
      else
        if openList1 then
          channelMap:push({dungeon_goalpoint[dungeon_act],outside,dungeon,closedList1,level,dungeonSize,terrenoG,mapa})
          for index, threadStart in pairs(openList1) do
            path_cmd = create_path_cmds(Reconstruct_path(openList1[index]))
            channel0:push({threadStart,path_cmd})
          end
          for index, _ in pairs(openList1) do
            thread[index]:start()
          end
        end
      end
		end
    mode=2
	end
	
	if mode == 1 then
    player.update()
    player.move(path_cmd[cmdCont])
		terrain = terrain_update(bloco,mapa)
		totalcost = cost_update(bloco,mapa)

		cmdCont = cmdCont+1
		
		if cmdCont == #path_cmd + 1 then
			mode = 0	
		end
	end
  
  if mode == 2 then
    if tableEmpty(finish) then
      finish = channelEnd:pop() or finish
    else
      tempoTotal = finish[3] + tempoBFS
      printtime(tempoTotal)
      if outside == true then
        act = act - 1
        dungeon_act = 1
        dungeon_back = false
      else
        if dungeon_act == 2 then
          dungeon_back = true
        end
        dungeon_act = dungeon_act + 1
      end
      path_cmd = {}
      temp1 = finish[2]
      temp2 = create_path_cmds(Reconstruct_path(finish[1]))
      if temp1 then
        for i=1,#temp2 do
          temp1[#temp1+1]=temp2[i]
        end
        path_cmd = temp1
      else
        path_cmd = temp2
      end
      cmdCont = 1
      mode = 1
      finish = {}
    end
  end
end

function love.draw()
	map.draw()
  player.draw()
	love.graphics.setColor(255,255,255)
	love.graphics.print("g(n): "..totalcost,775,0)
	love.graphics.print("terreno: "..terrain,775,30)
	love.graphics.print("x: "..bloco.x,775,60)
	love.graphics.print("y: "..bloco.y,810,60)
  if mode == 1 and path_cmd[cmdCont] then love.graphics.print("mv["..cmdCont.."]: "..path_cmd[cmdCont],775,90) end
  love.graphics.print("startx: "..startpoint.x,775,120)
  love.graphics.print("starty: "..startpoint.y,775,150)
  love.graphics.print("mode: "..mode,775,180)
  love.graphics.print("BFSD: "..BFSDepth,775,210)
end