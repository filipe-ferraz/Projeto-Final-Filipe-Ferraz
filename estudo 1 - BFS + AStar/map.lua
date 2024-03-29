map = {}


function map.load(path)
  --Inicialização de variáveis
  mapa = 0
  color = {}
  color.st = {0,0,1}
  color.f = {0,51/255,0}
  color.g = {0,204/255,102/255}
  color.w = {65/255,105/255,225/255}
  color.m = {139/255,69/255,19/255}
  color.s = {205/255,133/255,63/255}
  color.v = {205/255,133/255,63/255}
  color.vp1 = {0,255/255,0}
  color.vp2 = {0,0,255/255}
  color.vp3 = {255/255,0,0}
  color.vd = {0,204/255,102/255}
  color.i = {80/255,30/255,2/255}
  color.sd1 = {0,0,0}
  color.sd2 = {0,0,0}
  color.sd3 = {0,0,0}
  color.sdc = {0,0,0}
  color.gl = {0,0,0}
  terrenoG = {}
  terrenoG['st'] = 10 --ponto inicial
  terrenoG['g'] = 10 --grama
	terrenoG['f'] = 100 -- florest
	terrenoG['s'] = 20 --areia
	terrenoG['m'] = 450 --montanha
	terrenoG['w'] = 180 --água
	terrenoG['v'] = 10 --chão (nas cavernas)
	terrenoG['i'] = 11   --parede (nas cavernas)
	terrenoG['sd1'] = 20 --entradas de cavernas
  terrenoG['sd2'] = 20 --entradas de cavernas
  terrenoG['sd3'] = 20 --entradas de cavernas
  terrenoG['sdc'] = 20 --entradas de cavernas
	terrenoG['gl'] = 10 --objetivo final
	terrenoG['vp1'] = 10 --objetivo (nas cavernas)
  terrenoG['vp2'] = 10 --objetivo (nas cavernas)
  terrenoG['vp3'] = 10 --objetivo (nas cavernas)
	terrenoG['vd'] = 10 --saída da caverna
  spawnX=0
  spawnY=0

  levelSize = 42 --42 16
  levelHeight = levelSize
  levelWidth = levelSize
  
  dungeonSize = 28
  dungeonHeight = dungeonSize
  dungeonWidth = dungeonSize
  
  lines = {}
  level = {}
  dungeon = {}
  cost = 0

  for i=1,levelWidth do
    level[i] = {}
  end
  map.goalpoint = {}
  for goalCont=1,4 do
    map.goalpoint[goalCont] = {}
  end

  map.goalpoint[1].x = 7
  map.goalpoint[1].y = 6

  local f = io.open(path.."\\OverworldLogic.txt","r")

  if f == nil then
    print("O arquivo não existe")
    return nil
  end

  i = 0
  for lines in io.lines(path.."\\OverworldLogic.txt") do
    
    local j
    
    i = i + 1
    j = 0
    for k in string.gmatch(lines,"%S+") do
    node = {}
      node.terreno = k
      
      j = j + 1
      node.x = j
      node.y = i
      node.cost = nil
      if (k=='st') then
        spawnX=node.x
        spawnY=node.y
      elseif (k=='sd1') then
        set_goal(node,4)
      elseif (k=='sd2') then
        set_goal(node,3)
      elseif (k=='sd3') then
        set_goal(node,2)
      end

      level[i][j] = node
    end
  end

  f:close()

end

function map.draw()
	if (mapa == 0) then
		for i=1,levelHeight do
			for j=1,levelWidth do
				love.graphics.setColor(color[level[i][j].terreno])
				love.graphics.rectangle("fill",j*17.9,i*17.9,17.9,17.9)
			end
		end
	else
		for i=1,dungeonHeight do
			for j=1,dungeonWidth do
				love.graphics.setColor(color[dungeon[i][j].terreno])
				love.graphics.rectangle("fill",j*17.9,i*17.9,17.9,17.9)
			end
		end
	end
end

function set_goal(node,goalNum)
	map.goalpoint[goalNum].x = node.x
	map.goalpoint[goalNum].y = node.y
	--goalCont = goalCont + 1
end

function load_dungeon(mapa)

	local goal = {}
	dungeon = {}
	
	if (mapa == 1) then
		f = io.open(path.."\\Dungeon1Logic.txt","r")
		
		if f == nil then
			print("O arquivo não existe")
			return nil
		end

		for i=1,dungeonHeight do
			dungeon[i] = {}
		end

		i = 0

		for lines in io.lines(path.."\\Dungeon1Logic.txt") do
      local j
      
			i = i + 1
      j = 0
			for k in string.gmatch(lines,"%S+") do
			node = {}
				node.terreno = k
		
				j = j + 1
				node.x = j
				node.y = i
		
				if (k=='vp1') then
					goal[1] = node
				elseif (k=='vd') then
					goal[2] = node
				end
				dungeon[i][j] = node
			end
		end
	elseif (mapa == 2) then
		f = io.open(path.."\\Dungeon2Logic.txt","r")
		
		if f == nil then
			print("O arquivo não existe")
			return nil
		end

		for i=1,dungeonHeight do
			dungeon[i] = {}
		end

		i = 0

		for lines in io.lines(path.."\\Dungeon2Logic.txt") do
      
      local j
			i = i + 1
			j = 0
			for k in string.gmatch(lines,"%S+") do
			node = {}
				node.terreno = k
		
				j = j + 1
				node.x = j
				node.y = i
		
				if (k=='vp2') then
					goal[1] = node
				elseif (k=='vd') then
					goal[2] = node
				end
				dungeon[i][j] = node
			end
		end
	else
		f = io.open(path.."\\Dungeon3Logic.txt","r")
		if f == nil then
		 print("O arquivo não existe")
		 return nil
		end

		for i=1,dungeonHeight do
			dungeon[i] = {}
		end

		i = 0

		for lines in io.lines(path.."\\Dungeon3Logic.txt") do
      local j
      
			i = i + 1
			j = 0
			for k in string.gmatch(lines,"%S+") do
			node = {}
				node.terreno = k
		
				j = j + 1
				node.x = j
				node.y = i
		
				if (k=='vp3') then
					goal[1] = node
				elseif (k=='vd') then
					goal[2] = node
				end				
				dungeon[i][j] = node
			end
		end
	end
	f:close()

	return goal
end
function cost_update(node)
	if(mapa == 0) then
		cost = cost + terrenoG[level[node.y][node.x].terreno]
	elseif (mapa == 1) then
		cost = cost + terrenoG[dungeon[node.y][node.x].terreno]
	elseif (mapa == 2) then
		cost = cost + terrenoG[dungeon[node.y][node.x].terreno]
	else
		cost = cost + terrenoG[dungeon[node.y][node.x].terreno]
	end
	return cost
end

function terrain_update(bloco,mapa)
	if(mapa == 0) then
		return (level[bloco.y][bloco.x].terreno)
	else
		return (dungeon[bloco.y][bloco.x].terreno)
	end
end
