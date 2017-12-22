Input = {
}

function Input.startButton()
  local ret = nil
  if love.keyboard.isDown('return') then
    if (ret == nil) then ret = {} end
    table.insert(ret,"keyboard")
  end
  
  if (joystick1 ~= nil and joystick1:isGamepadDown('start')) then
    if (ret == nil) then ret = {} end
    table.insert(ret,"joystick1")
  end
  
  if (joystick2 ~= nil and joystick2:isGamepadDown('start')) then
    if (ret == nil) then ret = {} end
    table.insert(ret,"joystick2")
  end
  
  return ret
end

function Input.hasShot()
  
  local ret = nil
  if love.keyboard.isDown(' ', 'rctrl', 'lctrl', 'ctrl','space') then
    if (ret == nil) then ret = {} end
    table.insert(ret,"keyboard")
  end
  
  if (joystick1 ~= nil and joystick1:isDown(1)) then
    if (ret == nil) then ret = {} end
    table.insert(ret,"joystick1")
  end
  
  if (joystick2 ~= nil and joystick2:isDown(1)) then
    if (ret == nil) then ret = {} end
    table.insert(ret,"joystick2")
  end
  
  return ret
end
  
function Input.handlePlayerMovement(dt)
  local player=nil
  
	-- check joystick
	if joystick1 ~= nil then
    
    player = Player.getPlayerByInput("joystick1")
    
    if not (player == nil) then
      
			player.x = player.x + joystick1:getGamepadAxis("leftx") * (player.speed*dt)
			player.y = player.y + joystick1:getGamepadAxis("lefty") * (player.speed*dt)
				
      if joystick1:isGamepadDown("dpleft") then
				if player.x > 0 - player.img:getWidth()/2 then-- binds us to the map
					player.x = player.x - (player.speed*dt)
				end
			elseif joystick1:isGamepadDown("dpright") then
				if player.x < (screenWidth - player.img:getWidth()/2) then
					player.x = player.x + (player.speed*dt)
				end
			end
			if joystick1:isGamepadDown("dpup") then
				if player.y > 50 then
					player.y = player.y - (player.speed*dt)
				end
			elseif joystick1:isGamepadDown("dpdown") then
				if player.y < (screenHeight - 55) then
					player.y = player.y + (player.speed*dt)
				end
			end
      
      Player.setSuperSpeed(player, joystick1:isGamepadDown('x'))
      
      -- Shield!
      if (joystick1:isGamepadDown('b')) then
        Player.setShield(player)
      end
    end
	end
  
  if joystick2 ~= nil then
    
    player = Player.getPlayerByInput("joystick2")
    
    if not (player == nil) then
      
			player.x = player.x + joystick2:getGamepadAxis("leftx") * (player.speed*dt)
			player.y = player.y + joystick2:getGamepadAxis("lefty") * (player.speed*dt)
				
      if joystick2:isGamepadDown("dpleft") then
				if player.x > 0 - player.img:getWidth()/2 then -- binds us to the map
					player.x = player.x - (player.speed*dt)
				end
			elseif joystick2:isGamepadDown("dpright") then
				if player.x < (screenWidth - player.img:getWidth()/2) then
					player.x = player.x + (player.speed*dt)
				end
			end
			if joystick2:isGamepadDown("dpup") then
				if player.y > 50 then
					player.y = player.y - (player.speed*dt)
				end
			elseif joystick2:isGamepadDown("dpdown") then
				if player.y < (screenHeight - 55) then
					player.y = player.y + (player.speed*dt)
				end
			end
      
      -- SuperSpeed
      Player.setSuperSpeed(player, joystick2:isGamepadDown('x'))
      
      -- Shield!
      if (joystick2:isGamepadDown('b')) then
        Player.setShield(player)
      end
    end
	end
  
  player = Player.getPlayerByInput("keyboard")
  
  if not (player == nil) then
    if love.keyboard.isDown('left','a') then
      player.isTurningLeft = true
      if player.x > 0 - player.img:getWidth()/2 then -- binds us to the map
        player.x = player.x - (player.speed*dt)
      end
    elseif love.keyboard.isDown('right','d') then
      player.isTurningRight = true
      if player.x < (screenWidth - player.img:getWidth()/2) then
        player.x = player.x + (player.speed*dt)
      end
    end

    if love.keyboard.isDown('up', 'w') then
      if player.y > 50 then
        player.y = player.y - (player.speed*dt)
      end
    elseif love.keyboard.isDown('down', 's') then
      if player.y < (screenHeight - 55) then
        player.y = player.y + (player.speed*dt)
      end
    end
    
    if love.keyboard.isDown(' ', 'z') or love.keyboard.isDown("lshift") then
      Player.setSuperSpeed(player, true)
    else  
      Player.setSuperSpeed(player, false)
    end
    
    if love.keyboard.isDown(' ', 'x') then
      Player.setShield(player)
    end
    
  end
end