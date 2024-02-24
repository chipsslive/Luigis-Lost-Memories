local spawnzones = require("spawnzones")
local warpTransition = require("warpTransition")
local textplus = require("textplus")
local pauseplus = require("pauseplus")
local hudoverride = require("hudoverride")

local timer = 0
local startTimer = false
local drawText = false
local hidePlayer = false
local inSection3 = false
local exit
local forgotSFX = SFX.play("SFX/forgot.mp3")

warpTransition.activateOnInstantWarps = true

function onStart()
    forgotSFX:pause()
    exit = Layer.get("exit")
    GameData.awardCoins = false
end

function onTick()
    for _,v in ipairs(NPC.get(425, Section.getActive())) do
        local b = Section(v:mem(0x146,FIELD_WORD)).boundary
        if v.y > b.bottom then
            v.y = v.y - (b.bottom-b.top) - v.height
        elseif v.y + v.height < b.top then
            v.y = v.y + (b.bottom-b.top) + v.height
        end
    end

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

function onLoadSection3()
    inSection3 = true
end

function onEvent(eventName)
    if eventName == "Start Sound" then
        warpTransition.crossSectionTransition = warpTransition.TRANSITION_MELT
        forgotSFX:resume()
        pauseplus.canPause = false
    end
end

function onLoadSection4()
    GameData.cutscene = true
    hudoverride.visible.starcoins = false
    startTimer = true
    Defines.gravity = 1
    warpTransition.crossSectionTransition = warpTransition.TRANSITION_NONE
    drawText = true
end

function onLoadSection5()
    hidePlayer = true
end

function onDraw()
    if hidePlayer then
        player:setFrame(-50 * player.direction)
    end

    if drawText then
        -- First Text
        textplus.print{
            x = -119485,
            y = -120157,
            text = "No matter how hard you try...",
            xscale = 2,
            yscale = 2,
            color = Color.black,
            priority = 2,
            sceneCoords = true
        }
        textplus.print{
            x = -119488,
            y = -120160,
            text = "No matter how hard you try...",
            xscale = 2,
            yscale = 2,
            color = Color.white,
            priority = 2,
            sceneCoords = true
        }
        -- Second Text
        textplus.print{
            x = -119933,
            y = -119773,
            text = "...you can't seem to remember...",
            xscale = 2,
            yscale = 2,
            color = Color.black,
            priority = 2,
            sceneCoords = true
        }
        textplus.print{
            x = -119936,
            y = -119776,
            text = "...you can't seem to remember...",
            xscale = 2,
            yscale = 2,
            color = Color.white,
            priority = 2,
            sceneCoords = true
        }
        -- Third Text
        textplus.print{
            x = -119453,
            y = -119453,
            text = "...what happens next.",
            xscale = 2,
            yscale = 2,
            color = Color.black,
            priority = 2,
            sceneCoords = true
        }
        textplus.print{
            x = -119456,
            y = -119456,
            text = "...what happens next.",
            xscale = 2,
            yscale = 2,
            color = Color.white,
            priority = 2,
            sceneCoords = true
        }
        -- Final Text
        --[[textplus.print{
            x = -99808,
            y = -100320,
            text = "Returning to the Realm of<br>Recollection...",
            xscale = 3,
            yscale = 3,
            color = Color.white,
            priority = 2,
            sceneCoords = true
        }]]
    end
end

function onExitLevel()
    GameData.cutscene = false
    GameData.awardCoins = true
    hudoverride.visible.starcoins = true
end

--X=-99744; Y=-100320;