Enemy = {
  enemies = {},         -- array of current enemies
  enemyImgs = nil,      -- array with enemy sprites
  enemyBoxes = nil,     -- array of enemy bounding boxes
  createEnemyTimer = 0,
  bossImgs = nil,
  bossAlive = false,
  enemiesKilled = 0
}

function Enemy.init()
  
  Enemy.createEnemyTimer = createEnemyTimerMax
  
  spritesheet1 = love.graphics.newImage('assets/1945.png')
	local g64 = anim8.newGrid(64,64, 1024,768, 299,101, 2)
	--animation = anim8.newAnimation(g('1-8',1), 0.1)
	animPlane = anim8.newAnimation(g64(1,'1-3'), 0.1)
	animPlane:flipV() -- look down


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
end

function Enemy.spawnEnemy()
  
  randomNumber = math.random(10, gfx.getWidth() - 100)
  randomSpeed = math.random(10, (50 * playerLevel));
  randomImg = math.random(6);
  kamikaze = math.random() < 0.5

  newEnemy = { x = randomNumber, y = -50, img = Enemy.enemyImgs[randomImg] , isKamikaze=kamikaze, num=randomImg, speed = enemySpeed + randomSpeed, width = 100, height = 100, hitCounter=1, isBoss = false, boxes=Enemy.enemyBoxes[randomImg]}
  table.insert(Enemy.enemies, newEnemy)
  
end

function Enemy.spawnBoss()
  Enemy.bossAlive = true
  newBoss = { x = 150, y = -150, img = Enemy.bossImgs[1], width = 304, height = 400, speed = playerSpeed, hitCounter=20*playerLevel, isBoss = true, goingLeft = true, boxes=Enemy.bossBoxes[1]}
  table.insert(Enemy.enemies, newBoss)
  sfxFinishHim:play()
end


function Enemy.updatePositions(dt)
  for i, enemy in ipairs(Enemy.enemies) do
		if not enemy.isBoss then
      Enemy.moveEnemy(enemy, i, dt)
    else
      Enemy.moveBoss(enemy, dt)
    end
	end
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
  if boss.y < 0 then
    boss.y = boss.y + (boss.speed * dt)
  else
    if boss.goingLeft then
      if boss.x > 20 then
        boss.x = boss.x - (boss.speed * dt)
      else
        boss.goingLeft = false
      end
    else
      if boss.x < 300 then
        boss.x = boss.x + (boss.speed * dt)
      else
        boss.goingLeft = true
      end
    end
  end
end

function Enemy.drawAll()
  for i, enemy in ipairs(Enemy.enemies) do
    Enemy.draw(enemy)
	end
end

function Enemy.draw(enemy)
  --animPlane:draw( spritesheet1, enemy.x, enemy.y)
  gfx.draw(enemy.img, enemy.x, enemy.y)
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

    if (explodeSound:isPlaying()) then
      explodeSound:rewind()
    else
      explodeSound:play()
    end
    
    if enemy.isBoss then
      Enemy.bossAlive = false
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