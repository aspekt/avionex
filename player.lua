Player = {
  canShoot = true,        -- Player is ready to shoot or not 
  canShootTimer = 1,      -- Timer to next shot
  x = 250, 
  y = 710, 
  speed = playerSpeed, 
  img = nil,
  shieldImg = nil,
  isShieldOn = false,
  shieldTimer = 1,
  isAlive = true,
  bullets = {},            -- array of user shot bullets being drawn and updated
  isTurningRight = false,
  isTurningLeft = false,
	bulletImgs = nil,
	width = 100,
	height = 100,
  boxes = {{9,15,91,29},{44,7,20,81}}
}

function Player.init()
  
  timeToShieldOn = 5
  timeToShieldOff = 10
  
  Player.shieldTimer = timeToShieldOn
  
  Player.img = gfx.newImage('assets/player.png')
	Player.img_right = gfx.newImage('assets/player-right.png')
	Player.img_left = gfx.newImage('assets/player-left.png')
  Player.shieldImg = gfx.newImage('assets/64_shield.png')
  
  Player.width = Player.img:getWidth()
  Player.height = Player.img:getHeight()
  
  Player.bulletImgs = {gfx.newImage('assets/bullet.png'),
				gfx.newImage('assets/bullet_orange.png'),
				gfx.newImage('assets/bullet_purple.png'),
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
	explodePlayer:play()
	local explosion = getExplosion(getBlast(300))
	explosion:setPosition(Player.x + Player.width/2, Player.y + Player.height/2)
	explosion:emit(20)
	table.insert(explosions, explosion)
	saveScore(playerInitials)
end

function Player.updateMove(dt)
  
  Player.isTurningLeft = false
	Player.isTurningRight= false

	-- check joystick
	if joystick ~= nil then

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
      if (joystick:isDown(2) and not Player.isShieldOn and Player.shieldTimer <= 0) then
        Player.isShieldOn = true
        Player.shieldTimer = timeToShieldOff
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

	if love.keyboard.isDown(' ', 'z') then
		Player.speed = 500
	else
		Player.speed = 250
	end
  
  if (love.keyboard.isDown(' ', 'x') and not Player.isShieldOn and Player.shieldTimer <= 0) then
    Player.isShieldOn = true
		Player.shieldTimer = timeToShieldOff
		sfxShieldUp:play()
  end
  
end

function Player.updateShot(dt)
  if Player.isAlive and Player.canShoot and ((joystick ~= nil and joystick:isDown(1)) or love.keyboard.isDown(' ', 'rctrl', 'lctrl', 'ctrl','space'))  then
		-- Create some bullets

		bulletSpeed = currentBulletSpeed + (playerLevel * 20)

		newBullet1 = { x = Player.x + (Player.img:getWidth()/2 - 10), y = Player.y, img = Player.bulletImgs[1], speed = bulletSpeed }
		shotsFired = shotsFired + 1
		table.insert(Player.bullets, newBullet1)

		-- fixme: player levels are static (hacks) and need to be 100% dynamic
		if (playerLevel == 2) then
			shotsFired = shotsFired + 1
			newBullet2 = { x = Player.x + (Player.img:getWidth()/2 ), y = Player.y, img = Player.bulletImgs[2], speed = bulletSpeed }
			table.insert(Player.bullets, newBullet2)
		end

		if (playerLevel == 3) then
			newBullet3 = { x = Player.x + (Player.img:getWidth()/2 - 20), y = Player.y, img = Player.bulletImgs[3], speed = bulletSpeed }
			newBullet4 = { x = Player.x + (Player.img:getWidth()/2 + 10), y = Player.y, img = Player.bulletImgs[3], speed = bulletSpeed }
			shotsFired = shotsFired + 1
			shotsFired = shotsFired + 1

			table.insert(Player.bullets, newBullet3)
			table.insert(Player.bullets, newBullet4)
			
		end
		
		if (playerLevel > 3) then
			
			newBullet5 = { x = Player.x + (Player.img:getWidth()/2 - 30), y = Player.y, img = Player.bulletImgs[4], speed = bulletSpeed }
			newBullet6 = { x = Player.x + (Player.img:getWidth()/2 + 20), y = Player.y, img = Player.bulletImgs[4], speed = bulletSpeed }
			shotsFired = shotsFired + 1
			shotsFired = shotsFired + 1

			table.insert(Player.bullets, newBullet5)
			table.insert(Player.bullets, newBullet6)
			
		end

		if (gunSound:isPlaying()) then
			gunSound:rewind()
		else
			gunSound:play()
		end
		Player.canShoot = false
		Player.canShootTimer = bulletShootTimer[playerLevel]
	end
end

function Player.reset()
  Player.bullets = {}
	Player.isShieldOn = false
  Player.shieldTimer = timeToShieldOn
    
	-- reset timers
	Player.canShootTimer = 1
	Player.createEnemyTimer = createEnemyTimerMax
  
	-- move player back to default position
	Player.x = 250
	Player.y = 710
  Player.isAlive = true

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
    if Player.isTurningLeft then
			gfx.draw(Player.img_left, Player.x, Player.y)
		elseif Player.isTurningRight then
			gfx.draw(Player.img_right, Player.x, Player.y)
		else
			gfx.draw(Player.img, Player.x, Player.y)
		end
    
    if Player.isShieldOn then
      gfx.draw(Player.shieldImg, Player.x-10, Player.y-8, 0, 0.5, 0.4)
    end
    
	end
end