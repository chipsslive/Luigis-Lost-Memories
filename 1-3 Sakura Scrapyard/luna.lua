local spawnzones = require("spawnzones")
local particles = require("particles")

local leafEmitter = particles.Emitter(0, 0, "p_leaves.ini")

function onStart()
    GameData.awardCoins = false
end

function onExitLevel()
    GameData.awardCoins = true
end