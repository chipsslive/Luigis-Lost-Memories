--[[
    by Marioman2007 for Luigi's Lost Memories
    NOT TO BE USED WITHOUT PERMISSION!
]]

local pastPortal = require("pastPortal")
local stats = require("statsMisc")
local textplus = require("textplus")

local portalOpen = {}
portalOpen.portalID = 875
portalOpen.frames = {
    [true]  = {atPortal = 49, lerping = 3},
    [false] = {atPortal = 49, lerping = 5}
}
portalOpen.enterText = "Press UP to enter the portal!"

local targetPos = vector(0, 0)
local oldPos = vector(0, 0)
local currentPos = vector(0, 0)
local isLerping = false
local atPortal = false
local lerpSpeed = 0
local lerpTimer = 0
local opacity = 0

local function filter(o)
    if o.isValid and (not o.isHidden) then return true end
end

registerEvent(portalOpen, "onTick")
registerEvent(portalOpen, "onDraw")

function portalOpen.onTick()
    for k, v in NPC.iterate(portalOpen.portalID) do
        if filter(v) and Colliders.collide(player, v) and player.keys.up == KEYS_PRESSED and not isLerping and not atPortal then
            isLerping = true
            targetPos.x = v.x+v.width/2
            targetPos.y = v.y+v.height/2
        end
    end

    if #Colliders.getColliding{a = player, b = portalOpen.portalID, btype = Colliders.NPC, filter = filter} > 0 and not isLerping and not atPortal then
        opacity = math.min(opacity+0.075,1)
    else
        opacity = math.max(opacity-0.075,0)
    end

    local textAlpha = Color(opacity,opacity,opacity,opacity)
    textplus.print{text = portalOpen.enterText, x = 400, y = 576, font = stats.font, color = textAlpha, priority = stats.leastPriority-0.11, pivot = vector(0.5, 0)}
    textplus.print{text = "UP", x = 246, y = 576, font = stats.fontGreen, color = textAlpha, priority = stats.leastPriority-0.1}

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
            pastPortal.open()
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

function portalOpen.onDraw()
    if isLerping then
        player:setFrame(portalOpen.frames[player.powerup==1].lerping)
    elseif atPortal then
        player:setFrame(portalOpen.frames[player.powerup==1].atPortal)
    end
end

return portalOpen