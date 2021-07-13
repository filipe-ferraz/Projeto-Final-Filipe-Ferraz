local sleep = 0.3 --tempo de sleep em segundos

function atualizaCoordenadas (x, y, dir)
  local rand = math.random(20) --1=baixo, 2=direita, 3= cima, 4= esquerda 5+=repete direção anterior
  local mult = sleep*60 --o número de frames do socket.sleep(), simulando a passagem de tempo
  if dir == 0 then rand = rand%4+1 end -- precisa de uma direção inicial caso ela seja 0
  if rand > 4 then --input não muda com frequência, de acordo com valor máximo de math.random
    rand = dir
  end
  return (x + mult*math.sin((rand-1)*math.pi/2))%800, (y + mult*math.cos((rand-1)*math.pi/2))%600, rand
end

-- load namespace
local socket = require("socket")
-- create a TCP socket and bind it to the local host, at any port
local server = assert(socket.bind("*", 0))
-- find out which port the OS chose for us
local ip, port = server:getsockname()
-- print a message informing what's up
local f = io.open("port.txt","w+")
f:write(port)
io.close(f)
print("Abra o programa cliente")
-- loop forever waiting for clients
-- wait for a connection from any client
while 1 do
  local client = server:accept()
  local cpuX, cpuY, dir = 300, 400, 0
  print("Conectado com cliente em "..os.date())
  while 1 do
    -- make sure we don't block waiting for this client's line
    --client:settimeout(10)
    -- receive the line
    local line, err = client:receive()
    -- if there was no error, send it back to the client
    if not err then
      if line == "quitCode" then
        -- done with client, close the object
        client:close()
        print("Disconectado com cliente em "..os.date())
        break
      end
      print(line)
      cpuX, cpuY, dir = atualizaCoordenadas(cpuX, cpuY, dir)
      socket.sleep(sleep)
      client:send(line .. "," .. cpuX .. "," .. cpuY .. "," .. dir .. "\n")
    end
  end
end