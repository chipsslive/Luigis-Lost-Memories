--NPCManager is required for setting basic NPC properties
local npcManager = require("npcManager")

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
	frames = 2,
	framestyle = 1,
	framespeed = 6,
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
		HARM_TYPE_OFFSCREEN,
		HARM_TYPE_SWORD
	}, 
	{
		[HARM_TYPE_JUMP]=npcID,
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


--Register events
function cooligan.onInitAPI()
	npcManager.registerEvent(npcID, cooligan, "onTickNPC")
end

function cooligan.onTickNPC(v)
	--Don't act during time freeze
	if Defines.levelFreeze then return end
	
	v.speedX = 2 * v.direction
	
	if v:mem(0x138, FIELD_WORD) == 4 then
		if v:mem(0x144, FIELD_WORD) == 2 then
			v.x = v.x - 2
		elseif v:mem(0x144, FIELD_WORD) == 4 then
			v.x = v.x + 2
		end
	end
	
end

--Gotta return the library table!
return cooligan