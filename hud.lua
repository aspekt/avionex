HUD = {
  textsInScreen = {},      -- all texts on screen that expire
	playerLevelTextPos = {x = 0, y = 0, duration = 3},
	Logo = nil
}

function HUD.init()
  
  --	font = gfx.newFont(14) -- the number denotes the font size
	gfx.setNewFont("assets/octab-017.ttf", 26)

	--HUD.ShowText("READY!", screenWidth / 2 - 50, 400, 3)
	
	-- get and set where we are shoing changed level texts
	--HUD.playerLevelTextPos.x = screenWidth / 2 - 50
	--HUD.playerLevelTextPos.y = 430

	--HUD.ShowText("LEVEL 1", HUD.playerLevelTextPos.x, HUD.playerLevelTextPos.y, HUD.playerLevelTextPos.duration)
  
  Logo = gfx.newImage('assets/cosmic-fighter_small_c.png')
end

function HUD.showLevel(level)
  --HUD.ShowText("LEVEL ".. level, screenWidth/2-40, 100, HUD.playerLevelTextPos.duration)			
end

function HUD.ShowText(text, x, y, timeout) 
	-- timeout -1 means permanent, else dissapers afer timeout seconds
	local t = {text = text, x = x, y = y, timeleft = timeout}
	table.insert(HUD.textsInScreen, t)
end

function HUD.ShowTextPlayer(text, player, timeout) 
	-- timeout -1 means permanent, else dissapers afer timeout seconds
	local t = {text = text, playerFollow = player, timeleft = timeout}
	table.insert(HUD.textsInScreen, t)
end


function HUD.update(dt)
  for i = table.getn(HUD.textsInScreen), 1, -1 do
		local t = HUD.textsInScreen[i]
		if (t.timeleft >= 0) then
			t.timeleft = t.timeleft - dt
			if (t.timeleft >-1 and t.timeleft <= 0) then
				table.remove(HUD.textsInScreen, i)
			end
		end
	end
  
  if (showNewLevel) then
    HUD.showLevel(playerLevel)
    showNewLevel=false
  end
  
end

function HUD.draw(dt)
  
  for i = table.getn(HUD.textsInScreen), 1, -1 do
		local t = HUD.textsInScreen[i]
    if not (t.x == nil) then
      gfx.print(t.text, t.x, t.y)
    else
      gfx.print(t.text, t.playerFollow.x, t.playerFollow.y+t.playerFollow.height+5)
    end
	end
  
  -- DRAW PLAYER GUI
  gfx.setColor(255, 255, 255)
  if (Game.playing) then
    for index, player in ipairs(Player.players) do
      local xPos = screenWidth - 180
      if (index == 2) then
        xPos = 20
      end
      gfx.print("P" .. tostring(index) .. ": " .. tostring(player.score), xPos+30, 10)    
      
      -- draw lives
      local i =  1
      while i <= player.lives do
        gfx.draw(player.thumbnail, xPos + (i * 30), 40)
        i = i + 1
      end
      
      -- draw shield
      gfx.setColor(255, 255, 255)
      gfx.print("SHIELD ", xPos, screenHeight - 30)
      if player.isShieldOn then
        gfx.setColor(255, 0, 0)
        local sizeBar = player.shieldTimer/player.timeToShieldOff * 100
        gfx.rectangle("fill", xPos + 70, screenHeight - 23, sizeBar, 15)
        gfx.setColor(255, 255, 255)
      else
        gfx.setColor(255, 255, 255)    
        local sizeBar = 100
        if player.shieldTimer > 0 then
          sizeBar = (player.timeToShieldOn-player.shieldTimer)/player.timeToShieldOn * 100
        else
          gfx.setColor(0, 255, 0)
        end
        gfx.rectangle("fill",xPos + 70, screenHeight - 23, sizeBar, 15)
        gfx.setColor(255, 255, 255)
      end
    end
  end
  
  gfx.setColor(255, 255, 255)
  
  if (Game.playing) then
    gfx.print("LEVEL: " .. tostring(playerLevel), screenWidth/2 - 40, screenHeight - 30)
  end
  
  gfx.setColor(255, 255, 255)

  if not Game.playing then
    if (Game.showGameOver) then
      gfx.print("GAME OVER", screenWidth/2-50, screenHeight/2)
    else
      gfx.print("Press 'Enter' or 'Start' to start", screenWidth/2-140, screenHeight/2+30)
    end
  else
    if not (Player.numAlive==Player.numPlayers) then
      local canContinue = false
      for index, player in ipairs(Player.players) do
        if (not player.isAlive and Player.canContinue(player)) then
          canContinue = true
          if Player.numPlayers == 2 then
            local xPos = screenWidth - 180
            if (index == 2) then
              xPos = 20
            end
            gfx.print("Continue? " .. tostring(math.floor(player.countdown)), xPos+30, 90)
          else
            gfx.print("Continue? " .. tostring(math.floor(player.countdown)), screenWidth/2-60, screenHeight/2+30)
          end
        end
      end
    end
  end

	gfx.draw(Logo, screenWidth/2-(Logo:getWidth()/2), 10)

	--gfx.print("KILLER SKIES", screenWidth/2-60, 10)

	if debug then
		gfx.print("FPS: "..tostring(FPS), screenWidth/2 - 30, screenHeight - 60)
	end  
  
end