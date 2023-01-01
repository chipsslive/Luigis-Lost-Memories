local warpTransition = require("warpTransition")
local dropShadows = require("dropShadows")

-- Game logo
local logo = Graphics.loadImageResolved("logo.png")

local alpha = 0
local timer = 0

warpTransition.levelStartTransition = warpTransition.TRANSITION_FADE
warpTransition.transitionSpeeds[warpTransition.TRANSITION_FADE] = 200

function onStart()
    GameData.cutscene = true
end

function onTick()
    player:setFrame(-50 * player.direction)
    for k, v in pairs(player.keys) do
        player.keys[k] = false
    end

    timer = timer + 1

    if timer > 200 then
        Graphics.drawImageWP(logo, 110, 140, alpha, -50)
        if alpha < 1 then
            alpha = alpha + 0.01
        end
    end
end