require "map"
require "player"
require "LimitedBFS"
require "AStar"

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
	song = love.audio.newSource("ZeldaThemeSong.mp3","stream")
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
		mapa = 1
		outside = false
    bloco.retX = bloco.x
    bloco.retY = bloco.y
    level[bloco.y][bloco.x].terreno='sdc'
		dungeon_goalpoint = load_dungeon(mapa)
    bloco.x = dungeon_goalpoint[2].x
		bloco.y = dungeon_goalpoint[2].y
	elseif (terrain == 'sd2' and outside) then
		mapa = 2
		outside = false
    bloco.retX = bloco.x
    bloco.retY = bloco.y
    level[bloco.y][bloco.x].terreno='sdc'
		dungeon_goalpoint = load_dungeon(mapa)
		bloco.x = dungeon_goalpoint[2].x
		bloco.y = dungeon_goalpoint[2].y
	elseif (terrain == 'sd3' and outside) then
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
	
		--Program end
		if act == 0 then
			love.event.wait()
			love.event.quit()
		end
		
		startpoint.x = bloco.x
		startpoint.y = bloco.y
		
		path_cmd = {}
		if outside == true then
			openList1, closedList1, BFSfim = LimitedBFS(startpoint,goalpoint[act])
      for index, start in pairs(openList1) do
        thread[index] = love.thread.newThread("thread.lua")
        channel0:push({start, goalpoint[act],mapa,outside,index})
        thread[index]:start()
      end
		else
			openList1, closedList1, BFSfim = LimitedBFS(startpoint,dungeon_goalpoint[dungeon_act])
      for index, start in pairs(openList1) do
        thread[index] = love.thread.newThread("thread.lua")
        channel0:push({start, dungeon_goalpoint[dungeon_act],mapa,outside,index})
        thread[index]:start()
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
    end
    if finish ~= false and outside == true then
      act = act - 1
      dungeon_act = 1
      dungeon_back = false
      create_path_cmds(finish)
      cmdCont = 1
      mode = 1
      finish = false
    end
    if finish  ~= false and outside == false then
      if dungeon_act == 2 then
        dungeon_back = true
      end
      dungeon_act = dungeon_act + 1
      create_path_cmds(finish)
      cmdCont = 1
      mode = 1
      finish = false
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
  if mode == 1 then love.graphics.print("move: "..path_cmd[cmdCont],775,90) end
end