local slm = require("simpleLayerMovement")
local lineguide = require("lineguide")
local spawnzones = require("spawnzones")
local respawnRooms = require("respawnRooms")

lineguide.registerNPCs(67)
lineguide.properties[67] = {lineSpeed = 2}

function onStart()
    GameData.awardCoins = false

    slm.addLayer{name = "small barrel",speed = 96,verticalMovement = slm.MOVEMENT_COSINE,verticalSpeed = 64,verticalDistance = 0.2}
    slm.addLayer{name = "large barrel",speed = 96,verticalMovement = slm.MOVEMENT_COSINE,verticalSpeed = 64,verticalDistance = -0.2}
end

function onExitLevel()
    GameData.awardCoins = true
end

function respawnRooms.onPostReset(fromRespawn)
    slm.addLayer{name = "small barrel",speed = 96,verticalMovement = slm.MOVEMENT_COSINE,verticalSpeed = 64,verticalDistance = 0.2}
    slm.addLayer{name = "large barrel",speed = 96,verticalMovement = slm.MOVEMENT_COSINE,verticalSpeed = 64,verticalDistance = -0.2}
end