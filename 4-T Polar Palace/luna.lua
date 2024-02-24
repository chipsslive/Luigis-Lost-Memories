local slm = require("simpleLayerMovement")
local respawnRooms = require("respawnRooms")
local spawnzones = require("spawnzones")

function onStart()
    slm.addLayer{name = "leftToRight",speed = 250,horizontalMovement = slm.MOVEMENT_COSINE,horizontalSpeed = 70,horizontalDistance = 1.2}
    slm.addLayer{name = "rightToLeft",speed = 250,horizontalMovement = slm.MOVEMENT_COSINE,horizontalSpeed = 70,horizontalDistance = -1.2}
    GameData.awardCoins = false
end

function onExitLevel()
    GameData.awardCoins = true
end

function respawnRooms.onPostReset(fromRespawn)
    slm.addLayer{name = "leftToRight",speed = 250,horizontalMovement = slm.MOVEMENT_COSINE,horizontalSpeed = 70,horizontalDistance = 1.2}
    slm.addLayer{name = "rightToLeft",speed = 250,horizontalMovement = slm.MOVEMENT_COSINE,horizontalSpeed = 70,horizontalDistance = -1.2}
end