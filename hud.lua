HUD = {
  textsInScreen = {},      -- all texts on screen that expire
  playerLevelTextPos = {x = 0, y = 0, duration = 3}
}

function HUD.init()
  
  --	font = gfx.newFont(14) -- the number denotes the font size
	gfx.setNewFont("assets/octab-017.ttf", 26)

	HUD.ShowText("READY!", gfx:getWidth() / 2 - 40, 400, 3)
	
	-- get and set where we are shoing changed level texts
	HUD.playerLevelTextPos.x = gfx:getWidth() / 2 - 40
	HUD.playerLevelTextPos.y = 430

	HUD.ShowText("LEVEL 1", HUD.playerLevelTextPos.x, HUD.playerLevelTextPos.y, HUD.playerLevelTextPos.duration)
  
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
	gfx.print("SCORE: " .. tostring(score), gfx:getWidth() - 120, 10)
	gfx.print("LEVEL: " .. tostring(playerLevel),9, 10 )
	gfx.print("MISSED: " .. tostring(missedEnemies), gfx:getWidth() - 100, gfx:getHeight() - 30)
	gfx.print("FIRED: " .. tostring(shotsFired), 10, gfx:getHeight() - 30)
  
  gfx.print("SHIELD ", gfx:getWidth()/2 - 100, gfx:getHeight() - 30)
  if Player.isShieldOn then
    gfx.setColor(255, 0, 0)
    local sizeBar = Player.shieldTimer/timeToShieldOff * 100
    gfx.rectangle("fill",gfx:getWidth()/2 - 30, gfx:getHeight() - 23, sizeBar, 15)
  else
    gfx.setColor(255, 255, 255)    
    local sizeBar = 100
    if Player.shieldTimer > 0 then
      sizeBar = (timeToShieldOn-Player.shieldTimer)/timeToShieldOn * 100
    else
      gfx.setColor(0, 255, 0)
    end
    gfx.rectangle("fill",gfx:getWidth()/2 - 30, gfx:getHeight() - 23, sizeBar, 15)
    gfx.setColor(255, 255, 255)
  end
  
  gfx.setColor(255, 255, 255)

	if not Player.isAlive then
		gfx.print("GAME OVER",gfx:getWidth()/2-40, gfx:getHeight()/2)
		gfx.print("Press 'R' to restart", gfx:getWidth()/2-80, gfx:getHeight()/2+30)
	end

	gfx.print("KILLER SKIES", gfx:getWidth()/2-60, 10)

	if debug then
		gfx.print("FPS: "..tostring(FPS), gfx:getWidth() / 2 - 40, 35)
	end  
  
end