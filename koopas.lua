local npcutils = require("npcs/npcutils")
local koopas = {}

koopas.koopaIDs = {109, 110, 111, 112}
koopas.shellIDs = {113, 114, 115, 116}
koopas.beachIDs = {117, 118, 119, 120}
koopas.kamikazeShell = 194
koopas.rainbowShell = 195
koopas.rainbowVariants = 4
koopas.blueBeach = 119
koopas.beachEffect = 999

koopas.beachEffectVariants = {
    [117] = 1,
    [118] = 2,
    [119] = 3,
    [120] = 4,
}

local kamikazeImg
local rainbowImg
local blueImg

registerEvent(koopas, "onStart")
registerEvent(koopas, "onTick")
registerEvent(koopas, "onDraw")
registerEvent(koopas, "onPostNPCKill")

function koopas.onStart()
    kamikazeImg = Graphics.loadImageResolved("npc-"..koopas.kamikazeShell.."-main.png")
    rainbowImg = Graphics.loadImageResolved("npc-"..koopas.rainbowShell.."-main.png")
    blueImg = Graphics.loadImageResolved("npc-"..koopas.blueBeach.."-main.png")
end

function koopas.onTick()
    for k, v in NPC.iterate{koopas.kamikazeShell, koopas.rainbowShell} do
        v.data.customTimer = v.data.customTimer or 0
        v.data.variant = v.data.variant or 0
        v.data.customTimer = v.data.customTimer + 1
        v.data.variant = math.floor(v.data.customTimer/NPC.config[v.id].framespeed)%koopas.rainbowVariants
    end
end

function koopas.onDraw()
    for k, v in NPC.iterate(koopas.shellIDs) do
        if v.speedX == 0 then
            v.animationFrame = 0
        end
    end

    for k, v in NPC.iterate{koopas.kamikazeShell, koopas.rainbowShell} do
        if v.speedX == 0 then
            v.animationFrame = 0
        end

        local img

        if v.id == koopas.kamikazeShell then
            img = kamikazeImg
        elseif v.id == koopas.rainbowShell then
            img = rainbowImg
        end

        if v.data.variant then
            npcutils.drawNPC(v, {texture = img, sourceX = v.data.variant*NPC.config[v.id].width})
            npcutils.hideNPC(v)
        end
    end

    for k, v in NPC.iterate(koopas.blueBeach) do
        local sx = (v.animationTimer > 1 and 0) or NPC.config[v.id].width
        npcutils.drawNPC(v, {texture = blueImg, sourceX = sx})
        npcutils.hideNPC(v)
    end
end

function koopas.onPostNPCKill(v, r)
    if table.map(koopas.beachIDs)[v.id] then
        if r == HARM_TYPE_LAVA or r == HARM_TYPE_SPINJUMP or r == HARM_TYPE_VANISH then return end
        local e = Effect.spawn(koopas.beachEffect, v, koopas.beachEffectVariants[v.id])
        e.direction = -v.direction
    end
end

return koopas