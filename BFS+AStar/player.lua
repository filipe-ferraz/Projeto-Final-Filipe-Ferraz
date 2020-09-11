player = {}


function player.load()
  --Inicialização de variáveis
  bloco = {}
  bloco.x = spawnX
  bloco.y = spawnY
  bloco.retX = 0
  bloco.retY = 0
	--player.x = 25*17.9  -- 26 on the map
	--player.y = 28*17.9  -- 29 on the map
  player.x = spawnX*17.9
  player.y = spawnY*17.9
  player.retX = 0
  player.retY = 0
	
	player.link = love.graphics.newImage("8BitLink.png")

end

function player.draw()
	love.graphics.setColor(255,255,255)
	love.graphics.draw(player.link, player.x, player.y)
end

function player.update()
	player.x=17.9*bloco.x
	player.y=17.9*bloco.y
end

function player.move(cmd)
  local limitX
  local limitY
  local sleepTime 
  if outside == true then
    limitX = levelWidth
    limitY = levelHeight
    sleepTime = terrenoG[level[bloco.x][bloco.y].terreno]/100
  else
    limitX = dungeonHeight
    limitY = dungeonWidth
    sleepTime = terrenoG[dungeon[bloco.x][bloco.y].terreno]/100
  end
  sleepTime = .1
	love.timer.sleep(sleepTime)
	if cmd ~= nil then
		--print(cmd)
	end
	
	if cmd == 'right' and bloco.x < limitX then
			
		--player.x = player.x + 17.9
    bloco.x = bloco.x + 1
			
	elseif cmd == 'left' and bloco.x > 1 then
			
		--player.x = player.x - 17.9
		bloco.x = bloco.x - 1
			
	elseif cmd == 'up' and bloco.y > 1 then
			
		--player.y = player.y - 17.9
		bloco.y = bloco.y - 1
			
	elseif cmd == 'down' and bloco.y < limitY then
			
		--player.y = player.y + 17.9
		bloco.y = bloco.y + 1
			
	end
end