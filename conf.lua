-- Configuration
function love.conf(t)
	t.title = "COSMIC FIGHTER - A BURGER GAMES PROJECT" -- The title of the window the game is in (string)
	t.version = "0.10.2"         -- The LÖVE version this game was made for (string)
	t.window.width = 1000        -- we want our game to be long and thin.
	t.window.height = 600
	t.window.resizable = true
	t.window.fullscreentype = "desktop" -- desktop / exclusive

	t.window.fullscreen = true  
	
	-- For Windows debugging
	t.console = true

	t.window.highdpi = true     
	t.accelerometerjoystick = true   
	t.modules.touch = true
	
	--modes = love.window.getFullscreenModes()
	--table.sort(modes, function(a, b) return a.width*a.height < b.width*b.height end)   -- sort from smallest to largest

end
