local darkness = require("darkness");
local particles = require("particles")
local respawnRooms = require("respawnRooms")
local spawnzones = require("spawnzones")

local Moving2
local Moving
local myLayerTimer = 0

local layerKeyword = "instant"

local generators = {}

local function refreshGenerators()
    generators = {}

    for _,npc in NPC.iterate() do
        if npc.isGenerator and npc.layerName:lower():find(layerKeyword) then
            npc.generatorType = 1
            table.insert(generators,npc)
        end
    end
end

local generatorDirections = {
    [1] = vector(0,1), -- up
    [2] = vector(1,0), -- left
    [3] = vector(0,-1), -- down
    [4] = vector(-1,0), -- right
}

function onStart()
	Moving2 = Layer.get("Moving 2")
	Moving = Layer.get("Moving")
	refreshGenerators()
end

function onTickEnd()
    for _,npc in ipairs(generators) do
        if npc.isValid and not npc.isHidden and npc.generatorTimer == 0 then
            local direction = generatorDirections[npc.generatorDirection]
            local data = npc.data

            local x = npc.x+(npc.width /2)+(npc.width *0.5*direction.x)
            local y = npc.y+(npc.height/2)+(npc.height*0.5*direction.y)

            for _,generatedNPC in NPC.iterateIntersecting(x-1,y-1,x+1,y+1) do
                if generatedNPC ~= npc and generatedNPC:mem(0x138,FIELD_WORD) == 4 then
                    -- Cancel the generation state
                    generatedNPC:mem(0x138,FIELD_WORD,0)
                    generatedNPC:mem(0x13A,FIELD_WORD,0)
                    generatedNPC:mem(0x13C,FIELD_DFLOAT,0)
                    generatedNPC:mem(0x144,FIELD_WORD,0)

                    generatedNPC.x = generatedNPC.x - (direction.x*generatedNPC.width )
                    generatedNPC.y = generatedNPC.y - (direction.y*generatedNPC.height)

                    data.generatedNPC = generatedNPC


                    local effect = Effect.spawn(10,generatedNPC.x+(generatedNPC.width/2),generatedNPC.y+(generatedNPC.height/2))

                    effect.x = effect.x-(effect.width /2)
                    effect.y = effect.y-(effect.height/2)


                    break
                end
            end
        end
    end
end

function onTick()
	if Layer.isPaused() == true then

    else
		if Moving2 then
			myLayerTimer = myLayerTimer + 1

			Moving2.speedY = math.cos(myLayerTimer/48)*-0.75
			if Moving then
				myLayerTimer = myLayerTimer + 1
		
				Moving.speedY = math.cos(myLayerTimer/48)*0.75
			end
		end
	end
end

function respawnRooms.onPostReset(fromRespawn)
    myLayerTimer = 0
	refreshGenerators()
end

function onExitLevel(levelWinType)
	if levelWinType == LEVEL_WIN_TYPE_KEYHOLE and not GameData.usedAccessibility then
		if not SaveData.keyhole1Found then
			GameData.exitedWithKeyhole = true
			GameData.lastCondition = 1
			SaveData.totalKeyholesFound = SaveData.totalKeyholesFound + 1
			SaveData.keyhole1Found = true
		end
	end
end