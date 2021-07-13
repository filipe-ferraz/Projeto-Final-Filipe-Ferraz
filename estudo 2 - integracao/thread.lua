require 'functions'

channelPara = love.thread.getChannel("Parameter")
channelRes = love.thread.getChannel("Result")

while true do
  data = channelPara:pop()
  if data then
    local xi = data
    --local fun = data[2]
    channelRes:push(f1(xi))
  end
end