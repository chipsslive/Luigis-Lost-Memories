local respawnRooms = require("respawnRooms")
respawnRooms.deathCoinsCost = 0

function onStart()
    player.powerup = 1
end

function respawnRooms.onPostReset(fromRespawn)
    player.powerup = 1
end

function onExitLevel()
    respawnRooms.deathCoinsCost = 15
end