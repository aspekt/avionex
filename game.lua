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

showBoundingBoxes = false
useEffect = true

playerLevel = 1

bulletSpeeds = {250, 300, 400, 500, 500} -- FIXME: Cambiar esto por algo decente y que sea dinamico
bulletShootTimer = {0.2, 0.15, 0.1, 0.1, 0.1} -- FIXME: Igual que arriba

missedEnemies = 0

changedLevel = false

isGamePaused = false

Game = {}

function Game.enemyKilled(enemy)
  -- if boss killed, go up level
  if enemy.isBoss then
    enemy.isHit = true

    if enemyKilled then
      if (playerLevel < 5) then -- fixme: solo tenes 5 levels... 
        playerLevel = playerLevel + 1
        changedLevel = true;
      end
    end
    
  else
    -- after 20 hits, spawn boss
    if Enemy.enemiesKilled % 20 == 0 then 
      Sounds.perfect:play()

      if not Enemy.bossAlive then
      Enemy.spawnBoss()
      end
    end
  end
end