local slm = require("simpleLayerMovement")
local lineguide = require("lineguide")
local spawnzones = require("spawnzones")

-- There are two variants of coins used in the level, so only register 1 to lineguides

lineguide.registerNPCs(67)
lineguide.properties[67] = {lineSpeed = 2}

slm.addLayer{name = "small barrel",speed = 96,verticalMovement = slm.MOVEMENT_COSINE,verticalSpeed = 64,verticalDistance = 0.2}
slm.addLayer{name = "large barrel",speed = 96,verticalMovement = slm.MOVEMENT_COSINE,verticalSpeed = 64,verticalDistance = -0.2}

--[[function onTick()
    for _,v in NPC.iterate(67) do
        if v:mem(0x138, FIELD_WORD) ~= 4 then
            v.speedY = -4
        end
    end
end]]