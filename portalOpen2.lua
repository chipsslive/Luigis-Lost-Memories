--[[
    by Marioman2007 for Luigi's Lost Memories
    NOT TO BE USED WITHOUT PERMISSION!
]]

local pastPortal2 = require("pastPortal2")
local stats = require("statsMisc")
local textplus = require("textplus")

local portalOpen2 = {}
portalOpen2.portalID = 876
portalOpen2.frames = {
    [true]  = {atPortal = 49, lerping = 3},
    [false] = {atPortal = 49, lerping = 5}
}
portalOpen2.enterText = "Press    to enter the portal!"
portalOpen2.openText = "Press JUMP!"

local targetPos = vector(0, 0)
local oldPos = vector(0, 0)
local currentPos = vector(0, 0)
local isLerping = false
local atPortal = false
local lerpSpeed = 0
local lerpTimer = 0
local opacity = 0
local opacity2 = 0

local function filter(o)
    if o.isValid and (not o.isHidden) then return true end
end

registerEvent(portalOpen2, "onTick")
registerEvent(portalOpen2, "onDraw")

function portalOpen2.onTick()
    for k, v in NPC.iterate(portalOpen2.portalID) do
        if filter(v) and Colliders.collide(player, v) and player.keys.up == KEYS_PRESSED and not isLerping and not atPortal and SaveData.introFinished and SaveData.basementFound then
            isLerping = true
            targetPos.x = v.x+v.width/2
            targetPos.y = v.y+v.height/2
        end
    end

    if #Colliders.getColliding{a = player, b = portalOpen2.portalID, btype = Colliders.NPC, filter = filter} > 0 and not isLerping and not atPortal then
        opacity = math.min(opacity+0.09,1)
    else
        opacity = math.max(opacity-0.09,0)
    end

    local textAlpha = Color(opacity,opacity,opacity,opacity)
    if SaveData.introFinished and SaveData.basementFound then
        textplus.print{text = portalOpen2.enterText, x = 400, y = 576, font = stats.font, color = textAlpha, priority = stats.leastPriority-0.11, pivot = vector(0.5, 0)}
        textplus.print{text = "UP", x = 247, y = 576, font = stats.fontGreen, color = textAlpha, priority = stats.leastPriority-0.1}
    end

    if isLerping then
        if player.keys.down == KEYS_PRESSED or player.keys.run == KEYS_PRESSED then
            isLerping = false
        end

        lerpSpeed = math.min(lerpSpeed + 0.005, 0.05)
        lerpTimer = math.min(lerpTimer + lerpSpeed, 1)
        currentPos.x = math.floor(math.lerp(oldPos.x, targetPos.x, lerpTimer) + 0.5)
        currentPos.y = math.floor(math.lerp(oldPos.y, targetPos.y, lerpTimer) + 0.5)
        if lerpTimer == 1 or (currentPos.x==targetPos.x and currentPos.y==targetPos.y) then
            isLerping = false
            atPortal = true
            lerpSpeed = 0
            lerpTimer = 0
        end
    else
        oldPos    = vector(player.x + player.width/2, player.y + player.height/2)
        lerpSpeed = 0
        lerpTimer = 0
    end

    if atPortal then
        if player.keys.jump == KEYS_PRESSED then
            pastPortal2.open()
        elseif player.keys.down == KEYS_PRESSED or player.keys.run == KEYS_PRESSED then
            atPortal = false
        end
    end

    if isLerping or atPortal then
        player.x = currentPos.x - player.width/2
        player.y = currentPos.y + (math.sin(lunatime.drawtick() * 0.15) * 8) - player.height/2
        player.speedX = 0
        player.speedY = 0
    end
end

function portalOpen2.onDraw()
    local textAlpha2 = Color(opacity2,opacity2,opacity2,opacity2)
    if isLerping then
        player:setFrame(portalOpen2.frames[player.powerup==1].lerping)
    elseif atPortal and not Misc.isPaused() then
        opacity2 = math.min(opacity2+0.09,1)
        player:setFrame(portalOpen2.frames[player.powerup==1].atPortal)
        textplus.print{text = portalOpen2.openText, x = 400, y = 576, font = stats.font, color = textAlpha2, priority = stats.leastPriority-0.11, pivot = vector(0.5, 0)}
        textplus.print{text = "JUMP", x = 445, y = 576, font = stats.fontGreen, color = textAlpha2, priority = stats.leastPriority-0.11, pivot = vector(0.5, 0)}
    else
        opacity2 = math.max(opacity2-0.09,0)
    end
end

return portalOpen2