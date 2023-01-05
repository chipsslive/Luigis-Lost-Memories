-- Written by Chipss. Vast majority of code taken from pastPortal.lua made by Marioman2007

local textplus  = require("textplus")
local pauseplus = require("pauseplus")
local stats     = require("statsMisc")

local titleFont = textplus.loadFont("MKDS-Exit.ini")

local audiblette = {}

local mov            = stats.movement
local img            = stats.images
local isOpen         = false
local isPlaying      = false
local selection      = 1
local trackSelection = 1
local movementOver   = true
local menuOpacity    = 0
local fadeType       = -1
local isTargeting    = false
local targetPos      = 0
local currentPos     = 0
local selLerpTimer   = 0
local selLerpSpeed   = 0
local selTarget      = 1
local pressTimer     = 0
local flashOpacity   = 0
local waitTimer      = stats.waitTime
local waitFunc       = function() end
local waitOpacity    = 0
local executed       = false

registerEvent(audiblette, "onStart")
registerEvent(audiblette, "onDraw")
registerEvent(audiblette, "onInputUpdate")

local function SFXPlay(name)
    if stats.SFX[name] and stats.SFX[name].id then
        local volume = stats.SFX[name].volume or 1
        SFX.play(stats.SFX[name].id, volume)
    end
end

function audiblette.open()
    Misc.pause()
    SFXPlay("enter")
    isOpen       = true
    selection    = 1
    trackSelection = 1
    movementOver = false
    menuOpacity  = 0
    fadeType     = 1
    isTargeting  = false
    targetPos    = 0
    currentPos   = 0
    selLerpTimer = 0
    selLerpSpeed = 0
    selTarget    = 1
    pressTimer   = 0
    for k, v in pairs(mov) do
        mov[k].type = 1
    end

    pauseplus.canPause = false
end

function audiblette.close()
    SFXPlay("exit")
    fadeType     = -1
    movementOver = false
    for k, v in pairs(mov) do
        mov[k].type = -1
    end

    pauseplus.canPause = true
end

local function canUpdateInput()
    return (
        movementOver == true
        and (not isTargeting and selLerpTimer == 0)
        and flashOpacity == 0
    )
end

local function setTarget(x)
    selTarget = x
    isTargeting = true
    targetPos   = ((x-1) * 32) + mov.list.position + stats.listOffsetY
end

local function getVert(pos, center, scale)
	return (pos-center)*scale + center
end

local function draw9Slice(args) -- credit to Enjl and Hoeloe for this function
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

local function movClamp(name, a, b)
    return math.clamp(mov[name].position + mov[name].speed * mov[name].type, mov[name][a], mov[name][b])
end

function audiblette.onDraw()
    if not isOpen then return end

    -- Movement transitioning in and out
    mov.audibletteTitle.position = movClamp("audibletteTitle", "origin", "goal")
    mov.trackList.position       = movClamp("trackList",       "origin", "goal")
    mov.currentTrack.position    = movClamp("currentTrack",    "goal", "origin")

    if mov.audibletteTitle.position == mov.audibletteTitle.goal
    and mov.trackList.position      == mov.trackList.goal
    and mov.currentTrack.position   == mov.currentTrack.origin then
        movementOver = true
    end

    if menuOpacity == 0 and fadeType == -1 then
        Misc.unpause()
        isOpen = false
    end

    -- Darken background
    Graphics.drawScreen{color = Color.black..math.min(menuOpacity, 0.5), priority = 5}

    menuOpacity = math.clamp(menuOpacity + 0.075 * fadeType, 0, 1)
    local textOpacity  = Color(menuOpacity,menuOpacity,menuOpacity,menuOpacity)
    local sine = math.sin(lunatime.drawtick() * 0.2) * 2

    -- Title
    draw9Slice{texture = img.frame1, x = 225, y = mov.audibletteTitle.position+60, w = 360, h = 54, priority = 5.1, color = Color.white..menuOpacity}
    textplus.print{font = titleFont, x = 252, y = mov.audibletteTitle.position+74, text = "The Audiblette", priority = 5.2, color = textOpacity}
    
    -- Choose track
    draw9Slice{texture = img.frame1, x = 165, y = mov.trackList.position+120, w = 470, h = 230, priority = 5.1, color = Color.white..menuOpacity}

    Graphics.drawImageWP(img.selector, 12 + stats.listOffsetX - 20 + sine, currentPos, menuOpacity, 5.3)

    -- Current track
    textplus.print{font = stats.font, x = 290, y = -mov.currentTrack.position+400, text = "Current Track", priority = 5.2, color = textOpacity}
    draw9Slice{texture = img.frame1, x = 165, y = -mov.currentTrack.position+420, w = 470, h = 60, priority = 5.1, color = Color.white..menuOpacity}

    -- Warn if music is currently muted
    if pauseplus.getSelectionValue("settings","Mute Music") then
        textplus.print{font = stats.fontRed, x = 330, y = -mov.currentTrack.position+500, text = "<align center>WARNING!</align>", priority = 5.2, color = textOpacity}
        textplus.print{font = stats.font, x = 70, y = -mov.currentTrack.position+502, text = "<align center><br>The 'Mute Music' setting is<br>currently enabled in the pause menu!</align>", priority = 5.2, color = textOpacity}
    end

    if isTargeting then
        local oldPos = ((selection-1) * 32) + mov.list.position + stats.listOffsetY
        selLerpSpeed = math.min(selLerpSpeed + 0.025, 1)
        selLerpTimer = math.min(selLerpTimer + selLerpSpeed, 1)
        currentPos = math.floor(math.lerp(oldPos, targetPos, selLerpTimer) + 0.5)
        if selLerpTimer == 1 then
            selection = selTarget
            selLerpSpeed = 0
            selLerpTimer = 0
            isTargeting = false
        end
    else
        currentPos = ((selection-1) * 32) + mov.list.position + stats.listOffsetY
        targetPos  = ((selection-1) * 32) + mov.list.position + stats.listOffsetY
    end

    Text.print(selection,0,0)
    Text.print(movementOver,0,16)
end

function audiblette.onInputUpdate()
    if not isOpen then return end
    if canUpdateInput() then
        if player.rawKeys.run == KEYS_PRESSED then
            audiblette.close()
            player:mem(0x172, FIELD_BOOL, false)
        end

        if player.rawKeys.up == KEYS_PRESSED then
            if selection ~= 1 then
                selection = 1
                SFXPlay("cursor")
            end
        elseif player.rawKeys.down == KEYS_PRESSED then
            if selection ~= 2 then
                selection = 2
                SFXPlay("cursor")
            end
        end

        if player.rawKeys.left == KEYS_PRESSED then
            if trackSelection == 1 then
                trackSelection = 11
            else
                trackSelection = trackSelection - 1
            end
            SFXPlay("switch")
        elseif player.rawKeys.right == KEYS_PRESSED then
            if trackSelection == 11 then
                trackSelection = 1
            else
                trackSelection = trackSelection + 1
            end
            SFXPlay("switch")
        end

        if player.rawKeys.jump == KEYS_PRESSED then
            if selection == 1 then
                Audio.MusicChange(0,stats.unusedMusic[trackSelection].filename)
                Audio.MusicChange(1,stats.unusedMusic[trackSelection].filename)
                Audio.MusicChange(2,stats.unusedMusic[trackSelection].filename)
            elseif selection == 2 then
                Audio.MusicChange(0,"!The Realm of Recollection/Red&Green - Abyss of polygons.mp3")
                Audio.MusicChange(1,"!The Realm of Recollection/Red&Green - Abyss of polygons.mp3")
                Audio.MusicChange(2,"!The Realm of Recollection/Red&Green - Abyss of polygons.mp3")
            end
        end
    end
end

return audiblette