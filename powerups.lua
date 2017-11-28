PowerUps = {
  powerups = {},         -- array of shots
  createPowerUpTimer = createPowerUpTimeMax
}

function PowerUps.init()
  ssPowerUpBlue = love.graphics.newImage('assets/crystal-qubodup-ccby3-32-blue.png')
	local p64 = anim8.newGrid(32,32, 256, 32)
  animPowerUpBlue = anim8.newAnimation(p64('1-8', '1-1'), 0.1)
end

function PowerUps.updateTimers(dt)
  
  PowerUps.createPowerUpTimer = PowerUps.createPowerUpTimer - (1 * dt)
  if PowerUps.createPowerUpTimer < 0 then
    PowerUps.createPowerUpTimer = createPowerUpTimeMax
    
    -- Create a PowerUp
    PowerUps.spawnPowerUp()
  end
end

function PowerUps.spawnPowerUp()
  local dx=(math.random(1,2)*2)-3
  local x=math.random(screenWidth-132)+50
  local pu = {x=x,y=0,dx=dx*2,dy=2,
              spritesheet=ssPowerUpBlue,
              anim=animPowerUpBlue,
              width=32, height=32, boundLeft=x-50, boundRight=x+50}
  table.insert(PowerUps.powerups,pu)
end

function PowerUps.updatePositions(dt)
  for i, powerup in ipairs(PowerUps.powerups) do
    powerup.x = powerup.x + powerup.dx
    powerup.y = powerup.y + powerup.dy
    
    if (powerup.x < 0 or powerup.x < powerup.boundLeft) then
      powerup.x=powerup.boundLeft
      powerup.dx=1
    elseif (powerup.x+powerup.width > screenWidth or powerup.x > powerup.boundRight) then
      powerup.x=powerup.boundRight
      powerup.dx=-1
    end
    
    powerup.anim:update(dt)
    
    if (powerup.y>screenHeight) then
      table.remove(PowerUps.powerups,i)
    end
    
	end
end

function PowerUps.drawAll(enemy, index)
  
  for i, powerup in ipairs(PowerUps.powerups) do
    powerup.anim:draw(powerup.spritesheet, powerup.x, powerup.y)
  end
end

function PowerUps.checkCollisionsPlayer(player)
  for j, powerup in ipairs(PowerUps.powerups) do
			if CheckCollisionPowerUpPlayer(powerup, player) then  
        player.addPowerUp(powerup)
        table.remove(PowerUps.powerups, j)
        Sounds.powerup:play()
      end
  end
end