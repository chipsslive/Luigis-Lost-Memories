local respawnRooms = require("respawnRooms")

local collectedCoin = false

function onPostNPCKill(killedNPC,harmType)
    if killedNPC.id == 10 or killedNPC.id == 88 then
        collectedCoin = true
    end

    if killedNPC.id == 1000 then
        if not collectedCoin then
            GameData.ach_Challenge2:collect()
            SaveData.challenge2Completed = true
            SaveData.totalChallengesCompleted = SaveData.totalChallengesCompleted + 1
        end
    end
end

function respawnRooms.onPostReset(fromRespawn)
    if Checkpoint.getActive() == nil then
        collectedCoin = false
    end
end

function onDraw()
    Text.print(collectedCoin,0,0)
end