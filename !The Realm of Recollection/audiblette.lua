local textplus  = require("textplus")
local pauseplus = require("pauseplus")
local stats     = require("statsMisc")

local audiblette = {}

local mov          = stats.movement
local isOpen       = false
local isPlaying    = false
local selection    = 1
local movementOver = true
local menuOpacity  = 0
local fadeType     = -1
local isTargeting  = false
local targetPos    = 0
local currentPos   = 0
local selLerpTimer = 0
local selLerpSpeed = 0
local selTarget    = 1
local pressTimer   = 0
local flashOpacity = 0
local waitTimer    = stats.waitTime
local waitFunc     = function() end
local waitOpacity  = 0
local executed     = false

registerEvent(audiblette, "onStart")
registerEvent(audiblette, "onDraw")
registerEvent(audiblette, "onInputUpdate")

local function SFXPlay(name)
    if stats.SFX[name] and stats.SFX[name].id then
        local volume = stats.SFX[name].volume or 1
        SFX.play(stats.SFX[name].id, volume)
    end
end

function audiblette.open()
    Misc.pause()
    SFXPlay("enter")
    isOpen       = true
    selection    = 1
    movementOver = false
    menuOpacity  = 0
    fadeType     = 1
    isTargeting  = false
    targetPos    = 0
    currentPos   = 0
    selLerpTimer = 0
    selLerpSpeed = 0
    selTarget    = 1
    pressTimer   = 0
    for k, v in pairs(mov) do
        mov[k].type = 1
    end

    pauseplus.canPause = false
end

function audiblette.close()
    SFXPlay("exit")
    fadeType     = -1
    movementOver = false
    for k, v in pairs(mov) do
        mov[k].type = -1
    end

    pauseplus.canPause = true
end

function audiblette.onDraw()
    if not isOpen then return end

    if menuOpacity == 0 and fadeType == -1 then
        Misc.unpause()
        isOpen = false
    end
end

function audiblette.onInputUpdate()
    if not isOpen then return end

    if player.rawKeys.run == KEYS_PRESSED then
        audiblette.close()
        player:mem(0x172, FIELD_BOOL, false)
    end
end

return audiblette