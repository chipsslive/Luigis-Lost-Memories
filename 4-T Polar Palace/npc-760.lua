local npcManager = require("npcManager")
local colliders = require("colliders")

local lineguide = require("lineguide")
lineguide.registerNpcs(NPC_ID)

local touched = false
local sound = false
local timer = 0

local slowBall = {}

local npcID = NPC_ID

local slowBallSettings = {
	id = npcID,

	gfxheight = 48,
	gfxwidth = 48,

	width = 48,
	height = 48,

	gfxoffsetx = 0,
	gfxoffsety = 0,

	frames = 4,
	framestyle = 0,
	framespeed = 8,

	speed = 1,

	npcblock = false,
	npcblocktop = false,
	playerblock = false,
	playerblocktop = false,

	nohurt=true,
	nogravity = false,
	noblockcollision = true,
	nofireball = true,
	noiceball = true,
	noyoshi= true,
	nowaterphysics = false,

	jumphurt = true,
	spinjumpsafe = false,
	harmlessgrab = false,
	harmlessthrown = false,

	grabside=false,
	grabtop=false,
}

npcManager.setNpcSettings(slowBallSettings)

npcManager.registerHarmTypes(npcID,
	{
		HARM_TYPE_OFFSCREEN,
	}
);

function slowBall.onInitAPI()
	npcManager.registerEvent(npcID, slowBall, "onTickNPC")
	registerEvent(slowBall, "onTick")
	registerEvent(slowBall, "onDraw")
	registerEvent(slowBall, "onDrawEnd")
end

function slowBall.onTickNPC(v)
	if Defines.levelFreeze then return end
	
	local data = v.data
	
	if v:mem(0x12A, FIELD_WORD) <= 0 then
		data.initialized = false
		return
	end

	if not data.initialized then
		data.initialized = true
	end

	if v:mem(0x12C, FIELD_WORD) > 0    
	or v:mem(0x136, FIELD_BOOL)        
	or v:mem(0x138, FIELD_WORD) > 0   
	then

	end

	if (colliders.collide(player, v)) then
        touched = true
    end
end

function slowBall.onTick()
	if touched then
		if sound == false then
			SFX.play("freeze.mp3")
			sound = true
		end
		Defines.player_walkspeed = 0.5
		Defines.player_runspeed = 1
		timer = timer + 1
		if timer == 120 then
			Defines.player_walkspeed = 3
			Defines.player_runspeed = 6
			touched = false
			sound = false
			timer = 0
		end
	end
end

local storedFrame
function slowBall.onDraw()
    if touched then
        player:render{
            rendermounts = false,
            color = Color.cyan, -- Change this to a different shade if you want
        }
        
        storedFrame = player.frame
        player.frame = 51
    end
end

function slowBall.onDrawEnd()
    if storedFrame ~= nil then
        player.frame = storedFrame
        storedFrame = nil
    end
end

return slowBall