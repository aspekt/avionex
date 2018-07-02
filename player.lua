Player = {
  img = nil,
  thumbnail = nil,
  shieldImg = nil,
  playersAlive = false,
  superSpeed1 = false,
  superSpeed2 = false,
  superSpeed = false,
  originalSpeed = 0,
  numPlayers = 0,
  numAlive = 0,
  x = 0,
  y = 0,
  players = {}
}

--Player.x = (love.graphics.getWidth() / 2) - (Player.width / 2) -- medio trucho pero funca

function Player.init()
  playerImages = {
    gfx.newImage("assets/new_player1.png"),
    gfx.newImage("assets/new_player2.png"),
    gfx.newImage("assets/new_player3.png"),
    gfx.newImage("assets/new_player4.png")
  }
  playerBoxes = {
    {{34, 6, 14, 58}, {18, 37, 46, 28}, {26, 22, 30, 15}},
    {{34, 6, 14, 58}, {18, 37, 46, 28}, {26, 22, 30, 15}},
    {{34, 6, 14, 58}, {10, 37, 62, 28}, {26, 22, 30, 15}},
    {{34, 6, 14, 58}, {10, 37, 62, 28}, {26, 22, 30, 15}}
  }

  Player.thumbnail = gfx.newImage("assets/player_thumb.png")

  Player.img = playerImages[1]
  Player.boxes = playerBoxes[1]
  Player.shieldImg = gfx.newImage("assets/64_shield.png")

  Player.bulletImgs = {
    gfx.newImage("assets/bullet.png"),
    gfx.newImage("assets/new_bullet.png"),
    gfx.newImage("assets/new_bullet2.png"),
    gfx.newImage("assets/bullet_orange.png"),
    gfx.newImage("assets/bullet_purple.png")
  }
end

function Player.spawnPlayer(input)
  Player.playersAlive = true
  Player.numPlayers = Player.numPlayers + 1
  local newPlayer = {
    canShoot = true, -- Player is ready to shoot or not
    canShootTimer = 1, -- Timer to next shot
    x = 0,
    y = 710,
    speed = playerSpeed,
    originalSpeed = playerSpeed,
    input = input,
    img = playerImages[1],
    thumbnail = Player.thumbnail,
    numShots = 1,
    shieldImg = Player.shieldImg,
    isShieldOn = false,
    shieldTimer = timeToShieldOn,
    timeToShieldOn = timeToShieldOn,
    timeToShieldOff = timeToShieldOff,
    isAlive = true,
    bullets = {}, -- array of user shot bullets being drawn and updated
    superSpeed = false,
    bulletImgs = nil,
    width = playerImages[1]:getWidth(),
    height = playerImages[1]:getHeight(),
    boxes = playerBoxes[1],
    num = Player.numPlayers,
    score = 0,
    countdown = nil,
    lives = 3 -- how many lives left? 3 to start with
  }

  newPlayer.x = screenWidth / 2 - newPlayer.width / 2
  newPlayer.y = screenHeight - newPlayer.height - 30
  Player.numAlive = Player.numAlive + 1
  table.insert(Player.players, newPlayer)
end

function Player.updateTimers(dt)
  for index, player in ipairs(Player.players) do
    if not (player.countdown == nil) then
      if (player.countdown < 1) then
        player.lives = 0
        player.countdown = nil
        Player.setPlayersAlive()
      else
        player.countdown = player.countdown - 1 * dt
      end
    end
  end

  -- No player alive, do nothing
  if not Player.playersAlive then
    return
  end

  for index, player in ipairs(Player.players) do
    -- Time out how far apart our shots can be.
    player.canShootTimer = player.canShootTimer - (1 * dt)
    player.shieldTimer = player.shieldTimer - (1 * dt)

    if player.canShootTimer < 0 then
      player.canShoot = true
    end

    if player.isShieldOn and player.shieldTimer <= 0 then
      player.isShieldOn = false
      player.shieldTimer = player.timeToShieldOn
    end
  end
end

function Player.updateBulletPositions(dt)
  for index, player in ipairs(Player.players) do
    for index2 = table.getn(player.bullets), 1, -1 do
      local bullet = player.bullets[index2]
      bullet.y = bullet.y - (bullet.speed * dt)
      if bullet.y < 0 then -- remove bullets when they pass off the screen
        table.remove(player.bullets, index2)
      end
    end
  end
end

function Player.bulletHit(index, player)
  table.remove(player.bullets, index)
end

function Player.dead(player)
  player.isAlive = false
  Sounds.explodePlayer:play()
  local explosion = getExplosion(getBlast(300))
  explosion:setPosition(player.x + player.width / 2, player.y + player.height / 2)
  explosion:emit(20)
  table.insert(explosions, explosion)
  player.lives = player.lives - 1
  if (player.lives > 0) then
    player.countdown = 10
  end

  if player.input == "joystick1" and joystick1:isVibrationSupported() then
    joystick1:setVibration(0.7, 0.7, 0.6)
  elseif player.input == "joystick2" and joystick2:isVibrationSupported() then
    joystick2:setVibration(0.7, 0.7, 0.6)
  end

  if not Player.canContinue(player) then
  end

  Sounds.gameOver:play()
  Player.setPlayersAlive()
  Player.numAlive = Player.numAlive - 1
end

function Player.setPlayersAlive()
  local allLives = 0
  --Player.playersAlive = false
  for i, player in ipairs(Player.players) do
    --Player.playersAlive = Player.playersAlive or player.isAlive
    allLives = allLives + player.lives
  end

  if (allLives == 0) then
    Game.playing = false
    Game.showGameOver = true
  end
end

function Player.canContinue(player)
  return player.lives > 0
end

function Player.continue(player)
  -- move player back to default position
  player.countdown = nil
  player.x = screenWidth / 2 - 40
  player.y = screenHeight - 100
  player.isAlive = true
  player.originalSpeed = playerSpeed
  player.speed = playerSpeed
  player.timeToShieldOn = timeToShieldOn
  player.timeToShieldOff = timeToShieldOff
  player.isShieldOn = true
  player.shieldTimer = timeToShieldOff
  player.numShots = 1
  player.img = playerImages[player.numShots]
  player.boxes = playerBoxes[player.numShots]

  Player.numAlive = Player.numAlive + 1
  --Sounds.perfect:play()
end

function Player.getPlayerByInput(input)
  for i, player in ipairs(Player.players) do
    if player.input == input then
      return player
    end
  end
  return nil
end

function Player.updateMove(dt)
  -- No player alive, do nothing
  if not Player.playersAlive then
    return
  end

  Input.handlePlayerMovement(dt)

  for i, player in ipairs(Player.players) do
    if (player.x < -player.width / 2) then
      player.x = -player.width / 2
    end
    if (player.x > screenWidth - player.width / 2) then
      player.x = screenWidth - player.width / 2
    end
    if (player.y > screenHeight - player.height) then
      player.y = screenHeight - player.height
    end
    if (player.y < -player.height / 2) then
      player.y = -player.height / 2
    end
  end
end

function Player.updateShot(dt)
  -- No player alive, do nothing
  if not Player.playersAlive then
    return
  end

  local shotInput = Input.hasShot()
  if not (shotInput == nil) then
    for i, input in ipairs(shotInput) do
      local player = Player.getPlayerByInput(input)

      if (not (player == nil) and player.isAlive and player.canShoot) then
        bulletSpeed = currentBulletSpeed + (playerLevel * 20)
        local spaceBetweenShots = 20
        local separation = spaceBetweenShots * (player.numShots - 1)

        for i = 1, player.numShots do
          local img = player.numShots
          if (img > 3) then
            img = 3
          end
          newBullet1 = {
            x = player.x + player.width / 2 - 5 - separation / 2 + (i - 1) * spaceBetweenShots,
            y = player.y,
            img = Player.bulletImgs[img],
            speed = bulletSpeed
          }
          table.insert(player.bullets, newBullet1)
          shotsFired = shotsFired + 1
        end

        if (Sounds.gunSound:isPlaying()) then
          Sounds.gunSound:rewind()
        else
          Sounds.gunSound:play()
        end
        player.canShoot = false
        player.canShootTimer = bulletShootTimer[player.numShots]
      end
    end
  end
end

function Player.reset(player)
  player.bullets = {}
  player.isShieldOn = false
  player.shieldTimer = timeToShieldOff
  player.timeToShieldOn = timeToShieldOn
  player.timeToShieldOff = timeToShieldOff

  -- reset timers
  player.canShootTimer = 1
  player.numShots = 1
  player.img = playerImages[player.numShots]
  player.boxes = playerBoxes[player.numShots]
  player.createEnemyTimer = createEnemyTimerMax

  -- move player back to default position
  player.x = screenWidth / 2 - 40
  player.y = screenHeight - 100
  player.isAlive = true
  player.lives = 3
end

function Player.drawAll()
  -- No player alive, do nothing
  if not Player.playersAlive then
    return
  end

  for i, player in ipairs(Player.players) do
    Player.drawShots(player)
    Player.drawPlayer(player)
  end
end

function Player.drawShots(player)
  for i, bullet in ipairs(player.bullets) do
    gfx.draw(bullet.img, bullet.x, bullet.y)
  end
end

function Player.drawPlayer(player)
  if player.isAlive then
    gfx.draw(player.img, player.x, player.y)

    if showBoundingBoxes == true then
      for i, box in ipairs(player.boxes) do
        gfx.rectangle("line", player.x + box[1], player.y + box[2], box[3], box[4])
      end
    end

    if player.isShieldOn then
      gfx.draw(player.shieldImg, player.x + 2, player.y - 10, 0, 0.3, 0.3)
    else
      if (Sounds.shieldUp:isPlaying()) then
        Sounds.shieldUp:stop()
      end
    end
  end
end

function Player.addPowerUp(powerUp, player)
  if (player.isAlive) then
    if (powerUp.type == PowerUps.POWERUP_TYPE_LIFE) then
      if (player.lives < 3) then
        player.lives = player.lives + 1
        Sounds.perfect:play()
        HUD.ShowTextPlayer("+ 1 Life!", player, 1)
      end
    elseif (powerUp.type == PowerUps.POWERUP_TYPE_SHOT) then
      if player.numShots < 3 then
        player.numShots = player.numShots + 1
        player.img = playerImages[player.numShots]
        player.boxes = playerBoxes[player.numShots]
        HUD.ShowTextPlayer("+ Shots", player, 1)
      end
    elseif (powerUp.type == PowerUps.POWERUP_TYPE_SHIELD) then
      if player.timeToShieldOff < 5 then
        player.timeToShieldOn = player.timeToShieldOn - 1
        player.timeToShieldOff = player.timeToShieldOff + 1
        HUD.ShowTextPlayer("+ Shield", player, 1)
      end
    elseif (powerUp.type == PowerUps.POWERUP_TYPE_SPEED) then
      if (player.originalSpeed < 400) then
        player.originalSpeed = player.originalSpeed + 50
        player.speed = player.speed + 50
        HUD.ShowTextPlayer("+ Speed", player, 1)
      end
    end
  end
end

function Player.setSuperSpeed(player, flag)
  if flag then
    player.superSpeed = true
    player.speed = player.originalSpeed * 2
  else
    player.superSpeed = false
    player.speed = player.originalSpeed
  end
  if (player.num == 1) then
    Player.superSpeed1 = player.superSpeed
  else
    Player.superSpeed2 = player.superSpeed
  end
  Player.superSpeed = Player.superSpeed1 or Player.superSpeed2
end

function Player.setShield(player)
  if (not player.isShieldOn and player.shieldTimer <= 0) then
    player.isShieldOn = true
    player.shieldTimer = player.timeToShieldOff
    Sounds.shieldUp:play()
  end
end

function Player.getRandomPlayer()
  if Player.numPlayers == 1 then
    return Player.players[1]
  else
    return Player.players[math.random(2)]
  end
end
