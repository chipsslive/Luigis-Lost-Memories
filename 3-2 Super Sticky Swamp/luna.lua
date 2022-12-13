local spawnzones = require("spawnzones")
local respawnRooms = require("respawnRooms")
local slm = require("simpleLayerMovement")


function onStart()
    slm.addLayer{name = "moveOne",speed = 50,verticalMovement = slm.MOVEMENT_COSINE,verticalSpeed = 70,verticalDistance = 1.8}
    slm.addLayer{name = "moveTwo",speed = 70,verticalMovement = slm.MOVEMENT_COSINE,verticalSpeed = 30,verticalDistance = 1}
    slm.addLayer{name = "moveThree",speed = -50,verticalMovement = slm.MOVEMENT_COSINE,verticalSpeed = -70,verticalDistance = -0.9}
    slm.addLayer{name = "moveFour",speed = 50,verticalMovement = slm.MOVEMENT_COSINE,verticalSpeed = 70,verticalDistance = 0.9}
    slm.addLayer{name = "moveFive",speed = -50,verticalMovement = slm.MOVEMENT_COSINE,verticalSpeed = -70,verticalDistance = -1.83}
end

function respawnRooms.onPostReset(fromRespawn)
    slm.addLayer{name = "moveOne",speed = 50,verticalMovement = slm.MOVEMENT_COSINE,verticalSpeed = 70,verticalDistance = 1.8}
    slm.addLayer{name = "moveTwo",speed = 70,verticalMovement = slm.MOVEMENT_COSINE,verticalSpeed = 30,verticalDistance = 1}
    slm.addLayer{name = "moveThree",speed = -50,verticalMovement = slm.MOVEMENT_COSINE,verticalSpeed = -70,verticalDistance = -0.9}
    slm.addLayer{name = "moveFour",speed = 50,verticalMovement = slm.MOVEMENT_COSINE,verticalSpeed = 70,verticalDistance = 0.9}
    slm.addLayer{name = "moveFive",speed = -50,verticalMovement = slm.MOVEMENT_COSINE,verticalSpeed = -70,verticalDistance = -1.83}
end