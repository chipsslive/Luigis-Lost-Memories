local n = {}

local sh_portal = Shader()
sh_portal:compileFromFile(nil, "portal_glitched.frag")
local FONT_DEFAULT

local npcManager = require("npcManager")

local npcID = NPC_ID

--Defines NPC config for our NPC. You can remove superfluous definitions.
local sampleNPCSettings = {
	id = npcID,
	--Sprite size
	gfxheight = 128,
	gfxwidth = 128,
	--Hitbox size. Bottom-center-bound to sprite size.
	width = 128,
	height = 128,

	nohurt=true,
	nogravity = true,
	noblockcollision = true,
	nofireball = true,
	noiceball = true,
	noyoshi= true,
	nowaterphysics = true,
	--Various interactions
	jumphurt = true, --If true, spiny-like
	spinjumpsafe = true, --If true, prevents p hurt when spinjumping
	harmlessgrab = true, --Held NPC hurts other NPCs if false
	harmlessthrown = true, --Thrown NPC hurts other NPCs if false
}

--Applies NPC settings
npcManager.setNpcSettings(sampleNPCSettings)

function n.onInitAPI()
    npcManager.registerEvent(npcID, n, "onTickNPC")
	npcManager.registerEvent(npcID, n, "onDrawNPC")
	registerEvent(n, "onDraw")
end

local opacity = 0

local function overlay()
	opacity = 0.5
	SFX.play("sfx_portal.ogg")
end

function n.onDraw()
	opacity = opacity - 0.02
	if opacity > 0 then
		Graphics.drawScreen{priority = 0, color = Color.purple .. opacity}
	end
end

function n.onTickNPC(v)
	if v:mem(0x12A, FIELD_WORD) <= 0 then return end
	local data = v.data

	v.friendly = true
	if not data.initialized then
		local settings = data._settings
		data.initialized = true
		data.disappears = settings.disappear
		data.warpID = settings.warpID or 1
		data.used = false
	end

	if data.used then
		if data.disappears then
			v.isHidden = true
		end
		
		local w = Warp.get()[data.warpID]
		w.entranceX = data.lastWarpLocation.x
		w.entranceY = data.lastWarpLocation.y
	end
	--[[for k,p in ipairs(Player.get()) do
		if p.x + p.width > v.x - 32 and p.x < v.x + v.width + 32 then
			if vector(p.x + 0.5 * p.width - (v.x + 0.5 * v.width), p.y + 0.5 * p.height - (v.y + 0.5 * v.height)).length < 32 then
				local w = Warp.get()[data.warpID]
				data.lastWarpLocation = vector(w.entranceX, w.entranceY)
				w.entranceX = p.x + p.speedX
				w.entranceY = p.y + p.speedY
				overlay()
				data.used = true
			end
		end
	end]]
end

function n.onDrawNPC(v)
	if v:mem(0x12A, FIELD_WORD) <=0 then return end
	local data = v.data

    Graphics.drawBox{
        x = v.x,
        y = v.y,
        width = v.width,
        height = v.height,
        shader = sh_portal,
        uniforms = {
			perlinTexture = Graphics.sprites.hardcoded["53-0"].img,
			reasonableTime = lunatime.tick(),

            iTime = lunatime.tick() * 0.01,
        },
        priority = -46,
        sceneCoords = true
    }
end

return n