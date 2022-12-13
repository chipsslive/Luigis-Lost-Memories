local slm = require("simpleLayerMovement")
local respawnRooms = require("respawnRooms")

function onStart()
    slm.addLayer{name = "move 1",speed = 96,verticalMovement = slm.MOVEMENT_COSINE,verticalSpeed = 64,verticalDistance = 1}
    slm.addLayer{name = "move 2",speed = 96,verticalMovement = slm.MOVEMENT_COSINE,verticalSpeed = 64,verticalDistance = 1}
    slm.addLayer{name = "move 3",speed = 96,verticalMovement = slm.MOVEMENT_COSINE,verticalSpeed = 64,verticalDistance = -1}
end

function respawnRooms.onPostReset(fromRespawn)
    slm.addLayer{name = "move 1",speed = 96,verticalMovement = slm.MOVEMENT_COSINE,verticalSpeed = 64,verticalDistance = 1}
    slm.addLayer{name = "move 2",speed = 96,verticalMovement = slm.MOVEMENT_COSINE,verticalSpeed = 64,verticalDistance = 1}
    slm.addLayer{name = "move 3",speed = 96,verticalMovement = slm.MOVEMENT_COSINE,verticalSpeed = 64,verticalDistance = -1}
end