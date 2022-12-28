local spawnzones = require("spawnzones")

local function getDesiredBlocks(list)
    local blockList = {}
    for k, v in ipairs(list) do
        if v.isValid and (not Block.config[v.id].passthrough)
        and (not v.isHidden) and (not v.invisible)
        and (not Block.NONSOLID_MAP[v.id]) and (not Block.SEMISOLID_MAP[v.id]) and (not Block.SLOPE_MAP[v.id])
        and (not Block.SIZEABLE_MAP[v.id]) and (not Block.PLAYERSOLID_MAP[v.id]) and (not Block.PLAYER_MAP[v.id]) then
            table.insert(blockList, v)
        end
    end
    return blockList
end

local function isCol(v)
    local b = getDesiredBlocks(Block.getIntersecting(v.x+2,v.y+2,v.x+v.width-2,v.y+v.height-2))
    return #b > 0
end

function onTick()
    for _,v in NPC.iterate(278) do
        if isCol(v) and v:mem(0x138, FIELD_WORD) ~= 4 and v:mem(0x12C, FIELD_WORD) == 0 then
            v:kill(HARM_TYPE_VANISH)
        end
    end
end

function onPostNPCKill(npc, reason)
	if npc.id == 278 then
	  	local effect = Animation.spawn(75, npc.x + npc.width*0.5, npc.y + npc.height*0.5)
	  	effect.x, effect.y = effect.x - effect.width*0.5, effect.y - effect.height*0.5
	end 
end