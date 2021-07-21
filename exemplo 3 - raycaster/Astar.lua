function Astar(startX, startY, goalX, goalY, dir)
	local current = {}
  local goal = {}
	current.x = startY
	current.y = startX
  goal.x = goalY
  goal.y = goalX
	current.father = nil
	current.cost = 0
	current.totalcost = CalcH(current,goal)
	current.h = CalcH(current,goal)
  current.dirX = 0
  current.dirY = 0
	
	local openList = {}
	local closedList = {}
	
	table.insert(openList,current)
	
	while #openList > 0 do
		current = openList[1]
		
		if (current.x == goal.x and current.y == goal.y) then
			--Reconstruct_path(current)
			return current
		end
		
		local neighbors = neighbors_nodes(current)
		
		for _,neighbor in pairs(neighbors) do
      if neighbor ~= nil then
        if (not_in(closedList,neighbor) and valid(neighbor)) then
          print(current.x, current.y, neighbor.x, neighbor.y, not_in(closedList,neighbor), valid(neighbor))
          neighbor.cost = 1--terrenoG[level[neighbor.y][neighbor.x].terreno]
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
	return 0--{}
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

	if(current.x > 1) then
		neighborNodeL.x = current.x-1
		neighborNodeL.y = current.y
    neighborNodeL.dirX = -1
    neighborNodeL.dirY = 0
		neighborNodeL.terreno = worldMap[neighborNodeL.y][neighborNodeL.x]
		table.insert(neighbors,neighborNodeL)
	end
	
	if(current.x < my) then
		neighborNodeR.x = current.x+1
		neighborNodeR.y = current.y
    neighborNodeR.dirX = 1
    neighborNodeR.dirY = 0
    neighborNodeR.terreno = worldMap[neighborNodeR.y][neighborNodeR.x]
		table.insert(neighbors,neighborNodeR)
	end
	
	if(current.y > 1) then
		neighborNodeU.x = current.x
		neighborNodeU.y = current.y-1
    neighborNodeU.dirX = 0
    neighborNodeU.dirY = -1
		neighborNodeU.terreno = worldMap[neighborNodeU.y][neighborNodeU.x]
		table.insert(neighbors,neighborNodeU)
	end
	
	if(current.y < mx) then
		neighborNodeD.x = current.x
		neighborNodeD.y = current.y+1
    neighborNodeD.dirX = 0
    neighborNodeD.dirY = 1
		neighborNodeD.terreno = worldMap[neighborNodeD.y][neighborNodeD.x]
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
	if (neighbor.terreno > 0 ) and (neighbor.x > 0 and neighbor.x <= mx) and (neighbor.y > 0 and neighbor.y <= my) then
		return false
	else
    return true
	end
end