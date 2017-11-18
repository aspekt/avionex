Ballistics = {
  shots = {},         -- array of shots
}

function Ballistics.shootAtPlayer(x,y,player)
  
  x1 = player.x + player.width/2
  y1 = player.y + player.height/2
  
  d = math.sqrt((x1 - x)^2+(y1-y)^2)
  dt = 3 + playerLevel
  t = dt/d
  
  vX = (1-t)*x + t*x1 - x
  vY = (1-t)*y + t*y1 - y
  
  Ballistics.createShot(x,y,vX,vY,1)
end

function Ballistics.threeShotDown(x,y)
  
end

function Ballistics.createShot(x,y,vX,vY,shotType) 
    newShot = {x=x, y=y, vX=vX, vY=vY, shotType=shotType, radius=5}
    table.insert(Ballistics.shots, newShot)
end

function Ballistics.updatePositions(dt)
  for i, shot in ipairs(Ballistics.shots) do
		shot.x = shot.x + shot.vX;
    shot.y = shot.y + shot.vY;
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
  gfx.setColor(255, 255, 255)
  gfx.circle("fill", shot.x, shot.y, shot.radius, 5) -- Draw white circle with 100 segments.
end