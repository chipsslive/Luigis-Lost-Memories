local warpTransition = require("warpTransition")
local respawnRooms = require("respawnRooms")

local RocketTree1
local myLayerTimer = 0

warpTransition.activateOnInstantWarps = true

function onStart()
    RocketTree1 = Layer.get("Rocket Tree 1")
end

function onEvent(eventName)
    if eventName == "Launch Tree1" then
        if RocketTree1 then
            myLayerTimer = myLayerTimer + 1

            RocketTree1.speedY = math.cos(myLayerTimer/200)*-7
        end

        SFX.play("helmets_propellerBox_boost1.wav")
    end

    if eventName == "Launch Tree 2" then
        SFX.play("helmets_propellerBox_boost3.wav")
        player.speedX = 0
    end

    if eventName == "LuigiFree" then
        warpTransition.activateOnInstantWarps = false
    end
end

function respawnRooms.onPostReset(fromRespawn)
    myLayerTimer = 0
end