--require "audio"
gfx = love.graphics

-- https://github.com/kikito/anim8
anim8 = require 'libs/anim8/anim8'
socket = require("socket")
http = require("socket.http")
wapi = require "libs/webapi"
json = require "libs/json"
object = require("libs/object")
splashy = require("libs/splashy/splashy")

require 'boss'
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

joystick = nil
isShowingSplash = true

-- Loading
function love.load(arg)
  
 	if arg[#arg] == "-debug" then require("mobdebug").start() end
	math.randomseed(os.time())

	splashy.addSplash(love.graphics.newImage("assets/splash1.png")) -- Adds splash images.	
	splashy.onComplete(function() print("Splash end.")
																isShowingSplash = false
																gameStart()
															 end) -- Runs the argument once all splashes are done.


	local joysticks = love.joystick.getJoysticks()
	if (table.getn(joysticks) > 0) then 
		joystick = joysticks[1] -- get first stick 
	end

  if (useEffect) then
		-- some pixel shaders to give that 80s looooook (stranger things is in da haus)	
				
		local w = gfx:getWidth()
		local h = gfx:getHeight()

		speedEffect =  moonshine(moonshine.effects.godsray).
										chain(moonshine.effects.scanlines)

		speedEffect.scanlines.opacity = 0.5
		speedEffect.scanlines.width = 1

		speedEffect.godsray.light_x = 0.5
		speedEffect.godsray.light_y = 0
		
		speedEffect.godsray.exposure = 0.5
		speedEffect.godsray.decay = 0.9

    normalEffect = moonshine(moonshine.effects.glow).
              		chain(moonshine.effects.scanlines)
               --chain(moonshine.effects.crt)
					
								
		normalEffect.scanlines.opacity = 0.5
		normalEffect.scanlines.width = 1

    normalEffect.glow.min_luma = 0.3
		normalEffect.glow.strength = 10
		
  --	effect.pixelate.size = {2,2}
    --effect.pixelate.feedback = 0.2


    --playerEffect = moonshine(moonshine.effects.scanlines).chain(moonshine.effects.crt)
    
    --effect.crt.distortionFactor = {1.06, 1.06}
    --effect.crt.feather = 0.01
	end
	
	loadLeaderboard()	
	lue:setColor("my-color", {200, 100, 255})
	
end

local back_coord

function gameStart()

	Enemy.init()
	Player.init()
  PowerUps.init()
	Sounds.init()
  Game.startNewGame()

	--backgroundImage = gfx.newImage('assets/tileable-classic-nebula-space-patterns-wide.jpeg')
	--backgroundImageIverted = gfx.newImage('assets/background_inverted.png')
  back_coord = {x1=0, y1=0, x2=0, y2=-1022}
  backgroundImage1 = gfx.newImage('assets/background1.jpg')
  backgroundImage2 = gfx.newImage('assets/background2.jpg')

	Sounds.music:play()
	Sounds.ready:play() -- ready sfx
	
	HUD.init()

end


function love.keypressed( key, scancode, isrepeat)
	if key == "escape" then
		 love.event.quit()
	elseif key == "n" then
		Sounds.skipToNextMusicTrack()
	elseif key == "p" then
		isGamePaused = not isGamePaused
	elseif key == "e" then
		useEffect = not useEffect
	end

end

-- UPDATING
function love.update(dt)

  wapi.update()
	
	splashy.update(dt) -- Updates the fading of the splash images.
	if (isShowingSplash) then return end
	
	if (isGamePaused) then return end

	if (Player.superSpeed) then
		backgroundSpeed = 1
	else
		backgroundSpeed = 0.5
	end

  -- Update Background Images 
  back_coord.y1 = back_coord.y1 + backgroundSpeed
  back_coord.y2 = back_coord.y2 + backgroundSpeed
  if (back_coord.y2 > 1023) then
    back_coord.y2 = -1022  
  end
  if (back_coord.y1 > 1023) then
    back_coord.y1 = -1022  
  end
  
	 --lue:update(dt)
	Timer.update(dt)
	screenHeight = gfx:getHeight()
 	screenWidth = gfx:getWidth()

	--psystem:update(dt)
	animPlane:update(dt)
	updateExplosions(dt)

  -- First update timers
  Game.updateTimers(dt)  --Enemy and level creation is moved here
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
        if enemyKilled then
          Game.enemyKilled(enemy)
				end
			end
		end

		if CheckCollisionEnemyPlayer(enemy, Player) and Player.isAlive then
			Enemy.enemyHit(enemy, i)
      if not Player.isShieldOn or enemy.enemyType==4 then
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
	
	-- is player dead?
	if not Player.isAlive then
		if Player.canContinue() then
			if love.keyboard.isDown('return') or (joystick ~= nil and joystick:isGamepadDown('start')) then
				Player.continue()
				HUD.showLevel(playerLevel)
				Sounds.ready:play()
			end
		else
			if love.keyboard.isDown('return') or (joystick ~= nil and joystick:isGamepadDown('start')) then
				-- Reset players and enemies
				Player.reset()
				Enemy.reset()
				
				-- reset our game state
				Game.startNewGame()
				Sounds.ready:play()
				HUD.init()
			end
		end
	end

	HUD.update(dt)

end


readyFramesShown = 0
newLevelFramesShown = 0

-- Drawing
function love.draw(dt)

	FPS = love.timer.getFPS()
	if (isShowingSplash) then
		splashy.draw() -- Draws the splashes to the screen.
		return 
	end


	if (useEffect) then
		if (Player.superSpeed) then
				speedEffect(draw_all)
		else
				normalEffect(draw_all)
		end
	else
    draw_all(dt)
	end
	
	

end

function draw_all(dt)

  gfx.draw(backgroundImage1, back_coord.x1+(250-Player.x)/50,back_coord.y1+(600-Player.y)/50)
  gfx.draw(backgroundImage2, back_coord.x2+(250-Player.x)/50,back_coord.y2+(600-Player.y)/50)


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
	
	HUD.draw(dt)

	
end