--NPCManager is required for setting basic NPC properties
local npcManager = require("npcManager")
local respawnRooms = require("respawnRooms")

--Create the library table
local weakBrown = {}
--NPC_ID is dynamic based on the name of the library file
local npcID = NPC_ID
--Defines NPC config for our NPC. You can remove superfluous definitions.
local weakBrownSettings = {
	id = npcID,
	score = 0,
	--Sprite size
	gfxheight = 64,
	gfxwidth = 64,
	--Hitbox size. Bottom-center-bound to sprite size.
	width = 64,
	height = 64,
	--Sprite offset from hitbox for adjusting hitbox anchor on sprite.
	gfxoffsetx = 0,
	gfxoffsety = 0,
	--Frameloop-related
	frames = 1,
	framestyle = 0,
	framespeed = 8, --# frames between frame change
	--Movement speed. Only affects speedX by default.
	speed = 0,
	--Collision-related
	npcblock = true,
	npcblocktop = true, --Misnomer, affects whether thrown NPCs bounce off the NPC.
	playerblock = true,
	playerblocktop = true, --Also handles other NPCs walking atop this NPC.

	nohurt=true,
	nogravity = false,
	noblockcollision = false,
	nofireball = true,
	noiceball = true,
	noyoshi= true,
	nowaterphysics = false,
	--Various interactions
	jumphurt = false, --If true, spiny-like
	spinjumpsafe = false, --If true, prevents player hurt when spinjumping
	harmlessgrab = false, --Held NPC hurts other NPCs if false
	harmlessthrown = false, --Thrown NPC hurts other NPCs if false

	--Identity-related flags. Apply various vanilla AI based on the flag:
	--iswalker = false,
	--isbot = false,
	--isvegetable = false,
	--isshoe = false,
	--isyoshi = false,
	--isinteractable = false,
	--iscoin = false,
	--isvine = false,
	--iscollectablegoal = false,
	--isflying = false,
	--iswaternpc = false,
	--isshell = false,

	--Emits light if the Darkness feature is active:
	--lightradius = 100,
	--lightbrightness = 1,
	--lightoffsetx = 0,
	--lightoffsety = 0,
	--lightcolor = Color.white,

	--Define custom properties below
}

--Applies NPC settings
npcManager.setNpcSettings(weakBrownSettings)

--Registers the category of the NPC. Options include HITTABLE, UNHITTABLE, POWERUP, COLLECTIBLE, SHELL. For more options, check expandedDefines.lua
npcManager.registerDefines(npcID, {NPC.HITTABLE})

--Register the vulnerable harm types for this NPC. The first table defines the harm types the NPC should be affected by, while the second maps an effect to each, if desired.
npcManager.registerHarmTypes(npcID,
	{
		--HARM_TYPE_JUMP,
		HARM_TYPE_FROMBELOW,
		HARM_TYPE_NPC,
		HARM_TYPE_PROJECTILE_USED,
		--HARM_TYPE_LAVA,
		HARM_TYPE_HELD,
		HARM_TYPE_TAIL,
		--HARM_TYPE_SPINJUMP,
		--HARM_TYPE_OFFSCREEN,
		HARM_TYPE_SWORD
	}, 
	{
		--[HARM_TYPE_JUMP]=10,
		--[HARM_TYPE_FROMBELOW]=10,
		--[HARM_TYPE_NPC]=10,
		--[HARM_TYPE_PROJECTILE_USED]=10,
		--[HARM_TYPE_LAVA]={id=13, xoffset=0.5, xoffsetBack = 0, yoffset=1, yoffsetBack = 1.5},
		--[HARM_TYPE_HELD]=10,
		--[HARM_TYPE_TAIL]=10,
		--[HARM_TYPE_SPINJUMP]=10,
		--[HARM_TYPE_OFFSCREEN]=10,
		--[HARM_TYPE_SWORD]=10,
	}
);

--Custom local definitions below


--Register events
function weakBrown.onInitAPI()
	--npcManager.registerEvent(npcID, weakBrown, "onTickNPC")
	npcManager.registerEvent(npcID, weakBrown, "onTickEndNPC")
	--npcManager.registerEvent(npcID, weakBrown, "onDrawNPC")
	registerEvent(weakBrown, "onNPCKill")
end

function weakBrown.onTickEndNPC(v)
	--Don't act during time freeze
	if Defines.levelFreeze then return end
	
	local data = v.data
	
	if data.strength == nil then
		data.strength = 1
	end
	if data.restime == nil then
		data.restime = 16
	end
	if data.respite == nil then
		data.respite = false
	elseif data.respite then
		data.restime = data.restime - 1
	end
	if data.restime == 0 then
		data.restime = 16
		data.respite = false
	end
	
	v.animationFrame = 2
	
	--If despawned
	if v:mem(0x12A, FIELD_WORD) <= 0 then
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
end

function weakBrown.onNPCKill(eventObj, v, killReason, culprit)
	if v.id ~= npcID then return end
	if killReason == HARM_TYPE_JUMP or killReason == HARM_TYPE_SPINJUMP then return end
	local data = v.data
	if not data.respite then
		data.strength = data.strength - 1
	end
	if data.strength ~= 0 then
		eventObj.cancelled = true
	else
		SFX.play(4)
		Animation.spawn(1,v.x+32,v.y+32)
	end
	data.respite = true
end

function respawnRooms.onPreReset(fromRespawn)
	for k,v in ipairs(NPC.get(800)) do
		local data = v.data
		data.strength = 0
	end
end

--Gotta return the library table!
return weakBrown