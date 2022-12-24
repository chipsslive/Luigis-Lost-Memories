-- Library Loading and Initializing--
local smoothWorld = API.load("smoothWorld")
local wandr = require("wandr")
local travl = require("travl")
local worldmapluigi = require("worldmapluigi")
local mapdraw = require("mapdraw")
local pauseplus = require("pauseplus")

local holdJump = false

travl.showArrows = false

wandr.speed = 3

local hudoverride = require("hudoverride")

function onStart()
    mem(0xB25728, FIELD_BOOL, false)
    player.character = CHARACTER_LUIGI
    player.powerup = 2
    world.playerX = -1600
    world.playerY = 1216
    hudoverride.visible.lives = false
    hudoverride.visible.coins = false
    Cheats.trigger("imtiredofallthiswalking")

    pauseplus.createSubmenu("main",{headerText = "PAUSED",headerTextFont = bigFont})
    pauseplus.createOption("main",{text = "Continue",closeMenu = true})
    pauseplus.createOption("main",{text = "Exit Map",closeMenu = true,action = 
    function() 
        mem(0xB25728, FIELD_BOOL, true)
        player.character = CHARACTER_MARIO
        world.playerX = -3520
        world.playerY = -448
        holdJump = true
    end})
end

-- Coin Counter HUD Element --
local coin = Graphics.loadImage(Misc.resolveFile("coin1.png"))

local function customCounter()
    Graphics.draw{
        type = RTYPE_TEXT,
        text = "x".. tostring(SaveData.coins),
        priority = 0,
        x= 300,
        y= 650,
    }
    Graphics.draw{
        type = RTYPE_IMAGE,
        image = coin,
        x = 320,
        y = 650,
        priority = 0,
    }
end

Graphics.addHUDElement(customCounter)

--Animated Asset Drawing--
local none = Graphics.loadImage("none.png")

--How to use mapdraw: in the assets table add a line which contains: 
    --Asset type (Level, Scenery, Tile) - case sensitive, keep that in mind
    --Asset id
    --Image name (type without .png and inside "")
    --Image width
    --Image Height (not the whole picture tho, only height of 1 frame)
    --Image priority
    --Number of frames
    --Framespeed
    --OffsetX
    --OffsetY (offsets can be ignored if not needed)

--Example:
	--local assets = {
	--	{Scenery,23,"something",42,34,-35,2,8,-8,-12},
	--}
    --I drew an image named something.png which is 42x34 with the priority of -35 on 
    -- top of a scenery with the id of 23. It has 2 frames with the framespeed of 8 and -8 horizontal and -12 vertical offsets 

local assets = {
    {Level, 46, "level46", 32, 44, -30, 4, 8, 0, -16},
    {Level, 47, "level47", 32, 64, -30, 1, 8, 0, -32},
    {Scenery, 9, "scene9", 32, 32, -100, 4, 8, 0, 0},
}

function onDraw()
    for i=1, #assets do
    	mapdraw.Draw(assets[i][1], assets[i][2], assets[i][3], assets[i][4], assets[i][5], assets[i][6], assets[i][7], assets[i][8], i, assets[i][9], assets[i][10])
		if assets[i][1] == Level then
			Graphics.sprites.level[assets[i][2]].img = none
		end
    end
end

-- Checks that modify wandr speed based on world map location --
function onTick()
    if world.playerX > 0 and world.playerY > 1280 then
        travl.showArrows = true
        wandr.speed = 5
    else
        travl.showArrows = false
        wandr.speed = 3
    end

    if holdJump then
        player.keys.jump = KEYS_PRESSED
    end
end
