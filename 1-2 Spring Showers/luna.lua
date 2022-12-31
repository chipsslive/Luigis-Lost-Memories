local darkness = require("darkness");
local particles = require("particles")
local respawnRooms = require("respawnRooms")
local spawnzones = require("spawnzones")

local Moving2
local Moving
local myLayerTimer = 0

function onStart()
	Moving2 = Layer.get("Moving 2")
	Moving = Layer.get("Moving")
end

function onTick()
    if Moving2 then
        myLayerTimer = myLayerTimer + 1

		Moving2.speedY = math.cos(myLayerTimer/48)*-0.75
		if Moving then
			myLayerTimer = myLayerTimer + 1
	
			Moving.speedY = math.cos(myLayerTimer/48)*0.75
		end
    end
end

function respawnRooms.onPostReset(fromRespawn)
    myLayerTimer = 0
end

function onExitLevel(levelWinType)
	if levelWinType == LEVEL_WIN_TYPE_KEYHOLE then
		GameData.ach_AllKeyholes:setCondition(1,true)
	end
end