local spawnzones = require("spawnzones")
local warpTransition = require("warpTransition")
local textplus = require("textplus")
local hudoverride = require("hudoverride")
local pauseplus = require("pauseplus")

local startTimer = false
local drawText = false
local hidePlayer = false
local timer = 0
local inSection5 = false
local exit

warpTransition.activateOnInstantWarps = true

function onStart()
    exit = Layer.get("exit")
    GameData.awardCoins = false
end

function onTick()
    if inSection5 and not startTimer then
        if not musicSeized then
            Audio.SeizeStream(-1)
            musicSeized = true
        end
        
        Audio.MusicStop()
    else
        Audio.MusicPlay()
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

function onLoadSection5()
    inSection5 = true
end

function onEvent(eventName)
    if eventName == "Start Sound" then
        warpTransition.crossSectionTransition = warpTransition.TRANSITION_MELT
        Audio.MusicPlay()
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