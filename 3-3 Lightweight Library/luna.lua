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
    if levelWinType == LEVEL_WIN_TYPE_KEYHOLE and not GameData.usedAccessibility then
        if not SaveData.keyhole4Found then
            GameData.exitedWithKeyhole = true
			GameData.lastCondition = 4
			SaveData.totalKeyholesFound = SaveData.totalKeyholesFound + 1
			SaveData.keyhole4Found = true
		end
    end
end