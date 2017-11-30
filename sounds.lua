Sounds = {
    mainVolume = 0.7,
    trackNumber = 1
}


--[[

WHERE TO GET SOUNDS

https://www.playonloop.com/2017-music-loops/power-battle/


]]
function Sounds.init()

-- sfx
--bgm = love.audio.play("assets/music.wav", "stream", true) -- stream and loop background music
Sounds.gunSound = love.audio.newSource("assets/gun-sound.wav", "static")
Sounds.explodeSound = love.audio.newSource("assets/explodemini.wav", "static")
Sounds.explodePlayer = love.audio.newSource("assets/explode.wav", "static")
Sounds.comboBreaker = love.audio.newSource("assets/KI_Sounds_Combo_Breaker.mp3", "static")
Sounds.showNoMercy = love.audio.newSource("assets/ShowNoMercy.wav", "static")

Sounds.ready = love.audio.newSource("assets/Ready.mp3", "static")
Sounds.gameOver = love.audio.newSource("assets/GameOver.mp3", "static")
Sounds.shieldUp = love.audio.newSource("assets/zapsplat_science_fiction_alarm_loop_016_12614.mp3", "static")
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

Sounds.musicTracks = {  love.audio.newSource("assets/sounds/POL-twin-turbo-long.mp3"),
                        love.audio.newSource("assets/sounds/POL-cosmic-speedway-long.mp3"),
                        love.audio.newSource("assets/sounds/POL-crime-fighter-long.mp3"),
                        love.audio.newSource("assets/sounds/POL-galaxy-force-long.mp3"),
                        love.audio.newSource("assets/sounds/POL-underground-army-long.mp3")}

Sounds.music = Sounds.musicTracks[1] -- if "static" is omitted, LÖVE will stream the file from disk, good for longer music tracks
Sounds.music:setLooping(true)
Sounds.music:setVolume(Sounds.mainVolume) -- so player can hear the sfx at 100% volume

Sounds.musicBossBattle = love.audio.newSource("assets/sounds/POL-underground-army-long.mp3") 
Sounds.musicBossBattle:setLooping(true)
Sounds.musicBossBattle:setVolume(Sounds.mainVolume) -- so player can hear the sfx at 100% volume

end

function Sounds.skipToNextMusicTrack()
    

    Sounds.trackNumber = Sounds.trackNumber + 1
    local max = table.getn(Sounds.musicTracks)
    if (Sounds.trackNumber > max) then Sounds.trackNumber = 1 end
    Sounds.music:stop() 
    Sounds.music = Sounds.musicTracks[Sounds.trackNumber]
    Sounds.music:play()
     
 end

function Sounds.setMusicForBossBattle()
   
    Sounds.music:setVolume(0.1) 
    Sounds.musicBossBattle:play()
    
end

function Sounds.setMusicForNormalPlay()    
     Sounds.music:setVolume(Sounds.mainVolume) 
     Sounds.musicBossBattle:stop()     
end


