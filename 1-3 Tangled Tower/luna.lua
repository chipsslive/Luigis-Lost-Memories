local respawnRooms = require("respawnRooms")

local startTimer = false
local timer = 0

local startTimer2 = false
local timer2 = 0

local stopMusic = false

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
    refreshGenerators()
end

function onEvent(eventName)
    if eventName == "boss death" then
        stopMusic = true
        startTimer2 = true
    end

    if eventName == "boss start" then
        SFX.play("bossintro.mp3")
        startTimer = true
    end
end

function onTick()
    if startTimer then
        timer = timer + 1
        if timer == 330 then
            Audio.MusicChange(9,"1-3 Tangled Tower/Yoshi's Island - Big Boss.mp3")
        end
    end

    if startTimer2 then
        timer2 = timer2 + 1
        if timer2 == 300 then
            SFX.play("bossclear.mp3")
        end
    end

    if stopMusic then
        if player.section == 9 then
            if not musicSeized then
                Audio.SeizeStream(-1)
                musicSeized = true
            end
            
            Audio.MusicStop()
        end
    end

    for _,npc in ipairs(generators) do
        if npc.isValid and not npc.isHidden then
            local data = npc.data
            
            npc:mem(0x74,FIELD_BOOL,(data.generatedNPC == nil or not data.generatedNPC.isValid))
        end
    end
end

function respawnRooms.onPostReset(fromRespawn)
    refreshGenerators()

    startTimer = false
    timer = 0
    startTimer2 = false
    timer2 = 0
    stopMusic = false
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