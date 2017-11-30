-- Timers
-- We declare these here so we don't have to edit them multiple place
createEnemyTimerMax = 3
createPowerUpTimeMax = 50

--bulletSpeed = 400
enemySpeed = 150
playerSpeed = 250
kamikazeSpeed = 50
baseBulletSpeed = 250
enemyMainShootTimer = 3
currentBulletSpeed = baseBulletSpeed
maxEnemiesAtOnce = 2
enemiesToNextLevel = 20

showBoundingBoxes = false
useEffect = true

playerLevel = 1

bulletSpeeds = {250, 300, 400, 500, 500} -- FIXME: Cambiar esto por algo decente y que sea dinamico
bulletShootTimer = {0.3, 0.25, 0.2, 0.2, 0.1} -- FIXME: Igual que arriba

missedEnemies = 0
asteroidRainCount = 0

changedLevel = false

isGamePaused = false

Game = {}

--Enemy and level creation is moved here
function Game.updateTimers(dt)
  
  -- Odd levels with enemies
  if (playerLevel % 2 == 1) then 
    Game.updateLevelWithEnemies(dt)
  else
    Game.updateAsteroidRain(dt)
  end
  
end

function Game.updateLevelWithEnemies(dt)
  if not Enemy.bossAlive then
    Enemy.createEnemyTimer = Enemy.createEnemyTimer - (1 * dt)
    
    if Enemy.createEnemyTimer < 0 and table.getn(Enemy.enemies) < maxEnemiesAtOnce then
      Enemy.createEnemyTimer = createEnemyTimerMax

      -- Create an enemy
      local enemyType = math.random(3)
      local enemySpeed = math.random(10, (50 * playerLevel/2))
      local shootTimer = math.random()
      
      if (enemiesToNextLevel-table.getn(Enemy.enemies)>0) then
        Enemy.spawnEnemy(enemyType, playerSpeed - enemySpeed, shootTimer, math.ceil(playerLevel/2))
      end
    end
  end  
end

function Game.updateAsteroidRain(dt)
  Enemy.createEnemyTimer = Enemy.createEnemyTimer - (1 * dt)
  if Enemy.createEnemyTimer < 0 then
    Enemy.createEnemyTimer = createEnemyTimerMax/3 
    local asteroidSpeed = math.random(10, (50 * playerLevel))
    Enemy.spawnAsteroid(playerLevel)
    asteroidRainCount = asteroidRainCount + 1
    
    if (asteroidRainCount == 20+10*playerLevel/2) then
      Game.levelUp()
    end
  end 
end

function Game.enemyKilled(enemy)
  -- if boss killed, go up level
  if enemy.isBoss then
    enemy.isHit = true

    if enemyKilled then
      Game.levelUp()
    end
    
  else
    enemiesToNextLevel = enemiesToNextLevel - 1
    -- after 20 hits, spawn boss
    if enemiesToNextLevel <= 0 then 
      Sounds.perfect:play()
      if not Enemy.bossAlive then
        Enemy.spawnBoss(playerLevel)
      end
    end
  end
end

function Game.startNewGame()
  score = 0
	playerLevel = 1
  enemySpeed = 150
	showTextReady = true
	showNewLevel = true
	shotsFired = 0
	missedEnemies = 0
  enemyMainShootTimer = 3
  maxEnemiesAtOnce = 3
	isAlive = true
  enemiesToNextLevel=15
  createEnemyTimerMax = 2
end

function Game.levelUp()
  asteroidRainCount = 0
  enemyMainShootTimer = enemyMainShootTimer - 0.3
  if (enemyMainShootTimer <= 1) then
    enemyMainShootTimer = 1
  end
  createEnemyTimerMax = createEnemyTimerMax - 0.3
  if (createEnemyTimerMax <= 1) then
    createEnemyTimerMax = 1
  end
  enemySpeed = enemySpeed + 20
  playerLevel = playerLevel + 1
  maxEnemiesAtOnce = 3 + math.floor(playerLevel/2)
  enemiesToNextLevel = 15 + (playerLevel/2)*2
  changedLevel = true;
  showNewLevel = true;
end