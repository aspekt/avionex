Enemies = {
  enemies = {},         -- array of current enemies
  enemyImgs = nil,      -- array with enemy sprites
  asteroidImgs = nil,   -- array with asteroid sprites
  createEnemyTimer = 0,
  bossAlive = false
}

function Enemies.init()
  
  Enemies.createEnemyTimer = createEnemyTimerMax

  Enemies.enemyImgs = {gfx.newImage('assets/enemies/enemy_1.png'),
                       gfx.newImage('assets/enemies/enemy_2.png'), 
                       gfx.newImage('assets/enemies/enemy_3.png'),
                       gfx.newImage('assets/enemies/enemy_4.png'),
                       gfx.newImage('assets/enemies/enemy_5.png')}

  Enemies.asteroidImgs = {gfx.newImage('assets/asteroids/asteroid_L_1.png'),
                        gfx.newImage('assets/asteroids/asteroid_L_2.png'), 
                        gfx.newImage('assets/asteroids/asteroid_M_1.png'),
                        gfx.newImage('assets/asteroids/asteroid_M_2.png'),
                        gfx.newImage('assets/asteroids/asteroid_S_1.png'),
                        gfx.newImage('assets/asteroids/asteroid_S_2.png')}

end

function Enemies.updateTimers(dt)
  for i, enemy in ipairs(Enemies.enemies) do
    enemy:updateTimers(dt)
  end
end

-- Type 1 = Kamikaze ... doesn´t shoot but goes after player
-- Type 2 = One shot ... shoots towards the player once or twice and leaves
-- Type 3 = Three shot ... shoots three shots directly down once
-- Type 4 = Straight down
function Enemies.spawnEnemy(enemyType, enemySpeed, shootTimer, hitCounter)
  local newEnemy = nil
  if (enemyType == 1) then   
    newEnemy = EnemyKamikaze:new()
  elseif (enemyType == 2) then
    newEnemy = EnemyLeftRight:new()
  elseif (enemyType == 3) then  
    newEnemy = EnemyUpDown:new()
  elseif (enemyType == 4) then  
    newEnemy = EnemyStraight:new()  
  end
  newEnemy = EnemyStraight:new()
  newEnemy.x = math.random(screenWidth-newEnemy.width)
  table.insert(Enemies.enemies, newEnemy)
end

function Enemies.spawnAsteroid(level)
  newEnemy = EnemyAsteroid:new(level)
  table.insert(Enemies.enemies, newEnemy)
end

function Enemies.addEnemy(enemy)
  table.insert(Enemies.enemies, enemy)
end


local currentBoss = nil

function Enemies.spawnBoss(level)
  Enemies.bossAlive = true
  local newBoss = nil
  if (level % 4 == 1) then
    newBoss = BossOne:new()
  else
    newBoss = BossTwo:new()
  end
  newBoss:setBossLevel(1+math.floor(level/4))
  
  table.insert(Enemies.enemies, newBoss)
  currentBoss = newBoss
  
  Sounds.finishHim:play()
  Sounds.setMusicForBossBattle()
end

function Enemies.updatePositions(dt)
  for i, enemy in ipairs(Enemies.enemies) do
		if not enemy.isBoss then
      enemy:moveEnemy(dt, i)
      if enemy.y > screenHeight then -- remove enemies when they pass off the screen
        table.remove(Enemies.enemies, i)
        if not (Game.currentWave == nil) then
           Game.currentWave:enemyRemoved()
        end
      end
    else
      enemy:moveBoss(dt)
    end
	end
end

function Enemies.drawAll()
  for i, enemy in ipairs(Enemies.enemies) do
    Enemies.draw(enemy, i)
	end
end

function Enemies.draw(enemy, index)
  
  -- if enemy boss is hit then change hue to red so it shows some blooood
  if (enemy.isBoss) then
    if (enemy.isHit) then
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
    else
      gfx.draw(enemy.img, enemy.x, enemy.y)
    end
    Enemies.drawLife(enemy)
  else
    -- Every enemy draws itself
    enemy:draw()
    
    if (not(enemy.enemyType == nil) and enemy.enemyType > 0) then
      Enemies.drawLife(enemy)
    end
  end
  
  if showBoundingBoxes then
    for i, box in ipairs(enemy.boxes) do
        gfx.rectangle("line",enemy.x+box[1], enemy.y+box[2], box[3], box[4])
      end
  end
end

function Enemies.drawLife(enemy)
  local offset = 2
  local width = enemy.width/enemy.maxHitCounter
  if (width < 10) then
    offset=0
  else
    width = math.min(width-2, 10)
  end
  
  for i=1,enemy.hitCounter do 
    gfx.setColor(186, 251, 255)
    gfx.rectangle("fill", enemy.x + (i-1)*(width+offset), enemy.y-10, width, 5)
  end
  gfx.setColor(255, 255, 255)
end

function Enemies.enemyHit(enemy, index)

  enemy.hitCounter = enemy.hitCounter - 1;
  enemy.isHit = true

  if joystick ~= nil and joystick:isVibrationSupported() then
    joystick:setVibration( 0.5, 0.5, 0.2 )
  end

  -- enemy downed if hitcounter reaches 0
  if enemy.hitCounter <= 0 then
    
    table.remove(Enemies.enemies, index)
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
      Enemies.bossAlive = false
      Sounds.perfect:play()
      Sounds.setMusicForNormalPlay()
    end
    
    return true
  else
    if not enemy.isBoss then
      enemy.hitClock = 0.2
      if (Sounds.explodeSound:isPlaying()) then
        Sounds.explodeSound:rewind()
      else
        Sounds.explodeSound:play()
      end
    end
    return false
  end
end

function Enemies.reset()
  
  Enemies.enemies = {}
  Enemies.enemiesKilled = 0
  Enemies.bossAlive = false
  
end