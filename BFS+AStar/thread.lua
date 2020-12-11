require "AStar"
--require "map"
require "love.timer"


channel0 = love.thread.getChannel("geral")
channelMap = love.thread.getChannel("mapa")
channelEnd = love.thread.getChannel("fim")

dataMap = {}
data0 = {}
data0 = channel0:pop()
dataMap = channelMap:peek()

outside = dataMap[2]
dungeon = dataMap[3]
level = dataMap[5]
levelSize = dataMap[6]
dungeonSize = dataMap[6]
terrenoG = dataMap[7]
mapa = dataMap[8]

--channel = love.thread.getChannel(index)
tempoAStar = love.timer.getTime()
ret = Astar(data0[1],dataMap[1],dataMap[4])
tempoAStar = love.timer.getTime() - tempoAStar

if ret ~= 0 then
  --ret = Reconstruct_path(ret)
  channelEnd:push({ret,data0[2],tempoAStar})
end