player = {}


function player.load()
  --Inicialização de variáveis
  bloco = {}
  bloco.x = 25
  bloco.y = 28
  bloco.retX = 0
  bloco.retY = 0
	player.x = 25*17.9  -- 26 on the map
	player.y = 28*17.9  -- 29 on the map
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
	love.timer.sleep(.1)
	if cmd ~= nil then
		--print(cmd)
	end
	
	if cmd == 'right' then
			
		--player.x = player.x + 17.9
    bloco.x = bloco.x + 1
			
	elseif cmd == 'left' then
			
		--player.x = player.x - 17.9
		bloco.x = bloco.x - 1
			
	elseif cmd == 'up' then
			
		--player.y = player.y - 17.9
		bloco.y = bloco.y - 1
			
	elseif cmd == 'down' then
			
		--player.y = player.y + 17.9
		bloco.y = bloco.y + 1
			
	end
end