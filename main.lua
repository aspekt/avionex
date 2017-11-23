--require "audio"
gfx = love.graphics

-- https://github.com/kikito/anim8
anim8 = require 'libs/anim8/anim8'
socket = require("socket")
http = require("socket.http")
json = require "libs/json"

require 'game'
require 'hud'
require 'enemies'
require 'player'
require 'utils'
require 'leaderboard'
Timer = require 'libs/timer'
require 'ballistics'
lue = require "libs/lue/lue" --require the library
tween = require 'libs/tween/tween'

debug = true

FPS = 0
score  = 0
shotsFired = 0
isKill = false

osName = love.system.getOS()
explosions = {}
playerInitials = "DIE"          -- hay que pedir esto por teclado una vez al menos y guardarlo

-- Loading
function love.load(arg)
  
 	if arg[#arg] == "-debug" then require("mobdebug").start() end
	love.math.setRandomSeed(love.timer.getTime())

	loadLeaderboard()
	
	lue:setColor("my-color", {200, 100, 255})

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
	explodeSound = love.audio.newSource("assets/explodemini.wav", "static")
	explodePlayer = love.audio.newSource("assets/explode.wav", "static")
  --masterCombo = love.audio.newSource("assets/master_combo.mp3", "static")
	comboBreaker = love.audio.newSource("assets/KI_Sounds_Combo_Breaker.mp3", "static")
	--killerCombo = love.audio.newSource("assets/KI_Sounds_Killer_Combo.mp3", "static")
	--ultraCombo = love.audio.newSource("assets/KI_Sounds_Ultra_Combo.mp3", "static")
	showNoMercy = love.audio.newSource("assets/ShowNoMercy.wav", "static")

	sfxReady = love.audio.newSource("assets/Ready.mp3", "static")
	sfxGameOver = love.audio.newSource("assets/GameOver.mp3", "static")
	sfxShieldUp = love.audio.newSource("assets/shield.wav", "static")
	sfxShieldUp:setVolume(1)
	
	sfxPerfect =  love.audio.newSource("assets/Perfect.mp3", "static")
	sfxFinishHim = love.audio.newSource("assets/mk1-finishhim.mp3", "static")

	sfxCombos = { love.audio.newSource("assets/KI_Sounds_Triple_Combo.mp3", "static"),
                love.audio.newSource("assets/KI_Sounds_Killer_Combo.mp3", "static"),
                love.audio.newSource("assets/master_combo.mp3", "static"),
                love.audio.newSource("assets/KI_Sounds_Ultra_Combo.mp3", "static"),
                love.audio.newSource("assets/KI_Sounds_Brutal_Combo.mp3", "static"),
                love.audio.newSource("assets/ShowNoMercy.wav", "static")}
	sfxBlast = love.audio.newSource("assets/blast.wav", "static")
	sfxThreeShotDown = love.audio.newSource("assets/3shotsdown.wav", "static")

	music = love.audio.newSource("assets/22.-trailblazer-original-arcade-soundtrack-.mp3") -- if "static" is omitted, LÖVE will stream the file from disk, good for longer music tracks
	music:setLooping(true)
	music:setVolume(0.7) -- so player can hear the sfx at 100% volume
	music:play()

	sfxReady:play() -- ready sfx
	
  HUD.init()
  
end

-- Updating

function love.keypressed(key)
	if key == "p" then
		isGamePaused = not isGamePaused
	end
 end

function love.update(dt)

	if (isGamePaused) then return end

	 --lue:update(dt)
	Timer.update(dt)
	screenHeight = gfx:getHeight()
 	screenWidth = gfx:getWidth()

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
				if (score % 20 == 0) then
					sfxCombos[math.random(6)]:play()
				end

        Game.enemyKilled(enemy)
				
			end
		end

		if CheckCollisionEnemyPlayer(enemy, Player) and Player.isAlive then
			Enemy.enemyHit(enemy, i)
      if not Player.isShieldOn then
        Player.dead()
        sfxGameOver:play()
      end
		end

		if Ballistics.checkCollisionsPlayer(Player) and Player.isAlive then
      if not Player.isShieldOn then
        Player.dead()
        sfxGameOver:play()
		  end
    end
	end

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
    
    HUD.init()
    
	end

	-- check for super speed boost
	currentBulletSpeed = baseBulletSpeed
	if (joystick ~= nil and joystick:isDown(3)) or love.keyboard.isDown("lshift") then
		Player.speed = Player.speed * 2 -- double speed
		currentBulletSpeed = baseBulletSpeed * 2
	end

	HUD.update(dt)

end


readyFramesShown = 0
newLevelFramesShown = 0

-- Drawing
function love.draw(dt)

	FPS = love.timer.getFPS()
	
	gfx.draw(backgroundImage, (250-Player.x)/50,(600-Player.y)/50)

	HUD.draw(dt)

	-- draw explosions particle systems
	for i = table.getn(explosions), 1, -1 do
		local explosion = explosions[i]
		gfx.draw(explosion, 0, 0)
	end

	Player.drawAll()
	Enemy.drawAll()
	Ballistics.drawAll()

	if (isGamePaused) then
		drawLeaderboard()
	end

end