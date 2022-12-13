local spawnzones = require("spawnzones");

--[[function onTick()
	if (player:mem(0x44, FIELD_BOOL)) then
		Layer.get("Tracks"):show(true)
		for _,v in ipairs(NPC.get(195, player.section)) do
			if not v.isGenerator and not v.layerObj.isHidden and v:mem(0x12A, FIELD_WORD) > 0 and  (player.keys.altJump == KEYS_PRESSED) then
				v:kill(8)
			end
		end
	elseif not player:mem(0x44, FIELD_BOOL) then
		Layer.get("Tracks"):hide(true)
	end
end

function onDraw()
	if (player:mem(0x44, FIELD_BOOL) and player.standingNPC) then
		player.direction = math.sign(player.standingNPC.speedX)
		player.frame = 1
	end
end]]