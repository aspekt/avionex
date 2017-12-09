-- Timers
-- We declare these here so we don't have to edit them multiple place
createEnemyTimerMax = 2
createPowerUpTimeMax = 15

-- Shields
timeToShieldOn = 10
timeToShieldOff = 2

--bulletSpeed = 400
enemySpeed = 150
kamikazeSpeed = 50
baseBulletSpeed = 250
enemyMainShootTimer = 3
currentBulletSpeed = baseBulletSpeed
maxEnemiesAtOnce = 200
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

Game = {
  playing = false,
  timeBetweenWaves = 1,
  currentWave = nil
}

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
  
  if not Game.playing then
    return
  end
  
  if not Enemies.bossAlive then
    Game.timeBetweenWaves = Game.timeBetweenWaves - (1*dt)
    
    if (Game.timeBetweenWaves < 0 and Game.currentWave == nil) then
      
      local waveType = math.random(6)
      if (waveType == 1) then
        Game.currentWave = WaveKamikaze:new();
      elseif (waveType == 2) then
        Game.currentWave = WaveOne:new();
      elseif (waveType == 3) then
        Game.currentWave = WaveThreeShots:new();
      elseif (waveType == 4) then
        Game.currentWave = WaveOneShots:new();
      elseif (waveType == 5) then
        Game.currentWave = WaveRandom:new();
      elseif (waveType == 6) then
        Game.currentWave = WaveMines:new();
      end
      
      local enemyLevel = math.ceil(playerLevel/2);
      if (enemyLevel > 3) then enemyLevel = 3 end
      Game.currentWave:setLevel(enemyLevel);
    end
    
    if not (Game.currentWave == nil) then
      Game.currentWave:updateTimers(dt)
      
      if (Game.currentWave.finished) then
        Game.currentWave = nil
        Game.timeBetweenWaves = math.random(2)
        if enemiesToNextLevel <= 0  then 
          Sounds.perfect:play()
          Game.launchBoss()
        end
      end
    end
    
    --[[
    Enemies.createEnemyTimer = Enemies.createEnemyTimer - (1 * dt)     

    if Enemies.createEnemyTimer < 0 and table.getn(Enemies.enemies) < maxEnemiesAtOnce then
      Enemies.createEnemyTimer = createEnemyTimerMax

      -- Create an enemy
      local enemyType = math.random(3)
      local enemySpeed = math.random(10, (50 * playerLevel/2))
      local shootTimer = math.random()
      
      if (enemiesToNextLevel-table.getn(Enemies.enemies)>0) then
        Enemies.spawnEnemy(enemyType, playerSpeed - enemySpeed, shootTimer, math.ceil(playerLevel/2))
      end
    end
    --]]
  end  
end

function Game.updateAsteroidRain(dt)
  Enemies.createEnemyTimer = Enemies.createEnemyTimer - (1 * dt)
  if Enemies.createEnemyTimer < 0 then
    Enemies.createEnemyTimer = createEnemyTimerMax/3 
    local asteroidSpeed = math.random(10, (35 * playerLevel))
    Enemies.spawnAsteroid(playerLevel)
    asteroidRainCount = asteroidRainCount + 1
    
    if (asteroidRainCount == 20+10*playerLevel/2) then
      Game.levelUp()
    end
  end 
end

function Game.enemyKilled(enemy)
  -- if boss killed, go up level
  if (enemy.score > 0) then
    local points = "+".. tostring(enemy.score)
    HUD.ShowText(points, enemy.x+enemy.width/2-(points:len()*12)/2, enemy.y+enemy.height/2-10, 1)
  end
  
  if enemy.isBoss then
    enemy.isHit = true

    if enemyKilled then
      Game.levelUp()
    end
    
  else
    enemy:enemyKilled()
    enemiesToNextLevel = enemiesToNextLevel - 1
    
    if not (Game.currentWave == nil) then
      Game.currentWave:enemyRemoved()
    end
    
    -- after 20 hits, spawn boss
    if enemiesToNextLevel <= 0 and (Game.currentWave == nil or Game.currentWave.finished) then 
      Sounds.perfect:play()
      Game.launchBoss()
    end
  end
end

function Game.launchBoss()
  if not Enemies.bossAlive then
    Enemies.spawnBoss(playerLevel)
  end
end

function Game.startNewGame()
  Game.playing = true
  score = 0
  playerLevel = 1
  playerSpeed = 200
  enemySpeed = 150
	showTextReady = true
	showNewLevel = true
	shotsFired = 0
	missedEnemies = 0
  enemyMainShootTimer = 3
  maxEnemiesAtOnce = 300
	isAlive = true
  enemiesToNextLevel=20
  createEnemyTimerMax = 2
  Player.players = {}
  Player.numPlayers = 0
  Player.numAlive = 0
  Player.playersAlive = false
  Enemies.reset()
  PowerUps.reset()
  Ballistics.reset()
  Game.currentWave = nil
  Game.timeBetweenWaves = math.random(2)
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
  maxEnemiesAtOnce = maxEnemiesAtOnce + math.floor(playerLevel/2)
  enemiesToNextLevel = 20 + ((playerLevel)*4)
  changedLevel = true;
  showNewLevel = true;
  
  Game.currentWave = nil
  Game.timeBetweenWaves = math.random(2)
end