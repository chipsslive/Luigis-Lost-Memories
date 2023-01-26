local respawnRooms = require("respawnRooms")

local startTimer = false
local timer = 0

local startTimer2 = false
local timer2 = 0

local stopMusic = false

function onEvent(eventName)
    if eventName == "boss death" then
        stopMusic = true
        startTimer2 = true
    end

    if eventName == "boss start" then
        SFX.play("bossintro.mp3")
        startTimer = true
    end
end

function onTick()
    if startTimer then
        timer = timer + 1
        if timer == 330 then
            Audio.MusicChange(9,"1-3 Tangled Tower/Yoshi's Island - Big Boss.mp3")
        end
    end

    if startTimer2 then
        timer2 = timer2 + 1
        if timer2 == 300 then
            SFX.play("bossclear.mp3")
        end
    end

    if stopMusic then
        if player.section == 9 then
            if not musicSeized then
                Audio.SeizeStream(-1)
                musicSeized = true
            end
            
            Audio.MusicStop()
        end
    end
end

function respawnRooms.onPostReset(fromRespawn)
    startTimer = false
    timer = 0
    startTimer2 = false
    timer2 = 0
    stopMusic = false
end