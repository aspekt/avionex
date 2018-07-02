Ballistics = {
  shots = {},         -- array of shots
  shot_images = {gfx.newImage('assets/boss/missile.png'),
                 gfx.newImage('assets/boss/energy_shot.png')}
}

function Ballistics.shootAtPlayer(x,y)
  
  local player = Player.getRandomPlayer()
  x1 = player.x + player.width/2
  y1 = player.y + player.height/2
  speed = 4 + playerLevel/2
  
  vector = createDirectionVector(x,y,x1,y1,speed)
  
  Ballistics.createShot(x,y,vector[1],vector[2],1)
end

function Ballistics.threeShotDown(x,y)
  speed = 3.5 +playerLevel/2
  
  -- Straight Shot
  vector = createDirectionVector(x,y,x,y+100,speed)
  Ballistics.createShot(x,y,vector[1],vector[2],2)
  
  -- To the left
  vector = createDirectionVector(x,y,x-30,y+100,speed)
  Ballistics.createShot(x,y,vector[1],vector[2],2)
  
  -- To the right
  vector = createDirectionVector(x,y,x+30,y+100,speed)
  Ballistics.createShot(x,y,vector[1],vector[2],2)
end

function Ballistics.circularShots(x,y,cnt)
  speed = 3.5 +playerLevel/2
  
  for i=1,cnt do 
    vector = createDirectionVector(x,y,x+100*math.cos(i*math.pi/cnt*2+math.pi/4), y+100*math.sin(i*math.pi/cnt*2+math.pi/4),speed)
    Ballistics.createShot(x,y,vector[1],vector[2],5)
  end
  --[[
  --C′′x=rcosα
  --and
  --C′′y=rsinα
  
  -- Diag up left
  vector = createDirectionVector(x,y,x-100,y-100,speed)
  Ballistics.createShot(x,y,vector[1],vector[2],5)
  
  -- Diag down left
  vector = createDirectionVector(x,y,x-100,y+100,speed)
  Ballistics.createShot(x,y,vector[1],vector[2],5)
  
  -- Diag up right
  vector = createDirectionVector(x,y,x+100,y-100,speed)
  Ballistics.createShot(x,y,vector[1],vector[2],5)
  
  -- Diag down right
  vector = createDirectionVector(x,y,x+100,y+100,speed)
  Ballistics.createShot(x,y,vector[1],vector[2],5)
  --]]
end

function Ballistics.bossOneShotDown(boss)
  speed = 5 + 2 * boss.bossLevel
  
  vector = createDirectionVector(1,1,1,10,speed-2)
  Ballistics.createShot(boss.x+11,boss.y+113,vector[1],vector[2],3)
  
  vector = createDirectionVector(1,1,1,20,speed)
  Ballistics.createShot(boss.x+63,boss.y+132,vector[1],vector[2],3)
  
  vector = createDirectionVector(1,1,1,30,speed)
  Ballistics.createShot(boss.x+141,boss.y+132,vector[1],vector[2],3)
  
  vector = createDirectionVector(1,1,1,40,speed-2)
  Ballistics.createShot(boss.x+195,boss.y+113,vector[1],vector[2],3)

end

function Ballistics.bossTwoShotDown(boss, player)
  x1 = player.x + player.width/2
  y1 = player.y + player.height/2
  speed = 5 + 2 * boss.bossLevel
  vector = createDirectionVector(boss.x,boss.y,x1,y1,speed)
  Ballistics.createShot(boss.x+boss.width/2-22,boss.y+boss.height-10,vector[1],vector[2],4)
end

function Ballistics.createShot(x,y,vX,vY,shotType) 
    newShot = nil
    if shotType == 1 or shotType == 5 then
      newShot = {x=x, y=y, vX=vX, vY=vY, shotType=shotType, radius=5}
      newShot.box = {-newShot.radius/2+1, -newShot.radius/2+1, newShot.radius-1, newShot.radius-1}
    elseif shotType == 2 then
      newShot = {x=x, y=y, vX=vX, vY=vY, shotType=shotType, radius=8}
      newShot.box = {-newShot.radius/2+1, -newShot.radius/2+1, newShot.radius-1, newShot.radius-1}
    elseif shotType == 3 then
      newShot = {x=x, y=y, vX=vX, vY=vY, shotType=shotType}
      newShot.img = Ballistics.shot_images[1]
      newShot.box = {0, 0, newShot.img:getWidth(), newShot.img:getHeight()}
    elseif shotType == 4 then
      newShot = {x=x, y=y, vX=vX, vY=vY, shotType=shotType}
      newShot.img = Ballistics.shot_images[2]
      newShot.box = {1, 1, newShot.img:getWidth()-2, newShot.img:getHeight()-2} 
      newShot.tween = tween.new(2, newShot, {x=x+vX*150, y=y+vY*150}, tween.easing.inSine)
    end
    table.insert(Ballistics.shots, newShot)
end

function Ballistics.updatePositions(dt)
  for i=table.getn(Ballistics.shots),1,-1 do
    local shot = Ballistics.shots[i]
    if shot.y + shot.box[2] > screenHeight or shot.x + shot.box[1] > screenWidth or shot.x + shot.box[1] - shot.box[3] < 0 then -- remove enemies when they pass off the screen
			table.remove(Ballistics.shots, i)
		else
      if (shot.tween == nil) then
        shot.x = shot.x + shot.vX;
        shot.y = shot.y + shot.vY;
      else
        if (shot.tween:update(dt)) then
          shot.tween = nil
        end
      end
    end
	end
end

function Ballistics.drawAll()
  for i, shot in ipairs(Ballistics.shots) do
    Ballistics.drawShot(shot)
	end
end

function Ballistics.checkCollisionsPlayer(player)
  for j=table.getn(Ballistics.shots),1,-1 do
    local shot = Ballistics.shots[j]
			if CheckCollisionShotPlayer(shot, player) then  
        table.remove(Ballistics.shots, j)
        return true
      end
  end
  return false
end

function Ballistics.drawShot(shot)
  if shot.shotType == 1 or shot.shotType == 5 then
    gfx.setColor(255, 255, 255)
    gfx.circle("fill", shot.x, shot.y, shot.radius, 8)
  elseif shot.shotType == 2 then
    gfx.setColor(28, 235, 247)
    gfx.circle("fill", shot.x, shot.y, shot.radius, 8)
    gfx.setColor(255, 255, 255)
  elseif shot.shotType ==3 or shot.shotType ==4 then
    gfx.draw(shot.img, shot.x, shot.y)
  end
end

function Ballistics.reset()
  Ballistics.shots = {}
end