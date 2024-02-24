local spawnzones = require("spawnzones")
local respawnRooms = require("respawnRooms")

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

function onStart()
	refreshGenerators()
end

function respawnRooms.onPostReset(fromRespawn)
	refreshGenerators()
end

function onExitLevel(levelWinType)
    if levelWinType == LEVEL_WIN_TYPE_KEYHOLE and not GameData.usedAccesibility then
        if not SaveData.keyhole3Found then
			GameData.exitedWithKeyhole = true
			GameData.lastCondition = 3
			SaveData.totalKeyholesFound = SaveData.totalKeyholesFound + 1
			SaveData.keyhole3Found = true
		end
    end
end

function onDraw()
	--[[if (player:mem(0x44, FIELD_BOOL) and player.standingNPC) then
		player.direction = math.sign(player.standingNPC.speedX)
		player.frame = 1
	end]]

    -- If small Monty Mole is not out of ground yet, don't show its light
    for _,v in ipairs(NPC.get(309)) do
        local data = v.data._basegame
        if data.state == 1 or data.state == 2 then -- if not hiding or telegraphing
            if v.lightSource then
                v.lightSource.brightness = 0
            end
        else
            if v.lightSource then
                v.lightSource.brightness = 1
            end
        end
    end
end

--[[function onTick()
	if (player:mem(0x44, FIELD_BOOL)) then
		Layer.get("Tracks"):show(true)
		for _,v in ipairs(NPC.get(195, player.section)) do
			if not v.isGenerator and not v.layerObj.isHidden and v:mem(0x12A, FIELD_WORD) > 0 and  (player.keys.altJump == KEYS_PRESSED) then
				v:kill(8)
			end
		end
	elseif not player:mem(0x44, FIELD_BOOL) then
		Layer.get("Tracks"):hide(true)
	end
end
]]