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

local starcoin = require("npcs/AI/starcoin")
SaveData.starcoins = starcoin.getEpisodeCollected()

SaveData.coins = SaveData.coins or 0
SaveData.introFinished = true
SaveData.conceptuaryUnlocked = false
SaveData.audibletteUnlocked = false
local myIMG = Graphics.loadImageResolved("talkImage.png")

-- All this does is hide the coin count from the HUD

GameData.cutscene = false

-- Achievements Stuff

GameData.ach_Audiblette = Achievements(1)
GameData.ach_Conceptuary = Achievements(2)

-- Question asked when at end of Fragmented Memory

littleDialogue.registerAnswer("exitFragmentedMemory",{text = "Yes",chosenFunction = function() Level.exit(1) end})
littleDialogue.registerAnswer("exitFragmentedMemory",{text = "No"})

-- Add and subtract coins global functions

function addCoins(n)
	SaveData.coins = SaveData.coins + n
	SFX.play("bigcoin-50.ogg")
end

function subtractCoins(n)
    if n <= SaveData.coins then
        SaveData.coins = SaveData.coins - n
	else 
		SaveData.coins = 0
	end
	SFX.play("loseCoins.wav")
end

-- Used for coin effect replacing score effect
local coinEffects

-- The coin image used for the HUD element
local coin = Graphics.loadImage(Misc.resolveFile("coin1.png"))

-- Used for headers in pause menu
local bigFont = textplus.loadFont("bigFont.ini")

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

function onStart()
	SaveData.coins = 3000
    player.character = CHARACTER_LUIGI

	-- Disable unwanted HUD elements
    hudoverride.visible.lives = false
    hudoverride.visible.score = false
	hudoverride.visible.coins = false
	hudoverride.visible.itembox = false
	hudoverride.visible.starcoins = true

	-- Pause Menu Stuff (A lot of the design taken from ATWE. Credit to MrDoubleA)

	-- Main Pause Menu
	pauseplus.createSubmenu("main",{headerText = "PAUSED",headerTextFont = bigFont})
	pauseplus.createOption("main",{text = "Continue",closeMenu = true})

	

	-- Can't exit a memory when you're not in a memory!
	if Level.filename() ~= "!Memory Center.lvlx" and Level.filename() ~= "!The Realm of Recollection.lvlx" then
        pauseplus.createOption("main",{text = "Exit Memory",goToSubmenu = "exitConfirmation"}, 2)

		-- Set Powerup Menu
		pauseplus.createSubmenu("setPowerup",{headerText = "SET POWERUP",headerTextFont = bigFont})
		pauseplus.createOption("setPowerup",{text = "<image pause_mushroom.png> Mushroom",closeMenu = true,sfx = 35,action = function() setPowerup(2) end})
		pauseplus.createOption("setPowerup",{text = "<image pause_fireFlower.png> Fire Flower",closeMenu = true,sfx = 35,action = function() setPowerup(3) end})
		pauseplus.createOption("setPowerup",{text = "<image pause_iceFlower.png> Ice Flower",closeMenu = true,sfx = 35,action = function() setPowerup(7) end})
		pauseplus.createOption("setPowerup",{text = "<image pause_reset.png> None",closeMenu = true,sfx = 35,action = function() setPowerup(1) end})
    else
		pauseplus.createSubmenu("setPowerup",{headerText = "<align center>Not available outside<br>of memories.</align>"})
	end
	
	-- Can only save within The Realm of Recollection
	if Level.filename() == "!The Realm of Recollection.lvlx" then
		pauseplus.createOption("main",{text = "Save Game",action = pauseplus.save,sfx = 58,closeMenu = true})
	end

	pauseplus.createOption("main",{text = "Settings",goToSubmenu = "settings"})
	pauseplus.createOption("main",{text = "Quit Game",goToSubmenu = "quitConfirmation"})

	-- Settings Menu
	pauseplus.createSubmenu("settings",{headerText = "SETTINGS",headerTextFont = bigFont})
	pauseplus.createOption("settings",{text = "Mute Music",selectionType = pauseplus.SELECTION_CHECKBOX})
	pauseplus.createOption("settings",{text = "<color green>Accessibility</color>",goToSubmenu = "accessibility"})

	-- Exit Confirmation Menu
	pauseplus.createSubmenu("exitConfirmation",{headerText = "<align center>Exit the memory?<br>All progress up until<br>this point will be lost.</align>"})
	pauseplus.createOption("exitConfirmation",{text = "Yes",action = pauseplus.exitLevel})
	pauseplus.createOption("exitConfirmation",{text = "No",goToSubmenu = "main"})

	-- Quit Confirmation Menu
	pauseplus.createSubmenu("quitConfirmation",{headerText = "<align center>Quit the game?<br>All unsaved progress<br>will be lost.</align>"})
	pauseplus.createOption("quitConfirmation",{text = "Yes",action = pauseplus.quit})
	pauseplus.createOption("quitConfirmation",{text = "No",goToSubmenu = "main"})

	-- Accessbility Menu
	pauseplus.createSubmenu("accessibility",{headerText = "ACCESSIBILITY",headerTextFont = bigFont})
	pauseplus.createOption("accessibility",{text = "Invincibility",selectionType = pauseplus.SELECTION_CHECKBOX})
	pauseplus.createOption("accessibility",{text = "Infinite Jumps",selectionType = pauseplus.SELECTION_CHECKBOX})
	if Level.filename() == "!The Realm of Recollection.lvlx" or Level.filename() == "!Memory Center.lvlx" then
		pauseplus.createOption("accessibility",{text = "Set Powerup",goToSubmenu = "setPowerup",sfx="error.mp3"})
	else
		pauseplus.createOption("accessibility",{text = "Set Powerup",goToSubmenu = "setPowerup"})
	end
end

-- Setting powerup from pause menu
function setPowerup(m)
	if m == 1 then
		player.powerup = 1
		setHeight()
	end
	if m == 2 or m == 3 or m == 7 then
		if m == 2 then
			player.powerup = 2
		elseif m == 3 then
			player.powerup = 3
		elseif m == 7 then
			player.powerup = 7
		end
		setHeight()
	end
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

function onTick()
	-- Disable reserve powerup
	player.reservePowerup = 0

	-- Update coin counter
    SaveData.coins = SaveData.coins + mem(0x00B2C5A8,FIELD_WORD)
	mem(0x00B2C5A8,FIELD_WORD,0)
	
	-- Keep coins from exceeding max limit
	if SaveData.coins > 99999 then
		SaveData.coins = 99999
	end

	-- Instead of awarding score, this code adds to the coin count
	coinEffects = Effect.get(79)

	for _,v in pairs(coinEffects) do
        if v.timer == 60 then
            if (v.animationFrame == 2) then
                SaveData.coins = SaveData.coins + 1
			elseif (v.animationFrame == 3) then
				SaveData.coins = SaveData.coins + 2
			elseif (v.animationFrame == 4) then
				SaveData.coins = SaveData.coins + 3
			elseif (v.animationFrame == 5) then
				SaveData.coins = SaveData.coins + 4
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
local function customCounter()
	if not GameData.cutscene then
		Graphics.draw{
			type = RTYPE_TEXT,
			text = "x".. tostring(SaveData.coins),
			priority = 5,
			x= 680,
			y= 30,
		}
		Graphics.draw{
			type = RTYPE_IMAGE,
			image = coin,
			x = 660,
			y = 30,
			priority = 5,
		}
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