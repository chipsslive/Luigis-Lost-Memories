local slm = require("simpleLayerMovement")
local respawnRooms = require("respawnRooms")

local moveOne
local moveTwo
local moveThree
local moveFour
local moveTimer = 0

function onStart()
    moveOne = Layer.get("moveOne")
    moveTwo = Layer.get("moveTwo")
    moveThree = Layer.get("moveThree")
    moveFour = Layer.get("moveFour")
end

function onTick()
    if Layer.isPaused() == true then

    else
        if moveOne then
            moveTimer = moveTimer + 1

            moveOne.speedY = math.cos(moveTimer/48)*1
        end
        if moveTwo then
            moveTimer = moveTimer + 1

            moveTwo.speedY = math.cos(moveTimer/48)*-1
        end
        if moveThree then
            moveTimer = moveTimer + 1

            moveThree.speedY = math.cos(moveTimer/150)*-1
        end
        if moveFour then
            moveTimer = moveTimer + 1

            moveFour.speedY = math.cos(moveTimer/150)*1
        end
    end
end

function respawnRooms.onPostReset(fromRespawn)
    moveTimer = 0
end