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
require 'powerups'
require 'leaderboard'
require 'sounds'
Timer = require 'libs/timer'
require 'ballistics'
lue = require "libs/lue/lue" --require the library
tween = require 'libs/tween/tween'
local moonshine = require 'libs/moonshine'

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

	-- some pixel shaders to give that 80s looooook (stranger things is in da haus)	
	effect = moonshine(moonshine.effects.glow).
							chain(moonshine.effects.scanlines).
							chain(moonshine.effects.crt)
				

	effect.scanlines.opacity = 0.4
	effect.scanlines.width = 1

--	effect.pixelate.size = {2,2}
	--effect.pixelate.feedback = 0.2

	effect.glow.min_luma = 0.3
	effect.glow.strength = 10

	--playerEffect = moonshine(moonshine.effects.scanlines).chain(moonshine.effects.crt)
	
 	effect.crt.distortionFactor = {1.06, 1.06}
	effect.crt.feather = 0.01

	loadLeaderboard()
	
	lue:setColor("my-color", {200, 100, 255})

	local joysticks = love.joystick.getJoysticks()
	if (table.getn(joysticks) > 0) then 
		joystick = joysticks[1] -- get first stick 
	end
	
	Enemy.init();
	Player.init();
  PowerUps.init();
	Sounds.init();

	backgroundImage = gfx.newImage('assets/background.png')
	backgroundImageIverted = gfx.newImage('assets/background_inverted.png')

	Sounds.music:play()
	Sounds.ready:play() -- ready sfx
	
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
  PowerUps.updateTimers(dt);
  
	-- Update positions
	Player.updateBulletPositions(dt)
	Enemy.updatePositions(dt)
	Ballistics.updatePositions(dt)
  PowerUps.updatePositions(dt)

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
					Sounds.combos[math.random(6)]:play()
				end

        Game.enemyKilled(enemy)
				
			end
		end

		if CheckCollisionEnemyPlayer(enemy, Player) and Player.isAlive then
			Enemy.enemyHit(enemy, i)
      if not Player.isShieldOn then
        Player.dead()
        Sounds.gameOver:play()
      end
		end

		if Ballistics.checkCollisionsPlayer(Player) and Player.isAlive then
      if not Player.isShieldOn then
        Player.dead()
        Sounds.gameOver:play()
		  end
    end
    
    PowerUps.checkCollisionsPlayer(Player)
    
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
		Sounds.ready:play()
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

	effect(function()
	
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
		PowerUps.drawAll()

		if (isGamePaused) then
			drawLeaderboard()
		end


	end)

end