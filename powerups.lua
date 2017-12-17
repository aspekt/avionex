PowerUps = {
  powerups = {},         -- array of shots
  createPowerUpTimer = createPowerUpTimeMax,
  weaponPowerUpImg = love.graphics.newImage('assets/crystal-qubodup-ccby3-32-blue.png'),
  lifePowerUpImg = love.graphics.newImage('assets/life_powerup.png'),
  imgs = {},
  POWERUP_TYPE_LIFE = 1,
  POWERUP_TYPE_WEAPON = 2,
  POWERUP_TYPE_SPEED = 3,
  POWERUP_TYPE_SHOT = 4,
  POWERUP_TYPE_SHIELD = 5
}

function PowerUps.init()
	local p64 = anim8.newGrid(32,32, 256, 32)
  animPowerUpBlue = anim8.newAnimation(p64('1-8', '1-1'), 0.1)
  
  PowerUps.imgs = {gfx.newImage('assets/powerups/powerup_1.png'),
                   gfx.newImage('assets/powerups/powerup_2.png'), 
                   gfx.newImage('assets/powerups/powerup_3.png'),
                   gfx.newImage('assets/powerups/powerup_4.png'),
                   gfx.newImage('assets/powerups/powerup_5.png')}
  
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

  -- decide what powerup to spawn
  local type = math.random(1,10)
  local puType = nil
  local dx=(math.random(1,2)*2)-3
  local x=math.random(screenWidth-132)+50
  local pu = {x=x,y=0,dx=dx*2,dy=2,width=32, height=32, boundLeft=x-50, boundRight=x+50, anim = nil}
  
  if type <= 1 then 
     puType = PowerUps.POWERUP_TYPE_LIFE
     pu.img = PowerUps.imgs[1]
  elseif type>1 and type <= 4 then
    puType = PowerUps.POWERUP_TYPE_SHOT
    pu.img = PowerUps.imgs[2]
  elseif type>4 and type <= 7 then
    puType = PowerUps.POWERUP_TYPE_SHIELD
    pu.img = PowerUps.imgs[3]
  elseif type>7 and type <= 10 then
    puType = PowerUps.POWERUP_TYPE_SPEED
    pu.img = PowerUps.imgs[4]
  end
  
  pu.type = puType
  pu.width = pu.img:getWidth()
  pu.height = pu.img:getHeight()
  table.insert(PowerUps.powerups,pu)  
  
  --[[
  local type = math.random(1,10)
  local puType = nil
  local spritesheet = nil
  
  if type <= 7 then -- weapon powerup (70% of the time is a weapon, 30% is a life... kinda)
    puType = PowerUps.POWERUP_TYPE_WEAPON
    spritesheet = PowerUps.weaponPowerUpImg
  else
    puType = PowerUps.POWERUP_TYPE_LIFE
    spritesheet = PowerUps.lifePowerUpImg
  end

  local dx=(math.random(1,2)*2)-3
  local x=math.random(screenWidth-132)+50
  local pu = {x=x,y=0,dx=dx*2,dy=2,
              spritesheet=spritesheet,
              anim=animPowerUpBlue, -- we dont have this for the life PU
              width=32, height=32, boundLeft=x-50, boundRight=x+50,
              type = puType}
  --]]
  
end

function PowerUps.updatePositions(dt)
  for i=table.getn(PowerUps.powerups), 1, -1 do
    local powerup =PowerUps.powerups[i] 
    powerup.x = powerup.x + powerup.dx
    powerup.y = powerup.y + powerup.dy
    
    if (powerup.x < 0 or powerup.x < powerup.boundLeft) then
      powerup.x=powerup.boundLeft
      powerup.dx=1
    elseif (powerup.x+powerup.width > screenWidth or powerup.x > powerup.boundRight) then
      powerup.x=powerup.boundRight
      powerup.dx=-1
    end
    
    if not (powerup.anim == nil) then
      powerup.anim:update(dt)
    end
    
    if (powerup.y>screenHeight) then
      table.remove(PowerUps.powerups,i)
    end
    
	end
end

function PowerUps.drawAll(enemy, index)
  
  for i, powerup in ipairs(PowerUps.powerups) do
    if powerup.anim == nil then
      gfx.draw(powerup.img, powerup.x,powerup.y) 
    else
      powerup.anim:draw(powerup.spritesheet, powerup.x, powerup.y)
    end
  end
end

function PowerUps.checkCollisionsPlayer(player)
  for j=table.getn(PowerUps.powerups),1,-1 do
    local powerup = PowerUps.powerups[j]
		if CheckCollisionPowerUpPlayer(powerup, player) then  
      Player.addPowerUp(powerup, player)
      table.remove(PowerUps.powerups, j)
      Sounds.powerup:play()
    end
  end
end

function PowerUps.reset()
  PowerUps.powerups = {}
  PowerUps.createPowerUpTimer = createPowerUpTimeMax
end