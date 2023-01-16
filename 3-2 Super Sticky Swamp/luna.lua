local spawnzones = require("spawnzones")
local respawnRooms = require("respawnRooms")
local slm = require("simpleLayerMovement")
local textplus = require("textplus")
local pauseplus = require("pauseplus")

local totalJumps = 0
local checkpointJumps = 0

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

    if Checkpoint.getActive() == nil then
        totalJumps = 0
    else
        totalJumps = checkpointJumps
    end
end

function onCheckpoint()
    checkpointJumps = totalJumps
end

function onTick()
    if player.keys.jump == KEYS_PRESSED then
        totalJumps = totalJumps + 1
    elseif player.keys.altJump == KEYS_PRESSED then
        totalJumps = totalJumps + 1
    end
end

function onPostNPCKill(killedNPC,harmType)
    if killedNPC.id == 1000 then
        if totalJumps <= 25 and not GameData.usedAccessibility and not SaveData.challenge5Completed then
            GameData.ach_Challenge5:collect()
            SaveData.challenge5Completed = true
            SaveData.totalChallengesCompleted = SaveData.totalChallengesCompleted + 1
        end
    end
end

local portalFont = textplus.loadFont("portalFont.ini")

function onDraw()
    if pauseplus.getSelectionValue("settings","Show Challenge Status") then
        textplus.print{
			text = "<color lightgreen>Challenge Status</color><br>Total Jumps: "..totalJumps,
			priority = 5,
			x = 5,
			y = 550,
            xscale = 2,
            yscale = 2,
            priority = 2
		}
        textplus.print{
			text = "<color black>Challenge Status<br>Total Jumps: "..totalJumps.."</color>",
			priority = 5,
			x = 7,
			y = 552,
            xscale = 2,
            yscale = 2,
            priority = 1
		}
    end
end