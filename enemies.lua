Enemy = {
  enemies = {},         -- array of current enemies
  enemyImgs = nil,      -- array with enemy sprites
  asteroidImgs = nil,      -- array with asteroid sprites
  enemyBoxes = nil,     -- array of enemy bounding boxes
  createEnemyTimer = 0,
  bossAlive = false,
  enemiesKilled = 0,
  isHit = false         -- a player bullet has hit this enemy
}

function Enemy.init()
  
  Enemy.createEnemyTimer = createEnemyTimerMax
  
  spritesheet1 = love.graphics.newImage('assets/1945.png')
	local g64 = anim8.newGrid(64,64, 1024,768, 299,101, 2)
	--animation = anim8.newAnimation(g('1-8',1), 0.1)
	animPlane = anim8.newAnimation(g64(1,'1-3'), 0.1)
	animPlane:flipV() -- look down

  spriteSheetAsteroid = gfx.newImage('assets/asteroid_01_no_moblur.png')
  local a64 = anim8.newGrid(128,128, 1024, 1024)
  animAsteroid = anim8.newAnimation(a64('1-8', '1-8'), 0.06)

  Enemy.enemyImgs = {gfx.newImage('assets/enemies/enemy_1.png'),
                     gfx.newImage('assets/enemies/enemy_2.png'), 
                     gfx.newImage('assets/enemies/enemy_3.png')}

  Enemy.asteroidImgs = {gfx.newImage('assets/asteroids/asteroid_L_1.png'),
                        gfx.newImage('assets/asteroids/asteroid_L_2.png'), 
                        gfx.newImage('assets/asteroids/asteroid_M_1.png'),
                        gfx.newImage('assets/asteroids/asteroid_M_2.png'),
                        gfx.newImage('assets/asteroids/asteroid_S_1.png'),
                        gfx.newImage('assets/asteroids/asteroid_S_2.png')}

  Enemy.enemyBoxes = {
                      { {1,1,72,66} },
                      { {26,8,25,49}, {12,26,54,31} },
                      { {1,39,68,29}, {7,26,58,11}, {25,7,22,20}}
                    }

end

function Enemy.updateTimers(dt)
  
  for i, enemy in ipairs(Enemy.enemies) do
    
    if (enemy.isBoss) then
      -- Boss handles his own shit
      enemy:updateTimers(dt)
    else
      if enemy.willShoot then
        enemy.shootTimer = enemy.shootTimer - (1*dt)
        if enemy.shootTimer < 0 then
          
          if enemy.shotType == 1 then
            Sounds.blast:play()                    
            Ballistics.shootAtPlayer(enemy.x + enemy.width/2, enemy.y+enemy.height, Player)
          else
            Sounds.threeShotDown:play()          
            Ballistics.threeShotDown(enemy.x + enemy.width/2, enemy.y+enemy.height)
          end
          enemy.shootTimer = enemyMainShootTimer
        end
      end
    end
  end
end


-- Type 1 = Kamikaze ... doesn´t shoot but goes after player
-- Type 2 = One shot ... shoots towards the player once or twice and leaves
-- Type 3 = Three shot ... shoots three shots directly down once
-- Type 4 = Asteroid ... drifts aimlessly

function Enemy.spawnEnemy(enemyType, enemySpeed, shootTimer, hitCounter)
    
  kamikaze = enemyType == 1
  willShoot = not kamikaze

  randomNumber = math.random(screenWidth-Enemy.enemyImgs[enemyType]:getWidth())

  newEnemy = { x = randomNumber, y = -50, enemyType = enemyType, img = Enemy.enemyImgs[enemyType], isKamikaze=kamikaze,
               speed = enemySpeed, width=Enemy.enemyImgs[enemyType]:getWidth(), height=Enemy.enemyImgs[enemyType]:getHeight(), 
               hitCounter=hitCounter, isBoss = false, boxes=Enemy.enemyBoxes[enemyType], willShoot = willShoot, shootTimer = shootTimer}
  
  if (enemyType == 2) then
    if (math.random(2) == 1) then
      newEnemy.x = 0 - newEnemy.width
      newEnemy.dX = 1
    else 
      newEnemy.x = screenWidth + newEnemy.width
      newEnemy.dX = -1
    end
    
    newEnemy.minY = math.random(40)
    newEnemy.maxY = 100 + math.random(100)
    newEnemy.speed = newEnemy.speed * 0.7
    newEnemy.shotType = 1
    
  elseif (enemyType == 3) then  
    newEnemy.minY = 100
    newEnemy.maxY = 300
    newEnemy.speed = newEnemy.speed * 0.6
    newEnemy.startX = newEnemy.x
    newEnemy.dY = 1
    newEnemy.shotType = 2
  end
  
  table.insert(Enemy.enemies, newEnemy)
  
end

function Enemy.spawnAsteroid(level)
  
  local asteroidType = math.random(6)
  local asteroidImg = Enemy.asteroidImgs[asteroidType]
  local randomPosition = 100 + math.random(screenWidth-asteroidImg:getWidth()-100)
  
  newEnemy = { x = randomPosition, y = -50, enemyType=4, img = asteroidImg, 
               speed = 150+level*10, width = asteroidImg:getWidth(), height = asteroidImg:getHeight(), hitCounter=1000, 
               isBoss = false, boxes={{1,1,asteroidImg:getWidth()-2, asteroidImg:getHeight()-2}},
               willShoot = false, shootTimer = 1000}

  newEnemy.dX = math.random()
  
  if (newEnemy.x > screenWidth/2 and math.random(2) == 1) then
    newEnemy.dX = newEnemy.dX * -1 * level/3
  end
  
  newEnemy.dY = (2+math.random()*3/2) * level/3

  table.insert(Enemy.enemies, newEnemy)

end


local currentBoss = nil

function Enemy.spawnBoss(level)
  Enemy.bossAlive = true
  local newBoss = nil
  if (level % 4 == 1) then
    newBoss = BossOne:new()
  else
    newBoss = BossTwo:new()
  end
  newBoss:setBossLevel(1+math.floor(level/4))
  
  table.insert(Enemy.enemies, newBoss)
  currentBoss = newBoss
  
  Sounds.finishHim:play()
  Sounds.setMusicForBossBattle()
end

function Enemy.updatePositions(dt)
  for i, enemy in ipairs(Enemy.enemies) do
		if not enemy.isBoss then
      Enemy.moveEnemy(enemy, i, dt)
    else
      enemy:moveBoss(dt)
    end
	end
  animAsteroid:update(dt)
end

function Enemy.moveEnemy(enemy, index, dt)
  
  -- Kamikaze
  if enemy.enemyType == 1 then
    
    if (enemy.timeToVector == nil or enemy.timeToVector <= 0) then
      local vector = createDirectionVector(enemy.x, enemy.y, Player.x, Player.y, enemy.speed/90)
      enemy.dX = vector[1]
      enemy.dY = vector[2]
      enemy.timeToVector = 1
    end
    enemy.timeToVector = enemy.timeToVector - dt
    enemy.x = enemy.x + enemy.dX
    enemy.y = enemy.y + enemy.dY
    
  -- Este hace ZigZag y dispara hacia el player
  elseif enemy.enemyType == 2 then
    
    enemy.y = enemy.maxY - math.sin((screenWidth - enemy.x)/screenWidth * math.pi) * (enemy.maxY-enemy.minY) -- enemy.y + (enemy.speed * dt) * enemy.dY
    enemy.x = enemy.x + (enemy.speed * dt) * enemy.dX
    
    if (enemy.x < 0) then
      enemy.dX = 1
    end
    
    if (enemy.x > screenWidth - enemy.width) then
      enemy.dX = -1
    end
  
  -- Sigue al player desde distancia y dispara
  elseif enemy.enemyType == 3 then  
    enemy.x = enemy.startX + math.sin((enemy.y-enemy.minY) * 0.01 * math.pi)*25
    enemy.y = enemy.y + (enemy.speed * dt) * enemy.dY
    if (enemy.y > enemy.maxY) then
      enemy.dY = -1
    end
    
    if (enemy.y < enemy.minY) then
      enemy.dY = 1
    end
  
  -- Asteroid
  elseif enemy.enemyType == 4 then  
    enemy.y = enemy.y + (enemy.speed * dt) * enemy.dY
    enemy.x = enemy.x + (enemy.speed * dt) * enemy.dX
  end

	if enemy.y > screenHeight then -- remove enemies when they pass off the screen
		table.remove(Enemy.enemies, index)
		missedEnemies = missedEnemies + 1
	end
  
end

function Enemy.moveBoss(boss, dt)

  if (boss.bossTween == nil) then
    local xTo = math.random(screenWidth) - boss.width/2
    local yTo = math.random(120)-100
    
    boss.bossTween = tween.new(2, boss, {x=xTo, y=yTo}, tween.easing.outBounce)
  end

  -- if complete, set to nil
  if (boss.bossTween:update(dt)) then
    boss.bossTween = nil
  end
end

function Enemy.drawAll()
  for i, enemy in ipairs(Enemy.enemies) do
    Enemy.draw(enemy, i)
	end
end

function Enemy.draw(enemy, index)
  
  --animPlane:draw( spritesheet1, enemy.x, enemy.y)
  
    -- if enemy boss is hit then change hue to red so it shows some blooood
    if (enemy.isBoss and enemy.isHit) then
      gfx.push() -- save all love.graphics state so any changes can be restored
      gfx.setColor(lue:getHueColor(200, 100))
      gfx.draw(enemy.img, enemy.x, enemy.y)     
      gfx.pop() -- restore the saved love.graphics state
      Timer.after(0.2, function() currentBoss.isHit = false end)
      if (Sounds.explodeSound:isPlaying()) then
        Sounds.explodeSound:rewind()
      else
        Sounds.explodeSound:play()
      end
      --timer.after (0.1, function ()  end) -- no funca
    else
      --if (not enemy.isBoss and not enemy.willShoot) then
      --  animAsteroid:draw(spriteSheetAsteroid, enemy.x, enemy.y)
      --else
        if (enemy.enemyType == 1) then
          local angle = math.pi * 2 - math.atan((enemy.x-Player.x)/math.abs(enemy.y-Player.y))
          if (enemy.y<=Player.y) then
            angle = math.atan((enemy.x-Player.x)/math.abs(enemy.y-Player.y)) - math.pi
          end
          
          gfx.draw(enemy.img, enemy.x, enemy.y, angle, 1, 1, enemy.width/2, enemy.height/2)
        else
          gfx.draw(enemy.img, enemy.x, enemy.y)           
        end
      --end
    end

end

function Enemy.enemyHit(enemy, index)

  enemy.hitCounter = enemy.hitCounter - 1;
  enemy.isHit = true


  if joystick ~= nil and joystick:isVibrationSupported() then
    joystick:setVibration( 0.5, 0.5, 0.2 )
  end

  -- enemy downed if hitcounter reaches 0
  if enemy.hitCounter == 0 then
    
    table.remove(Enemy.enemies, index)
    isKill = true;

    local explosion = getExplosion(getBlast(80))
    explosion:setPosition(enemy.x + enemy.width/2, enemy.y + enemy.height/2)
    explosion:emit(10)
    table.insert(explosions, explosion)

    if (Sounds.explodeSound:isPlaying()) then
      Sounds.explodeSound:rewind()
    else
      Sounds.explodeSound:play()
    end
    
    if enemy.isBoss then
      Enemy.bossAlive = false
      Sounds.perfect:play()
      Sounds.setMusicForNormalPlay()
      
    else
      Enemy.enemiesKilled = Enemy.enemiesKilled + 1;
    end
    
    return true
  else
    return false
  end
end

function Enemy.reset()
  
  Enemy.enemies = {}
  Enemy.enemiesKilled = 0
  Enemy.bossAlive = false

end