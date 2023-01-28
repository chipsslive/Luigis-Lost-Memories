local slm = require("simpleLayerMovement")
local respawnRooms = require("respawnRooms")
local customExit = require("customExit")

local room
local lockPlayer = false
local bossActive = false

function onStart()
    slm.addLayer{name = "float",speed = 96,verticalMovement = slm.MOVEMENT_COSINE,verticalSpeed = 64,verticalDistance = 1}
end

function respawnRooms.onPostReset(fromRespawn)
    slm.addLayer{name = "float",speed = 96,verticalMovement = slm.MOVEMENT_COSINE,verticalSpeed = 64,verticalDistance = 1}
    lockPlayer = false
end

function onEvent(eventName)
    if eventName == "blwo up bridge" then
        lockPlayer = true
        player.speedX = 0
    end

    if eventName == "bye toad" then
        lockPlayer = false
    end

    if eventName == "Boss" then
        bossActive = true
    end

    if eventName == "Level - Start" then
        bossActive = false
    end

    if eventName == "Boss Exit" then
        bossActive = false
    end
end

function onTick()
    if lockPlayer then
        for k, v in pairs(player.keys) do
            player.keys[k] = false
        end
    end
end

function customExit.checkChallenge()
    Audio.MusicStop()
end

function onDraw()
    if not musicSeized and not customExit.isInExit then
        Audio.SeizeStream(-1)
        musicSeized = true
    end
    
    if stopMusic then
        Audio.MusicStop()
    elseif bossActive then
        Audio.MusicOpen("4-1 Smoldering Steppe/Red&Green - Strike!! Great Aerial Offensive.mp3")
        Audio.MusicPlay()
    elseif player.x < -184264 then
        Audio.MusicOpen("4-1 Smoldering Steppe/Red&Green- Inside the Volcano.mp3")
        Audio.MusicPlay()
    end
end