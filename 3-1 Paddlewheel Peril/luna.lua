local respawnRooms = require("respawnRooms")
local pauseplus = require("pauseplus")
local textplus = require("textplus")

local collectedCoin = false
local checkpointStatus = false

function onCheckpoint()
    checkpointStatus = collectedCoin
end

function onPostNPCKill(killedNPC,harmType)
    if killedNPC.id == 10 or killedNPC.id == 88 then
        collectedCoin = true
    end

    if killedNPC.id == 1000 then
        if not collectedCoin and not GameData.usedAccessibility and not SaveData.challenge2Completed then
            GameData.ach_Challenge2:collect()
            SaveData.challenge2Completed = true
            SaveData.totalChallengesCompleted = SaveData.totalChallengesCompleted + 1
        end
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