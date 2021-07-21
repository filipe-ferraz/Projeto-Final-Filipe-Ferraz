require 'functions'

channelPara = love.thread.getChannel("Parameter")
channelRes = love.thread.getChannel("Result")

while true do
  data = channelPara:pop()
  if data then
    local a = data[1]
    local b = data[2]
    local n = data[3]
    local i0 = data[4]
    local h = data[5]
    local approx = 0
    for i=i0,n,1 do
      local xi = a + i*h
      approx = approx + f1(xi)
    end
    channelRes:push(approx)
  end
end