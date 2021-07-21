require 'functions'

channelPara = love.thread.getChannel("Parameter")
channelRes = love.thread.getChannel("Result")

while true do
  data = channelPara:pop()
  if data then
    local a = data[1]
    local b = data[2]
    local n = data[3]
    local h = (b-a)/n
    local approx = (f1(a) + f1(b))/2.0
    for i=1,n-1,1 do
      local xi = a + i*h
      approx = approx + f1(xi)
    end
    channelRes:push(h*approx)
  end
end