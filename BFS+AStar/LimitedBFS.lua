function LimitedBFS(start,goal,depth)
	local current = {}
	current.x = start.x
	current.y = start.y
	current.father = nil
  current.depth = 0
	current.cost = 0
	current.totalcost = 0
	--current.h = CalcH(start,goal)
	
	local openList1 = {}
	local closedList1 = {}
	
	table.insert(openList1,current)
	
	while #openList1 > 0 do
		current = openList1[1]
    if current.depth >= depth then
      return openList1, closedList1, false
    end
		
		if (current.x == goal.x and current.y == goal.y) then
			return openList1, ClosedList1, true
		end
		
		local neighbors = neighbors_nodes(current)
		
		for _,neighbor in pairs(neighbors) do
      if neighbor ~= nil then
        if (not_in(closedList1,neighbor) and not_in(openList1,neighbor) and valid(neighbor)) then
          neighbor.cost = terrenoG[level[neighbor.y][neighbor.x].terreno]
          --neighbor.h = CalcH(neighbor,goal)
          neighbor.father = current
          neighbor.depth = current.depth+1
          neighbor.totalcost = 0
          
          local aux = neighbor.father
          while (aux ~= nil) do
            neighbor.totalcost = aux.cost + neighbor.totalcost
            aux = aux.father
          end
          
          neighbor.totalcost = neighbor.totalcost + neighbor.cost --+ neighbor.h
          table.insert(openList1,neighbor)
        end	
      end
		end
		remove(openList1,current)
		table.insert(closedList1,current)
		
		table.sort(openList1,function(a,b) return a.depth < b.depth end)
	end
	-- no possible path
	return openList1, closedList1, false
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
	reverse_path(path)
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
	create_path_cmds(final)
end

--Calcula Heurística (distância entre euclidiana entre o ponto corrente e o objetivo)
function CalcH(cur,goal)
	local x = math.abs(goal.x - cur.x)
	local y = math.abs(goal.y - cur.y)	
	--return x + y
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