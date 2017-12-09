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

WaveThreeShots = Wave:extend(function(class,parent)
  
  function class:init()
    parent.init(self)
  end
  
  function class:setLevel(level)
    -- Three sets of enemies, 2-1-2 or 1-2-1 (level1), 3-2-3 or 2-3-2 (level2), 2-4-2 or 3-1-4 (level3)
    local sets = {{{2,1,2}, {1,2,1}}, {{3,2,3}, {2,3,2}}, {{2,4,2}, {3,1,4}}}
    local moves = sets[level][math.random(2)]
    local enemyTimer = 4+(level-1)*2
    
    for i=1, table.getn(moves) do
      for j=1, moves[i] do
        local newEnemy = EnemyUpDown:new()
        newEnemy:setLevel(level)
        newEnemy.startX = (j-0.5) * (screenWidth-newEnemy.width)/(moves[i]) 
        newEnemy.y=-100
        table.insert(self.enemies, newEnemy)
        if (j == moves[i]) then
          table.insert(self.enemyTimers, enemyTimer)
        else
          table.insert(self.enemyTimers, 0)
        end
        self.enemyStillAlive = self.enemyStillAlive + 1
      end
    end
  end
end)

WaveOneShots = Wave:extend(function(class,parent)
  
  function class:init()
    parent.init(self)
  end
  
  function class:setLevel(level)
    -- Three sets of enemies, 2-1-2 or 1-2-1 (level1), 3-2-3 or 2-3-2 (level2), 2-4-2 or 3-1-4 (level3)
    local sets = {{{2,1,2}, {1,2,1}}, {{3,2,3}, {2,3,2}}, {{2,4,2}, {3,1,4}}}
    local moves = sets[level][math.random(2)]
    local enemyTimer = 4+(level-1)*2
    
    for i=1, table.getn(moves) do
      for j=1, moves[i] do
        local down = math.random(100)
        local newEnemy = EnemyLeftRight:new(j%2, down, down+150)
        newEnemy:setLevel(level)
        table.insert(self.enemies, newEnemy)
        if (j == moves[i]) then
          table.insert(self.enemyTimers, enemyTimer)
        else
          table.insert(self.enemyTimers, 0.4)
        end
        self.enemyStillAlive = self.enemyStillAlive + 1
      end
    end
  end
end)

WaveKamikaze = Wave:extend(function(class,parent)
  
  function class:init()
    parent.init(self)
  end
  
  function class:setLevel(level)
    -- Three sets of enemies, 2-1-2 or 1-2-1 (level1), 3-2-3 or 2-3-2 (level2), 2-4-2 or 3-1-4 (level3)
    local sets = {{{2,3,2}, {3,2,3}}, {{4,3,4}, {3,4,3}}, {{5,6,5}, {6,5,6}}}
    local moves = sets[level][math.random(2)]
    local enemyTimer = 4+(level-1)*2
    
    for i=1, table.getn(moves) do
      for j=1, moves[i] do
        local upSide = math.random(2)
        local newEnemy = EnemyKamikaze:new()
        if (upSide == 1) then
          -- From above
          newEnemy.x = math.random(screenWidth)
          newEnemy.y = -50
        else
          if (math.random(2) == 1) then
            newEnemy.x = -10 - newEnemy.width
          else
            newEnemy.x = screenWidth + 10 + newEnemy.width
          end
          newEnemy.y = math.random(100)  
        end
        
        newEnemy:setLevel(level)
        table.insert(self.enemies, newEnemy)
        if (j == moves[i]) then
          table.insert(self.enemyTimers, enemyTimer)
        else
          table.insert(self.enemyTimers, 0.2)
        end
        self.enemyStillAlive = self.enemyStillAlive + 1
      end
    end
  end
end)

-- Random Waves
WaveRandom = Wave:extend(function(class,parent)
  
  function class:init()
    parent.init(self)
  end
  
  function class:setLevel(level)
    local enemyTimer = 1-(level-1)*0.2
    for i=1,(math.random(4)+level) do
      local enemyType = math.random(4)
      local newEnemy = nil
      if (enemyType == 1) then   
        newEnemy = EnemyKamikaze:new()
        newEnemy.x = math.random(screenWidth)
      elseif (enemyType == 2) then
        newEnemy = EnemyLeftRight:new(math.random(2), math.random(40), 100+math.random(140))
      elseif (enemyType == 3) then  
        newEnemy = EnemyUpDown:new()
        newEnemy.x = math.random(screenWidth)
      elseif (enemyType == 4) then  
        newEnemy = EnemyStraight:new()  
        newEnemy.x = math.random(screenWidth)
      end
      newEnemy:setLevel(level)
      table.insert(self.enemies, newEnemy)
      table.insert(self.enemyTimers, enemyTimer)
      self.enemyStillAlive = self.enemyStillAlive + 1
    end
  end
  
end)

-- Random Waves
WaveMines = Wave:extend(function(class,parent)
  
  function class:init()
    parent.init(self)
  end
  
  function class:setLevel(level)
    local enemyTimer = 1-(level-1)*0.2
    for j=1,2 do
      for i=1,(math.random(4)+level*2) do
        local newEnemy = EnemyMine:new()
        newEnemy.x = math.random(screenWidth)
        newEnemy:setLevel(level)
        table.insert(self.enemies, newEnemy)
        table.insert(self.enemyTimers, enemyTimer)
        self.enemyStillAlive = self.enemyStillAlive + 1
      end
      self.enemyTimers[table.getn(self.enemyTimers)] = 5
    end
  end
  
end)


-- Wave of straight down enemies
WaveOne = Wave:extend(function(class,parent)
  
  function class:init()
    parent.init(self)
  end
  
  function class:setLevel(level)
    local loop = math.random() < 0.5
    local moveType = math.random(3)
    local numEnemies = 4+level
    local enemyTimer = 1-(level-1)*0.2
    
    if (moveType == 1) then
      -- Left to right
      for i=1,(numEnemies) do
        local newEnemy = EnemyStraight:new()
        newEnemy:setLevel(level)
        newEnemy.x = (i-1) * (screenWidth+newEnemy.width)/numEnemies + newEnemy.width/2
        table.insert(self.enemies, newEnemy)
        table.insert(self.enemyTimers, enemyTimer)
        self.enemyStillAlive = self.enemyStillAlive + 1
      end
      
      if (loop) then
        for i=(numEnemies-1),1,-1 do
          local newEnemy = EnemyStraight:new()
          newEnemy:setLevel(level)
          newEnemy.x = (i-1) * (screenWidth+newEnemy.width)/numEnemies + newEnemy.width/2
          table.insert(self.enemies, newEnemy)
          table.insert(self.enemyTimers, enemyTimer)
          self.enemyStillAlive = self.enemyStillAlive + 1
        end
      end
    elseif (moveType == 2) then
      --Right to left
      for i=(numEnemies),1,-1 do
        local newEnemy = EnemyStraight:new()
        newEnemy:setLevel(level)
        newEnemy.x = (i-1) * (screenWidth+newEnemy.width)/numEnemies + newEnemy.width/2
        table.insert(self.enemies, newEnemy)
        table.insert(self.enemyTimers, enemyTimer)
        self.enemyStillAlive = self.enemyStillAlive + 1
      end
      
      if (loop) then
        for i=2, (numEnemies) do
          local newEnemy = EnemyStraight:new()
          newEnemy:setLevel(level)
          newEnemy.x = (i-1) * (screenWidth+newEnemy.width)/numEnemies + newEnemy.width/2
          table.insert(self.enemies, newEnemy)
          table.insert(self.enemyTimers, enemyTimer)
          self.enemyStillAlive = self.enemyStillAlive + 1
        end
      end
    elseif (moveType == 3) then
      -- Center, left, right
      for i=1, numEnemies do
        local newEnemy = EnemyStraight:new()
        newEnemy:setLevel(level)
        if (i%2 == 1) then
          newEnemy.x = (math.floor(numEnemies/2) + math.floor(i/2)+1-1) * (screenWidth+newEnemy.width)/(numEnemies+1) + newEnemy.width
        else
          newEnemy.x = (math.ceil(numEnemies/2) - (math.floor((i-1)/2)+1)-1) * (screenWidth+newEnemy.width)/(numEnemies+1) + newEnemy.width
        end
        table.insert(self.enemies, newEnemy)
        table.insert(self.enemyTimers, enemyTimer)
        self.enemyStillAlive = self.enemyStillAlive + 1
      end
      
      if (loop) then
        for i=(numEnemies-1), 1, -1 do
          local newEnemy = EnemyStraight:new()
          newEnemy:setLevel(level)
          if (i%2 == 1) then
            newEnemy.x = (math.floor(numEnemies/2) + math.floor(i/2)+1-1) * (screenWidth+newEnemy.width)/(numEnemies+1) + newEnemy.width
          else
            newEnemy.x = (math.ceil(numEnemies/2) - (math.floor((i-1)/2)+1)-1) * (screenWidth+newEnemy.width)/(numEnemies+1) + newEnemy.width
          end
          table.insert(self.enemies, newEnemy)
          table.insert(self.enemyTimers, enemyTimer)
          self.enemyStillAlive = self.enemyStillAlive + 1
        end
      end
    end
  end
end)