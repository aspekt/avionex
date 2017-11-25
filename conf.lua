-- Configuration
function love.conf(t)
	t.title = "KILLER SKIES by BURGER GAMES" -- The title of the window the game is in (string)
	t.version = "0.10.2"         -- The LÖVE version this game was made for (string)
	t.window.width = 600        -- we want our game to be long and thin.
	t.window.height = 800
	t.window.resizable = true
	t.window.fullscreentype = "desktop"

	-- For Windows debugging
	t.console = true

	t.window.highdpi = false     
	t.accelerometerjoystick = true   
	t.modules.touch = true
	
	--modes = love.window.getFullscreenModes()
	--table.sort(modes, function(a, b) return a.width*a.height < b.width*b.height end)   -- sort from smallest to largest

end
