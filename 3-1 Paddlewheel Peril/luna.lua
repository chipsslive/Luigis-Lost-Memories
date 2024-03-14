local respawnRooms = require("respawnRooms")
local pauseplus = require("pauseplus")
local textplus = require("textplus")
local customExit = require("customExit")

local collectedCoin = false
local checkpointStatus = false
local permittedHarmTypes = table.map({HARM_TYPE_PROJECTILE_USED,HARM_TYPE_VANISH})

function onStart()
    collectedCoin = false
    checkpointStatus = false
end

function onCheckpoint()
    checkpointStatus = collectedCoin
end

function onPostNPCKill(killedNPC,harmType)
    if ((killedNPC.id == 10 or killedNPC.id == 88 or killedNPC.id == 751 or killedNPC.id == 752 or killedNPC.id == 753) and harmType ~= HARM_TYPE_LAVA) then
        collectedCoin = true
    end
end

function customExit.checkChallenge()
    if not collectedCoin and not GameData.usedAccessibility and not SaveData.challenge2Completed then
        GameData.ach_Challenge2:collect()
        SaveData.challenge2Completed = true
        SaveData.totalChallengesCompleted = SaveData.totalChallengesCompleted + 1
        GameData.justCompletedChallenge = 2
    end
end

function respawnRooms.onPostReset(fromRespawn)
    if Checkpoint.getActive() == nil then
        collectedCoin = false
    else
        collectedCoin = checkpointStatus
    end
end

local challengeFailedText = "No"

function onDraw()
	if collectedCoin then
		challengeFailedText = "Yes"
    else
        challengeFailedText = "No"
    end
	if pauseplus.getSelectionValue("settings","Show Challenge Status") then
        textplus.print{
			text = "<color lightgreen>Challenge Status</color><br>Failed?: "..challengeFailedText,
			priority = 5,
			x = 5,
			y = 550,
            xscale = 2,
            yscale = 2,
            priority = 2
		}
        textplus.print{
			text = "<color black>Challenge Status<br>Failed?: "..challengeFailedText.."</color>",
			priority = 5,
			x = 7,
			y = 552,
            xscale = 2,
            yscale = 2,
            priority = 1
		}
    end
end