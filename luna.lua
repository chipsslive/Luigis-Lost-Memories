-- Written by Chipss

--[[ The Scripts of Old
local rooms = require("rooms")
]]

-- The Scripts of New
local respawnRooms = require("respawnRooms")
local nsmbwalls = require("nsmbwalls")
local warpTransition = require('warpTransition')
local anotherPowerDownLibrary = require("anotherPowerDownLibrary")
local hudoverride = require('hudoverride')
local helmets = require("helmets")
local antizip = require("antizip")
local customSwimming = require("customSwimming")
local littleDialogue = require("littleDialogue")
local pauseplus = require("pauseplus")
local textplus = require("textplus")
local extraNPCProperties = require("extraNPCProperties")
local pastPortal = require("pastPortal")
local stats = require("statsMisc")
local koopas = require("koopas")

for k, v in ipairs(stats.levelList) do
    pastPortal.registerLevel(v)
end

local starcoin = require("npcs/AI/starcoin")
SaveData.starcoins = 52--starcoin.getEpisodeCollected()

SaveData.coins = SaveData.coins or 0

-- New talk-to-NPC image

local myIMG = Graphics.loadImageResolved("talkImage.png")

-- Max coins

local coinlimit = 99999

-- Used to disable coin award on level exit

GameData.awardCoins = true

-- All this does is hide the coin count from the HUD

GameData.cutscene = false

local accessbilityWarning = "<align center><color red>WARNING</color><br>While any of these options<br>are enabled, challenge<br>and keyhole achievements<br>cannot be collected!<br></align>"

-- Achievements Stuff

GameData.ach_Audiblette = Achievements(1)
GameData.ach_Conceptuary = Achievements(2)
GameData.ach_AllMemories = Achievements(3)
GameData.ach_AllPurpleStars = Achievements(4)
GameData.ach_AllKeyholes = Achievements(5)
GameData.ach_Challenge1 = Achievements(6)
GameData.ach_Challenge2 = Achievements(7)
GameData.ach_Challenge3 = Achievements(8)
GameData.ach_Challenge4 = Achievements(9)
GameData.ach_Challenge5 = Achievements(10)
GameData.ach_HundredPercent = Achievements(11)
GameData.ach_Chuck = Achievements(12)

-- Question asked when at end of Fragmented Memory

littleDialogue.registerAnswer("exitFragmentedMemory",{text = "Yes",chosenFunction = function() showExit() end})
littleDialogue.registerAnswer("exitFragmentedMemory",{text = "No"})

function showExit()
	local exit = Layer.get("exit")
	if exit ~= nil then
		exit:show(true)
	end
end

-- Check if accessibility options are active

GameData.usedAccesibility = false
GameData.usedSetPowerup = false

function checkAccessibility()
	if (pauseplus.getSelectionValue("accessibility","Invincibility") or pauseplus.getSelectionValue("infiniteJumps","Infinite Jumps")) and GameData.usedAccesibility == false then
		GameData.usedAccesibility = true
	elseif GameData.usedSetPowerup and GameData.usedAccesibility == false then
		GameData.usedAccesibility = true
	end
end


-- Add and subtract coins global functions

function addCoins(n)
	SaveData.coins = math.clamp(SaveData.coins + n, 0, coinlimit)
	SFX.play("bigcoin-50.ogg")
end

function subtractCoins(n)
    SaveData.coins = math.max(SaveData.coins - n, 0)
    SFX.play("loseCoins.wav")
end

-- Used for coin effect replacing score effect
local coinEffects

-- The coin image used for the HUD element
local coin = Graphics.loadImage(Misc.resolveFile("coin1.png"))

-- Used for headers in pause menu
local MKDS = textplus.loadFont("MKDS.ini")

-- littleDialogue Styles
littleDialogue.registerStyle("madelyn",{
    borderSize = 30,
    typewriterEnabled = true,
    typewriterDelayNormal = 2,
    typewriterDelayLong = 16,
	textColor = Color.green,
})

littleDialogue.registerStyle("conceptuary",{
    borderSize = 16,
    typewriterEnabled = false,
	textColor = Color(80/255,80/255,112/255),
})

littleDialogue.registerStyle("fragmentedSign",{
    borderSize = 16,
    typewriterEnabled = false,
	textColor = Color(1,0,128/255),
})

-- World map doesn't work correctly without this idek
function exitLevel()
	Level.exit()
end

-- Checks if 'a' is null, if it is return the alternative, 'b'

function nil_or(a,b)
	if a == nil then
		return b
	end
	return b
end

function onStart()
	-- Progression flags

	SaveData.introFinished = SaveData.introFinished or nil_or(SaveData.introFinished, false)
	SaveData.conceptuaryUnlocked = SaveData.conceptuaryUnlocked or nil_or(SaveData.conceptuaryUnlocked, false)
	SaveData.audibletteUnlocked = SaveData.audibletteUnlocked or nil_or(SaveData.audibletteUnlocked, false)
	SaveData.creditsSeen = SaveData.creditsSeen or nil_or(SaveData.creditsSeen, false)

	-- Achievement flags

	SaveData.keyhole1Found = SaveData.keyhole1Found or nil_or(SaveData.keyhole1Found, false)
	SaveData.keyhole2Found = SaveData.keyhole2Found or nil_or(SaveData.keyhole2Found, false)
	SaveData.keyhole3Found = SaveData.keyhole3Found or nil_or(SaveData.keyhole3Found, false)
	SaveData.keyhole4Found = SaveData.keyhole4Found or nil_or(SaveData.keyhole4Found, false)
	SaveData.keyhole5Found = SaveData.keyhole5Found or nil_or(SaveData.keyhole5Found, false)
	
	-- Check if player has seen the title screen yet
	if not GameData.seenTitle and Level.filename() ~= "!Title Screen.lvlx" then
		Level.load("!Title Screen.lvlx")
	end

	-- Check for current Purple Star count for achievements
	GameData.ach_AllPurpleStars:setCondition(1,SaveData.starcoins)
    GameData.ach_HundredPercent:setCondition(2,SaveData.starcoins)

	-- Reset accessbility checks
	GameData.usedAccesibility = false
	GameData.usedSetPowerup = false

	-- Checks how many memories are completed for the achievement

    local function getRecoveredCount()
        local list = {}
		for k,v in ipairs(stats.levelList) do
			if SaveData.levelStats[stats.levelList[k].filename] and SaveData.levelStats[stats.levelList[k].filename].beaten then
				table.insert(list, v)
			end
		end
        return list
    end

	-- Other achievement stuff

	GameData.ach_AllMemories:setCondition(1,#getRecoveredCount())
	GameData.ach_HundredPercent:setCondition(1,#getRecoveredCount())

	-- This is needed to allow the world map to be accessed from the hub
    mem(0xB25728, FIELD_BOOL, true)

	--SaveData.coins = 3000
    player.character = CHARACTER_LUIGI

	-- Disable unwanted HUD elements
    hudoverride.visible.lives = false
    hudoverride.visible.score = false
	hudoverride.visible.coins = false
	hudoverride.visible.itembox = false
	hudoverride.visible.starcoins = true

	-- Pause Menu Stuff (A lot of the design taken from ATWE. Credit to MrDoubleA)

	-- Main Pause Menu
	pauseplus.createSubmenu("main",{headerText = "PAUSED",headerTextFont = MKDS})
	pauseplus.createOption("main",{text = "Continue",closeMenu = true})
	
	-- Can't exit or restart a memory when you're not in a memory!
	if Level.filename() ~= "!Memory Center.lvlx" and Level.filename() ~= "!The Realm of Recollection.lvlx" then
		pauseplus.createOption("main",{text = "Restart Memory",goToSubmenu = "restartConfirmation"}, 2)
        pauseplus.createOption("main",{text = "Exit Memory",goToSubmenu = "exitConfirmation"}, 3)

		-- Set Powerup Menu
		pauseplus.createSubmenu("setPowerup",{headerText = "SET POWERUP",headerTextFont = MKDS})
		pauseplus.createOption("setPowerup",{text = "<image pause_mushroom.png> Mushroom",closeMenu = true,sfx = 35,action = function() setPowerup(2) end})
		pauseplus.createOption("setPowerup",{text = "<image pause_fireFlower.png> Fire Flower",closeMenu = true,sfx = 35,action = function() setPowerup(3) end})
		pauseplus.createOption("setPowerup",{text = "<image pause_iceFlower.png> Ice Flower",closeMenu = true,sfx = 35,action = function() setPowerup(7) end})
		pauseplus.createOption("setPowerup",{text = "<image pause_reset.png> None",closeMenu = true,sfx = 35,action = function() setPowerup(1) end})
    else
		pauseplus.createSubmenu("setPowerup",{headerText = "<align center>Not available<br>outside of memories.</align>"})
	end
	
	-- Can only save within The Realm of Recollection
	if Level.filename() == "!The Realm of Recollection.lvlx" then
		pauseplus.createOption("main",{text = "Save Game",action = pauseplus.save,sfx = 58,closeMenu = true})
	end

	pauseplus.createOption("main",{text = "Settings",goToSubmenu = "settings"})
	pauseplus.createOption("main",{text = "Quit Game",goToSubmenu = "quitConfirmation"})

	-- Settings Menu
	pauseplus.createSubmenu("settings",{headerText = "SETTINGS",headerTextFont = MKDS})
	pauseplus.createOption("settings",{text = "Mute Music",selectionType = pauseplus.SELECTION_CHECKBOX})
	pauseplus.createOption("settings",{text = "Show Speedrun Timer",selectionType = pauseplus.SELECTION_CHECKBOX})
	pauseplus.createOption("settings",{text = "<color green>Accessibility</color>",goToSubmenu = "accessibility"})

	-- Exit Confirmation Menu
	pauseplus.createSubmenu("exitConfirmation",{headerText = "<align center>Exit the memory?<br>All progress up until<br>this point will be lost.</align>"})
	pauseplus.createOption("exitConfirmation",{text = "Yes",closeMenu = true,action = function() mem(0xB25728, FIELD_BOOL, true) exitLevel() end})
	pauseplus.createOption("exitConfirmation",{text = "No",goToSubmenu = "main"})

	-- Restart Confirmation Menu
	pauseplus.createSubmenu("restartConfirmation",{headerText = "<align center>Restart the memory?<br>All progress up until<br>this point will be lost.</align>"})
	pauseplus.createOption("restartConfirmation",{text = "Yes",closeMenu = true,action = function() Level.load(Level.filename()) Checkpoint.reset() end})
	pauseplus.createOption("restartConfirmation",{text = "No",goToSubmenu = "main"})

	-- Quit Confirmation Menu
	pauseplus.createSubmenu("quitConfirmation",{headerText = "<align center>Quit the game?<br>All unsaved progress<br>will be lost.</align>"})
	pauseplus.createOption("quitConfirmation",{text = "Yes",action = pauseplus.quit})
	pauseplus.createOption("quitConfirmation",{text = "No",goToSubmenu = "main"})

	-- Accessbility Menu
	pauseplus.createSubmenu("accessibility",{headerText = "ACCESSIBILITY",headerTextFont = MKDS})
	pauseplus.createOption("accessibility",{text = "Invincibility",selectionType = pauseplus.SELECTION_CHECKBOX,description = accessbilityWarning})
	pauseplus.createOption("accessibility",{text = "Infinite Jumps",selectionType = pauseplus.SELECTION_CHECKBOX,description = accessbilityWarning})
	if Level.filename() == "!The Realm of Recollection.lvlx" or Level.filename() == "!Memory Center.lvlx" then
		pauseplus.createOption("accessibility",{text = "Set Powerup",goToSubmenu = "setPowerup",sfx="error.mp3",description = accessbilityWarning})
	else
		pauseplus.createOption("accessibility",{text = "Set Powerup",goToSubmenu = "setPowerup",description = accessbilityWarning})
	end
end

-- Setting powerup from pause menu
function setPowerup(m)
    player.powerup = m
    setHeight()
	GameData.usedSetPowerup = true
end 

-- Prevent janky teleports when changing powerups via the pause menu
function setHeight()
	local settings = PlayerSettings.get(player.character,player.powerup)
	local newHeight = settings.hitboxHeight

	player.y = player.y + player.height - newHeight
	player.height = newHeight

	if player:mem(0x12E,FIELD_BOOL) then -- ducking
		player:mem(0x12E,FIELD_BOOL,false)
		player.frame = 1
	end
end

function onDraw()
	if pauseplus.getSelectionValue("settings","Mute Music") then
        if not musicSeized then
            Audio.SeizeStream(-1)
            musicSeized = true
        end
        
        Audio.MusicStop()
    elseif musicSeized then
        Audio.ReleaseStream(-1)
        musicSeized = false
    end

	stats.displayTimer = pauseplus.getSelectionValue("settings","Show Speedrun Timer")

	-- Replaces standard talk-to-NPC graphic

	for k,v in NPC.iterateIntersecting(player.x, player.y, player.x + player.width, player.y + player.height) do
        local gfxHeight = NPC.config[v.id].gfxheight - v.height
        if gfxHeight < 0 then gfxHeight = 0 end
            
        local trueX = (v.x + 0.5 * v.width) - (0.5 * myIMG.width)
        local trueY = (v.y - 8 - gfxHeight) - myIMG.height

		if v.msg and v.msg ~= "" and not v.isHidden then
        	Graphics.drawImageToSceneWP(myIMG, trueX, trueY, -40)
		end
    end
end

function onTickEnd()
	local hijackedValue = mem(0x00B2C5A8, FIELD_WORD)
	if hijackedValue > 0 then
		mem(0x00B2C5A8, FIELD_WORD, 0)
		SaveData.coins = math.clamp(SaveData.coins + hijackedValue, 0, coinlimit)
	end
end

function onTick()
	checkAccessibility()

	-- Disable reserve powerup
	player.reservePowerup = 0

	-- Update coin counter
    SaveData.coins = SaveData.coins + mem(0x00B2C5A8,FIELD_WORD)
	mem(0x00B2C5A8,FIELD_WORD,0)
	
	-- Keep coins from exceeding max limit
	SaveData.coins = math.min(SaveData.coins, coinlimit)

	-- Instead of awarding score, this code adds to the coin count
	coinEffects = Effect.get(79)

	for _,v in pairs(coinEffects) do
        if v.timer == 60 then
            if (v.animationFrame > 1) and (v.animationFrame < 6) then
                SaveData.coins = SaveData.coins + (v.animationFrame-1)
            elseif (v.animationFrame >= 6) and (v.animationFrame <= 8) then
                SaveData.coins = SaveData.coins + 5
            elseif (v.animationFrame > 8) then
                SaveData.coins = SaveData.coins + 10
            end
        end
    end

	-- Invincibility Accessibility Option (Taken from ATWE Code)
	local donthurtmeActive = Cheats.get("donthurtme").active
    local invincibility = pauseplus.getSelectionValue("accessibility","Invincibility")

    Defines.cheat_donthurtme = donthurtmeActive or invincibility

	-- Infinite Jumps Accessibility Option
	local ahippinandahoppinActive = Cheats.get("ahippinandahoppin").active
    local infiniteJumps = pauseplus.getSelectionValue("accessibility","Infinite Jumps")

    Defines.cheat_ahippinandahoppin = ahippinandahoppinActive or infiniteJumps
end

function respawnRooms.onPostReset(fromRespawn)
	if fromRespawn then
        respawnRooms.deathCoins = {}
    end
end

-- Custom Coin Counter HUD Element

local portalFont = textplus.loadFont("portalFont.ini")

local function customCounter()
	if not GameData.cutscene then
		textplus.print{
			text = string.format("%.4d", SaveData.coins),
			priority = 5,
			x = 700,
			y = 30,
			font = portalFont
		}
		Graphics.drawImageWP(coin, 660, 30, 5)
	end
end

Graphics.addHUDElement(customCounter)

--Leftovers from the demo release

--[[local isPauseActive = false
local pauseSelection = 0
local saveImg = Graphics.loadImageResolved("gameSavedImg.png")

local saveTimer = 0

local hub_filename = "!Demo Hub.lvlx" --edit this to fit the hub level

function onPause(eventObj)
	eventObj.cancelled = true
	
	if not isPauseActive then
		isPauseActive = true
		Misc.pause()
		SFX.play(30)
	end
end

function onDraw()
	if isPauseActive then
		--box
		Graphics.drawBox{x = 210, y = 200, width = 380, height = 200, color = Color.black}
		--texts (placeholder positions)
		Text.printWP("continue", 324, 276, 5)
		
		if Level.filename() ~= hub_filename then
			Text.printWP("exit level", 324, 310, 5)
		else
			Text.printWP("save and", 324, 310, 5)
			Text.printWP("quit", 324, 326, 5)
			--Text.printWP("main menu", 324, 342, 5) -- coming soon
		end
		
		--move cursor
		if player.rawKeys.up == KEYS_PRESSED then
			pauseSelection = pauseSelection - 1
			SFX.play(71)
		elseif player.rawKeys.down == KEYS_PRESSED then
			pauseSelection = pauseSelection + 1
			SFX.play(71)
		end
		
		--overflow alert
		if pauseSelection > 1 then
			pauseSelection = 0
		elseif pauseSelection < 0 then
			pauseSelection = 1
		end
		
		--draw cursor
		Graphics.draw{
			x = 292,
			y = 276 + pauseSelection * 32,
			type = RTYPE_IMAGE,
			priority = 5,
			image = Graphics.loadImageResolved("hardcoded-34-0.png"),
		}
		
		--select
		if player.rawKeys.jump == KEYS_PRESSED then
			if pauseSelection == 0 then
				Misc.unpause()
				SFX.play(30)
				isPauseActive = false
				player:mem(0x11E, FIELD_WORD, 0)
				if player2 ~= nil and player2.isValid then
					player2:mem(0x11E, FIELD_WORD, 0)
				end
			elseif pauseSelection == 1 then
				Misc.unpause()
				isPauseActive = false
				player:mem(0x11E, FIELD_WORD, 0)
				if player2 ~= nil and player2.isValid then
					player2:mem(0x11E, FIELD_WORD, 0)
				end
				
				if Level.filename() ~= hub_filename then
					Level.exit()
				else
					Misc.saveGame()
					Misc.exitGame()
					SFX.play(30)
					isPauseActive = false
					saveTimer = 128
					player:mem(0x11E, FIELD_WORD, 0)
					if player2 ~= nil and player2.isValid then
						player2:mem(0x11E, FIELD_WORD, 0)
					end
				end
			end
		end
	end
	
	for k,_ in pairs(player.keys) do
		player.keys[k] = false
	end
	
	if saveTimer > 0 then
		saveTimer = saveTimer - 1
	
		Graphics.draw{
			x = 0,
			y = 584,
			image = saveImg,
			type = RTYPE_IMAGE,
			priority = 5,
			opacity = (saveTimer / 128)
		}
	end
end]]