--require "audio"
local gfx = love.graphics

-- https://github.com/kikito/anim8
local anim8 = require 'anim8/anim8'
local spritesheet1, animPlane

debug = true

-- Timers
-- We declare these here so we don't have to edit them multiple places
canShoot = true

canShootTimer = 1;
createEnemyTimerMax = 1	
createEnemyTimer = createEnemyTimerMax
--bulletSpeed = 400
enemySpeed = 150
playerSpeed = 250
kamikazeSpeed = 50
baseBulletSpeed = 250

-- Player Object
player = { x = 250, y = 710, speed = playerSpeed, img = nil }
isAlive = true
score  = 0
shotsFired = 0

-- Image Storage
bulletImg = nil
enemyImg = nil

-- Entity Storage
bullets = {} -- array of current bullets being drawn and updated
enemies = {} -- array of current enemies on screen
isKill = false

playerLevel = 1
isTurningRight = false
isTurningLeft = false

bulletSpeeds = {250, 300, 400, 500, 500} -- FIXME: Cambiar esto por algo decente y que sea dinamico
bulletShootTimer = {0.4, 0.35, 0.30, 0.25, 0.20} -- FIXME: Igual que arriba
-- music
missedEnemies = 0
osName = love.system.getOS()
changedLevel = false

expireAfterFrames = {} -- things that expire

-- sfx


-- Collision detection taken function from http://love2d.org/wiki/BoundingBox.lua
-- Returns true if two boxes overlap, false if they don't
-- x1,y1 are the left-top coords of the first box, while w1,h1 are its width and height
-- x2,y2,w2 & h2 are the same, but for the second box
function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < ((x2+w2)) and
         x2 < ((x1+ w1)) and
         y1 < ((y2+ h2)) and
         y2 < ((y1+ h1))
end

function CheckCollisionEnemy(enemy, x2,y2,w2,h2)
  
  for i, box in ipairs(enemyBoxes[enemy.num]) do
    if CheckCollision(enemy.x+box[1], enemy.y+box[2], box[3], box[4], x2, y2, w2, h2) then
      return true
    end
	end
  
  return false

end

-- Loading
function love.load(arg)
  
  if arg[#arg] == "-debug" then require("mobdebug").start() end
  
--	love.window.setFullscreen(true, "desktop")
	-- love.window.setMode(0,0,{resizable = true,vsync = true}) 
	local joysticks = love.joystick.getJoysticks()
	if (table.getn(joysticks) > 0) then 
		joystick = joysticks[1] -- get first stick 
	end
	

	spritesheet1 = love.graphics.newImage('assets/1945.png')
	local g64 = anim8.newGrid(64,64, 1024,768, 299,101, 2)
	--animation = anim8.newAnimation(g('1-8',1), 0.1)
	animPlane = anim8.newAnimation(g64(1,'1-3'), 0.1)
	animPlane:flipV() -- look down

	player.img = gfx.newImage('assets/player.png')
	player.img_right =  gfx.newImage('assets/player-right.png')
	player.img_left =  gfx.newImage('assets/player-left.png')

	enemyImgs = {gfx.newImage('assets/aircraft01.png'),
				gfx.newImage('assets/aircraft02.png'), 
				gfx.newImage('assets/aircraft03.png'),
				gfx.newImage('assets/aircraft04.png'),
				gfx.newImage('assets/aircraft07.png'),
				gfx.newImage('assets/aircraft08.png')}

  enemyBoxes = {
                { {42,3,26,87}, {4,47,101,30} },
                { {42,5,26,79}, {4,42,103,26} },
                { {43,5,26,80}, {5,42,102,22} },
                { {44,5,21,76}, {5,34,101,22} },
                { {46,4,20,74}, {5,36,101,27} },
                { {38,6,19,67}, {6,37,82,20} }
              }

	bulletImgs = {gfx.newImage('assets/bullet.png'),
				gfx.newImage('assets/bullet_orange.png'),
				gfx.newImage('assets/bullet_purple.png'),
				gfx.newImage('assets/bullet_orange.png'),
				gfx.newImage('assets/bullet_purple.png')}

	backgroundImage = gfx.newImage('assets/background.png')
	backgroundImageIverted = gfx.newImage('assets/background_inverted.png')

	-- sfx
	--bgm = love.audio.play("assets/music.wav", "stream", true) -- stream and loop background music
	gunSound = love.audio.newSource("assets/gun-sound.wav", "static")
	explodeSound = love.audio.newSource("assets/explode.wav", "static")
	explodePlayer = love.audio.newSource("assets/explode.wav", "static")
--	masterCombo = love.audio.newSource("assets/master_combo.mp3", "static")
	comboBreaker = love.audio.newSource("assets/KI_Sounds_Combo_Breaker.mp3", "static")
	--killerCombo = love.audio.newSource("assets/KI_Sounds_Killer_Combo.mp3", "static")
	--ultraCombo = love.audio.newSource("assets/KI_Sounds_Ultra_Combo.mp3", "static")
	showNoMercy = love.audio.newSource("assets/ShowNoMercy.wav", "static")
	
	sfxReady = love.audio.newSource("assets/Ready.mp3", "static")
	sfxGameOver = love.audio.newSource("assets/GameOver.mp3", "static")

	sfxPerfect =  love.audio.newSource("assets/Perfect.mp3", "static")

	sfxCombos = { love.audio.newSource("assets/KI_Sounds_Triple_Combo.mp3", "static"),
					love.audio.newSource("assets/KI_Sounds_Killer_Combo.mp3", "static"),
					love.audio.newSource("assets/master_combo.mp3", "static"),
					love.audio.newSource("assets/KI_Sounds_Ultra_Combo.mp3", "static"),
					love.audio.newSource("assets/KI_Sounds_Brutal_Combo.mp3", "static"),
					love.audio.newSource("assets/ShowNoMercy.wav", "static")}

	music = love.audio.newSource("assets/22.-trailblazer-original-arcade-soundtrack-.mp3") -- if "static" is omitted, LÖVE will stream the file from disk, good for longer music tracks
	music:setLooping(true)
	music:play()

	sfxReady:play()
	
--	font = gfx.newFont(14) -- the number denotes the font size
	gfx.setNewFont("assets/gomarice_no_continue.ttf", 20)
	showTextReady = true
	showNewLevel = true

	psystem = gfx.newParticleSystem(player.img, 32)
	psystem:setParticleLifetime(1, 3) -- Particles live at least 2s and at most 5s.
	psystem:setEmissionRate(5)
	psystem:setSizeVariation(1)
	psystem:setLinearAcceleration(-20, -20, 20, 20) -- Random movement in all directions.
	psystem:setColors(255, 255, 255, 255, 255, 255, 255, 0) -- Fade to transparency.

	--canShootTimer = bulletShootTimer(playerLevel)
end


-- Updating
function love.update(dt)

	screenHeight = gfx:getHeight()
	--psystem:update(dt)
	animPlane:update(dt)

	-- I always start with an easy way to exit the game
	if love.keyboard.isDown('escape') then
		love.event.push('quit')
	end

	-- Time out how far apart our shots can be.
	canShootTimer = canShootTimer - (1 * dt)
	if canShootTimer < 0 then
		canShoot = true
	end

	-- Time out enemy creation
	createEnemyTimer = createEnemyTimer - (1 * dt)
	if createEnemyTimer < 0 then
		createEnemyTimer = (createEnemyTimerMax * 1/playerLevel)

		-- Create an enemy
		randomNumber = math.random(10, gfx.getWidth() - 100)
		randomSpeed = math.random(10, (50 * playerLevel));
		randomImg = math.random(6);
    	kamikaze = math.random() < 0.5

		newEnemy = { x = randomNumber, y = -50, img = enemyImgs[randomImg] , isKamikaze=kamikaze, num=randomImg, speed = enemySpeed + randomSpeed}
		table.insert(enemies, newEnemy)
	end


	-- update the positions of bullets
	for i, bullet in ipairs(bullets) do
		bullet.y = bullet.y - (bullet.speed * dt)

		if bullet.y < 0 then -- remove bullets when they pass off the screen
			table.remove(bullets, i)
		end
	end

	-- update the positions of enemies
	for i, enemy in ipairs(enemies) do
		enemy.y = enemy.y + (enemy.speed * dt)
    
    if enemy.isKamikaze then
      if (enemy.x < player.x) then
        enemy.x = enemy.x + kamikazeSpeed * dt
      else
        enemy.x = enemy.x - kamikazeSpeed * dt
      end
    end

		if enemy.y > screenHeight then -- remove enemies when they pass off the screen
			table.remove(enemies, i)
			missedEnemies = missedEnemies + 1
		end
	end

	-- run our collision detection
	-- Since there will be fewer enemies on screen than bullets we'll loop them first
	-- Also, we need to see if the enemies hit our player
	for i, enemy in ipairs(enemies) do
		for j, bullet in ipairs(bullets) do
			if CheckCollisionEnemy(enemy, bullet.x, bullet.y, bullet.img:getWidth(), bullet.img:getHeight()) then
				table.remove(bullets, j)
				table.remove(enemies, i)
				isKill = true;
				if (explodeSound:isPlaying()) then
					explodeSound:rewind()
				else
					explodeSound:play()
				end
				score = score + 1
				
				-- fixme: sfx combos are supposed to be played when you actually kill N enemies in a row/short period of time 
				
				if (score % 10 == 0) then
					sfxCombos[math.random(6)]:play()
				end

				-- fixme: when do we need to change levels? every N kills?
				if (score % 20 == 0) then 
					sfxPerfect:play()
					if (playerLevel < 5) then -- fixme: solo tenes 5 levels... 
						playerLevel = playerLevel + 1
						showNewLevel = true					
						changedLevel = true;
					end
				end
			end
		end

		if CheckCollision(enemy.x, enemy.y, enemy.img:getWidth(), enemy.img:getHeight(), player.x, player.y, player.img:getWidth(), player.img:getHeight()) 
		and isAlive then
			table.remove(enemies, i)
			isAlive = false
			explodePlayer:play()
			sfxGameOver:play()
		end
	end

	-- use mouse instead of kb
	--player.x = love.mouse.getX() 
	--player.y = love.mouse.getY() 
	
  	--camera:setPosition(love.mouse.getX() * 2, love.mouse.getY() * 2)

	isTurningLeft = false
	isTurningRight= false


	-- check joystick
	if joystick ~= nil then

		if joystick:isGamepadDown("dpleft") then
				if player.x > 0 then -- binds us to the map
					player.x = player.x - (player.speed*dt)
				end
			elseif joystick:isGamepadDown("dpright") then
				if player.x < (gfx.getWidth() - player.img:getWidth()) then
					player.x = player.x + (player.speed*dt)
				end
			end

			if joystick:isGamepadDown("dpup") then
				if player.y > 50 then
					player.y = player.y - (player.speed*dt)
				end
			elseif joystick:isGamepadDown("dpdown") then
				if player.y < (gfx.getHeight() - 55) then
					player.y = player.y + (player.speed*dt)
				end
			end

	end
	
	if love.keyboard.isDown('left','a') then
		isTurningLeft = true
		if player.x > 0 then -- binds us to the map
			player.x = player.x - (player.speed*dt)
		end
	elseif love.keyboard.isDown('right','d') then
		isTurningRight = true
		if player.x < (gfx.getWidth() - player.img:getWidth()) then
			player.x = player.x + (player.speed*dt)
		end
	end

	if love.keyboard.isDown('up', 'w') then
	if player.y > 50 then
		player.y = player.y - (player.speed*dt)
	end
	elseif love.keyboard.isDown('down', 's') then
		if player.y < (gfx.getHeight() - 55) then
			player.y = player.y + (player.speed*dt)
		end
	end

	if love.keyboard.isDown(' ', 'z') then
		player.speed = 500
	else
		player.speed = 250
	end

	if canShoot and ((joystick ~= nil and joystick:isDown(1)) or love.keyboard.isDown(' ', 'rctrl', 'lctrl', 'ctrl','space'))  then
		-- Create some bullets

		bulletSpeed = baseBulletSpeed + (playerLevel * 20)

		newBullet1 = { x = player.x + (player.img:getWidth()/2 - 10), y = player.y, img = bulletImgs[1], speed = bulletSpeed }
		shotsFired = shotsFired + 1
		table.insert(bullets, newBullet1)

		-- fixme: player levels are static (hacks) and need to be 100% dynamic
		if (playerLevel == 2) then
			shotsFired = shotsFired + 1
			newBullet2 = { x = player.x + (player.img:getWidth()/2 ), y = player.y, img = bulletImgs[2], speed = bulletSpeed }
			table.insert(bullets, newBullet2)
		end

		if (playerLevel == 3) then
			newBullet3 = { x = player.x + (player.img:getWidth()/2 - 20), y = player.y, img = bulletImgs[3], speed = bulletSpeed }
			newBullet4 = { x = player.x + (player.img:getWidth()/2 + 10), y = player.y, img = bulletImgs[3], speed = bulletSpeed }
			shotsFired = shotsFired + 1
			shotsFired = shotsFired + 1

			table.insert(bullets, newBullet3)
			table.insert(bullets, newBullet4)
			
		end
		
		if (playerLevel > 3) then
			
			newBullet5 = { x = player.x + (player.img:getWidth()/2 - 30), y = player.y, img = bulletImgs[4], speed = bulletSpeed }
			newBullet6 = { x = player.x + (player.img:getWidth()/2 + 20), y = player.y, img = bulletImgs[4], speed = bulletSpeed }
			shotsFired = shotsFired + 1
			shotsFired = shotsFired + 1

			table.insert(bullets, newBullet5)
			table.insert(bullets, newBullet6)
			
		end

		if (gunSound:isPlaying()) then
			gunSound:rewind()
		else
			gunSound:play()
		end
		canShoot = false
		canShootTimer = bulletShootTimer[playerLevel]
	end

	if not isAlive and love.keyboard.isDown('r') then
		-- remove all our bullets and enemies from screen
		bullets = {}
		enemies = {}

		-- reset timers
		canShootTimer = 1
		createEnemyTimer = createEnemyTimerMax

		-- move player back to default position
		player.x = 250
		player.y = 710

		-- reset our game state
		score = 0
		playerLevel = 1
		showTextReady = true
		showNewLevel = true
		shotsFired = 0
		missedEnemies = 0
		sfxReady:play()
		isAlive = true
	end
end


readyFramesShown = 0
newLevelFramesShown = 0

-- Drawing
function love.draw(dt)

	gfx.draw(backgroundImage, 0,0)

	if showNewLevel then
		gfx.print("LEVEL " .. tostring(playerLevel), gfx:getWidth() / 2 - 40, gfx:getHeight()/2 - 50)
		newLevelFramesShown = newLevelFramesShown + 1
		if newLevelFramesShown >= (3 * 60) then	
			showNewLevel = false
			newLevelFramesShown = 0
		end
	end

	if showTextReady then
		gfx.print("READY!", gfx:getWidth() / 2 - 40, gfx:getHeight()/2)
		readyFramesShown = readyFramesShown + 1
		if readyFramesShown >= (3 * 60) then	
			showTextReady = false
			readyFramesShown = 0
		end
	end

	-- if we killed an enemy blink the background
	if isKill then
		--gfx.draw(backgroundImageIverted, 0,0)
		--gfx.setBackgroundColor(255, 255, 255)
		isKill = false
	else
		--gfx.draw(backgroundImage, 0,0)
		--gfx.setBackgroundColor(0, 0, 0)
	end

	for i, bullet in ipairs(bullets) do
		gfx.draw(bullet.img, bullet.x, bullet.y)
	end

	for i, enemy in ipairs(enemies) do
		animPlane:draw( spritesheet1, enemy.x, enemy.y)
		--gfx.draw(enemy.img, enemy.x, enemy.y)
	
	end

	gfx.setColor(255, 255, 255)
	gfx.print("SCORE: " .. tostring(score), gfx:getWidth() - 100, 10)
	gfx.print("LEVEL: " .. tostring(playerLevel), gfx:getWidth() - 100, 30)
	gfx.print("MISSED: " .. tostring(missedEnemies), gfx:getWidth() - 100, gfx:getHeight() - 30)
	gfx.print("FIRED: " .. tostring(shotsFired), 10, gfx:getHeight() - 30)

--	if changedLevel then
	--	gfx.print("PERFECT!" .. tostring(dt), gfx:getWidth() / 2, gfx:getHeight() / 2)

--	end

	if isAlive then
		if isTurningLeft then
			gfx.draw(player.img_left, player.x, player.y)
		elseif isTurningRight then
			gfx.draw(player.img_right, player.x, player.y)
		else
			gfx.draw(player.img, player.x, player.y)
		end
	else
		gfx.print("GAME OVER",gfx:getWidth()/2-40, gfx:getHeight()/2)
		gfx.print("Press 'R' to restart", gfx:getWidth()/2-80, gfx:getHeight()/2+30)
	end

	gfx.print("AVIONEX", gfx:getWidth()/2-60, 10)

	if debug then
		fps = tostring(love.timer.getFPS())
		gfx.print("FPS: "..fps, 9, 10)

		
	end
end

