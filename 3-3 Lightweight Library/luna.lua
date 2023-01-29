local slm = require("simpleLayerMovement")
local respawnRooms = require("respawnRooms")
local textplus = require("textplus")
local pauseplus = require("pauseplus")

local permittedHarmTypes = table.map({HARM_TYPE_PROJECTILE_USED})

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

function onPostNPCKill(killedNPC,harmType)
    if killedNPC.id == 254 and not (permittedHarmTypes[harmType])  then
        player.speedY = 0
    end
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

function onDraw()
    if pauseplus.getSelectionValue("settings","Show Challenge Status") then
        textplus.print{
			text = "<color lightgreen>Challenge Status</color><br>Use Speedrun Timer",
			priority = 5,
			x = 5,
			y = 550,
            xscale = 2,
            yscale = 2,
            priority = 2
		}
        textplus.print{
			text = "<color black>Challenge Status<br>Use Speedrun Timer</color>",
			priority = 5,
			x = 7,
			y = 552,
            xscale = 2,
            yscale = 2,
            priority = 1
		}
    end
end