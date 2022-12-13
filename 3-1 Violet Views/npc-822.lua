local npcManager = require("npcManager");

local paddleWheel = {};

local npcID = NPC_ID
local platTexture = Graphics.loadImageResolved("platform.png");

paddleWheel.platformConfig = npcManager.setNpcSettings{
	id=npcID, 
	gfxwidth=64, 
	gfxheight=32, 
	width=64, 
	height=32, 
	frames=1,
	score=0,
	playerblock=false,
	playerblocktop=true,
	ignorethrownnpcs = true,
	npcblock=false,
	npcblocktop=true,
	nogravity=true,
	noblockcollision=true,
	nofireball=true,
	noiceball=true,
	noyoshi=true,
	grabside=false,
	isshoe=false,
	isyoshi=false,
	iscoin=false,
	nohurt=true,
	nogliding=true,
	notcointransformable = true,
};

function paddleWheel.onInitAPI()
	npcManager.registerEvent(npcID, paddleWheel, "onTickNPC", "onTickPlatform");
	npcManager.registerEvent(npcID, paddleWheel, "onDrawNPC", "onDrawPlatform");
end

function paddleWheel.onTickPlatform(npc)
	if Defines.levelFreeze then return end
	
	if npc.data._orbits == nil then
		if npc:mem(0x132, FIELD_WORD) > 0 then
			npc.speedX, npc.speedY = 0, 0;
			
			npc:mem(0x132, FIELD_WORD, 0);
		end
	end
end

function paddleWheel.onDrawPlatform(npc)
	local data = npc.data

	if not data.initialized then
		data.initialized = true
		data.sprite = Sprite.box{
			texture = platTexture,
			priority = -66,
			x = 0,
			y = 0
		}
	end
	
	data.sprite.position = vector(npc.x,npc.y)
  
	data.sprite:draw{priority=-66,sceneCoords=true}
end

return paddleWheel