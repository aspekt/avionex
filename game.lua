-- Timers
-- We declare these here so we don't have to edit them multiple place
createEnemyTimerMax = 1
createPowerUpTimeMax = 15

--bulletSpeed = 400
enemySpeed = 150
playerSpeed = 250
kamikazeSpeed = 50
baseBulletSpeed = 250
currentBulletSpeed = baseBulletSpeed
maxEnemiesAtOnce = 2

showBoundingBoxes = false
useEffect = true

playerLevel = 1

bulletSpeeds = {250, 300, 400, 500, 500} -- FIXME: Cambiar esto por algo decente y que sea dinamico
bulletShootTimer = {0.2, 0.15, 0.1, 0.1, 0.1} -- FIXME: Igual que arriba

missedEnemies = 0
enemiesToNextLevel = 20
asteroidRainCount = 0

changedLevel = false

isGamePaused = false

Game = {}

function Game.startNewGame()
  score = 0
	playerLevel = 1
	showTextReady = true
	showNewLevel = true
	shotsFired = 0
	missedEnemies = 0
	isAlive = true
end

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
      Enemy.createEnemyTimer = (createEnemyTimerMax * 1/playerLevel)

      -- Create an enemy
      local enemyType = math.random(3)
      local enemySpeed = math.random(10, (50 * playerLevel/2))
      local shootTimer = math.random()
      
      Enemy.spawnEnemy(enemyType, playerSpeed - enemySpeed, shootTimer, math.ceil(playerLevel/2))
      
    end
  end  
end

function Game.updateAsteroidRain(dt)
  Enemy.createEnemyTimer = Enemy.createEnemyTimer - (1 * dt)
  if Enemy.createEnemyTimer < 0 then
    Enemy.createEnemyTimer = (createEnemyTimerMax * 1/playerLevel)
    local asteroidSpeed = math.random(10, (50 * playerLevel))
    Enemy.spawnAsteroid(playerSpeed + enemySpeed)
    asteroidRainCount = asteroidRainCount + 1
    
    if (asteroidRainCount == 50*playerLevel/2) then
      playerLevel = playerLevel + 1
      changedLevel = true;
      showNewLevel = true;
    end
  end 
end

function Game.enemyKilled(enemy)
  -- if boss killed, go up level
  if enemy.isBoss then
    enemy.isHit = true

    if enemyKilled then
      asteroidRainCount = 0
      playerLevel = playerLevel + 1
      maxEnemiesAtOnce = 2 + playerLevel*2
      changedLevel = true;
      showNewLevel = true;
    end
    
  else
    -- after 20 hits, spawn boss
    if Enemy.enemiesKilled % enemiesToNextLevel == 0 then 
      Sounds.perfect:play()
      if not Enemy.bossAlive then
        Enemy.spawnBoss()
      end
    end
  end
end