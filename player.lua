Player = {
  canShoot = true,        -- Player is ready to shoot or not 
  canShootTimer = 1,      -- Timer to next shot
  x =  0, 
  y = 710, 
  speed = playerSpeed, 
	img = nil,
	thumbnail = nil,
  numShots = 1,
  shieldImg = nil,
  isShieldOn = false,
  shieldTimer = 1,
  isAlive = true,
  bullets = {},            -- array of user shot bullets being drawn and updated
  isTurningRight = false,
  isTurningLeft = false,
  superSpeed = false,
	bulletImgs = nil,
	width = 110,
	height = 95,
	boxes = {{9,15,91,29},{44,7,20,81}},
	lives = 3 -- how many lives left? 3 to start with
}

Player.x = (love.graphics.getWidth() / 2) - (Player.width / 2) -- medio trucho pero funca

function Player.init()
  
  timeToShieldOn = 5
  timeToShieldOff = 10
  
  Player.shieldTimer = timeToShieldOn
  
  playerImages = {gfx.newImage('assets/new_player1.png'), gfx.newImage('assets/new_player2.png'), gfx.newImage('assets/new_player3.png'), gfx.newImage('assets/new_player4.png')}
  playerBoxes = { {{34,6,14,58},{18,37,46,28},{26,22,30,15}},
                  {{34,6,14,58},{18,37,46,28},{26,22,30,15}},
                  {{34,6,14,58},{10,37,62,28},{26,22,30,15}},
									{{34,6,14,58},{10,37,62,28},{26,22,30,15}}}
									
	Player.thumbnail = gfx.newImage('assets/player_thumb.png')
  
  Player.img = playerImages[1]
  Player.boxes = playerBoxes[1]
	--Player.img_right = gfx.newImage('assets/player-right.png')
	--Player.img_left = gfx.newImage('assets/player-left.png')
  Player.shieldImg = gfx.newImage('assets/64_shield.png')
  
  Player.width = Player.img:getWidth()
  Player.height = Player.img:getHeight()
  
  Player.bulletImgs = {gfx.newImage('assets/bullet.png'),
                       gfx.newImage('assets/new_bullet.png'),
                       gfx.newImage('assets/new_bullet2.png'),
                       gfx.newImage('assets/bullet_orange.png'),
                       gfx.newImage('assets/bullet_purple.png')}
      
end

function Player.updateTimers(dt)
  
  -- Time out how far apart our shots can be.
	Player.canShootTimer = Player.canShootTimer - (1 * dt)
  Player.shieldTimer = Player.shieldTimer - (1 * dt)
  
	if Player.canShootTimer < 0 then
		Player.canShoot = true
	end
  
  if Player.isShieldOn and Player.shieldTimer <= 0 then
    Player.isShieldOn=false
    Player.shieldTimer=timeToShieldOn
  end

end


function Player.updateBulletPositions(dt)
  for index, bullet in ipairs(Player.bullets) do
		bullet.y = bullet.y - (bullet.speed * dt)

		if bullet.y < 0 then -- remove bullets when they pass off the screen
			table.remove(Player.bullets, index)
		end
	end
end

function Player.bulletHit(index)
  table.remove(Player.bullets, index)
end

function Player.dead()
  Player.isAlive = false
	Sounds.explodePlayer:play()
	local explosion = getExplosion(getBlast(300))
	explosion:setPosition(Player.x + Player.width/2, Player.y + Player.height/2)
	explosion:emit(20)
	table.insert(explosions, explosion)
	Player.lives = Player.lives - 1
	if joystick ~= nil and joystick:isVibrationSupported() then
    joystick:setVibration( 0.7, 0.7, 0.6 )
  end
	if not Player.canContinue()	then
		saveScore(playerInitials)
	end
end

function Player.canContinue() 
	return Player.lives > 0
end

function Player.continue()

	-- move player back to default position
	Player.x = gfx.getWidth() / 2 - 40
	Player.y = gfx.getHeight() - 100
	Player.isAlive = true
	
	--Sounds.perfect:play()
end


function Player.updateMove(dt)
  
  Player.isTurningLeft = false
	Player.isTurningRight= false

	-- check joystick
	if joystick ~= nil then

		-- getGamepadAxis returns a value between -1 and 1. It returns 0 when it is at rest
		--https://love2d.org/wiki/GamepadButton
			Player.x = Player.x + joystick:getGamepadAxis("leftx") * (Player.speed*dt)
			Player.y = 	Player.y + joystick:getGamepadAxis("lefty") *  (Player.speed*dt)
				
		if joystick:isGamepadDown("dpleft") then
				if Player.x > 0 then -- binds us to the map
					Player.x = Player.x - (Player.speed*dt)
				end
			elseif joystick:isGamepadDown("dpright") then
				if Player.x < (gfx.getWidth() - Player.img:getWidth()) then
					Player.x = Player.x + (Player.speed*dt)
				end
			end

			if joystick:isGamepadDown("dpup") then
				if Player.y > 50 then
					Player.y = Player.y - (Player.speed*dt)
				end
			elseif joystick:isGamepadDown("dpdown") then
				if Player.y < (gfx.getHeight() - 55) then
					Player.y = Player.y + (Player.speed*dt)
				end
			end
      
      -- Shield!
      if (joystick:isGamepadDown('b') and not Player.isShieldOn and Player.shieldTimer <= 0) then
        Player.isShieldOn = true
				Player.shieldTimer = timeToShieldOff
				Sounds.shieldUp:play()
      end

	end
	
	if love.keyboard.isDown('left','a') then
		Player.isTurningLeft = true
		if Player.x > 0 then -- binds us to the map
			Player.x = Player.x - (Player.speed*dt)
		end
	elseif love.keyboard.isDown('right','d') then
		Player.isTurningRight = true
		if Player.x < (gfx.getWidth() - Player.img:getWidth()) then
			Player.x = Player.x + (Player.speed*dt)
		end
	end

	if love.keyboard.isDown('up', 'w') then
	if Player.y > 50 then
		Player.y = Player.y - (Player.speed*dt)
	end
	elseif love.keyboard.isDown('down', 's') then
		if Player.y < (gfx.getHeight() - 55) then
			Player.y = Player.y + (Player.speed*dt)
		end
	end

	-- superspeed
	if love.keyboard.isDown(' ', 'z') or (joystick ~= nil and joystick:isGamepadDown('x')) or love.keyboard.isDown("lshift")  then
    Player.superSpeed = true
		Player.speed = 500 + (10 * playerLevel)
	else
    Player.superSpeed = false
		Player.speed = 300
	end
  
  if (love.keyboard.isDown(' ', 'x') and not Player.isShieldOn and Player.shieldTimer <= 0) then
    Player.isShieldOn = true
		Player.shieldTimer = timeToShieldOff
		Sounds.shieldUp:play()
  end
  
end

function Player.updateShot(dt)
  if Player.isAlive and Player.canShoot and ((joystick ~= nil and joystick:isDown(1)) or love.keyboard.isDown(' ', 'rctrl', 'lctrl', 'ctrl','space'))  then
		-- Create some bullets

		bulletSpeed = currentBulletSpeed + (playerLevel * 20)
    local spaceBetweenShots = 20
    local separation = spaceBetweenShots * (Player.numShots-1)
    
    for i=1,Player.numShots do 
      local img = Player.numShots
      if (img>3) then
        img=3
      end
      newBullet1 = { x = Player.x + Player.width/2 - 5 - separation/2 + (i-1)*spaceBetweenShots, y = Player.y, img = Player.bulletImgs[img], speed = bulletSpeed }  
      table.insert(Player.bullets, newBullet1)
      shotsFired = shotsFired + 1
    end
    
		if (Sounds.gunSound:isPlaying()) then
			Sounds.gunSound:rewind()
		else
			Sounds.gunSound:play()
		end
		Player.canShoot = false
		Player.canShootTimer = bulletShootTimer[Player.numShots]
	end
end

function Player.reset()
  Player.bullets = {}
	Player.isShieldOn = false
  Player.shieldTimer = timeToShieldOn
    
	-- reset timers
	Player.canShootTimer = 1
  Player.numShots = 1
	Player.createEnemyTimer = createEnemyTimerMax
  
	-- move player back to default position
	Player.x = gfx.getWidth() / 2 - 40
	Player.y = gfx.getHeight() - 100
  Player.isAlive = true
	Player.lives = 3
end

function Player.drawAll()
  Player.drawShots()
  Player.drawPlayer()
end

function Player.drawShots()
  for i, bullet in ipairs(Player.bullets) do
		gfx.draw(bullet.img, bullet.x, bullet.y)
	end
end

function Player.drawPlayer()
  if Player.isAlive then
    
    gfx.draw(Player.img, Player.x, Player.y)
    
    if showBoundingBoxes == true then
      for i, box in ipairs(Player.boxes) do
        gfx.rectangle("line",Player.x+box[1], Player.y+box[2], box[3], box[4])
      end
    end
    
    --if Player.isTurningLeft then
		--	gfx.draw(Player.img_left, Player.x, Player.y)
		--elseif Player.isTurningRight then
    --gfx.draw(Player.img_right, Player.x, Player.y)
		--else
		--end
    
    if Player.isShieldOn then
      gfx.draw(Player.shieldImg, Player.x+2, Player.y-10, 0, 0.3, 0.3)
		else
			if (Sounds.shieldUp:isPlaying()) then
				Sounds.shieldUp:stop()
			end
		end
    
	end
end

function Player.addPowerUp(powerUp)
	if (powerUp.type == PowerUps.POWERUP_TYPE_LIFE) then
		if (Player.lives < 3) then
			Player.lives = Player.lives + 1
			Sounds.perfect:play()
		end
	else
		if (Player.numShots < 3) then
			Player.numShots = Player.numShots+1  
			Player.img = playerImages[Player.numShots]
			Player.boxes = playerBoxes[Player.numShots]
		end
	end
end