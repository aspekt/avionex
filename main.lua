--require "audio"
gfx = love.graphics

-- https://github.com/kikito/anim8
anim8 = require 'anim8/anim8'
require 'ballistics'
require 'enemies'
require 'player'
require 'utils'

debug = true

-- Timers
-- We declare these here so we don't have to edit them multiple place
createEnemyTimerMax = 1	

--bulletSpeed = 400
enemySpeed = 150
playerSpeed = 250
kamikazeSpeed = 50
baseBulletSpeed = 250

-- Player Object
Player.x = 250; Player.y = 710; Player.speed = playerSpeed

score  = 0
shotsFired = 0

-- Entity Storage
isKill = false

playerLevel = 1

bulletSpeeds = {250, 300, 400, 500, 500} -- FIXME: Cambiar esto por algo decente y que sea dinamico
bulletShootTimer = {0.4, 0.35, 0.30, 0.25, 0.20} -- FIXME: Igual que arriba

-- music
missedEnemies = 0
osName = love.system.getOS()
changedLevel = false

expireAfterFrames = {} -- things that expire

explosions = {}

-- Loading
function love.load(arg)
  
  if arg[#arg] == "-debug" then require("mobdebug").start() end
  
  -- love.window.setFullscreen(true, "desktop")
	-- love.window.setMode(0,0,{resizable = true,vsync = true}) 
	local joysticks = love.joystick.getJoysticks()
	if (table.getn(joysticks) > 0) then 
		joystick = joysticks[1] -- get first stick 
	end
	
  -- Initialize all enemy stuff
  Enemy.init();
	
  Player.init();
  
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

	psystem = gfx.newParticleSystem(Player.img, 32)
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
	updateExplosions(dt)

	-- I always start with an easy way to exit the game
	if love.keyboard.isDown('escape') then
		love.event.push('quit')
	end

  -- First update timers
	Player.updateTimers(dt)
  Enemy.updateTimers(dt)
  
  -- Update positions
  Player.updateBulletPositions(dt)
  Enemy.updatePositions(dt)
  Ballistics.updatePositions(dt)

	-- run our collision detection
	-- Since there will be fewer enemies on screen than bullets we'll loop them first
	-- Also, we need to see if the enemies hit our player
	for i, enemy in ipairs(Enemy.enemies) do
		for j, bullet in ipairs(Player.bullets) do
			if CheckCollisionEnemyBullet(enemy, bullet) then
        
        Player.bulletHit(j)
        enemyKilled = Enemy.enemyHit(enemy, i)
				
				score = score + 1
				
				-- fixme: sfx combos are supposed to be played when you actually kill N enemies in a row/short period of time 
				if (score % 10 == 0) then
					sfxCombos[math.random(6)]:play()
				end

				-- if boss killed, go up level
        if enemy.isBoss and enemyKilled then
          if (playerLevel < 5) then -- fixme: solo tenes 5 levels... 
						playerLevel = playerLevel + 1
						showNewLevel = true					
						changedLevel = true;
					end
          
				else
          -- after 20 hits, spawn boss
          if Enemy.enemiesKilled % 20 == 0 then 
            sfxPerfect:play()
          
            if not Enemy.bossAlive then
              Enemy.spawnBoss()
            end
          end
          
				end
			end
		end
    
		if CheckCollisionEnemyPlayer(enemy, Player) and Player.isAlive then
			Enemy.enemyHit(enemy, i)
      Player.dead()
			sfxGameOver:play()
		end
	end
  
  if Ballistics.checkCollisionsPlayer(Player) and Player.isAlive then
    Player.dead()
		sfxGameOver:play()
  end

	-- use mouse instead of kb
	--player.x = love.mouse.getX() 
	--player.y = love.mouse.getY() 
	
  --camera:setPosition(love.mouse.getX() * 2, love.mouse.getY() * 2)

  Player.updateMove(dt)
  Player.updateShot(dt)
  
	if not Player.isAlive and love.keyboard.isDown('r') then
		-- Reset players and enemies
		Player.reset()
    Enemy.reset()
		
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

	gfx.draw(backgroundImage, (250-Player.x)/50,(600-Player.y)/50)

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

	-- draw explosions particle systems
	for i = table.getn(explosions), 1, -1 do
		local explosion = explosions[i]
		gfx.draw(explosion, 0, 0)
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

  Player.drawAll()

  Enemy.drawAll()
  
  Ballistics.drawAll()

	gfx.setColor(255, 255, 255)
	gfx.print("SCORE: " .. tostring(score), gfx:getWidth() - 100, 10)
	gfx.print("LEVEL: " .. tostring(playerLevel), gfx:getWidth() - 100, 30)
	gfx.print("MISSED: " .. tostring(missedEnemies), gfx:getWidth() - 100, gfx:getHeight() - 30)
	gfx.print("FIRED: " .. tostring(shotsFired), 10, gfx:getHeight() - 30)


	if not Player.isAlive then
		gfx.print("GAME OVER",gfx:getWidth()/2-40, gfx:getHeight()/2)
		gfx.print("Press 'R' to restart", gfx:getWidth()/2-80, gfx:getHeight()/2+30)
	end

	gfx.print("AVIONEX", gfx:getWidth()/2-60, 10)

	if debug then
		fps = tostring(love.timer.getFPS())
		gfx.print("FPS: "..fps, 9, 10)
	end
end

