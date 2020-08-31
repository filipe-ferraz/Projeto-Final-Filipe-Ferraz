require "map"
require "player"
require "LimitedBFS"
require "AStar"

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
	for n=1,#path do
    if (n==#path) then
      path[n] = nil
		elseif(path[n+1].x == (path[n].x)-1) then
			path_cmd[n] = 'left'
		elseif(path[n+1].x == (path[n].x)+1) then
			path_cmd[n] = 'right'
		elseif(path[n+1].y == (path[n].y)-1) then
			path_cmd[n] = 'up'
		elseif(path[n+1].y == (path[n].y)+1) then
			path_cmd[n] = 'down'
		end
	end
end

function love.load()
  --Inicialização de variáveis
  local openList1 = {}
  local closedList1 = {}
  local BFSfim = false
  BFSdepth = 100
  thread = {}
  totalcost = 0
  terrain = 'g'
  outside = true
  
  channel0 = love.thread.getChannel("geral")
  channelEnd = love.thread.getChannel("fim")

  startpoint = {}
  goalpoint = {}
  dungeon_goalpoint = {}

  act = 4
  numact = 4
  dungeon_act = 1
  dungeon_back = false
  finish = false

  for i=1,numact do

    goalpoint[i] = {}
    
  end

  mode = 0 -- 0 -> calculating ; 1 -> moving
  love.graphics.getBackgroundColor(255,255,255)
	--song = love.audio.newSource("ZeldaThemeSong.mp3","stream")
	--love.audio.play(song)
	
	map.load()
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
    player.update()
		--Program end
		if act == 0 then
			love.event.wait()
			love.event.quit()
		end
		
		startpoint.x = bloco.x
		startpoint.y = bloco.y
		
		path_cmd = {}
		if outside == true then
			openList1, closedList1, BFSfim = LimitedBFS(startpoint,goalpoint[act],BFSdepth)
      if BFSfim then
        finish = openList1[1]
      else
        if openList1 then
          for index, threadStart in pairs(openList1) do
            thread[index] = love.thread.newThread("thread.lua")
            channel0:push({threadStart, goalpoint[act],mapa,outside,index,0,closedList1})
            thread[index]:start()
          end
        end
      end
		else
			openList1, closedList1, BFSfim = LimitedBFS(startpoint,dungeon_goalpoint[dungeon_act],BFSdepth)
      if BFSfim then
        finish = openList1[1]
      else
        if openList1 then
          for index, threadStart in pairs(openList1) do
            thread[index] = love.thread.newThread("thread.lua")
            channel0:push({threadStart, dungeon_goalpoint[dungeon_act],mapa,outside,index,dungeon,closedList1})
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
    if finish == false then
      finish = channelEnd:pop() or false
    else
      if outside == true then
        act = act - 1
        dungeon_act = 1
        dungeon_back = false
        create_path_cmds(Reconstruct_path(finish))
        cmdCont = 1
        mode = 1
        finish = false
      end
      if outside == false then
        if dungeon_act == 2 then
          dungeon_back = true
        end
        dungeon_act = dungeon_act + 1
        create_path_cmds(Reconstruct_path(finish))
        cmdCont = 1
        mode = 1
        finish = false
      end
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
end