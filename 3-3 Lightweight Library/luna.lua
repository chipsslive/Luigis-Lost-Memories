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

function onExitLevel(levelWinType)
    if levelWinType == LEVEL_WIN_TYPE_KEYHOLE and not GameData.usedAccesibility then
        GameData.ach_AllKeyholes:setCondition(4,true)
        if not SaveData.keyhole4Found then
			GameData.ach_HundredPercent:progressCondition(4)
			SaveData.keyhole4Found = true
		end
    end
end