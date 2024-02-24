local slm = require("simpleLayerMovement")
local respawnRooms = require("respawnRooms")

local throwToGround = false
local timer = 0

slm.addLayer{name = "Floating Ship",speed = 96,verticalMovement = slm.MOVEMENT_COSINE,verticalpeed = 64,verticalDistance = 0.1}
slm.addLayer{name = "Floating Ship2",speed = -96,verticalMovement = slm.MOVEMENT_COSINE,verticalpeed = 64,verticalDistance = 0.095}

slm.addLayer{name = "Floating Crate1",speed = 66,verticalMovement = slm.MOVEMENT_COSINE,verticalpeed = 64,verticalDistance = 0.1}
slm.addLayer{name = "Floating Crate2",speed = -66,verticalMovement = slm.MOVEMENT_SINE,verticalpeed = 64,verticalDistance = 0.1}

function onStart()
    GameData.awardCoins = false
    local room = Layer.get("Room")
    local water = Layer.get("water")
    room:show(true)
    water:show(true)
end

function onExitLevel()
    GameData.awardCoins = true
end

function respawnRooms.onPostReset(fromRespawn)
    local room = Layer.get("Room")
    local water = Layer.get("water")
    room:show(true)
    water:show(true)
end

function onPostNPCKill(killedNPC, harmType)
    if killedNPC.id == 1000 then
        throwToGround = true 
    end
end

function onTick()
    if throwToGround then
        timer = timer + 1
        player.speedY = 30 -- so it doesn't take forever to float to the ground (which starts the music)
        if timer == 100 then
            throwToGround = false
            timer = 0
        end
    end
end
