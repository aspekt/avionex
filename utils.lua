-- Collision detection taken function from http://love2d.org/wiki/BoundingBox.lua
-- Returns true if two boxes overlap, false if they don't
-- x1,y1 are the left-top coords of the first box, while w1,h1 are its width and height
-- x2,y2,w2 & h2 are the same, but for the second box
function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < ((x2+w2)) and
         x2 < ((x1+ w1)) and
         y1 < ((y2+ h2)) and
         y2 < ((y1+ h1))
end



function CheckCollisionEnemy(enemy, x2,y2,w2,h2)
  
  for i, box in ipairs(enemy.boxes) do
    if CheckCollision(enemy.x+box[1], enemy.y+box[2], box[3], box[4], x2, y2, w2, h2) then
      return true
    end
	end
  
  return false

end

function CheckCollisionEnemyBullet(enemy, bullet)
  
  for i, box in ipairs(enemy.boxes) do
    if CheckCollision(enemy.x+box[1], enemy.y+box[2], box[3], box[4], bullet.x, bullet.y, bullet.img:getWidth(), bullet.img:getHeight()) then
      return true
    end
	end
  
  return false

end

function CheckCollisionEnemyPlayer(enemy, player)
  for i, box in ipairs(player.boxes) do
    if CheckCollision(enemy.x, enemy.y, enemy.img:getWidth(), enemy.img:getHeight(), player.x+box[1], player.y+box[2], box[3], box[4]) then
      return true
    end
  end
  return false
end

function CheckCollisionShotPlayer(shot, player)
  for i, box in ipairs(player.boxes) do
    if player.isAlive and CheckCollision(shot.x + shot.box[1], shot.y + shot.box[2], shot.box[3], shot.box[4], player.x+box[1], player.y+box[2], box[3], box[4]) then
      return true
    end
  end
  return false
end

function CheckCollisionPowerUpPlayer(powerUp, player)
  for i, box in ipairs(player.boxes) do
    if CheckCollision(powerUp.x+6, powerUp.y, powerUp.width-12, powerUp.height, player.x+box[1], player.y+box[2], box[3], box[4]) then
      return true
    end
  end
  return false
end

-- sfx
--https://dev.to/jeansberg/make-a-shooter-in-lualove2d---animations-and-particles
function getBlast(size)
	local blast = love.graphics.newCanvas(size, size)
	love.graphics.setCanvas(blast)
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.circle("fill", size/2, size/2, size/2)
	love.graphics.setCanvas()
	return blast
  end

function getExplosion(image)
	pSystem = love.graphics.newParticleSystem(image, 30)
	pSystem:setParticleLifetime(0.5, 0.5)
	pSystem:setLinearAcceleration(-100, -100, 100, 100)
	pSystem:setColors(255, 255, 0, 255, 255, 153, 51, 255, 64, 64, 64, 0)
	pSystem:setSizes(0.5, 0.5)
	return pSystem
end

function updateExplosions(dt)
	for i = table.getn(explosions), 1, -1 do
	  local explosion = explosions[i]
	  explosion:update(dt)
	  if explosion:getCount() == 0 then
		table.remove(explosions, i)
	  end
	end
end

function createDirectionVector(x,y,x1,y1,speed)
  
  d = math.sqrt((x1 - x)^2+(y1-y)^2)
  dt = speed
  t = dt/d
  
  vX = (1-t)*x + t*x1 - x
  vY = (1-t)*y + t*y1 - y
  
  return {vX, vY}
  
end