local spawnzones = require("spawnzones")
local slm = require("simpleLayerMovement")
local respawnRooms = require("respawnRooms")
local clearpipe = require("blocks/ai/clearpipe")
local clearpipe_npc = require("npcs/ai/clearpipeNPC")
local lineguide = require("lineguide")
local autoscroll = require("autoscroll")
local warpTransition = require("warpTransition")

-- There are two variants of coins used in the level, so only register 1 to lineguides

lineguide.registerNpcs(88)
lineguide.properties[88] = {lineSpeed = 1}

-- Assign stuff to clearpipes

table.insert(clearpipe_npc.ids, 312)
clearpipe_npc.ids_map[312] = true
clearpipe.registerPipe(1, "END", "VERT", {true, true, false, false})

-- NPC remover stuff

local hasRemoverBGOs = 0
local extraPadding = 256

local launched = false

function loadFile(name)
	return Misc.resolveFile(name)
end

clearpipe.sfx = loadFile("sfx_clearpipe.ogg")
clearpipe_npc.sfx = clearpipe.sfx

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

function onLoadSection3()
	warpTransition.crossSectionTransition = warpTransition.TRANSITION_FADE
	warpTransition.transitionSpeeds[warpTransition.TRANSITION_FADE] = 150
end

function onLoadSection4()
	player.powerup = 2
end

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

	for _,v in NPC.iterate(278) do
        if isCol(v) and v:mem(0x138, FIELD_WORD) ~= 4 and v:mem(0x12C, FIELD_WORD) == 0 then
            v:kill(HARM_TYPE_VANISH)
        end
    end

	if player.section == 1 and player.y < -181280 and player:isGroundTouching() and not launched then
		triggerEvent("Launch Tree1")
		launched = true
	end

	if player.deathTimer > 0 then return end
    if player:mem(0x148, FIELD_WORD) > 0
    and player:mem(0x14C, FIELD_WORD) > 0 then
        player:kill()
    end
end

function onEvent(eventName)
	if eventName == "Launch Tree1" then
		SFX.play("helmets_propellerBox_boost1.wav")
	end
end

local silence = SFX.open("Silence.ogg")

function onLoadSection2()
	Audio.sounds[24].sfx = silence
end

function onPostNPCKill(npc, reason)
	if npc.id == 319 then
	  	local effect = Animation.spawn(176, npc.x + npc.width*0.5, npc.y + npc.height*0.5)
	  	effect.x, effect.y = effect.x - effect.width*0.5, effect.y - effect.height*0.5
	end 

	if npc.id == 278 then
		local effect = Animation.spawn(75, npc.x + npc.width*0.5, npc.y + npc.height*0.5)
		effect.x, effect.y = effect.x - effect.width*0.5, effect.y - effect.height*0.5
 	end 

	--[[if npc.id == 320 then
		local effect = Animation.spawn(10, npc.x + npc.width*0.5, npc.y + npc.height*0.5)
		effect.x, effect.y = effect.x - effect.width*0.5, effect.y - effect.height*0.5
  	end ]]
end

function respawnRooms.onPostReset(fromRespawn)
    slm.addLayer{name = "Float1",speed = 96,verticalMovement = slm.MOVEMENT_COSINE,verticalSpeed = 76,verticalDistance = 0.1}
	slm.addLayer{name = "Float2",speed = 96,verticalMovement = slm.MOVEMENT_COSINE,verticalSpeed = 76,verticalDistance = -0.1}

	launched = false
end