HUD = {
  textsInScreen = {},      -- all texts on screen that expire
	playerLevelTextPos = {x = 0, y = 0, duration = 3},
	Logo = nil
}

function HUD.init()
  
  --	font = gfx.newFont(14) -- the number denotes the font size
	gfx.setNewFont("assets/octab-017.ttf", 26)

	HUD.ShowText("READY!", screenWidth / 2 - 50, 400, 3)
	
	-- get and set where we are shoing changed level texts
	HUD.playerLevelTextPos.x = screenWidth / 2 - 50
	HUD.playerLevelTextPos.y = 430

	HUD.ShowText("LEVEL 1", HUD.playerLevelTextPos.x, HUD.playerLevelTextPos.y, HUD.playerLevelTextPos.duration)
  Logo = gfx.newImage('assets/cosmic-fighter_small_c.png')
end

function HUD.showLevel(level)
  HUD.ShowText("LEVEL ".. level, HUD.playerLevelTextPos.x, HUD.playerLevelTextPos.y, HUD.playerLevelTextPos.duration)			
end

function HUD.ShowText(text, x, y, timeout) 
	-- timeout -1 means permanent, else dissapers afer timeout seconds
	local t = {text = text, x = x, y = y, timeleft = timeout}
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
		gfx.print(t.text, t.x, t.y)
	end
  
  -- DRAW STATIC GUI
	gfx.setColor(255, 255, 255)
	gfx.print("SCORE: " .. tostring(score), screenWidth - 120, 10)

	local i =  1
	while i <= Player.lives do
		gfx.draw(Player.thumbnail, screenWidth - 160 + (i * 30), 40)
		i = i + 1
	end
	
	

	gfx.print("LEVEL: " .. tostring(playerLevel),9, 10 )
	gfx.print("MISSED: " .. tostring(missedEnemies), screenWidth - 100, screenHeight - 30)
	gfx.print("FIRED: " .. tostring(shotsFired), 10, screenHeight - 30)
  
  gfx.print("SHIELD ", screenWidth/2 - 100, screenHeight - 30)
  if Player.isShieldOn then
    gfx.setColor(255, 0, 0)
    local sizeBar = Player.shieldTimer/timeToShieldOff * 100
    gfx.rectangle("fill",screenWidth/2 - 30, screenHeight - 23, sizeBar, 15)
  else
    gfx.setColor(255, 255, 255)    
    local sizeBar = 100
    if Player.shieldTimer > 0 then
      sizeBar = (timeToShieldOn-Player.shieldTimer)/timeToShieldOn * 100
    else
      gfx.setColor(0, 255, 0)
    end
    gfx.rectangle("fill",screenWidth/2 - 30, screenHeight - 23, sizeBar, 15)
    gfx.setColor(255, 255, 255)
  end
  
  gfx.setColor(255, 255, 255)

	
	if not Player.isAlive then

		gfx.print("GAME OVER",screenWidth/2-50, screenHeight/2)

		if Player.canContinue() then
			-- offer to continue
			gfx.print("Press 'Enter' or 'Start' to continue", screenWidth/2-140, screenHeight/2+30)
			gfx.print(Player.lives.." LIVES LEFT", screenWidth/2-50, screenHeight/2 + 60)			
			
	  else
			gfx.print("Press 'Enter' or 'Start' to restart", screenWidth/2-140, screenHeight/2+30)
		end
	end

	gfx.draw(Logo, screenWidth/2-(Logo:getWidth()/2), 10)

	--gfx.print("KILLER SKIES", screenWidth/2-60, 10)

	if debug then
		gfx.print("FPS: "..tostring(FPS), 9, 35)
	end  
  
end