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
        GameData.ach_AllKeyholes:setCondition(4,true)
        if not SaveData.keyhole4Found then
            if GameData.ach_HundredPercent:getCondition(4).value < SaveData.totalKeyholesFound + 1 then
			    GameData.ach_HundredPercent:setCondition(4,SaveData.totalKeyholesFound + 1)
            end
			SaveData.totalKeyholesFound = SaveData.totalKeyholesFound + 1
			SaveData.keyhole4Found = true
		end
    end
end