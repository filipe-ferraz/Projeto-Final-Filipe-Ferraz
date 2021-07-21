function Astar(start,goal,closedList)
	local current = {}
	current.x = start.x
	current.y = start.y
	current.father = nil
	current.cost = 0
	current.totalcost = CalcH(start,goal)
	current.h = CalcH(start,goal)
	
	local openList = {}
	
	table.insert(openList,current)
	
	while #openList > 0 do
		current = openList[1]
		
		if (current.x == goal.x and current.y == goal.y) then
			return current
		end
		
		local neighbors = neighbors_nodes(current)
		
		for _,neighbor in pairs(neighbors) do
      if neighbor ~= nil then
        if (not_in(closedList,neighbor) and valid(neighbor)) then
          neighbor.cost = terrenoG[level[neighbor.y][neighbor.x].terreno]
          neighbor.h = CalcH(neighbor,goal)
          neighbor.father = current
          neighbor.totalcost = 0
          
          local aux = neighbor.father
          while (aux ~= nil) do
            neighbor.totalcost = aux.cost + neighbor.totalcost
            aux = aux.father
          end
          
          neighbor.totalcost = neighbor.totalcost + neighbor.cost + neighbor.h
          
    
          if not_in(openList, neighbor) then
            table.insert(openList,neighbor)
          end
        end	
      end
		end
		remove(openList,current)
		table.insert(closedList,current)
		
		table.sort(openList,function(a,b) return a.totalcost < b.totalcost end)
	end
	-- no possible path
	return 0
end

--Calcula Heurística (distância entre euclidiana entre o ponto corrente e o objetivo)
function CalcH(cur,goal)
	local x = math.abs(goal.x - cur.x)
	local y = math.abs(goal.y - cur.y)	
  return math.sqrt(x^2 + y^2)
end

function neighbors_nodes(current)
	local neighbors = {}
	local neighborNodeL = {}
	local neighborNodeR = {}
	local neighborNodeU = {}
	local neighborNodeD = {}
  local size
  if (outside == true) then
    size=levelSize
  else
    size=dungeonSize
  end

	if(current.x > 1) then
		neighborNodeL.x = current.x-1
		neighborNodeL.y = current.y
		if outside == true then
			neighborNodeL.terreno = level[neighborNodeL.y][neighborNodeL.x].terreno
		else
			neighborNodeL.terreno = dungeon[neighborNodeL.y][neighborNodeL.x].terreno
		end
		table.insert(neighbors,neighborNodeL)
	end
	
	if(current.x < size) then
		neighborNodeR.x = current.x+1
		neighborNodeR.y = current.y
		if outside == true then
			neighborNodeR.terreno = level[neighborNodeR.y][neighborNodeR.x].terreno
		else
			neighborNodeR.terreno = dungeon[neighborNodeR.y][neighborNodeR.x].terreno
		end
		table.insert(neighbors,neighborNodeR)
	end
	
	if(current.y > 1) then
		neighborNodeU.x = current.x
		neighborNodeU.y = current.y-1
		if outside == true then
			neighborNodeU.terreno = level[neighborNodeU.y][neighborNodeU.x].terreno
		else
			neighborNodeU.terreno = dungeon[neighborNodeU.y][neighborNodeU.x].terreno
		end
		table.insert(neighbors,neighborNodeU)
	end
	
	if(current.y < size) then
		neighborNodeD.x = current.x
		neighborNodeD.y = current.y+1
		if outside == true then
			neighborNodeD.terreno = level[neighborNodeD.y][neighborNodeD.x].terreno
		else
			neighborNodeD.terreno = dungeon[neighborNodeD.y][neighborNodeD.x].terreno
		end
		table.insert(neighbors,neighborNodeD)
	end

	return neighbors
end

function contains (table_z,node)
	local t
	for t=1,#table_z do
		if table_z[t].x == node.x and table_z[t].y == node.y then
			return true
		end
	end
	return false
end

function remove(table_x,node)
	for i,n in pairs(table_x) do
		if n == node then
			table_x[i] = table_x[#table_x]
			table_x[#table_x] = nil
		end
	end
end

function not_in(table_x,node)
	for _,n in pairs(table_x) do
		if (n.x == node.x) and (n.y == node.y) then
			return false
		end
	end
	return true
end

function valid(neighbor)
	if (neighbor.terreno == 'i' ) then
		return false
	end
	
	if(mapa == 0) then
		if(neighbor.x > 0 and neighbor.x < 43) and (neighbor.y > 0 and neighbor.y < 43)then
			return true
		end
	elseif (mapa == 1) or (mapa == 2) or (mapa == 3) then
		if(neighbor.x > 0 and neighbor.x < 29) and (neighbor.y > 0 and neighbor.y < 29) then
			return true
		end
	else
		return false
	end
end