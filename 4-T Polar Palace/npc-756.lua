--NPCManager is required for setting basic NPC properties
local npcManager = require("npcManager")
local clearpipe = require("blocks/ai/clearpipe")

--Create the library table
local cooligan = {}
--NPC_ID is dynamic based on the name of the library file
local npcID = NPC_ID

--Defines NPC config for our NPC. You can remove superfluous definitions.
local cooliganSettings = {
	id = npcID,
	gfxheight = 32,
	gfxwidth = 54,
	width = 54,
	height = 30,
	frames = 1,
	framestyle = 1,
	framespeed = 8,
	npcblock = false,
	npcblocktop = false,
	playerblock = false,
	playerblocktop = false,

	nohurt=false,
	nogravity = false,
	noblockcollision = false,
	nofireball = false,
	noiceball = false,
	noyoshi= false,
	nowaterphysics = true,
	--Various interactions
	jumphurt = false, --If true, spiny-like
	spinjumpsafe = false, --If true, prevents player hurt when spinjumping
	harmlessgrab = false, --Held NPC hurts other NPCs if false
	harmlessthrown = false, --Thrown NPC hurts other NPCs if false

	grabside=false,
	grabtop=false,
}

--Applies NPC settings
npcManager.setNpcSettings(cooliganSettings)

--Register the vulnerable harm types for this NPC. The first table defines the harm types the NPC should be affected by, while the second maps an effect to each, if desired.
npcManager.registerHarmTypes(npcID,
	{
		HARM_TYPE_JUMP,
		HARM_TYPE_FROMBELOW,
		HARM_TYPE_NPC,
		HARM_TYPE_PROJECTILE_USED,
		HARM_TYPE_LAVA,
		HARM_TYPE_HELD,
		--HARM_TYPE_TAIL,
		HARM_TYPE_SPINJUMP,
		--HARM_TYPE_OFFSCREEN,
		HARM_TYPE_SWORD
	}, 
	{
		--[HARM_TYPE_JUMP]=10,
		[HARM_TYPE_FROMBELOW]=npcID,
		[HARM_TYPE_NPC]=npcID,
		[HARM_TYPE_PROJECTILE_USED]=npcID,
		[HARM_TYPE_LAVA]={id=13, xoffset=0.5, xoffsetBack = 0, yoffset=1, yoffsetBack = 1.5},
		[HARM_TYPE_HELD]=npcID,
		--[HARM_TYPE_TAIL]=10,
		[HARM_TYPE_SPINJUMP]=10,
		--[HARM_TYPE_OFFSCREEN]=10,
		[HARM_TYPE_SWORD]=10,
	}
);


clearpipe.registerNPC(npcID)

--Register events
function cooligan.onInitAPI()
	npcManager.registerEvent(npcID, cooligan, "onTickNPC")
	registerEvent(cooligan, "onTick")
	registerEvent(cooligan, "onNPCKill")
end

function cooligan.onTick(v)
	for _,i in NPC.iterate(263) do
		if i:mem(0x12C, FIELD_WORD) > 0 then
			i.ai4 = i.ai4 + 1
		end
		if i.ai1 == npcID then
			i.ai3 = 2
			if i.ai4 == 0 then
				i.speedX = 5 * i.direction
			end
		end
    end
end

function cooligan.onTickNPC(v)
	--Don't act during time freeze
	if Defines.levelFreeze then return end
	
	local data = v.data
	
	--If despawned
	if v.despawnTimer <= 0 then
		--Reset our properties, if necessary
		data.initialized = false
		return
	end

	--Initialize
	if not data.initialized then
		--Initialize necessary data.
		data.initialized = true
	end

	--Depending on the NPC, these checks must be handled differently
	if v:mem(0x12C, FIELD_WORD) > 0    --Grabbed
	or v:mem(0x136, FIELD_BOOL)        --Thrown
	or v:mem(0x138, FIELD_WORD) > 0    --Contained within
	then
		--Handling
	end
		v.speedX = 5 * v.direction
		
	if v.underwater then
		v.speedY = -0.3
	end
	
	for _,npc in ipairs (NPC.getIntersecting(v.x - 7, v.y - 7, v.x + v.width + 7, v.y + v.height + 7)) do
		if npc.id == npcID + 1 then
			npc:kill(HARM_TYPE_NPC)
		end
	end
	
	if v:mem(0x138, FIELD_WORD) == 4 then
		if v:mem(0x144, FIELD_WORD) == 2 then
			v.x = v.x - 5
		elseif v:mem(0x144, FIELD_WORD) == 4 then
			v.x = v.x + 5
		end
	end
end

function cooligan.onNPCKill(obj, v, harm)
	if v.id == npcID then
		if harm == HARM_TYPE_JUMP then
		obj.cancelled = true
			local e = Animation.spawn(npcID + 2, v.x - 22, v.y - 16, v.animationFrame + 1)
			e.speedX = 3 * v.direction
			v:transform(npcID + 1, v.x, v.y)
			if v.direction == DIR_RIGHT then v.animationFrame = 2 end
		end
	end
end

--Gotta return the library table!
return cooligan