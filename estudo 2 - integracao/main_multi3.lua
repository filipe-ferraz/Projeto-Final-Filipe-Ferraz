require 'functions'

function integral(a,b,n,fun)
  local h = (b-a)/n
  local approx = (fun(a) + fun(b))/2.0
  local i0 = 0
  local np = math.floor(n/numThreads)
  for i=1,numThreads,1 do
    if i == numThreads then
      np = n
    else
      np = math.floor(i*(n/numThreads))
    end
    channelPara:push({a,b,np,i0,h})
    i0 = np + 1
  end
  for i=1,numThreads,1 do
    local p = channelRes:demand()
    approx = approx + p
  end
  return h*approx
end

function love.load()
  a=0
  b=10
  numThreads = 8
  n=10000
  tempoMedio = 0
  tempo={}
  ret={}
  thread={}
  channelPara = love.thread.getChannel("Parameter")
  channelRes = love.thread.getChannel("Result")
  fileCount = 0
  for i=1,numThreads,1 do
    thread[i]= love.thread.newThread("thread3.lua")
    thread[i]:start()
  end
end

function love.update()
  tempoMedio = 0
  tempoTotal = love.timer.getTime()
  for i=1,40,1 do
    tempo[i] = love.timer.getTime()
    ret[i] = integral(a,b,n,f1)
    tempo[i] = love.timer.getTime() - tempo[i]
  end
  for i in pairs(tempo) do
    printFile(tempo[i],"tempoM3.txt")
    tempoMedio = tempoMedio + tempo[i]
  end
  tempoTotal = love.timer.getTime() - tempoTotal
  tempoMedio = tempoMedio/(#tempo)
end

function love.draw()
  for i=1,40,1 do
    love.graphics.print("Int(fx(x),x=0..π)="..ret[i].." calculado em: "..tempo[i],0,15*(i-1))
  end
  love.graphics.print("tempo medio: "..tempoMedio,500,love.graphics.getHeight()/2)
  love.graphics.print("FPS: "..love.timer.getFPS( ),love.graphics.getWidth()-50,0)
  love.graphics.print("tempo total: "..tempoTotal,500,love.graphics.getHeight()/2+15)
end