local respawnRooms = require("respawnRooms")

function onStart()
    player.powerup = 1
end

function respawnRooms.onPostReset(fromRespawn)
    player.powerup = 1
end