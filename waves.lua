Wave = object:extend(function(class)
  
  function class:init()
    self.enemies = {}
    self.enemyTimers = {}
    self.enemyCount = 0
    self.enemyStillAlive = 0
    self.currentTimer = 0
    self.finished = false
  end
 
  function class:updateTimers(dt)
    self.currentTimer = self.currentTimer - (1*dt)
    if (self.currentTimer < 0) then
      self.enemyCount = self.enemyCount + 1
      if (self.enemyCount <= table.getn(self.enemies)) then
        Enemies.addEnemy(self.enemies[self.enemyCount])
        self.currentTimer = self.enemyTimers[self.enemyCount]
      end
    end
  end
  
  function class:enemyRemoved()
    self.enemyStillAlive = self.enemyStillAlive - 1
    self.finished = (self.enemyStillAlive == 0)
  end
  
end)

WaveOne = Wave:extend(function(class,parent)
  
  function class:init()
    parent.init(self)
  end
  
  function class:setLevel(level)
    for i=1,(4+level) do
      local newEnemy = EnemyStraight:new()
      newEnemy:setLevel(level)
      newEnemy.x = (i-1) * (screenWidth+newEnemy.width)/4 + newEnemy.width/2
      table.insert(self.enemies, newEnemy)
      table.insert(self.enemyTimers, 1)
      self.enemyStillAlive = self.enemyStillAlive + 1
    end
  end
  
end)

WaveTwo = Wave:extend(function(class,parent)
  
  function class:init()
    parent.init(self)
  end
  
  function class:setLevel(level)
    for i=1,(math.random(4)+level*2) do
      local enemyType = math.random(4)
      local newEnemy = nil
      if (enemyType == 1) then   
        newEnemy = EnemyKamikaze:new()
        newEnemy.x = math.random(screenWidth)
      elseif (enemyType == 2) then
        newEnemy = EnemyLeftRight:new()
      elseif (enemyType == 3) then  
        newEnemy = EnemyUpDown:new()
        newEnemy.x = math.random(screenWidth)
      elseif (enemyType == 4) then  
        newEnemy = EnemyStraight:new()  
        newEnemy.x = math.random(screenWidth)
      end
      newEnemy:setLevel(level)
      table.insert(self.enemies, newEnemy)
      table.insert(self.enemyTimers, 1)
      self.enemyStillAlive = self.enemyStillAlive + 1
    end
  end
  
end)