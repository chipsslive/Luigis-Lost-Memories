local customCamera = require("customCamera")
local slm          = require("simpleLayerMovement")

function onStart()
    GameData.cutscene = true

    slm.addLayer{name = "Float 1",speed = 96,verticalMovement = slm.MOVEMENT_COSINE,verticalSpeed = 76,verticalDistance = 0.1}
    slm.addLayer{name = "Float 2",speed = 96,verticalMovement = slm.MOVEMENT_COSINE,verticalSpeed = 76,verticalDistance = -0.1}
end

function onTick()
    customCamera.currentSettings.zoom = 1
end

function onExitLevel()
    GameData.cutscene = false
end