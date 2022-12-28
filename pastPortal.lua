--[[
    by Marioman2007 for Luigi's Lost Memories
    NOT TO BE USED WITHOUT PERMISSION!
]]

local stats = require("statsMisc")
local textplus = require("textplus")
local pauseplus = require("pauseplus")

local pastPortal = {}

local levelList    = {[stats.LVL_LOST] = {}, [stats.LVL_FRAG] = {}, [stats.LVL_ALT] = {}, [stats.LVL_MAP] = {}}
local mov          = stats.movement
local img          = stats.images
local isOpen       = false
local selection    = 1
local currentTab   = stats.LVL_LOST
local movementOver = true
local confActive   = 0
local menuOpacity  = 0
local fadeType     = -1
local isTargeting  = false
local targetPos    = 0
local currentPos   = 0
local selLerpTimer = 0
local selLerpSpeed = 0
local selTarget    = 1
local confirmSel   = 0
local confOpacity  = 0
local pressTimer   = 0
local confText     = ""
local conOffset    = 26
local lvlTitle     = ""
local flashOpacity = 0
local waitTimer    = stats.waitTime
local waitFunc     = function() end
local waitOpacity  = 0
local executed     = false

local priorities = {}
priorities.bg        = stats.leastPriority
priorities.tabs      = stats.leastPriority + 0.1
priorities.stuff     = stats.leastPriority + 0.2
priorities.stuffHigh = stats.leastPriority + 0.3
priorities.stars     = stats.leastPriority + 0.4
priorities.confBg    = stats.leastPriority + 0.5
priorities.confirm   = stats.leastPriority + 0.6
priorities.options   = stats.leastPriority + 0.7
priorities.flash     = stats.leastPriority + 0.8

local function SFXPlay(name)
    if stats.SFX[name] and stats.SFX[name].id then
        local volume = stats.SFX[name].volume or 1
        SFX.play(stats.SFX[name].id, volume)
    end
end

function pastPortal.open()
    Misc.pause()
    SFXPlay("enter")
    isOpen       = true
    selection    = 1
    currentTab   = stats.LVL_LOST
    movementOver = false
    confActive   = 0
    menuOpacity  = 0
    fadeType     = 1
    isTargeting  = false
    targetPos    = 0
    currentPos   = 0
    selLerpTimer = 0
    selLerpSpeed = 0
    selTarget    = 1
    confirmSel   = 0
    confOpacity  = 0
    pressTimer   = 0
    for k, v in pairs(mov) do
        mov[k].type = 1
    end

    pauseplus.canPause = false
end

function pastPortal.close()
    SFXPlay("exit")
    fadeType     = -1
    movementOver = false
    for k, v in pairs(mov) do
        mov[k].type = -1
    end

    pauseplus.canPause = true
end

function pastPortal.registerLevel(args)
    args = args or {}
    args.name = args.name or "Untitled"
    args.description = args.description or "None"
    args.type = args.type or stats.LVL_LOST

    local imgName = args.filename:gsub("%.lvlx", "")
    local image = Graphics.loadImageResolved("pastPortal/levels/"..imgName..".png")
    local entry = {image = image, name = args.name, description = args.description, type = args.type, filename = args.filename}
    local id = #levelList[args.type] + 1

    levelList[args.type][id] = entry
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

-- copied straight from my shop lib
local function movClamp(name, a, b)
    return math.clamp(mov[name].position + mov[name].speed * mov[name].type, mov[name][a], mov[name][b])
end

local function getNPC(filename, id)
    local levelData = FileFormats.openLevel(filename)
    local idMap = (type(id) == "table" and table.map(id)) or {[id] = true}

    local npcList = {}
    for k, v in ipairs(levelData.npc) do
        if idMap[v.id] then
            table.insert(npcList, v)
        end
    end
    return npcList
end

registerEvent(pastPortal, "onStart")
registerEvent(pastPortal, "onDraw")
registerEvent(pastPortal, "onInputUpdate")

function pastPortal.onStart()
    for i = 1, 3 do -- the ultimate performance killer
        for k, v in ipairs(levelList[i]) do
            v.starcoins = getNPC(v.filename, 310)
        end
    end
end

function pastPortal.onDraw()
    if not isOpen then return end

    mov.title.position   = movClamp("title",   "origin", "goal")
    mov.tabs.position    = movClamp("tabs",    "origin", "goal")
    mov.list.position    = movClamp("list",    "goal",   "origin")
    mov.details.position = movClamp("details", "goal",   "origin")

    if mov.title.position    == mov.title.goal
    and mov.tabs.position    == mov.tabs.goal
    and mov.list.position    == mov.list.goal
    and mov.details.position == mov.details.goal then
        movementOver = true
    end

    if menuOpacity == 0 and fadeType == -1 then
        Misc.unpause()
        isOpen = false
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

    pressTimer = math.max(pressTimer - 1, 0)
    menuOpacity = math.clamp(menuOpacity + 0.075 * fadeType, 0, 1)
    local textOpacity  = Color(menuOpacity,menuOpacity,menuOpacity,menuOpacity)
    local textOpacity2 = Color.black..menuOpacity
    local totalStars = math.max(SaveData._basegame.starcoinCounter - SaveData.spentStars, 0)
    local sine = math.sin(lunatime.drawtick() * 0.2) * 2

    Graphics.drawScreen{color = Color.black..math.min(menuOpacity, 0.5), priority = priorities.bg}
    Graphics.drawImageWP(img.title, 400-img.title.width/2, mov.title.position, menuOpacity, priorities.tabs)
    draw9Slice{texture = img.frame1, x = 12, y = mov.list.position,     w = 512, h = 456, priority = priorities.tabs, color = Color.white..menuOpacity}
    draw9Slice{texture = img.frame1, x = mov.details.position, y = 124, w = 248, h = 456, priority = priorities.tabs, color = Color.white..menuOpacity}
    draw9Slice{texture = img.frame1, x = mov.details.position+142, y = 70, w = 106, h = 50, priority = priorities.tabs, color = Color.white..menuOpacity}
    Graphics.drawImageWP(img.starCol, mov.details.position+156, 84, menuOpacity, priorities.stuff)
    Graphics.drawImageWP(img.cross, mov.details.position+182, 90, menuOpacity, priorities.stuff)
    textplus.print{font = stats.font, x = mov.details.position+200, y = 88, text = string.format("%.2d", totalStars), priority = priorities.stuff, color = textOpacity}

    for i = 1, 4 do -- the 4 tabs
        draw9Slice{texture = img.frame1, x = mov.tabs.position + ((i-1)*124), y = 60, w = 120, h = 60, priority = priorities.tabs, color = Color.white..menuOpacity}
        textplus.print{font = stats.smallFont, x = mov.tabs.position + 12 + ((i-1)*124), y = 92, text = "Memories", priority = priorities.stuffHigh, color = textOpacity, xscale = 2, yscale = 2}
        textplus.print{font = stats.smallFont, x = mov.tabs.position + 14 + ((i-1)*124), y = 94, text = "Memories", priority = priorities.stuff, color = textOpacity2, xscale = 2, yscale = 2}

        local headings = {"Lost", "Fragmented", "Alternate", "Map of"}
        textplus.print{font = stats.smallFont, x = mov.tabs.position + 12 + ((i-1)*124), y = 72, text = headings[i], priority = priorities.stuffHigh, color = textOpacity, xscale = 2, yscale = 2}
        textplus.print{font = stats.smallFont, x = mov.tabs.position + 14 + ((i-1)*124), y = 74, text = headings[i], priority = priorities.stuff, color = textOpacity2, xscale = 2, yscale = 2}

        if i ~= currentTab or (not SaveData.unlockedTabs[currentTab]) then
            Graphics.drawImageWP(img.dark, mov.tabs.position + ((i-1)*124), 60, menuOpacity, priorities.stuffHigh)
        end

        if i == currentTab and (not SaveData.unlockedTabs[currentTab]) then
            draw9Slice{texture = img.frame2, x = mov.tabs.position + ((i-1)*124), y = 60, w = 120, h = 60, priority = priorities.stars, color = Color.white..menuOpacity}
        end

        local thisFont = stats.font

        if stats.tabDetails[i].starsNeeded <= totalStars then
            thisFont = stats.fontGreen
        end

        if not SaveData.unlockedTabs[i] then
            Graphics.drawImageWP(img.starCol, mov.tabs.position + ((i-1)*124)+30, 78, menuOpacity, priorities.stars)
            textplus.print{font = thisFont, x = mov.tabs.position + ((i-1)*124)+56, y = 82, text = string.format("%.2d", stats.tabDetails[i].starsNeeded), priority = priorities.stars, color = textOpacity}
        end
    end

    if SaveData.unlockedTabs[currentTab] then
        if currentTab ~= stats.LVL_MAP then -- details
            local v = levelList[currentTab][selection]
            
            Graphics.drawImageWP(v.image, mov.details.position + 44, 152, menuOpacity, priorities.stuff)
            draw9Slice{texture = img.frame2, x = mov.details.position + 36, y = 144, w = v.image.width+16, h = v.image.height+16, priority = priorities.stuffHigh, color = Color.white..menuOpacity}
            Graphics.drawImageWP(img.selector, 12 + stats.listOffsetX - 20 + sine, currentPos, menuOpacity, priorities.stuff)

            local desTxt = textplus.layout(v.description, 220, {font = stats.smallFont, xscale =2, yscale = 2, color = textOpacity})
            textplus.print{font = stats.font, x = mov.details.position + 124, y = 268, pivot = vector(0.5, 0), text = "Description:", priority = priorities.stuff, color = textOpacity}
            textplus.render{x = mov.details.position + 16, y = 292, layout = desTxt, priority = priorities.stuffHigh}

            local desTxtBG = textplus.layout(v.description, 220, {font = stats.smallFont, xscale =2, yscale = 2, color = textOpacity2})
            textplus.render{x = mov.details.position + 18, y = 294, layout = desTxtBG, priority = priorities.stuff}

            textplus.print{font = stats.font, x = mov.details.position + 16, y = 446, text = "Recovered?", priority = priorities.stuff, color = textOpacity}
            Graphics.drawImageWP(img.boxBig, mov.details.position + 200, 440, menuOpacity, priorities.stuff)
            if SaveData.levelStats[v.filename] and SaveData.levelStats[v.filename].beaten then
                Graphics.drawImageWP(img.checkBig, mov.details.position + 200, 440, menuOpacity, priorities.stuffHigh)
            end

            textplus.print{font = stats.font, x = mov.details.position + 124, y = 518, pivot = vector(0.5, 0), text = "Best Time", priority = priorities.stuff, color = textOpacity}

            local bestTime = (SaveData.levelStats[v.filename] and stats.formatTime(SaveData.levelStats[v.filename].bestTime)) or "-"
            textplus.print{font = stats.font, x = mov.details.position + 124, y = 538, pivot = vector(0.5, 0), text = bestTime, priority = priorities.stuff, color = textOpacity}

            local starCoins = SaveData._basegame.starcoin[v.filename]
            local sX = mov.details.position + 60
            local sX2 = sX + 128

            if starCoins and #starCoins > 0 then
                for index, value in ipairs(starCoins) do
                    local length = 46 * (#starCoins - 1) + img.bigStarCol.width
                    local xcen = math.ceil((math.abs(sX - sX2) - length)/2)
                    local simg
                    if value == 0 then simg = img.bigStarUncol else simg = img.bigStarCol end
        
                    Graphics.drawImageWP(simg, sX + xcen + 46 * (index - 1), 472, menuOpacity, priorities.stuffHigh)
                end
            else -- the level wasn't loaded hence the game can't check for starcoins, open the level and count the starcoins
                if v.starcoins and #v.starcoins > 0 then
                    for i = 1, #v.starcoins do
                        local length = 46 * (#v.starcoins - 1) + img.bigStarCol.width
                        local xcen = math.ceil((math.abs(sX - sX2) - length)/2)
                        Graphics.drawImageWP(img.bigStarUncol, sX + xcen + 46 * (i - 1), 472, menuOpacity, priorities.stuffHigh)
                    end
                else -- if the level doesn't have any starcoins
                    textplus.print{font = stats.font, x = mov.details.position + 124, y = 484, pivot = vector(0.5, 0), text = "-", priority = priorities.stuff, color = textOpacity}
                end
            end
        else
            local desTxt = textplus.layout(stats.mapDescription, 180, {font = stats.smallFont, xscale =2, yscale = 2, color = textOpacity})
            textplus.print{font = stats.font, x = mov.details.position + 44, y = 268, text = "World Map", priority = priorities.stuff, color = textOpacity}
            textplus.render{x = mov.details.position + 44, y = 292, layout = desTxt, priority = priorities.stuffHigh}

            local desTxtBG = textplus.layout(stats.mapDescription, 180, {font = stats.smallFont, xscale =2, yscale = 2, color = textOpacity2})
            textplus.render{x = mov.details.position + 46, y = 294, layout = desTxtBG, priority = priorities.stuff}

            Graphics.drawImageWP(stats.mapImg2, mov.details.position + 44, 152, menuOpacity, priorities.stuff)
            Graphics.drawImageWP(stats.mapImg, 36, mov.list.position + 28, menuOpacity, priorities.stuff)

            draw9Slice{texture = img.frame2, x = mov.details.position + 36, y = 144, w = stats.mapImg2.width+16, h = stats.mapImg2.height+16, priority = priorities.stuffHigh, color = Color.white..menuOpacity}
            draw9Slice{texture = img.frame2, x = 28, y = mov.list.position + 20, w = stats.mapImg.width+16, h = stats.mapImg.height+16, priority = priorities.stuffHigh, color = Color.white..menuOpacity}

            textplus.print{font = stats.font, x = 50, y = mov.list.position + 414, text = "Explore!", priority = priorities.stuff, color = textOpacity}
            Graphics.drawImageWP(img.selector, 28 + sine, mov.list.position + 414, menuOpacity, priorities.stuff)
        end

        for k, v in ipairs(levelList[currentTab]) do -- level list
            textplus.print{font = stats.font, x = 12 + stats.listOffsetX, y = ((k-1) * 32) + mov.list.position + stats.listOffsetY, text = v.name, priority = priorities.stuff, color = textOpacity}
            Graphics.drawImageWP(img.boxSmall, 12 + stats.listOffsetX + 360, ((k-1) * 32) + mov.list.position + stats.listOffsetY - 2, menuOpacity, priorities.stuff)

            if SaveData.levelStats[v.filename] and SaveData.levelStats[v.filename].beaten then
                Graphics.drawImageWP(img.checkSmall, 12 + stats.listOffsetX + 360, ((k-1) * 32) + mov.list.position + stats.listOffsetY - 2, menuOpacity, priorities.stuffHigh)
            end

            --Text.printWP(#v.starcoins, 442, ((k-1) * 32) + mov.list.position + stats.listOffsetY - 2, priorities.stuffHigh+10)

            local starCoins = SaveData._basegame.starcoin[v.filename]

            if starCoins and #starCoins > 0 then
                for index, value in ipairs(starCoins) do
                    local length = 24 * (#starCoins - 1) + img.starCol.width
                    local xcen = math.ceil((math.abs(442 - 512) - length)/2)
                    local simg
                    if value == 0 then simg = img.starUncol else simg = img.starCol end
        
                    Graphics.drawImageWP(simg, 442 + xcen + 24 * (index - 1), ((k-1) * 32) + mov.list.position + stats.listOffsetY - 2, menuOpacity, priorities.stuffHigh)
                end
            else -- the level wasn't loaded hence the game can't check for starcoins, open the level and count the starcoins
                if v.starcoins and #v.starcoins > 0 then
                    for i = 1, #v.starcoins do
                        local length = 24 * (#v.starcoins - 1) + img.starCol.width
                        local xcen = math.ceil((math.abs(442 - 512) - length)/2)
                        Graphics.drawImageWP(img.starUncol, 442 + xcen + 24 * (i - 1), ((k-1) * 32) + mov.list.position + stats.listOffsetY - 2, menuOpacity, priorities.stuffHigh)
                    end
                else -- if the level doesn't have any starcoins
                    textplus.print{font = stats.font, x = 12 + stats.listOffsetX + 420, y = ((k-1) * 32) + mov.list.position + stats.listOffsetY, text = "-", priority = priorities.stuff, color = textOpacity}
                end
            end
        end
    else --------------- not unlocked ---------------
        Graphics.drawImageWP(img.lock, mov.details.position + 100, 224, menuOpacity, priorities.stuff)
        Graphics.drawImageWP(img.lock, 244, mov.list.position + 100, menuOpacity, priorities.stuff)

        local text1 = textplus.layout(stats.tabDetails[currentTab].text, 490, {font = stats.font, color = textOpacity})
        textplus.render{x = 28, y = mov.list.position + 268, layout = text1, priority = priorities.stuff}

        local bottomText = (stats.tabDetails[currentTab].starsNeeded <= totalStars and stats.pressJump) or stats.notEnough
        local text2 = textplus.layout(bottomText, 490, {font = stats.font, color = textOpacity})
        textplus.render{x = 28, y = mov.list.position + 378, layout = text2, priority = priorities.stuff}

        if bottomText == stats.pressJump then
            textplus.print{text = "JUMP", x = 136, y = mov.list.position + 378, font = stats.fontGreen, color = textOpacity, priority = priorities.stuffHigh}
        end

        local text3 = textplus.layout(stats.locked, 220, {font = stats.font, color = textOpacity})
        textplus.render{x = mov.details.position + 44, y = 392, layout = text3, priority = priorities.stuff}
    end

    -- Confirm Box
    if confActive > 0 then
        confOpacity = math.min(confOpacity + 0.075, 1)
    else
        confOpacity = math.max(confOpacity - 0.075, 0)
    end

    if confOpacity == 0 then
        lvlTitle  = ""
        conOffset = 26
        confirmSel = 0
    end

    local conTextAlpha = Color(confOpacity,confOpacity,confOpacity,confOpacity)
    local xOffset = 157

    if confirmSel == 1 then
        xOffset = 157
    elseif confirmSel == 2 then
        xOffset = 358
    end

    Graphics.drawScreen{color = Color.black..math.min(confOpacity, 0.75), priority = priorities.confBg}
    draw9Slice{texture = img.frame1, x = 400, y = 300, w = 600, h = 120, priority = priorities.confirm, color = Color.white..confOpacity, pivot = Sprite.align.CENTER}

    local conLt = textplus.layout(confText, 560, {font = stats.font, color = conTextAlpha})
    textplus.render{x = 122, y = 240 + conOffset, layout = conLt, priority = priorities.options}
    textplus.print{text = lvlTitle, x = 400, y = 262, font = stats.font, color = conTextAlpha, priority = priorities.options, pivot = vector(0.5, 0)}

    for i = -1, 1, 2 do
        local opt = "Yes"
        if i == -1 then
            opt = "Yes"
        elseif i == 1 then
            opt = "No"
        end
        textplus.print{text = opt, x = 400+(i*96), y = 320, font = stats.font, color = conTextAlpha, priority = priorities.options, pivot = vector(0.5, 0)}
    end

    Graphics.drawImageWP(img.selector, 100 + xOffset + sine, 320, confOpacity, priorities.options)

    flashOpacity = math.max(flashOpacity - 0.05, 0)
    Graphics.drawScreen{color = stats.flashColor..flashOpacity, priority = priorities.flash}

    if waitOpacity > 0 then
        waitOpacity = math.min(waitOpacity+0.075,1)
    end

    if waitOpacity > 0 then
        waitTimer = math.max(waitTimer-1,0)
        Graphics.drawScreen{color = Color.black..waitOpacity, priority = stats.waitPriority}

        if waitTimer == 0 then
            waitFunc()
        end
    end
end

function pastPortal.onInputUpdate()
    if not isOpen then return end
    local totalStars = math.max(SaveData._basegame.starcoinCounter - SaveData.spentStars, 0)

    if canUpdateInput() and confActive == 0 then
        if currentTab ~= stats.LVL_MAP and SaveData.unlockedTabs[currentTab] and (not player.rawKeys.left) and (not player.rawKeys.right) then
            if player.rawKeys.up and selection > 1 then
                setTarget(selection - 1)
                SFXPlay("cursor")
            elseif player.rawKeys.down and selection < #levelList[currentTab] then
                setTarget(selection + 1)
                SFXPlay("cursor")
            end
        end

        if (not player.rawKeys.up) and (not player.rawKeys.down) and pressTimer == 0 then
            if player.rawKeys.left then
                selection = 1
                selTarget = 1
                isTargeting = false
                currentTab = currentTab - 1
                pressTimer = 16
                SFXPlay("switch")
            elseif player.rawKeys.right then
                selection = 1
                selTarget = 1
                isTargeting = false
                currentTab = currentTab + 1
                pressTimer = 16
                SFXPlay("switch")
            end
        end

        if (not player.rawKeys.up) and (not player.rawKeys.down) and (not player.rawKeys.left) and (not player.rawKeys.right) then
            if player.rawKeys.jump == KEYS_PRESSED then
                if SaveData.unlockedTabs[currentTab] then
                    if currentTab ~= stats.LVL_MAP then
                        confActive = stats.CON_START_LVL
                        conOffset = 46
                        lvlTitle  = levelList[currentTab][selection].name
                    else
                        confActive = stats.CON_START_MAP
                    end

                    confText = stats.confText[confActive]
                    SFXPlay("select")
                else
                    if stats.tabDetails[currentTab].starsNeeded <= totalStars then
                        confActive = stats.CON_UNLOCK
                        confText = stats.spendStars(stats.tabDetails[currentTab].starsNeeded)
                    else
                        SFXPlay("deny")
                    end
                end
            elseif player.rawKeys.run == KEYS_PRESSED then
                pastPortal.close()
                player:mem(0x172, FIELD_BOOL, false)
            end
        end
    end

    if canUpdateInput() and confActive > 0 and not executed then
        if player.rawKeys.left == KEYS_PRESSED and confirmSel == 2 then
            confirmSel = 1
            SFXPlay("cursor")
        elseif player.rawKeys.right == KEYS_PRESSED and confirmSel == 1 then
            confirmSel = 2
            SFXPlay("cursor")
        elseif player.rawKeys.jump == KEYS_PRESSED then
            if confirmSel == 0 then
                confirmSel = 1
            elseif confirmSel == 1 then
                if confActive == stats.CON_START_LVL then
                    waitOpacity = 0.075
                    SFXPlay("confirm")
                    waitFunc = function()
                        Misc.unpause()
                        Level.load(levelList[currentTab][selection].filename)
                    end
                    executed = true
                elseif confActive == stats.CON_START_MAP then
                    waitOpacity = 0.075
                    SFXPlay("confirm")
                    waitFunc = function()
                        Misc.unpause()
                        mem(0xB25728, FIELD_BOOL, false)
                        Level.exit()
                    end
                    executed = true
                elseif confActive == stats.CON_UNLOCK then
                    SaveData.spentStars = SaveData.spentStars + stats.tabDetails[currentTab].starsNeeded
                    SaveData.unlockedTabs[currentTab] = true
                    flashOpacity = 1.375
                    confActive = 0
                    SFXPlay("unlock")
                    executed = true
                end
            elseif confirmSel == 2 then
                confActive = 0
                SFXPlay("deny")
            end
        elseif player.rawKeys.run == KEYS_PRESSED then
            confActive = 0
            SFXPlay("deny")
        end
    end

    if currentTab == stats.LVL_MAP then
        selection = 1
    end

    if currentTab < 1 then
        currentTab = 4
    elseif currentTab > 4 then
        currentTab = 1
    end

    if confActive == 0 then
        executed = false
    end
end

return pastPortal