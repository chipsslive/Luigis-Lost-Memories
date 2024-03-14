local spawnzones = require("spawnzones")
local respawnRooms = require("respawnRooms")
local textplus = require("textplus")
local pauseplus = require("pauseplus")
local customExit = require("customExit")

local challengeFailed = false
local checkpointStatus = false

function onCheckpoint()
    checkpointStatus = challengeFailed
end

function onTick()
    if player.keys.left == KEYS_PRESSED then
        challengeFailed = true
    end
end

function customExit.checkChallenge()
    if not challengeFailed and not GameData.usedAccessibility and not SaveData.challenge3Completed then
        GameData.ach_Challenge3:collect()
        SaveData.challenge3Completed = true
        SaveData.totalChallengesCompleted = SaveData.totalChallengesCompleted + 1
        GameData.justCompletedChallenge = 3
    end
end

function respawnRooms.onPostReset(fromRespawn)
    if Checkpoint.getActive() == nil then
        challengeFailed = false
    else
		challengeFailed = checkpointStatus
	end
end

local challengeFailedText = "No"

function onDraw()
	if challengeFailed then
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