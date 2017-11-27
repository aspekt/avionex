Enemy = {
  enemies = {},         -- array of current enemies
  enemyImgs = nil,      -- array with enemy sprites
  enemyBoxes = nil,     -- array of enemy bounding boxes
  createEnemyTimer = 0,
  bossImgs = nil,
  bossAlive = false,
  enemiesKilled = 0,
  isHit = false -- a player bullet has hit this enemy
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
  


  Enemy.enemyImgs = {gfx.newImage('assets/aircraft01.png'),
				gfx.newImage('assets/aircraft02.png'), 
				gfx.newImage('assets/aircraft03.png'),
				gfx.newImage('assets/aircraft04.png'),
				gfx.newImage('assets/aircraft07.png'),
				gfx.newImage('assets/aircraft08.png')}

  Enemy.enemyBoxes = {
                { {42,3,26,87}, {4,47,101,30} },
                { {42,5,26,79}, {4,42,103,26} },
                { {43,5,26,80}, {5,42,102,22} },
                { {44,5,21,76}, {5,34,101,22} },
                { {46,4,20,74}, {5,36,101,27} },
                { {38,6,19,67}, {6,37,82,20} }
              }

  Enemy.bossImgs = {gfx.newImage('assets/zepellin.png')}
	Enemy.bossBoxes = {{{31,12,252,378}}}

end

function Enemy.updateTimers(dt)
  -- Every X time, create new enemy
  if not Enemy.bossAlive then
    Enemy.createEnemyTimer = Enemy.createEnemyTimer - (1 * dt)
    if Enemy.createEnemyTimer < 0 then
      Enemy.createEnemyTimer = (createEnemyTimerMax * 1/playerLevel)

      -- Create an enemy
      Enemy.spawnEnemy()
    end
  end
  
  for i, enemy in ipairs(Enemy.enemies) do
    if enemy.willShoot then
      enemy.shootTimer = enemy.shootTimer - (1*dt)
      if enemy.shootTimer < 0 then
        
        local shotType = math.random(2)
        if shotType == 1 then
          Sounds.blast:play()                    
          Ballistics.shootAtPlayer(enemy.x + enemy.width/2, enemy.y+enemy.height, Player)
        else
          Sounds.threeShotDown:play()          
          Ballistics.threeShotDown(enemy.x + enemy.width/2, enemy.y+enemy.height)
          
        end
      
        if enemy.isBoss then
          enemy.shootTimer = math.random(6-playerLevel) * math.random()
        else
          enemy.shootTimer = 1000
        end
      end
    end
  end
  
end

function Enemy.spawnEnemy()
  
  randomNumber = math.random(10, gfx.getWidth() - 100)
  randomSpeed = math.random(10, (50 * playerLevel))
  randomImg = math.random(6)
  willShoot = math.random(10) < playerLevel*2
  kamikaze = math.random() < 0.5

  newEnemy = { x = randomNumber, y = -50, img = Enemy.enemyImgs[randomImg] , isKamikaze=kamikaze, num=randomImg, 
               speed = enemySpeed + randomSpeed, width = 100, height = 100, hitCounter=1, isBoss = false, boxes=Enemy.enemyBoxes[randomImg],
               willShoot = willShoot, shootTimer = math.random()}
             
             
  --todo temp por asteroids
  if not willShoot then
    newEnemy.boxes = {{20,20,88,88}}
  end
  
  table.insert(Enemy.enemies, newEnemy)
  
end
local currentBoss = nil

function Enemy.spawnBoss()
  Enemy.bossAlive = true
  newBoss = { x = 150, y = -150, img = Enemy.bossImgs[1], width = 304, height = 400, 
              speed = playerSpeed, hitCounter=20*playerLevel, isBoss = true, goingLeft = true, boxes=Enemy.bossBoxes[1],
               willShoot = true, shootTimer = math.random(6-playerLevel) * math.random(), bossTween = nil}
  table.insert(Enemy.enemies, newBoss)
  currentBoss = newBoss
  Sounds.finishHim:play()
end

function Enemy.updatePositions(dt)
  for i, enemy in ipairs(Enemy.enemies) do
		if not enemy.isBoss then
      Enemy.moveEnemy(enemy, i, dt)
    else
      Enemy.moveBoss(enemy, dt)
    end
	end
  animAsteroid:update(dt)
end

function Enemy.moveEnemy(enemy, index, dt)
  enemy.y = enemy.y + (enemy.speed * dt)
    
    if enemy.isKamikaze then
      if (enemy.x < Player.x) then
        enemy.x = enemy.x + kamikazeSpeed * dt
      else
        enemy.x = enemy.x - kamikazeSpeed * dt
      end
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
      if (not enemy.isBoss and not enemy.willShoot) then
        animAsteroid:draw(spriteSheetAsteroid, enemy.x, enemy.y)
      else
        gfx.draw(enemy.img, enemy.x, enemy.y)           
      end
    end

end

function Enemy.enemyHit(enemy, index)

  enemy.hitCounter = enemy.hitCounter - 1;
  
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