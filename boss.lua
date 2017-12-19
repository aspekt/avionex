Boss = object:extend(function(class)
    
  class.boss_images = {gfx.newImage('assets/boss/boss1.png'),
                       gfx.newImage('assets/boss/boss2.png')}
  class.boss_boxes = {{{0,0,212,112}},
                      {{2,4,229,116}}}
    
  function class:init(index)
    self.img = Boss.boss_images[index]
    self.boxes = Boss.boss_boxes[index]
    self.width = self.img:getWidth()
    self.height = self.img:getHeight() 
    self.score = 1000
    
    self.x = (screenWidth - self.width) / 2
    self.y = -100
  
    self.speed = playerSpeed
    self.isBoss = true
    self.goingLeft = true
    self.willShoot = true
    self.bossTween = nil
    self.comingOut = true
    self.charging = false
    self.lastCharging = false
    self.droppingMines = false
  end
 
  function class:setBossLevel(level)
    self.bossLevel = level
    self.hitCounter = level * 100
    self.maxHitCounter = self.hitCounter
    self.speed = 100 + 100 * level
    self.score = 1000 * level
    self.bossShootTimer = 3 - level
    self.shootTimer = self.bossShootTimer
  end
 
  function class:updateTimers(dt)
    -- must override
  end

  function class:moveBoss(dt)
    
    -- First come out
    if (self.comingOut) then
      if (self.y >= 50) then
        self.comingOut = false
      else
        self.y = self.y+ self.speed*dt
      end
    end
 end
end)

BossOne = Boss:extend(function(class,parent)
  function class:init()
    parent.init(self, 1)
  end
 
  function class:updateTimers(dt)
    self.shootTimer = self.shootTimer - (1*dt)
    
    if self.shootTimer < 0 then
      if self.droppingMines and self.lastCharging then
        Sounds.blast:play()                    
        local newEnemy = EnemyMine:new()
        newEnemy.x = self.x + self.width/2
        newEnemy.y = self.y + self.height
        newEnemy:setLevel(self.bossLevel)
        Enemies.addEnemy(newEnemy)
        self.shootTimer = 2 / (self.bossLevel*3)
       elseif not(self.charging) then
        Sounds.threeShotDown:play()          
        Ballistics.bossOneShotDown(self)
        self.shootTimer = math.random(self.bossShootTimer)
      end
    end
  end

  function class:moveBoss(dt)
    parent.moveBoss(self, dt)
   
    -- Then start moving
    if (not self.comingOut) then
      if (self.bossTween == nil) then
        local motion = math.random()
        if (motion <= 0.6 or self.lastCharging) then 
          self.lastCharging = false
          local xTo = 100 + math.random(screenWidth-100) - self.width/2
          local yTo = 100 + math.random(120)-self.width/2
          self.bossTween = tween.new(2, self, {x=xTo, y=yTo}, tween.easing.outBounce)
        elseif (motion>0.6 and motion <= 0.8) then
          self.droppingMines=true
          self.bossTween = tween.new(1, self, {x=5}, tween.easing.inCubic)
        else
          self.lastCharging=true
          self.charging=true
          self.bossTween = tween.new(1, self, {y=screenHeight-150}, tween.easing.inCubic)
        end
      end

      -- if complete, set to nil
      if (self.bossTween:update(dt)) then
        self.bossTween = nil
        if (self.charging) then
          if (self.y > screenHeight-200) then
            self.bossTween = tween.new(1, self, {y=50}, tween.easing.inCubic)
          else
            self.charging=false
          end
        elseif (self.droppingMines) then
          if not (self.lastCharging) then
            self.lastCharging=true
            self.shootTimer = -1
            self.bossTween = tween.new(2, self, {x=screenWidth-self.width}, tween.easing.linear)
          else
            self.droppingMines=false
          end
        end
      end
    end
  end
end)

BossTwo = Boss:extend(function(class,parent)
  function class:init()
    parent.init(self, 2)
    self.rafaga = 3
  end
 
  function class:setBossLevel(level)
    parent.setBossLevel(self,level)
    self.hitCounter = level * 100
    self.maxHitCounter = self.hitCounter
    self.bossShootTimer = 5 + math.random(5) - level*2
    self.rafaga = 4 + (level-1)*2
  end
 
  function class:updateTimers(dt)
    self.shootTimer = self.shootTimer - (1*dt)
    
    if self.shootTimer < 0 then
      if self.droppingMines and self.lastCharging then
        Sounds.blast:play()                    
        local newEnemy = EnemyKamikaze:new()
        newEnemy.x = self.x + self.width/2
        newEnemy.y = self.y
        newEnemy:setLevel(self.bossLevel*2)
        Enemies.addEnemy(newEnemy)
        self.shootTimer = 2 / (self.bossLevel*3)
      elseif not(self.charging) then
        Sounds.blast:play() 
        Ballistics.bossTwoShotDown(self, Player.getRandomPlayer())
        if (self.rafaga == 0) then
          self.shootTimer = math.random(self.bossShootTimer)
          self.rafaga = 4 + (self.bossLevel-1)*2
        else
          self.shootTimer = 0.5
          self.rafaga = self.rafaga-1
        end
      end
    end
  end

  function class:moveBoss(dt)
    parent.moveBoss(self, dt)
   
    -- Then start moving
    if (not self.comingOut) then
      if (self.bossTween == nil) then
        local motion = math.random()
        if (motion <= 0.6 or self.lastCharging) then 
          self.lastCharging = false
          local xTo = 100 + math.random(screenWidth-100) - self.width/2
          local yTo = 100 + math.random(120)-self.width/2
          self.bossTween = tween.new(2, self, {x=xTo, y=yTo}, tween.easing.outBounce)
        elseif (motion>0.6 and motion <= 0.8) then
          self.droppingMines=true
          self.bossTween = tween.new(1, self, {x=5}, tween.easing.inCubic)
        else
          self.lastCharging=true
          self.charging=true
          self.bossTween = tween.new(1, self, {y=screenHeight-150}, tween.easing.inCubic)
        end
      end

      -- if complete, set to nil
      if (self.bossTween:update(dt)) then
        self.bossTween = nil
        if (self.charging) then
          if (self.y > screenHeight-200) then
            self.bossTween = tween.new(1, self, {y=50}, tween.easing.inCubic)
          else
            self.charging=false
          end
        elseif (self.droppingMines) then
          if not (self.lastCharging) then
            self.lastCharging=true
            self.shootTimer = -1
            self.bossTween = tween.new(2, self, {x=screenWidth-self.width}, tween.easing.linear)
          else
            self.droppingMines=false
          end
        end
      end
    end
  end
end)