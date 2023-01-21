local multipoints = require("multipoints");

function onTick()
    if player.character == CHARACTER_LUIGI and Defines.jumpheight ~= 20 then
        Defines.jumpheight = 20
    elseif player.character == CHARACTER_TOAD and Defines.jumpheight ~= 20 then
        Defines.jumpheight = 20
    end
end