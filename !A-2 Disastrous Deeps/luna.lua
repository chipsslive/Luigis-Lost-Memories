local spawnzones = require("spawnzones")

function onStart()
    for _,npc in NPC.iterate() do
        if npc.section == 0 and Section.getFromCoords(npc) == nil then -- Out of bounds
            -- see what section it's above/below
            for _,sec in ipairs(Section.get()) do
                if npc.x+npc.width >= sec.boundary.left and npc.x <= sec.boundary.right then
                    npc.section = sec.idx
                    break
                end
            end
        end
    end
end