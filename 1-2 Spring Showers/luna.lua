local darkness = require("darkness");

local particles = require("particles")

local spawnzones = require("spawnzones")

local effect = particles.Emitter(0, 0, Misc.resolveFile("particles/p_rain.ini"));
effect:AttachToCamera(Camera.get()[1]);

local darknessField = darkness.Create{
	falloff = darkness.falloff.DEFAULT,
	shadows = darkness.shadow.DEFAULT,
	maxLights = 60, 
	priorityType = darkness.priority.DISTANCE,
	bounds = nil,
	boundBlendLength = 64,
	sections = -1,
	ambient = Color.grey,
    priority = 0,
    distanceField = false,
	enabled = true
}

function onCameraUpdate()
    effect:Draw();
end

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

function onRespawnReset()
    myLayerTimer = 0
end
function onRoomEnter(roomIdx)
    myLayerTimer = 0
end