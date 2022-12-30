local slm = require("simpleLayerMovement")

slm.addLayer{name = "Floating Ship",speed = 96,verticalMovement = slm.MOVEMENT_COSINE,verticalpeed = 64,verticalDistance = 0.1}

function onStart()
    GameData.awardCoins = false
end

function onExitLevel()
    GameData.awardCoins = true
end