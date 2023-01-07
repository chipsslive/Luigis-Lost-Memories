local spawnzones = require("spawnzones");

function onExitLevel(levelWinType)
    if levelWinType == LEVEL_WIN_TYPE_KEYHOLE and not GameData.usedAccesibility then
        GameData.ach_AllKeyholes:setCondition(3,true)
		if not SaveData.keyhole3Found then
			if GameData.ach_HundredPercent:getCondition(4).value < SaveData.totalKeyholesFound + 1 then
			    GameData.ach_HundredPercent:setCondition(4,SaveData.totalKeyholesFound + 1)
            end
			SaveData.totalKeyholesFound = SaveData.totalKeyholesFound + 1
			SaveData.keyhole3Found = true
		end
    end
end

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