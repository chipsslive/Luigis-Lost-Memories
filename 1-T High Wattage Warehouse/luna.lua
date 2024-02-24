local spawnzones = require("spawnzones")
local warpTransition = require("warpTransition")
local textplus = require("textplus")
local hudoverride = require("hudoverride")
local pauseplus = require("pauseplus")
local respawnRooms = require("respawnRooms")

local startTimer = false
local drawText = false
local hidePlayer = false
local timer = 0
local inSection5 = false
local exit
local forgotSFX = SFX.play("SFX/forgot.mp3")

warpTransition.activateOnInstantWarps = true

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
    forgotSFX:pause()
    exit = Layer.get("exit")
    GameData.awardCoins = false
    refreshGenerators()
end

function onTick()
    if startTimer then
        timer = timer + 1
    end

    if timer == 1460 then
        hidePlayer = true
    end

    if timer == 1600 then
        exit:show(true)
    end
end

function onLoadSection5()
    inSection5 = true
end

function onEvent(eventName)
    if eventName == "Start Sound" then
        warpTransition.crossSectionTransition = warpTransition.TRANSITION_MELT
        forgotSFX:resume()
        pauseplus.canPause = false
    end
end

function onLoadSection6()
    GameData.cutscene = true
    hudoverride.visible.starcoins = false
    startTimer = true
    Defines.gravity = 1
    warpTransition.crossSectionTransition = warpTransition.TRANSITION_NONE
    drawText = true
end

function onLoadSection7()
    hidePlayer = true
end

function onDraw()
    if hidePlayer then
        player:setFrame(-50 * player.direction)
    end

    if drawText then
        -- First Text
        textplus.print{
            x = -79485,
            y = -79965,
            text = "No matter how hard you try...",
            xscale = 2,
            yscale = 2,
            color = Color.black,
            priority = 2,
            sceneCoords = true
        }
        textplus.print{
            x = -79488,
            y = -79968,
            text = "No matter how hard you try...",
            xscale = 2,
            yscale = 2,
            color = Color.white,
            priority = 2,
            sceneCoords = true
        }
        -- Second Text
        textplus.print{
            x = -79933,
            y = -79581,
            text = "...you can't seem to remember...",
            xscale = 2,
            yscale = 2,
            color = Color.black,
            priority = 2,
            sceneCoords = true
        }
        textplus.print{
            x = -79936,
            y = -79584,
            text = "...you can't seem to remember...",
            xscale = 2,
            yscale = 2,
            color = Color.white,
            priority = 2,
            sceneCoords = true
        }
        -- Third Text
        textplus.print{
            x = -79453,
            y = -79261,
            text = "...what happens next.",
            xscale = 2,
            yscale = 2,
            color = Color.black,
            priority = 2,
            sceneCoords = true
        }
        textplus.print{
            x = -79456,
            y = -79264,
            text = "...what happens next.",
            xscale = 2,
            yscale = 2,
            color = Color.white,
            priority = 2,
            sceneCoords = true
        }
        -- Final Text
        --[[textplus.print{
            x = -59808,
            y = -60320,
            text = "Returning to the Memory Center...",
            xscale = 3,
            yscale = 3,
            color = Color.white,
            priority = 2,
            sceneCoords = true
        }]]
    end
end

function respawnRooms.onPostReset(fromRespawn)
	refreshGenerators()
end

function onExitLevel(levelWinType)
    GameData.cutscene = false
    GameData.awardCoins = true
    hudoverride.visible.starcoins = true
    if levelWinType == LEVEL_WIN_TYPE_KEYHOLE and not GameData.usedAccesibility then
        if not SaveData.keyhole2Found then
            GameData.exitedWithKeyhole = true
            GameData.lastCondition = 2
			SaveData.totalKeyholesFound = SaveData.totalKeyholesFound + 1
			SaveData.keyhole2Found = true
		end
    end
end