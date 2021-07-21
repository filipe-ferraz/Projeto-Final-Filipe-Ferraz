function worldRayCastCallback(fixture, x, y, xn, yn, fraction)
	local hit = {}
	hit.fixture = fixture
	hit.x, hit.y = x, y
	hit.xn, hit.yn = xn, yn
	hit.fraction = fraction

	table.insert(Ray.hitList, hit)

	return 1 -- Continues with ray cast through all shapes.
end

function createStuff()
	-- Cleaning up the previous stuff.
	for i = #Terrain.Stuff, 1, -1 do
		Terrain.Stuff[i].Fixture:destroy()
		Terrain.Stuff[i] = nil
	end

	-- Generates some random shapes.
	for i = 1, 30 do
		local p = {}

		p.x, p.y = math.random(100, 700), math.random(100, 500)
		local shapetype = math.random(3)
		if shapetype == 1 then
			local w, h, r = math.random() * 10 + 40, math.random() * 10 + 40, math.random() * math.pi * 2
			p.Shape = love.physics.newRectangleShape(p.x, p.y, w, h, r)
		elseif shapetype == 2 then
			local a = math.random() * math.pi * 2
			local x2, y2 = p.x + math.cos(a) * (math.random() * 30 + 20), p.y + math.sin(a) * (math.random() * 30 + 20)
			p.Shape = love.physics.newEdgeShape(p.x, p.y, x2, y2)
		else
			local r = math.random() * 40 + 10
			p.Shape = love.physics.newCircleShape(p.x, p.y, r)
		end

		p.Fixture = love.physics.newFixture(Terrain.Body, p.Shape)

		Terrain.Stuff[i] = p
	end
end

function drawMiniMap(s)
  love.graphics.setColor(0.1, 0.1, 0.1)
  love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth()*s, love.graphics.getHeight()*s)
  -- Drawing the terrain.
	love.graphics.setColor(255, 255, 255)
  --love.graphics.polygon("fill", 100, 200, 100, 150, 200)
	for i, v in ipairs(Terrain.Stuff) do
		if v.Shape:getType() == "polygon" then
      local points = {Terrain.Body:getWorldPoints( v.Shape:getPoints() )}
      for i in pairs(points) do
          points[i] = points[i]*s
      end
			love.graphics.polygon("line", points)
		elseif v.Shape:getType() == "edge" then
      local points = {Terrain.Body:getWorldPoints( v.Shape:getPoints() )}
      for i in pairs(points) do
          points[i] = points[i]*s
      end
			love.graphics.line(points)
		else
			local x, y = Terrain.Body:getWorldPoints(v.x, v.y)
			love.graphics.circle("line", x*s, y*s, v.Shape:getRadius()*s)
		end
    love.graphics.polygon("fill", Player.Shape:getPoints())
	end

	-- Drawing the ray.
	love.graphics.setLineWidth(3)
	love.graphics.setColor(255, 255, 255, 100)
	love.graphics.line(Ray.x1, Ray.y1, Ray.x2*s, Ray.y2*s)
	love.graphics.setLineWidth(1)

	-- Drawing the intersection points and normal vectors if there were any.
	for i, hit in ipairs(Ray.hitList) do
		love.graphics.setColor(255, 0, 0)
		love.graphics.print(i, hit.x*s, hit.y*s) -- Prints the hit order besides the point.
		love.graphics.circle("line", hit.x*s, hit.y*s, 3*s)
		love.graphics.setColor(0, 255, 0)
		love.graphics.line(hit.x*s, hit.y*s, (hit.x + hit.xn * 25)*s, (hit.y + hit.yn * 25)*s)
	end
end

function love.keypressed(key)
  if key == 'r' then
    createStuff()
  end
end

function characterMove()
  if love.keyboard.isDown("up") or love.keyboard.isDown("w") then
    Ray.y1 = math.max(Ray.y1-1,0)
    Player.y = Ray.y1
  elseif love.keyboard.isDown("down") or love.keyboard.isDown("s") then
    Ray.y1 = math.min(Ray.y1+1,love.graphics.getHeight())
    --Player.y = Ray.y1
    Player.Body:setX(math.min(Player.Body:getX()+1,love.graphics.getHeight()))
  elseif love.keyboard.isDown("left") or love.keyboard.isDown("a") then
    Ray.x1 = math.max(Ray.x1-1,0)
    Player.x = Ray.x1
  elseif love.keyboard.isDown("right") or love.keyboard.isDown("d") then
    Ray.x1 = math.min(Ray.x1+1,love.graphics.getWidth())
    Player.x = Ray.x1
  end
end

function love.load()
	-- Setting this to 1 to avoid all current scaling bugs.
	love.physics.setMeter(1)

	-- Start out with the same random stuff each start.
	math.randomseed(0xfacef00d)
  
  Scale = 1

	World = love.physics.newWorld()

	Terrain = {}
	Terrain.Body = love.physics.newBody(World, 0, 0, "static")
	Terrain.Stuff = {}
	createStuff()
  
  Player = {}
  Player.x = 0
  Player.y = 0
  Player.Body = love.physics.newBody(World, 0, 0, "dynamic")
  Player.Shape = love.physics.newPolygonShape(Player.Body:getX()+10, Player.Body:getY(), Player.Body:getX(), Player.Body:getY()-5, Player.Body:getX(), Player.Body:getY()+5)
  Player.Fixture = love.physics.newFixture(Player.Body, Player.Shape, 1)

	Ray = {
		x1 = 0,
		y1 = 0,
		x2 = 0,
		y2 = 0,
		hitList = {}
	}
end

function love.update(dt)
	local now = love.timer.getTime()
  
  characterMove()

	World:update(dt)

	-- Clear fixture hit list.
	Ray.hitList = {}
	
	-- Calculate ray position.
	local pos = (math.sin(now/4) + 1) * 0.5
	Ray.x2, Ray.y2 = math.min(math.cos(pos * (math.pi/2)) * 1000, love.graphics.getWidth()), math.min(math.sin(pos * (math.pi/2)) * 1000, love.graphics.getHeight())
	
	-- Cast the ray and populate the hitList table.
	World:rayCast(Ray.x1, Ray.y1, Ray.x2, Ray.y2, worldRayCastCallback)
end

function love.draw()
  drawMiniMap(Scale)
end