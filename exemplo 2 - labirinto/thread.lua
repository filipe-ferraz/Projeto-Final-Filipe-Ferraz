function oposto(dir)
  if dir == 1 then
    return 3
  elseif dir == 2 then
    return 4
  elseif dir == 3 then
    return 1
  elseif dir == 4 then
    return 2
  else
    return 0
  end
end

function shuffle(list)
	for i = #list, 2, -1 do
		local j = math.random(i)
		list[i], list[j] = list[j], list[i]
	end
end

function caminhoTotal(xc, yc, passo, caminho)
  local i = {1,2,3,4}
  shuffle(i)
  if yc == 1 and xc == nx - 1 then
    table.insert(caminho, 0)
    return caminho
  end
  for j=1,4 do
    if i[j] ~= oposto(passo) then
      local xn = math.floor(xc - math.cos(i[j]*math.pi/2))
      local yn = math.floor(yc - math.cos((i[j]-1)*math.pi/2))
      if M[yn][xn] then
        caminho = caminhoTotal(xn, yn, i[j], caminho)
        if #caminho ~= 0 then
          table.insert(caminho,i[j])
          return caminho
        end
      end
    end
  end
  return {}
end

message = {}
caminho = {}
canal1 = love.thread.getChannel("canal1")
canal2 = love.thread.getChannel("canal2")
canal3 = love.thread.getChannel("canal3")
math.randomseed(canal3:pop())
while #message == 0 do
  message = canal1:peek()
end
M=message[1]
nx = message[6]
ny = message[7]
caminho = caminhoTotal(message[2],message[3],message[4],message[5])
if #caminho ~= {} then
  canal2:push(caminho)
end