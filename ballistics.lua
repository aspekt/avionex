Ballistics = {
  shots = {},         -- array of shots
}

function Ballistics.shootAtPlayer(x,y,player)
  
  x1 = player.x + player.width/2
  y1 = player.y + player.height/2
  speed = 3+playerLevel
  
  vector = createDirectionVector(x,y,x1,y1,speed)
  
  Ballistics.createShot(x,y,vector[1],vector[2],1)
end

function Ballistics.threeShotDown(x,y)
  speed = 2+playerLevel/2
  
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

function Ballistics.createShot(x,y,vX,vY,shotType) 
    newShot = nil
    if shotType == 1 then
      newShot = {x=x, y=y, vX=vX, vY=vY, shotType=shotType, radius=5}
    else
      newShot = {x=x, y=y, vX=vX, vY=vY, shotType=shotType, radius=8}
    end
    table.insert(Ballistics.shots, newShot)
end

function Ballistics.updatePositions(dt)
  for i, shot in ipairs(Ballistics.shots) do
    
    if shot.y + shot.radius > screenHeight or shot.x + shot.radius > screenWidth or shot.x - shot.radius < 0 then -- remove enemies when they pass off the screen
			table.remove(Ballistics.shots, i)
		else
      shot.x = shot.x + shot.vX;
      shot.y = shot.y + shot.vY;
    end
	end
end

function Ballistics.drawAll()
  for i, shot in ipairs(Ballistics.shots) do
    Ballistics.drawShot(shot)
	end
end

function Ballistics.checkCollisionsPlayer(player)
  for j, shot in ipairs(Ballistics.shots) do
			if CheckCollisionShotPlayer(shot, player) then  
        table.remove(Ballistics.shots, j)
        return true
      end
  end
  return false
end

function Ballistics.drawShot(shot)
  if shot.shotType == 1 then
    gfx.setColor(255, 255, 255)
  else
    gfx.setColor(28, 235, 247)
  end
  gfx.circle("fill", shot.x, shot.y, shot.radius, 8) -- Draw white circle with 100 segments.
end

function Ballistics.reset()
  Ballistics.shots = {}
end