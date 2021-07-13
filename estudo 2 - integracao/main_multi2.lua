require 'functions'

function love.load()
  a=0
  b=10
  numThreads=8
  n=10000--math.floor((b-a)/0.0001)
  tempoMedio = 0
  tempo1={}
  tempo2={}
  ret={}
  thread={}
  channelPara = love.thread.getChannel("Parameter")
  channelRes = love.thread.getChannel("Result")
  fileCount = 0
  for i=1,numThreads,1 do
    thread[i]= love.thread.newThread("thread2.lua")
    thread[i]:start()
  end
end

function love.update()
  tempoMedio = 0
  tempoTotal = love.timer.getTime()
  for i=1,40,1 do
    tempo1[i] = love.timer.getTime()
    channelPara:push({a,b,n})
    tempo1[i] = love.timer.getTime() - tempo1[i]
  end
  for i=1,40,1 do
    tempo2[i] = love.timer.getTime()
    ret[i] = channelRes:demand()
    tempo2[i] = love.timer.getTime() - tempo2[i]
  end
  for i in pairs(tempo1) do
    printFile(tempo1[i]+tempo2[i],"tempoM2.txt")
    tempoMedio = tempoMedio + tempo1[i] + tempo2[i]
  end
  tempoTotal = love.timer.getTime() - tempoTotal
  tempoMedio = tempoMedio/(#tempo1)
  --love.timer.sleep(0.5)
end

function love.draw()
  for i=1,40,1 do
    love.graphics.print("Int(fx(x),x=0..π)="..ret[i].." calculado em: "..tempo1[i]+tempo2[i],0,15*(i-1))
  end
  love.graphics.print("tempo medio: "..tempoMedio,500,love.graphics.getHeight()/2)
  love.graphics.print("FPS: "..love.timer.getFPS( ),love.graphics.getWidth()-50,0)
  love.graphics.print("tempo total: "..tempoTotal,500,love.graphics.getHeight()/2+15)
end