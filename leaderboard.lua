leaderboard = {
  inputInitials = false,
  currentPlayer = nil,
  currentInitials = "AAA",
  lastInputTimer = 0,
  lastInitials = "AAA",
  lastInitials2 = "AAA",
  currentLetter = 1,
  numPlayer = 1,
  font = love.graphics.newFont("assets/BPdotsSquare.otf", 80)
}

function loadLeaderboard()
  request =
    wapi.request(
    {
      method = "GET",
      url = "http://kobot.mybluemix.net/api/killerskies"
    },
    function(body, headers, code)
      leaderboard = json.decode(body)
      print(body)
    end
  )
end

function saveScore(initials, score)
  local payload = '{"initials":"' .. initials .. '","score":' .. score .. "}"
  local args = {
    method = "POST",
    url = "http://kobot.mybluemix.net/api/killerskies",
    body = payload,
    headers = {
      ["Content-Type"] = "application/json",
      ["Content-Length"] = payload:len()
    }
  }

  print(json.encode(args))

  request =
    wapi.request(
    args,
    function(body, headers, code)
      print(body)
    end
  )
end

function drawLeaderboard()
  gfx.push("all")
  gfx.setNewFont("assets/octab-017.ttf", 40)

  local w = screenWidth
  local h = screenHeight

  gfx.push("all")

  love.graphics.setBlendMode("alpha")
  love.graphics.setColor(0, 0, 0, 190)
  love.graphics.rectangle("fill", w / 2 - 150, 180, 300, 480)

  love.graphics.setColor(0, 255, 0, 200)

  love.graphics.print("HALL  OF  FAME", w / 2 - 110, 200)

  local i = 1
  while leaderboard[i] and i <= 10 do
    local score = leaderboard[i]
    love.graphics.print(i .. ".", w / 2 - 100, 200 + (i * 40))
    love.graphics.print(score["initials"], w / 2 - 50, 200 + (i * 40))
    love.graphics.print(score["score"], w / 2 + 40, 200 + (i * 40))
    i = i + 1
  end
  gfx.pop()

  gfx.pop()
end

function leaderboard.startInputInitials()
  leaderboard.inputInitials = true
  leaderboard.currentPlayer = Player.players[1]
  leaderboard.numPlayer = 1
  leaderboard.currentInitials = leaderboard.lastInitials
  leaderboard.currentLetter = 1
end

function leaderboard.updateTimers(dt)
  leaderboard.lastInputTimer = leaderboard.lastInputTimer - 1 * dt
  if (leaderboard.lastInputTimer <= 0) then
    local input = leaderboard.handleInitialsInputs(dt)
    if not (input == nil) then
      local letter = string.byte(leaderboard.currentInitials, leaderboard.currentLetter)
      if (input == "down") then
        letter = letter - 1
        if (letter < 58) then
          letter = 93
        end
      elseif (input == "up") then
        letter = letter + 1
        if (letter > 93) then
          letter = 58
        end
      elseif (input == "left" and leaderboard.currentLetter > 1) then
        leaderboard.currentLetter = leaderboard.currentLetter - 1
        letter = string.byte(leaderboard.currentInitials, leaderboard.currentLetter)
      elseif ((input == "right" or input == "click") and leaderboard.currentLetter < 3) then
        leaderboard.currentLetter = leaderboard.currentLetter + 1
        letter = string.byte(leaderboard.currentInitials, leaderboard.currentLetter)
      elseif ((input == "click" and leaderboard.currentLetter == 3) or input == "start") then
        saveScore(leaderboard.currentInitials, leaderboard.currentPlayer.score)
        if (leaderboard.numPlayer == 1) then
          leaderboard.lastInitials = leaderboard.currentInitials
        else
          leaderboard.lastInitials2 = leaderboard.currentInitials
        end

        if (Player.numPlayers > 1 and leaderboard.numPlayer < 2) then
          leaderboard.currentPlayer = Player.players[2]
          leaderboard.numPlayer = 2
          leaderboard.currentLetter = 1
          leaderboard.currentInitials = leaderboard.lastInitials2
        else
          leaderboard.inputInitials = false
        end
      end
      local newInitials = ""
      for i = 1, 3 do
        if (i == leaderboard.currentLetter) then
          newInitials = newInitials .. string.char(letter)
        else
          newInitials = newInitials .. string.sub(leaderboard.currentInitials, i, i)
        end
      end
      leaderboard.currentInitials = newInitials
      leaderboard.lastInputTimer = 0.1
    end
  end
end

function leaderboard.draw()
  gfx.setColor(0, 0, 0, 180)
  gfx.rectangle("fill", screenWidth / 2 - 120, screenHeight / 2 - 80, 240, 140)
  gfx.setColor(255, 255, 255)
  gfx.print("PLAYER " .. tostring(leaderboard.numPlayer), screenWidth / 2 - 80, screenHeight / 2 - 70)
  gfx.setFont(leaderboard.font)
  for i = 1, 3 do
    if (leaderboard.currentLetter == i) then
      gfx.setColor(255, 255, 0)
      gfx.rectangle("fill", screenWidth / 2 - 140 + i * 60, screenHeight / 2 + 40, 42, 3)
    else
      gfx.setColor(255, 255, 255)
    end
    gfx.print(string.sub(leaderboard.currentInitials, i, i), screenWidth / 2 - 140 + i * 60, screenHeight / 2 - 40)
  end
  gfx.setFont(HUD.font)
end

function leaderboard.handleInitialsInputs(dt)
  local player = nil

  -- check joystick
  if joystick1 ~= nil then
    player = Player.getPlayerByInput("joystick1")

    if not (player == nil) then
      if joystick1:isGamepadDown("dpleft") or joystick1:getGamepadAxis("leftx") < -0.7 then
        return "left"
      elseif joystick1:isGamepadDown("dpright") or joystick1:getGamepadAxis("leftx") > 0.7 then
        return "right"
      end
      if joystick1:isGamepadDown("dpup") or joystick1:getGamepadAxis("lefty") < -0.7 then
        return "up"
      elseif joystick1:isGamepadDown("dpdown") or joystick1:getGamepadAxis("lefty") > 0.7 then
        return "down"
      end

      -- Shield!
      if (joystick1:isGamepadDown("b") or joystick1:isDown(1)) then
        return "click"
      end

      if (joystick1:isGamepadDown("start")) then
        return "start"
      end
    end
  end

  if joystick2 ~= nil then
    player = Player.getPlayerByInput("joystick2")

    if not (player == nil) then
      if joystick2:isGamepadDown("dpleft") or joystick2:getGamepadAxis("leftx") < -0.7 then
        return "left"
      elseif joystick2:isGamepadDown("dpright") or joystick2:getGamepadAxis("leftx") > -0.7 then
        return "right"
      end
      if joystick2:isGamepadDown("dpup") or joystick2:getGamepadAxis("lefty") < -0.7 then
        return "up"
      elseif joystick2:isGamepadDown("dpdown") or joystick2:getGamepadAxis("lefty") > 0.7 then
        return "down"
      end

      if (joystick2:isGamepadDown("b") or joystick2:isDown(2)) then
        return "click"
      end

      if (joystick2:isGamepadDown("start")) then
        return "start"
      end
    end
  end

  player = Player.getPlayerByInput("keyboard")

  if not (player == nil) then
    if love.keyboard.isDown("left", "a") then
      return "left"
    elseif love.keyboard.isDown("right", "d") then
      return "right"
    end
    if love.keyboard.isDown("up", "w") then
      return "up"
    elseif love.keyboard.isDown("down", "s") then
      return "down"
    end

    if
      love.keyboard.isDown(" ", "z") or love.keyboard.isDown("lshift") or
        love.keyboard.isDown(" ", "rctrl", "lctrl", "ctrl", "space")
     then
      return "click"
    end

    if love.keyboard.isDown("return") then
      return "start"
    end
  end
  return nil
end
