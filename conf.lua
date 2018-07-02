-- Configuration
function love.conf(t)
	t.title = "COSMIC FIGHTER - A BURGER GAMES PROJECT" -- The title of the window the game is in (string)
	t.version = "11.1" -- The LÖVE version this game was made for (string)
	t.window.width = 800 -- we want our game to be long and thin.
	t.window.height = 900
	t.window.resizable = true
	t.window.fullscreentype = "desktop" -- desktop / exclusive

	t.window.fullscreen = false

	-- For Windows debugging
	t.console = true

	t.window.highdpi = true
	t.accelerometerjoystick = true
	t.modules.touch = true

	--modes = love.window.getFullscreenModes()
	--table.sort(modes, function(a, b) return a.width*a.height < b.width*b.height end)   -- sort from smallest to largest
end

-- Fixes game size, and later it is scaled to window/fullscreen
screenWidth = 800
screenHeight = 845
