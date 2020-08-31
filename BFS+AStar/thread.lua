require "AStar"
require "map"


channel0 = love.thread.getChannel("geral")
channelEnd = love.thread.getChannel("fim")

data = {}

data = channel0:pop()

dungeon_goal = load_dungeon(data[3])

outside = data[4]

map.load()
dungeon = data[6]

--channel = love.thread.getChannel(index)

ret = Astar(data[1],data[2],data[7])

if ret ~= 0 then
  --ret = Reconstruct_path(ret)
  channelEnd:push(ret)
end