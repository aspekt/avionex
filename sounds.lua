Sounds = {
}

function Sounds.init()

-- sfx
--bgm = love.audio.play("assets/music.wav", "stream", true) -- stream and loop background music
Sounds.gunSound = love.audio.newSource("assets/gun-sound.wav", "static")
Sounds.explodeSound = love.audio.newSource("assets/explodemini.wav", "static")
Sounds.explodePlayer = love.audio.newSource("assets/explode.wav", "static")
--masterCombo = love.audio.newSource("assets/master_combo.mp3", "static")
Sounds.comboBreaker = love.audio.newSource("assets/KI_Sounds_Combo_Breaker.mp3", "static")
--killerCombo = love.audio.newSource("assets/KI_Sounds_Killer_Combo.mp3", "static")
--ultraCombo = love.audio.newSource("assets/KI_Sounds_Ultra_Combo.mp3", "static")
Sounds.showNoMercy = love.audio.newSource("assets/ShowNoMercy.wav", "static")

Sounds.ready = love.audio.newSource("assets/Ready.mp3", "static")
Sounds.gameOver = love.audio.newSource("assets/GameOver.mp3", "static")
Sounds.shieldUp = love.audio.newSource("assets/mk3-21185.mp3", "static")
--	sfxShieldUp:setVolume(1)

Sounds.perfect =  love.audio.newSource("assets/Perfect.mp3", "static")
Sounds.finishHim = love.audio.newSource("assets/mk1-finishhim.mp3", "static")

Sounds.combos = { love.audio.newSource("assets/KI_Sounds_Triple_Combo.mp3", "static"),
            love.audio.newSource("assets/KI_Sounds_Killer_Combo.mp3", "static"),
            love.audio.newSource("assets/master_combo.mp3", "static"),
            love.audio.newSource("assets/KI_Sounds_Ultra_Combo.mp3", "static"),
            love.audio.newSource("assets/KI_Sounds_Brutal_Combo.mp3", "static"),
            love.audio.newSource("assets/ShowNoMercy.wav", "static")}
Sounds.blast = love.audio.newSource("assets/blast.wav", "static")
Sounds.threeShotDown = love.audio.newSource("assets/3shotsdown.wav", "static")
Sounds.powerup = love.audio.newSource("assets/mk3-00535.mp3", "static")

Sounds.music = love.audio.newSource("assets/22.-trailblazer-original-arcade-soundtrack-.mp3") -- if "static" is omitted, LÖVE will stream the file from disk, good for longer music tracks
Sounds.music:setLooping(true)
Sounds.music:setVolume(0.7) -- so player can hear the sfx at 100% volume

end