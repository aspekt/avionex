Enemy = object:extend(function(class)
    
  function class:init(enemyType)
    self.x = 0
    self.y = 0
    self.shootTimer = 1
    self.willShoot = false
    self.maxShootTimer = 6
    self.shotType = 1
    self.enemyType = 0
    self.level = 1
    self.speed = 100
    self.hitClock = 0
    self.hitCounter = 1
    self.isBoss = false
    self.img = Enemies.enemyImgs[enemyType]
    self.enemyType = enemyType
    self.width=self.img:getWidth()
    self.height=self.img:getHeight()
    self.score = 10
  end
  
  function class:setLevel(level)
    self.level = level
    self.speed = 100 + level * 25
    self.hitCounter = level+1
    self.score = 10 + (level-1)*20
  end
 
  function class:updateTimers(dt)
    self.shootTimer = self.shootTimer - (1*dt)
    if (self.hitClock > 0) then
      self.hitClock  = self.hitClock - (1*dt)
    end
    if self.willShoot then
      self.shootTimer = self.shootTimer - (1*dt)
      if self.shootTimer < 0 then
          
        if self.shotType == 1 then
          Sounds.blast:play()                    
          Ballistics.shootAtPlayer(self.x + self.width/2, self.y+self.height)
        else
          Sounds.threeShotDown:play()          
          Ballistics.threeShotDown(self.x + self.width/2, self.y+self.height)
        end
        self.shootTimer = self.maxShootTimer
      end
    end

  end

  function class:moveEnemy(dt, index)
    -- must override
  end
  
  function class:draw()
    if (self.hitClock > 0) then
      gfx.setColor(lue:getHueColor(100, 100))
      gfx.draw(self.img, self.x, self.y)
      gfx.setColor(255,255,255)
    else
      gfx.draw(self.img, self.x, self.y)
    end
  end
  
end)

EnemyKamikaze = Enemy:extend(function(class,parent)
  
  function class:init()
    parent.init(self, 1)
    self.boxes = { {1,1,72,66} }
    self.followPlayer = Player.getRandomPlayer()
    self.tween = nil
  end
  
  function class:moveEnemy(dt, index)
    --[[
    if (self.timeToVector == nil or self.timeToVector <= 0) then
      local vector = createDirectionVector(self.x, self.y, self.followPlayer.x, self.followPlayer.y, self.speed/50)
      self.dX = vector[1]
      self.dY = vector[2]
      self.timeToVector = 1
    end
    self.timeToVector = self.timeToVector - dt
    self.x = self.x + self.dX
    self.y = self.y + self.dY
    --]]
    
    if (self.tween == nil) then
      local vector = createDirectionVector(self.x, self.y, self.followPlayer.x, self.followPlayer.y, self.speed/50)
      local xTo = self.x + vector[1] * 100
      local yTo = self.y + vector[2] * 100
      self.tween = tween.new(2-(self.level-1)*0.3, self, {x=xTo, y=yTo}, tween.easing.outCirc)
    end

    -- if complete, set to nil
    if (self.tween:update(dt)) then
      self.tween = nil
    end
    
  end
  
  function class:draw()
    local angle = math.pi * 2 - math.atan((self.x-self.followPlayer.x)/math.abs(self.y-self.followPlayer.y))
    if (self.y<=self.followPlayer.y) then
      angle = math.atan((self.x-self.followPlayer.x)/math.abs(self.y-self.followPlayer.y)) - math.pi
    end
    if (self.hitClock>0) then
      gfx.setColor(lue:getHueColor(100, 100))
      gfx.draw(self.img, self.x+self.width/2, self.y+self.height/2, angle, 1, 1, self.width/2, self.height/2)
      gfx.setColor(255,255,255)
    else
      gfx.draw(self.img, self.x+self.width/2, self.y+self.height/2, angle, 1, 1, self.width/2, self.height/2)
    end
  end
  
end)

EnemyLeftRight = Enemy:extend(function(class,parent)
  
  function class:init(side, minY, maxY)
    parent.init(self, 2)
    self.willShoot = true
    self.boxes = { {26,8,25,49}, {12,26,54,31} }
    if (side == 1) then
      self.x = 0 - self.width
      self.dX = 1
    else
      self.x = screenWidth + self.width
      self.dX = -1
    end
    
    self.shootTime = 1.5
    self.minY = minY
    self.maxY = maxY
    self.y = self.minY
    self.shotType = 1
  end
  
  function class:moveEnemy(dt, index)
    self.y = self.maxY - math.sin((screenWidth - self.x)/screenWidth * math.pi) * (self.maxY-self.minY) 
    self.x = self.x + (self.speed * dt) * self.dX
    
    if (self.x < 0) then
      self.dX = 1
    end
    
    if (self.x > screenWidth - self.width) then
      self.dX = -1
    end
  end
end)

EnemyUpDown = Enemy:extend(function(class,parent)
  
  function class:init()
    parent.init(self, 3)
    self.willShoot = true
    self.boxes = { {1,39,68,29}, {7,26,58,11}, {25,7,22,20}}
    self.minY = 100
    self.maxY = 300
    self.startX = 100
    self.dY = 1
    self.shotType = 2
  end
  
  function class:moveEnemy(dt, index)
    self.x = self.startX + math.sin((self.y-self.minY) * 0.01 * math.pi)*25
    self.y = self.y + (self.speed * dt) * self.dY
    if (self.y > self.maxY) then
      self.dY = -1
    end
    
    if (self.y < self.minY) then
      self.dY = 1
    end
  end
end)

EnemyStraight = Enemy:extend(function(class,parent)
  
  function class:init()
    parent.init(self, 4)
    self.willShoot = false
    self.boxes = { {0,0,62,56}}
    self.speed = self.speed + 70
    self.y = -50
    self.dY = 1
  end
  
  function class:setLevel(level)
    self.level = level
    self.speed = 125 + level * 50
    self.hitCounter = level
  end
  
  function class:moveEnemy(dt, index)
    self.y = self.y + self.dY*self.speed/50
  end
end)

EnemyAsteroid = Enemy:extend(function(class,parent)
  
  function class:init(level)
    
    local asteroidType = math.random(6)
    local asteroidImg = Enemies.asteroidImgs[asteroidType]
    local randomPosition = 100 + math.random(screenWidth-asteroidImg:getWidth()-100)
    
    self.hitClock = 0
    self.x = randomPosition
    self.y = -40
    self.img = asteroidImg
    self.width=self.img:getWidth()
    self.height=self.img:getHeight()
    level = level/2
    if (level>3) then level = 3 end
    self.speed = 150+math.random(50) + level*30
    self.hitCounter=1000
    self.boxes = {{1,1,asteroidImg:getWidth()-2, asteroidImg:getHeight()-2}}
    self.willShoot = false
    self.shootTimer = 1
    
    self.dX = math.random()
    if (self.x > screenWidth/2 and math.random(2) == 1) then
      self.dX = self.dX * -1 * level/3
    end
    self.dY = (2+math.random()*3/2) * level/3
  end
  
  function class:moveEnemy(dt, index)
    self.y = self.y + (self.speed * dt) * self.dY
    self.x = self.x + (self.speed * dt) * self.dX
  end
end)