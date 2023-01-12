--NPCManager is required for setting basic NPC properties
local npcManager = require("npcManager")
local autoscroll = require("autoscroll")
local respawnRooms = require("respawnRooms")

--Create the library table
local heaveho = {}
--NPC_ID is dynamic based on the name of the library file
local npcID = NPC_ID

--Defines NPC config for our NPC. You can remove superfluous definitions.
local heavehoSettings = {
	id = npcID,
	--Sprite size
	gfxheight = 32,
	gfxwidth = 54,
	--Hitbox size. Bottom-center-bound to sprite size.
	width = 54,
	height = 32,
	--Sprite offset from hitbox for adjusting hitbox anchor on sprite.
	gfxoffsetx = 0,
	gfxoffsety = 0,
	--Frameloop-related
	frames = 8,
	framestyle = 0,
	framespeed = 8, --# frames between frame change
	--Movement speed. Only affects speedX by default.
	speed = 1,
	--Collision-related
	npcblock = false,
	npcblocktop = false, --Misnomer, affects whether thrown NPCs bounce off the NPC.
	playerblock = false,
	playerblocktop = true, --Also handles other NPCs walking atop this NPC.

	nohurt=true,
	nogravity = false,
	noblockcollision = false,
	nofireball = true,
	noiceball = false,
	noyoshi= true,
	nowaterphysics = false,
	--Various interactions
	jumphurt = false, --If true, spiny-like
	spinjumpsafe = false, --If true, prevents player hurt when spinjumping
	harmlessgrab = false, --Held NPC hurts other NPCs if false
	harmlessthrown = false, --Thrown NPC hurts other NPCs if false

	grabside=false,
	grabtop=false,
	cliffturn=true,

	--Identity-related flags. Apply various vanilla AI based on the flag:
	iswalker = true,
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
npcManager.setNpcSettings(heavehoSettings)

--Register the vulnerable harm types for this NPC. The first table defines the harm types the NPC should be affected by, while the second maps an effect to each, if desired.
npcManager.registerHarmTypes(npcID,
	{
		--HARM_TYPE_JUMP,
		--HARM_TYPE_FROMBELOW,
		--HARM_TYPE_NPC,
		--HARM_TYPE_PROJECTILE_USED,
		--HARM_TYPE_LAVA,
		--HARM_TYPE_HELD,
		--HARM_TYPE_TAIL,
		--HARM_TYPE_SPINJUMP,
		--HARM_TYPE_OFFSCREEN,
		--HARM_TYPE_SWORD
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

local barrel

--Register events
function heaveho.onInitAPI()
	npcManager.registerEvent(npcID, heaveho, "onTickNPC")
	--npcManager.registerEvent(npcID, heaveho, "onTickEndNPC")
	--npcManager.registerEvent(npcID, heaveho, "onDrawNPC")
	registerEvent(heaveho, "onStart")
end

local scrolling = false
local timer = 0
local timerStart = false
local lockPlayer = false

function heaveho.onTickNPC(v)
	--Don't act during time freeze
	if Defines.levelFreeze then return end
	
	local data = v.data

	v.direction = -1

	v.data.throwtimer = v.data.throwtimer or 0
	
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
	
	--Execute main AI. This template just jumps when it touches the ground.
	v.animationTimer = 0
	v.speedX = 1.5 * v.direction

	if data.throwtimer > 0 then
		data.throwtimer = data.throwtimer - 1
	end


	if data.throwtimer == 0 then
		if v.speedX == -1.5 then
			v.animationFrame = math.floor(lunatime.tick() / 8) % 3
		else
			v.animationFrame = (math.floor(lunatime.tick() / 8) % 3) + 3
		end
	else
		if v.direction == -1 then
			v.animationFrame = 6
		else
			v.animationFrame = 7
		end
		v.speedX = 0
	end

	if Colliders.collide(player, v) then
		if player.direction == -v.direction then
			data.throwtimer = 50
			player.speedY = -14
			player.speedX = v.direction * -8
			SFX.play(25)
		end
	end

	if data.throwtimer > 0 and not scrolling then
		autoscroll.scrollRight(4)
		lockPlayer = true
		scrolling = true
		timerStart = true
	end

	if timerStart then
		timer = timer + 1
	end

	if timer == 70 then
		lockPlayer = false
	end

	if timer == 120 then
		barrel:show(true)
	end

	if timer == 140 then
		barrel:hide(true)
	end

	if lockPlayer then
        for k, v in pairs(player.keys) do
            player.keys[k] = false
        end
    end
end

function heaveho.onStart()
	barrel = Layer.get("Barrel")
end

function respawnRooms.onPostReset(fromRespawn)
	autoscroll.unlockSection(3)
    autoscroll.scrollDown(0,nil,3)
	scrolling = false
	timer = 0
	timerStart = false
	lockPlayer = false
end

--Gotta return the library table!
return heaveho