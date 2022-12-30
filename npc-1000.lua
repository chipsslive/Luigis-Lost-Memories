local npcManager = require("npcManager")
local AI = require("customExit")
local sampleNPC = {}
local npcID = NPC_ID

local sampleNPCSettings = {
	id = npcID,
	gfxheight = 32,
	gfxwidth = 32,
	width = 32,
	height = 32,
	frames = 3,
	framestyle = 0,
	framespeed = 8,
	npcblock = false,
	npcblocktop = false, --Misnomer, affects whether thrown NPCs bounce off the NPC.
	playerblock = false,
	playerblocktop = false,

	nohurt = true,
	nogravity = true,
	noblockcollision = false,
	nofireball = true,
	noiceball = true,
	noyoshi = true,
	nowaterphysics = true,

	jumphurt = true,
	spinjumpsafe = false,
	harmlessgrab = true,
    harmlessthrown = true,

	grabside=false,
	grabtop=false,
	ignorethrownnpcs = true,
    notcointransformable = true,
}

npcManager.setNpcSettings(sampleNPCSettings)
npcManager.registerHarmTypes(npcID, {}, {})
AI.register(npcID)

return sampleNPC