require "AStar"
require "map"


channel0 = love.thread.getChannel("geral")
channelEnd = love.thread.getChannel("fim")

data = {}

data = channel0:pop()
--print(data[1].x,data[1].y, data[3])

dungeon_goal = load_dungeon(data[3])

outside = data[4]

map.load()

--channel = love.thread.getChannel(index)

ret = Astar(data[1],data[2])

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

if ret ~= 0 then
  ret = Reconstruct_path(ret)
  channelEnd:push(ret)
end