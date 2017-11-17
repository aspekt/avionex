-- Configuration
function love.conf(t)
	t.title = "AVIONEX by BURGER GAMES" -- The title of the window the game is in (string)
	t.version = "0.10.2"         -- The LÖVE version this game was made for (string)
	t.window.width = 600        -- we want our game to be long and thin.
	t.window.height = 900

	-- For Windows debugging
	t.console = true

	t.window.highdpi = true     
	t.accelerometerjoystick = true   
	t.modules.touch = true  
end
