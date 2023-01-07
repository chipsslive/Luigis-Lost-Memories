local spawnzones = require("spawnzones")
local slm = require("simpleLayerMovement")
local respawnRooms = require("respawnRooms")
clearpipe = require("blocks/ai/clearpipe")
clearpipe_npc = require("npcs/ai/clearpipeNPC")

table.insert(clearpipe_npc.ids, 312)
clearpipe_npc.ids_map[312] = true
clearpipe.registerPipe(1, "END", "VERT", {true, true, false, false})

local hasRemoverBGOs = 0
local extraPadding = 256

function loadFile(name)
	return Misc.resolveFile(name)
end

clearpipe.sfx = loadFile("sfx_clearpipe.ogg")
clearpipe_npc.sfx = clearpipe.sfx

function onStart()
    for _,v in NPC.iterate() do
        v.section = Section.getIdxFromCoords(v.x - extraPadding, v.y - extraPadding, v.width + extraPadding*2, v.height + extraPadding*2)
    end

	hasRemoverBGOs = #BGO.get(752)

    slm.addLayer{name = "Float1",speed = 96,verticalMovement = slm.MOVEMENT_COSINE,verticalSpeed = 76,verticalDistance = 0.1}
	slm.addLayer{name = "Float2",speed = 96,verticalMovement = slm.MOVEMENT_COSINE,verticalSpeed = 76,verticalDistance = -0.1}
end

function onTick()
    if hasRemoverBGOs > 0 then
		for k,v in ipairs(NPC.get(-1,player.section)) do
			if not v.friendly and v:mem(0x12A, FIELD_WORD) > 0 then
				for _,u in ipairs(BGO.getIntersecting(v.x + 2,v.y + 2,v.x + v.width - 2,v.y + v.height - 2)) do
					if u.id == 752 then
						v:kill(176)
					end
				end
			end
		end
	end
end

function onPostNPCKill(npc, reason)
	if npc.id == 319 then
	  	local effect = Animation.spawn(176, npc.x + npc.width*0.5, npc.y + npc.height*0.5)
	  	effect.x, effect.y = effect.x - effect.width*0.5, effect.y - effect.height*0.5
	end 

	if npc.id == 320 then
		local effect = Animation.spawn(10, npc.x + npc.width*0.5, npc.y + npc.height*0.5)
		effect.x, effect.y = effect.x - effect.width*0.5, effect.y - effect.height*0.5
  	end 
end

function respawnRooms.onPostReset(fromRespawn)
    slm.addLayer{name = "Float1",speed = 96,verticalMovement = slm.MOVEMENT_COSINE,verticalSpeed = 76,verticalDistance = 0.1}
end