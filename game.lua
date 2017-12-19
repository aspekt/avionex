-- Timers
-- We declare these here so we don't have to edit them multiple place
createEnemyTimerMax = 2
createPowerUpTimeMax = 20

-- Shields
timeToShieldOn = 10
timeToShieldOff = 2

--bulletSpeed = 400
enemySpeed = 200
kamikazeSpeed = 50
baseBulletSpeed = 250
enemyMainShootTimer = 3
currentBulletSpeed = baseBulletSpeed
maxEnemiesAtOnce = 200
enemiesToNextLevel = 20

showBoundingBoxes = false

playerLevel = 1

bulletSpeeds = {250, 300, 400, 500, 500} -- FIXME: Cambiar esto por algo decente y que sea dinamico
bulletShootTimer = {0.25, 0.20, 0.15, 0.2, 0.1} -- FIXME: Igual que arriba

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
      if (enemyLevel > 5) then enemyLevel = 5 end
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

    if enemy.hitCounter<=0 then
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
  playerSpeed = 300
  enemySpeed = 150
	showTextReady = true
	showNewLevel = true
	shotsFired = 0
	missedEnemies = 0
  enemyMainShootTimer = 3
  maxEnemiesAtOnce = 300
	isAlive = true
  enemiesToNextLevel= 20
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
  enemiesToNextLevel = 20 + ((playerLevel)*5)
  changedLevel = true;
  showNewLevel = true;
  
  Game.currentWave = nil
  Game.timeBetweenWaves = math.random(2)
  Sounds:skipToNextMusicTrack()
end