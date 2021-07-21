player = {}


function player.load()
  --Inicialização de variáveis
  bloco = {}
  bloco.x = spawnX
  bloco.y = spawnY
  bloco.retX = 0
  bloco.retY = 0
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
  sleepTime = 0--.1
	love.timer.sleep(sleepTime)
	if cmd ~= nil then
	end
	
	if cmd == 'right' and bloco.x < limitX then
			
    bloco.x = bloco.x + 1
			
	elseif cmd == 'left' and bloco.x > 1 then
			
		bloco.x = bloco.x - 1
			
	elseif cmd == 'up' and bloco.y > 1 then
			
		bloco.y = bloco.y - 1
			
	elseif cmd == 'down' and bloco.y < limitY then
			
		bloco.y = bloco.y + 1
			
	end
end