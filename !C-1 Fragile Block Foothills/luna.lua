local autoscroll = require("autoscroll")
local respawnRooms = require("respawnRooms")
local helmets = require("helmets")

respawnRooms.roomSettings.jumpFromBelowSpeed = -14

local scroll = false

function onEvent(eventName)
    if eventName == "go" then
        autoscroll.scrollRight(4)
        scroll = true
    end

    if eventName == "stop" then
        autoscroll.unlockSection(1)
        scroll = false
    end
end

function onLoadSection1()
    autoscroll.lockScreen()
end

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

local print = false

local powerupStates = table.map{
    FORCEDSTATE_POWERUP_BIG, FORCEDSTATE_POWERDOWN_SMALL, FORCEDSTATE_POWERUP_FIRE, FORCEDSTATE_POWERUP_LEAF, FORCEDSTATE_POWERUP_TANOOKI,
    FORCEDSTATE_POWERUP_HAMMER, FORCEDSTATE_POWERUP_ICE, FORCEDSTATE_POWERDOWN_FIRE, FORCEDSTATE_POWERDOWN_ICE, FORCEDSTATE_MEGASHROOM
}

function onTick()
    --Defines.levelFreeze = (powerupStates[player.forcedState] or mem(0x00B2C62E,FIELD_WORD,  0)) 

    for _,npc in ipairs(generators) do
        if npc.isValid and not npc.isHidden then
            local data = npc.data
            
            npc:mem(0x74,FIELD_BOOL,(data.generatedNPC == nil or not data.generatedNPC.isValid))
        end
    end

    if player.deathTimer > 0 then return end
    if player:mem(0x148, FIELD_WORD) > 0
    and player:mem(0x14C, FIELD_WORD) > 0 then
        player:kill()
    end
end

function onStart()
    refreshGenerators()
end

function respawnRooms.onPostReset(fromRespawn)
    refreshGenerators()
    autoscroll.unlockSection(1)
    autoscroll.scrollDown(0,nil,1)
    scroll = false
end

function respawnRooms.onPreReset(fromRespawn)
    helmets.setCurrentType(p,nil)
end

function onExitLevel(levelWinType)
	if levelWinType == LEVEL_WIN_TYPE_KEYHOLE and not GameData.usedAccesibility then
		if not SaveData.keyhole5Found then
            GameData.exitedWithKeyhole = true
            GameData.lastCondition = 5
			SaveData.totalKeyholesFound = SaveData.totalKeyholesFound + 1
			SaveData.keyhole5Found = true
		end
	end
end