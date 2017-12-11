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
cscreen = require "libs/cscreen"

require 'boss'
require 'input'
require 'game'
require 'hud'
require 'enemies'
require 'enemy'
require 'waves'
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

debug = true -- dev mode on

FPS = 0
score  = 0
shotsFired = 0
isKill = false

osName = love.system.getOS()
explosions = {}
playerInitials = "DIE"          -- hay que pedir esto por teclado una vez al menos y guardarlo

joystick1 = nil
joystick2 = nil
isShowingSplash = true

-- MAIN VFX EFFECTS SECTION
useEffect = true
useEffectScanlines = true
useEffectGlow = true
useEffectGodsRay = true
useEffectCRT = false

-- Loading
function love.load(arg)
  
 	if arg[#arg] == "-debug" then require("mobdebug").start() end
	math.randomseed(os.time())
  
  if useEffect then
    cscreen.init(screenWidth, screenHeight, true, 3)
  else
    cscreen.init(screenWidth, screenHeight, true, 1)
  end
  cscreen_adjust = cscreen.getData()
  
 

	local joysticks = love.joystick.getJoysticks()
	if (table.getn(joysticks) > 0) then 
		joystick1 = joysticks[1] -- get first stick 
    if (table.getn(joysticks) > 1) then 
      joystick2 = joysticks[2]
    end
	end

  if (useEffect) then
		-- some pixel shaders to give that 80s looooook (stranger things is in da haus)	
				
		local w = gfx:getWidth()
    local h = gfx:getHeight()
    
    if (useEffectScanlines) then
      normalEffect = moonshine(moonshine.effects.scanlines)
      
      normalEffect.scanlines.opacity = 0.5
      normalEffect.scanlines.width = 1
  
    end

    if (useEffectGlow) then
      if (normalEffect ~= nil) then
         normalEffect.chain(moonshine.effects.glow) 
      else
        normalEffect = moonshine(moonshine.effects.glow) 
      end

      normalEffect.glow.min_luma = 0.3
      normalEffect.glow.strength = 10
    end

    if (useEffectCRT) then
      if (normalEffect ~= nil) then
        normalEffect.chain(moonshine.effects.crt) 
      else
        normalEffect = moonshine(moonshine.effects.crt) 
     end
    end

    -- speed effect
		speedEffect =  moonshine(moonshine.effects.godsray)

		speedEffect.godsray.light_x = 0.5
		speedEffect.godsray.light_y = 0
		speedEffect.godsray.exposure = 0.5
		speedEffect.godsray.decay = 0.9

	end
	
	--loadLeaderboard()	
	lue:setColor("my-color", {200, 100, 255})
  
  if (not debug) then
    
    splashy.addSplash(love.graphics.newImage("assets/splash1.png")) -- Adds splash images.	
    splashy.onComplete(function() print("Splash end.")
                                  isShowingSplash = false
                                  gameStart()
                                end) -- Runs the argument once all splashes are done.
  else
    gameStart()
  end

end

local back_coord

function gameStart()

	Enemies.init()
	Player.init()
  PowerUps.init()
	Sounds.init()
  --Game.startNewGame()

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
  
  if ( not debug) then
    splashy.update(dt) -- Updates the fading of the splash images.
    if (isShowingSplash) then return end
    
  end

	
	if (isGamePaused) then return end

	if (Player.superSpeed) then
		backgroundSpeed = 1.7
	else
		backgroundSpeed = 1
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

	updateExplosions(dt)

  -- First update timers
  Game.updateTimers(dt)  --Enemy and level creation is moved here
	Player.updateTimers(dt)
  Enemies.updateTimers(dt)
  PowerUps.updateTimers(dt);
  
	-- Update positions
	Player.updateBulletPositions(dt)
	Enemies.updatePositions(dt)
	Ballistics.updatePositions(dt)
  PowerUps.updatePositions(dt)

	-- run our collision detection
	-- Since there will be fewer enemies on screen than bullets we'll loop them first
	-- Also, we need to see if the enemies hit our player
	for w, player in ipairs(Player.players) do
    for i, enemy in ipairs(Enemies.enemies) do
      for j, bullet in ipairs(player.bullets) do
        if CheckCollisionEnemyBullet(enemy, bullet) then
          
          Player.bulletHit(j, player)
          enemyKilled = Enemies.enemyHit(enemy, i)
          
          -- fixme: sfx combos are supposed to be played when you actually kill N enemies in a row/short period of time 
          if (player.score % 20 == 0) then
            Sounds.combos[math.random(6)]:play()
          end
          if enemyKilled then
            player.score = player.score + enemy.score
            Game.enemyKilled(enemy)
          end
        end
      end

      if CheckCollisionEnemyPlayer(enemy, player) and player.isAlive then
        enemyKilled = Enemies.enemyHit(enemy, i)
        if not player.isShieldOn or enemy.enemyType==4 then
          Player.dead(player)
        end
        if enemyKilled then
          Game.enemyKilled(enemy)
        end
      end

      if Ballistics.checkCollisionsPlayer(player) and player.isAlive then
        if not player.isShieldOn then
          Player.dead(player)
        end
      end
    end
    PowerUps.checkCollisionsPlayer(player)
	end

	Player.updateMove(dt)
  
	Player.updateShot(dt)
	
	-- is player dead?
  local startButton = Input.startButton()
  if not (startButton == nil) then
    if Game.playing then
      for w, input in ipairs(startButton) do
        local player = Player.getPlayerByInput(input)
        if player == nil then
          -- Second player coming in
          Player.spawnPlayer(startButton[1])    
        elseif not player.isAlive and Player.canContinue(player) then
          Player.continue(player)
          Sounds.ready:play()
        end
      end
    else 
      -- Reset players and enemies
      Player.spawnPlayer(startButton[1])
      Enemies.reset()
       
      -- reset our game state
      Game.startNewGame()
      Sounds.ready:play()
      HUD.init()
    end
  end

	HUD.update(dt)

end


readyFramesShown = 0
newLevelFramesShown = 0

-- Drawing
function love.draw(dt)

  FPS = love.timer.getFPS()
  if (not debug) then
    if (isShowingSplash) then
      splashy.draw() -- Draws the splashes to the screen.
      return 
    end
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

  cscreen.apply()

  gfx.draw(backgroundImage1, back_coord.x1+(250-Player.x)/50,back_coord.y1+(600-Player.y)/50)
  gfx.draw(backgroundImage2, back_coord.x2+(250-Player.x)/50,back_coord.y2+(600-Player.y)/50)

  Player.drawAll()
  Enemies.drawAll()
  Ballistics.drawAll()
  PowerUps.drawAll()

  if (isGamePaused) then
    drawLeaderboard()
	end
	
  
  -- draw explosions particle systems
  for i = table.getn(explosions), 1, -1 do
    local explosion = explosions[i]
    gfx.draw(explosion, 0, 0)
  end

  HUD.draw(dt)  
  
  cscreen.cease()
  
end