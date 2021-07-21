require 'functions'

function integral(a,b,n,fun)
  local h = (b-a)/n
  local approx = (fun(a) + fun(b))/2.0
  for i=1,n-1,1 do
    local xi = a + i*h
    approx = approx + fun(xi)
  end
  return h*approx
end

function love.load()
  a=0
  b=10
  n=10000
  tempoMedio = 0
  tempoTotal = 0
  tempo={}
  ret={}
  fileCount = 0
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
    printFile(tempo[i],"tempoST.txt")
    tempoMedio = tempoMedio + tempo[i]
  end
  tempoTotal = love.timer.getTime() - tempoTotal
  tempoMedio = tempoMedio/(#tempo)
  love.timer.sleep(0.5)
end

function love.draw()
  for i=1,40,1 do
    love.graphics.print("Int(fx(x),x=0..π)="..ret[i].." calculado em: "..tempo[i],0,15*(i-1))
  end
  
  love.graphics.print("FPS: "..love.timer.getFPS( ),love.graphics.getWidth()-50,0)
  love.graphics.print("tempo medio: "..tempoMedio,500,love.graphics.getHeight()/2)
  love.graphics.print("tempo total: "..tempoTotal,500,love.graphics.getHeight()/2+15)
end