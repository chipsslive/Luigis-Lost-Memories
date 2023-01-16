local megashroom = require("npcs/ai/megashroom")
local starman = require("npcs/ai/starman")
local npcManager = require("npcManager")
local npcutils = require("npcs/npcutils")
local textplus = require("textplus")
local stats = require("statsMisc")

local customExit = {}

customExit.npcList = {}
customExit.winTypeCUSTOM = 751
customExit.exitType      = LEVEL_END_STATE_ROULETTE
customExit.isInExit      = false
customExit.isInOptions   = false
customExit.isleaving     = false
customExit.animDelay     = 16
customExit.effectID      = 1000
customExit.leastPriority = 7
customExit.fadeSpeed     = 100
customExit.blackPriority = 100
customExit.font          = textplus.loadFont("portalFont.ini")
customExit.titleFont     = textplus.loadFont("MKDS-Exit.ini")
customExit.victory       = Graphics.loadImageResolved("luigi-victory.png")
customExit.collectSFX    = SFX.open(Misc.resolveSoundFile("goaltape_short"))

customExit.text = {
	"Memory Recovered!",
	"Summary",
	"Time",
	"Exit Memory",
	"Restart Memory"
}

customExit.images = {
	coin      = Graphics.loadImageResolved("coin2.png"),
	box       = Graphics.loadImageResolved("backdrop.png"),
	cross     = Graphics.loadImageResolved("pastPortal/cross.png"),
	selector  = Graphics.loadImageResolved("pastPortal/selector.png"),
	starCol   = Graphics.loadImageResolved("pastPortal/bigStarCol.png"),
	starUncol = Graphics.loadImageResolved("pastPortal/bigStarUncol.png"),
}

local darkAlpha = 0
local exitTimer  = 0
local victoryFrame = 0
local standTimer = 0
local updateFrame = false
local volume = 0
local img = customExit.images
local txt = customExit.text
local swipe1 = false
local swipe2 = false
local swipe3 = false
local alpha1 = 0
local alpha2 = 0
local alpha3 = 0
local headOffset = 39
local sumOffset  = 89
local optOffset  = 37
local fadeOut = false
local selection = 1
local exitFunc = function() Level.finish(customExit.exitType) end
local blackOpa = 0

--SaveData.coins = 10 -- TESTING
local initCoins = 0

local priorities = {}
priorities.dark = customExit.leastPriority
priorities.plyr = customExit.leastPriority + 0.1
priorities.back = customExit.leastPriority + 0.2
priorities.stuff = customExit.leastPriority + 0.3

local function getVert(pos, center, scale)
	return (pos-center)*scale + center
end

local function draw9Slice(args) -- thanks to Enjl for this code! (Feel free to copy this function but give credits to Enjl & Hoeloe)
	if not args.texture and not args.image then error("No image was provided as a texture!") end
	args.texture     = args.texture or args.image
	args.x, args.y   = args.x or 0, args.y or 0
	args.width       = args.width or args.w or 0
	args.height      = args.height or args.h or 0
	args.pivot       = args.pivot or args.align or Sprite.align.TOPLEFT
	args.priority    = args.priority or 5
    args.color       = args.color or args.colour or args.col or Color.white
    args.scale       = args.scale or vector(1,1)
	args.rotation    = args.rotation or args.angle or 0
	local scaleX,scaleY = 1,1
	if type(args.scale) == "number" then
		scaleX,scaleY = args.scale,args.scale
	else
		scaleX,scaleY = args.scale.x,args.scale.y
	end
	local tf = Transform.new2d(vector(xPos, yPos), args.rotation, vector(scaleX,scaleY))
	local xMod, yMod = args.width*args.pivot.x, args.height*args.pivot.y
	local xPos, yPos = args.x - xMod, args.y - yMod
    local width = args.texture.width
	local height = args.texture.height
    local cellWidth  = (width/3)
    local cellHeight = (height/3)
	local x1 = {0, cellWidth/width, (width - cellWidth)/width}
	local x2 = {cellWidth/width, (width - cellWidth)/width, 1}
	local y1 = {0, cellHeight/height, (height - cellHeight)/height}
	local y2 = {cellHeight/height, (height - cellHeight)/height, 1}
	local w  = {cellWidth, args.width - cellWidth - cellWidth, cellWidth}
	local h  = {cellHeight, args.height - cellHeight - cellHeight, cellHeight}
	local xv = {0, cellWidth, args.width - cellWidth}
	local yv = {0, cellHeight, args.height - cellWidth}
	local vt, tx = {}, {}
	local w1,w2,h1,h2 = 0,0,0,0

	for x = 1, 3 do
		for y=1, 3 do
			table.insert(vt, getVert(xPos + xv[x], xPos, scaleX))
			table.insert(vt, getVert(yPos + yv[y], yPos, scaleY))
			table.insert(tx, x1[x])
			table.insert(tx, y1[y])
			for i=1, 2 do
				table.insert(vt, getVert(xPos + xv[x] + w[x], xPos, scaleX))
				table.insert(vt, getVert(yPos + yv[y], yPos, scaleY))
				table.insert(tx, x2[x])
				table.insert(tx, y1[y])
				table.insert(vt, getVert(xPos + xv[x], xPos, scaleX))
				table.insert(vt, getVert(yPos + yv[y] + h[y], yPos, scaleY))
				table.insert(tx, x1[x])
				table.insert(tx, y2[y])
			end
			table.insert(vt, getVert(xPos + xv[x] + w[x], xPos, scaleX))
			table.insert(vt, getVert(yPos + yv[y] + h[y], yPos, scaleY))
			table.insert(tx, x2[x])
			table.insert(tx, y2[y])
		end
	end

	Graphics.glDraw{
		vertexCoords = vt,
		textureCoords = tx,
		priority = args.priority,
		texture = args.texture,
        color = args.color,
		primitive = Graphics.GL_TRIANGLES
	}
end

local function isOnGround(p)
	return (
		p.speedY == 0 -- "on a block"
		or p:mem(0x176,FIELD_WORD) ~= 0 -- on an NPC
		or p:mem(0x48,FIELD_WORD) ~= 0 -- on a slope
	)
end

local function awardCoins(amount)
	if GameData.awardCoins then
		local variant = math.min(math.floor(amount/5), 3)
		Effect.spawn(customExit.effectID, player, variant)
		Misc.coins(amount)
	end
end

local function getWidth(name)
	local w1 = (#name   * 22) + 24
    local w2 = (#txt[1] * 18) + 24
	return math.max(w1, w2)
end

function customExit.register(id)
    npcManager.registerEvent(id, customExit, "onTickNPC")
	table.insert(customExit.npcList, id)
end

function customExit.startExit(p)
	if Level.endState() > 0 then
        return
    end

	SFX.play(customExit.collectSFX)
	p.sectionObj.musicID = 0
	megashroom.StopMega(p,true)
    starman.stop(p)
	Level.endState(customExit.winTypeCUSTOM)
	Misc.npcToCoins()
	victoryFrame = RNG.randomInt(1, 3)

	for _,o in ipairs(Player.get()) do
        if o.idx ~= p.idx then
            o.section = p.section
            o.x = (p.x+(p.width/2)-(o.width/2))
            o.y = (p.y+p.height-o.height)
            o.speedX,o.speedY = 0,0
            o.forcedState,o.forcedTimer = 8,-p.idx
        end
    end

	customExit.isInExit = true
end

function customExit.onInitAPI()
	registerEvent(customExit, "onStart")
	registerEvent(customExit, "onTick")
	registerEvent(customExit, "onDraw")
end

function customExit.onStart()
	initCoins = SaveData.coins -- amount of coins that the player has, at the start
	--player.sectionObj.musicID = 0
end

function customExit.onTick()
	-- TESTING
	SaveData.coins = SaveData.coins + mem(0x00B2C5A8,FIELD_WORD)
	mem(0x00B2C5A8,FIELD_WORD,0)

	if (customExit.isInExit or customExit.isInOptions) then
		for k, v in pairs(player.keys) do
			player.keys[k] = false
		end
		if isOnGround(player) and not customExit.isleaving then
			standTimer = math.min(standTimer+1, customExit.animDelay+1)
			if standTimer == customExit.animDelay then
				updateFrame = true
				Audio.MusicChange(player.section, "triumph.mp3")
				volume = customExit.fadeSpeed
			end
			player.speedX = 0
			player.speedY = 0
		end
	end

	if volume >= 0 then
		volume = math.min(volume+customExit.fadeSpeed,64)
	end
	Audio.MusicVolume(volume)
end

function customExit.onDraw()
	local isVisible = (not player:mem(0x142, FIELD_BOOL) and player:mem(0x140, FIELD_WORD) ~= 0) or player:mem(0x140, FIELD_WORD) == 0

	if (customExit.isInExit or customExit.isInOptions) and (not customExit.isleaving) and isOnGround(player) and victoryFrame > 0 and isVisible and updateFrame then
		player.frame = -50 * player.direction

		Graphics.drawBox{
			texture = customExit.victory, x = player.x+player.width/2, y = player.y+player.height/2,
			width = 100*player.direction, height = 100,
			sourceX = 100*(victoryFrame-1), sourceY = 100*(player.powerup-1),
			sourceWidth = 100, sourceHeight = 100,
			centered = true, sceneCoords = true, priority = priorities.plyr,
		}
	elseif (customExit.isInExit or customExit.isInOptions) then
		player:render{priority = priorities.plyr}
	end

	if (customExit.isInExit or customExit.isInOptions) and not customExit.isleaving then
		darkAlpha = math.min(darkAlpha+0.0375,0.5)
		exitTimer = math.min(exitTimer + 1, 600)
	else
		darkAlpha = math.max(darkAlpha-0.025,0)
		exitTimer = 0
	end

	if exitTimer == 96 then
		swipe1 = true
	elseif exitTimer == 192 then
		swipe2 = true
	elseif exitTimer == 288 then
		swipe3 = true
	end

	if swipe1 then
		alpha1 = math.min(alpha1 + 0.075, 1)
		headOffset = math.max(headOffset - 4, 0)
	end

	if swipe2 then
		alpha2 = math.min(alpha2 + 0.075, 1)
		sumOffset = math.max(sumOffset - 4, 0)
	end

	if swipe3 then
		alpha3 = math.min(alpha3 + 0.075, 1)
		optOffset = math.max(optOffset - 4, 0)

		if alpha3 == 1 and optOffset == 0 then
			if player.rawKeys.up == KEYS_PRESSED and selection == 2 then
				selection = 1
				SFX.play(stats.SFX.cursor.id, stats.SFX.cursor.volume)
			elseif player.rawKeys.down == KEYS_PRESSED and selection == 1 then
				selection = 2
				SFX.play(stats.SFX.cursor.id, stats.SFX.cursor.volume)
			elseif player.rawKeys.jump == KEYS_PRESSED then
				if selection == 1 then
					exitFunc = function() Level.finish(customExit.exitType) end
				elseif selection == 2 then
					exitFunc = function() Level.load(Level.filename()) end
				end
				SFX.play(stats.SFX.select.id, stats.SFX.select.volume)
				fadeOut = true
				Level.endState(0)
				customExit.isleaving = true
			end
		end
	end

	if fadeOut then
		swipe1 = false
		swipe2 = false
		swipe3 = false
		alpha1 = math.max(alpha1 - 0.075, 0)
		alpha2 = math.max(alpha2 - 0.075, 0)
		alpha3 = math.max(alpha3 - 0.075, 0)
	end

	if customExit.isleaving then
		player.direction = 1
		player.speedX = Defines.player_walkspeed
		blackOpa = math.min(blackOpa + 0.05, 1)
	end

	if blackOpa == 1 then
		exitFunc()
	end

	Graphics.drawScreen{color = Color.black..darkAlpha, priority = priorities.dark}
	Graphics.drawScreen{color = Color.black..blackOpa, priority = customExit.blackPriority}

	local opa1 = Color(alpha1,alpha1,alpha1,alpha1)
	local opa2 = Color(alpha2,alpha2,alpha2,alpha2)
	local opa3 = Color(alpha3,alpha3,alpha3,alpha3)

	local name = (stats.getByFilename(Level.filename()) and stats.getByFilename(Level.filename()).name) or "Untitled"
	local timer = (SaveData.levelStats[Level.filename()] and SaveData.levelStats[Level.filename()].timer) or "00:00:00:00"
	draw9Slice{image=img.box, x=400, y=headOffset+96, w=getWidth(name), h=78, priority=priorities.back, color=Color.white..alpha1, align=Sprite.align.TOP}
	draw9Slice{image=img.box, x=400, y=sumOffset+210, w=220, h=178, priority=priorities.back, color=Color.white..alpha2, align=Sprite.align.TOP}
	draw9Slice{image=img.box, x=400, y=optOffset+424, w=298, h=74, priority=priorities.back, color=Color.white..alpha3, align=Sprite.align.TOP}

	textplus.print{font = customExit.titleFont, x = 400, y = headOffset+108, text = name, priority = priorities.stuff, color = opa1, pivot = vector(0.5, 0)}
	textplus.print{font = customExit.font, x = 400, y = headOffset+144, text = txt[1], priority = priorities.stuff, color = opa1, pivot = vector(0.5, 0)}

	textplus.print{font = customExit.font, x = 400, y = sumOffset+222, text = txt[2], priority = priorities.stuff, color = opa2, pivot = vector(0.5, 0)}
	textplus.print{font = customExit.font, x = 400, y = sumOffset+336, text = txt[3], priority = priorities.stuff, color = opa2, pivot = vector(0.5, 0)}
	textplus.print{font = customExit.font, x = 400, y = sumOffset+360, text = stats.formatTime(timer), priority = priorities.stuff, color = opa2, pivot = vector(0.5, 0)}
	textplus.print{font = customExit.font, x = 404, y = sumOffset+250, text = tostring(SaveData.coins-initCoins), priority = priorities.stuff, color = opa2}

	textplus.print{font = customExit.font, x = 284, y = optOffset+436, text = txt[4], priority = priorities.stuff, color = opa3}
	textplus.print{font = customExit.font, x = 284, y = optOffset+468, text = txt[5], priority = priorities.stuff, color = opa3}

	Graphics.drawImageWP(img.coin, 362, sumOffset+248, alpha2, priorities.stuff)
	Graphics.drawImageWP(img.cross, 386, sumOffset+252, alpha2, priorities.stuff)
	Graphics.drawImageWP(img.selector, 262, optOffset+436 + 32*(selection-1), alpha3, priorities.stuff)

	local starCoins = SaveData._basegame.starcoin[Level.filename()]
	local sX = 336
	local sX2 = sX + 128

	if starCoins and #starCoins > 0 then
		for index, value in ipairs(starCoins) do
			local length = 46 * (#starCoins - 1) + img.starCol.width
			local xcen = math.ceil((math.abs(sX - sX2) - length)/2)
			local simg
			if value == 0 then simg = img.starUncol else simg = img.starCol end

			Graphics.drawImageWP(simg, sX + xcen + 46 * (index - 1), sumOffset+276, alpha2, priorities.stuff)
		end
	end
end

function customExit.onTickNPC(v)
	if Defines.levelFreeze then return end
	
	local data = v.data

	if v.despawnTimer <= 0 then
		data.initialized = false
		return
	end

	if not data.initialized then
		data.initialized = true
	end

	if v:mem(0x12C, FIELD_WORD) > 0    --Grabbed
	or v:mem(0x136, FIELD_BOOL)        --Thrown
	or v:mem(0x138, FIELD_WORD) > 0    --Contained within
	then return end

	for _, p in ipairs(Player.get()) do
        if (p.forcedState == 0 and p.deathTimer == 0 and not p:mem(0x13C,FIELD_BOOL)) then
			if Colliders.collide(v,p) then
				if SaveData.levelStats[Level.filename()] then
					SaveData.levelStats[Level.filename()].beaten = true
				end
				awardCoins((v.animationFrame+1)*5)
				customExit.startExit(p)
				v:kill(HARM_TYPE_VANISH)

				if Level.filename() == "3-3 Lightweight Library.lvlx" and SaveData.levelStats[Level.filename()].timer < lunatime.toTicks(120) and not GameData.usedAccessibility then
					if not SaveData.challenge1Completed then
						GameData.ach_Challenge1:collect()
						SaveData.totalChallengesCompleted = SaveData.totalChallengesCompleted + 1
						SaveData.challenge1Completed = true
					end
				end
			end
		end
	end
end

return customExit