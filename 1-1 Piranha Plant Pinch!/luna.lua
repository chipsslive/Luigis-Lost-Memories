local slm = require("simpleLayerMovement")
local respawnRooms = require("respawnRooms")

function onStart()
    slm.addLayer{name = "moving clouds",speed = 32,horizontalMovement = slm.MOVEMENT_COSINE,horizontalSpeed = 42,horizontalDistance = 0.15}
    slm.addLayer{name = "moving clouds2",speed = 32,horizontalMovement = slm.MOVEMENT_COSINE,horizontalSpeed = 42,horizontalDistance = -0.15}
end

function respawnRooms.onPostReset(fromRespawn)
    slm.addLayer{name = "moving clouds",speed = 32,horizontalMovement = slm.MOVEMENT_COSINE,horizontalSpeed = 42,horizontalDistance = 0.15}
    slm.addLayer{name = "moving clouds2",speed = 32,horizontalMovement = slm.MOVEMENT_COSINE,horizontalSpeed = 42,horizontalDistance = -0.15}
end