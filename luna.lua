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
local pastPortal2 = require("pastPortal2")
local stats = require("statsMisc")
local koopas = require("koopas")
local newcheats = require("base/game/newcheats")

for k, v in ipairs(stats.levelList) do
    pastPortal.registerLevel(v)
end
for k, v in ipairs(stats.repressedLevelList) do
	pastPortal2.registerLevel(v)
end

local windowIcon = Graphics.loadImageResolved("windowIcon.png")

Misc.setWindowTitle("Luigi's Lost Memories")
Misc.setWindowIcon(windowIcon)

-- Keeps held items from getting stuck inside walls

local function getDesiredBlocks(list)
    local blockList = {}
    for k, v in ipairs(list) do
        if v.isValid and (not Block.config[v.id].passthrough)
        and (not v.isHidden) and (not v.invisible)
        and (not Block.NONSOLID_MAP[v.id]) and (not Block.SEMISOLID_MAP[v.id]) and (not Block.SLOPE_MAP[v.id])
        and (not Block.SIZEABLE_MAP[v.id]) and (not Block.PLAYERSOLID_MAP[v.id]) and (not Block.PLAYER_MAP[v.id]) then
            table.insert(blockList, v)
        end
    end
    return blockList
end

local function isCol(v)
    local b = getDesiredBlocks(Block.getIntersecting(v.x+2,v.y+2,v.x+v.width-2,v.y+v.height-2))
    return #b > 0
end

-- Starcoin/coins stuff

local starcoin = require("npcs/AI/starcoin")
SaveData.starcoins = starcoin.getEpisodeCollected()

SaveData.coins = SaveData.coins or 0

-- New talk-to-NPC image

local myIMG = Graphics.loadImageResolved("talkImage.png")

-- Max coins

local coinlimit = 99999

-- Used to disable coin award on level exit

GameData.awardCoins = true

-- All this does is hide the coin count from the HUD

GameData.cutscene = false

-- If the player has just completed a challenge and is return to hub, this will be the # of the challenge, otherwise 0

GameData.justCompletedChallenge = GameData.justCompletedChallenge or 0

local accessbilityWarning = "<align center><color red>WARNING</color><br>While any of these options<br>are enabled, challenge<br>and keyhole achievements<br>cannot be collected!<br>Restart the memory for<br>changes to take effect.<br></align>"

-- Achievements Stuff

GameData.ach_Audiblette  	= Achievements(1)
GameData.ach_Conceptuary 	= Achievements(2)
GameData.ach_AllMemories 	= Achievements(3)
GameData.ach_AllPurpleStars = Achievements(4)
GameData.ach_AllKeyholes 	= Achievements(5)
GameData.ach_Challenge1 	= Achievements(6)
GameData.ach_Challenge2 	= Achievements(7)
GameData.ach_Challenge3 	= Achievements(8)
GameData.ach_Challenge4 	= Achievements(9)
GameData.ach_Challenge5 	= Achievements(10)
GameData.ach_HundredPercent = Achievements(11)
GameData.ach_Chuck 			= Achievements(12)
GameData.ach_MapOfMemories  = Achievements(13)
GameData.ach_Exiled         = Achievements(14)
GameData.ach_Credits		= Achievements(15)

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

function checkAccessibility()
	if (pauseplus.getSelectionValue("accessibility","Invincibility") or pauseplus.getSelectionValue("accessibility","Infinite Jumps")) then
		GameData.usedAccessibility = true
	elseif GameData.usedSetPowerup then
		GameData.usedAccessibility = true
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
	textMaxWidth = 395,
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

local MAX_VALUE = 100

function onStart()
	-- failsafe for really weird glitch
	if SaveData.fullyComplete then
		SaveData.starcoins = 43
	end

	-- Used to save Purple Stars when restarting memory from summary screen
	if GameData.lastLevelFile ~= nil then
		Level.load(GameData.lastLevelFile)
		GameData.lastLevelFile = nil
	end
	
	Misc.saveGame()

	-- Checks how many memories are completed for the achievement

    function getRecoveredCount()
        local list = {}
		for k,v in ipairs(stats.levelList) do
			if SaveData.levelStats[stats.levelList[k].filename] and SaveData.levelStats[stats.levelList[k].filename].beaten then
				table.insert(list, v)
			end
		end
        return list
    end

	GameData.usedAccessibility = false
	GameData.usedSetPowerup = false

	newcheats.enabled = false
	player.powerup = 2

	-- Progression flags

	SaveData.introFinished 			       = SaveData.introFinished 		   		or nil_or(SaveData.introFinished, false)
	SaveData.conceptuaryUnlocked		   = SaveData.conceptuaryUnlocked   		or nil_or(SaveData.conceptuaryUnlocked, false)
	SaveData.audibletteUnlocked			   = SaveData.audibletteUnlocked    		or nil_or(SaveData.audibletteUnlocked, false)
	SaveData.allMemoriesRecovered		   = SaveData.allMemoriesRecovered  		or nil_or(SaveData.allMemoriesRecovered, false)
	SaveData.allPurpleStarsFound  		   = SaveData.allPurpleStarsFound  		 	or nil_or(SaveData.allPurpleStarsFound, false)
	SaveData.creditsSeen 			       = SaveData.creditsSeen 		   			or nil_or(SaveData.creditsSeen, false)
	SaveData.fullyComplete 			       = SaveData.fullyComplete         		or nil_or(SaveData.fullyComplete, false)
	SaveData.basementFound        		   = SaveData.basementFound         		or nil_or(SaveData.basementFound, false)
	SaveData.allRepressedMemoriesRecovered = SaveData.allRepressedMemoriesRecovered or nil_or(SaveData.allRepressedMemoriesRecovered, false)
	SaveData.seenPurpleStarReward		   = SaveData.seenPurpleStarReward          or nil_or(SaveData.seenPurpleStarReward, false)
	SaveData.talkedToMaroonbaAfterCredits  = SaveData.talkedToMaroonbaAfterCredits  or nil_or(SaveData.talkedToMaroonbaAfterCredits, false)

	SaveData.totalMemoriesRecovered = #getRecoveredCount()

	-- Achievement flags

	SaveData.keyhole1Found = SaveData.keyhole1Found or nil_or(SaveData.keyhole1Found, false)
	SaveData.keyhole2Found = SaveData.keyhole2Found or nil_or(SaveData.keyhole2Found, false)
	SaveData.keyhole3Found = SaveData.keyhole3Found or nil_or(SaveData.keyhole3Found, false)
	SaveData.keyhole4Found = SaveData.keyhole4Found or nil_or(SaveData.keyhole4Found, false)
	SaveData.keyhole5Found = SaveData.keyhole5Found or nil_or(SaveData.keyhole5Found, false)
	
	SaveData.totalKeyholesFound  = SaveData.totalKeyholesFound or nil_or(SaveData.totalKeyholesFound, 0)

	SaveData.challenge1Completed = SaveData.challenge1Completed or nil_or(SaveData.challenge1Completed, false)
	SaveData.challenge2Completed = SaveData.challenge2Completed or nil_or(SaveData.challenge2Completed, false)
	SaveData.challenge3Completed = SaveData.challenge3Completed or nil_or(SaveData.challenge3Completed, false)
	SaveData.challenge4Completed = SaveData.challenge4Completed or nil_or(SaveData.challenge4Completed, false)
	SaveData.challenge5Completed = SaveData.challenge5Completed or nil_or(SaveData.challenge5Completed, false)

	SaveData.totalChallengesCompleted = SaveData.totalChallengesCompleted or nil_or(SaveData.totalChallengesCompleted, 0)

	-- Progress variables (percentage in launcher)

	creditsSeenVar = (SaveData.creditsSeen and 6) or 0
	audibletteUnlockedVar = (SaveData.audibletteUnlocked and 3) or 0
	conceptuaryUnlockedVar = (SaveData.conceptuaryUnlocked and 3) or 0
	foundMossVar = (SaveData.basementFound and 1) or 0

	--[[
	Memories = 34%
	Purple Stars = 43%
	Keyholes = 5%
	Challenges = 5%
	Audiblette = 3%
	Conceptuary = 3%
	Credits = 6%
	Basement Found = 1%
	]]

	local totalProg = SaveData.totalMemoriesRecovered*2 + SaveData.starcoins + SaveData.totalKeyholesFound + SaveData.totalChallengesCompleted + audibletteUnlockedVar + conceptuaryUnlockedVar + creditsSeenVar + foundMossVar
    Progress.value = (totalProg/MAX_VALUE)*100
	
	-- Check if player has seen the title screen yet
	if not GameData.seenTitle and Level.filename() ~= "!Title Screen.lvlx" and not Misc.inEditor() then
		Level.load("!Title Screen.lvlx")
	end

	-- Reset accessbility checks
	GameData.usedAccessibility = false
	GameData.usedSetPowerup = false

	-- Other achievement stuff
	GameData.ach_AllMemories:setCondition(1,math.max(#getRecoveredCount(), GameData.ach_AllMemories:getCondition(1).value))

	GameData.ach_AllPurpleStars:setCondition(1,math.max(SaveData.starcoins, GameData.ach_AllPurpleStars:getCondition(1).value))

	GameData.ach_HundredPercent:setCondition(1,math.max(#getRecoveredCount(), GameData.ach_HundredPercent:getCondition(1).value))
    GameData.ach_HundredPercent:setCondition(2,math.max(SaveData.starcoins, GameData.ach_HundredPercent:getCondition(2).value))
    GameData.ach_HundredPercent:setCondition(3,math.max(SaveData.totalChallengesCompleted, GameData.ach_HundredPercent:getCondition(3).value))
    GameData.ach_HundredPercent:setCondition(4,math.max(SaveData.totalKeyholesFound, GameData.ach_HundredPercent:getCondition(4).value))

	if #getRecoveredCount() >= 17 and not SaveData.allMemoriesRecovered then
		SaveData.allMemoriesRecovered = true
	end

	if SaveData.starcoins >= 43 and not SaveData.allPurpleStarsFound then
		SaveData.allPurpleStarsFound = true
	end

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
	pauseplus.createOption("settings",{text = "Show Challenge Status",selectionType = pauseplus.SELECTION_CHECKBOX})
	pauseplus.createOption("settings",{text = "<color green>Accessibility</color>",goToSubmenu = "accessibility"})

	-- Exit Confirmation Menu
	pauseplus.createSubmenu("exitConfirmation",{headerText = "<align center>Exit the memory?<br>All progress up until<br>this point will be lost.</align>"})
	pauseplus.createOption("exitConfirmation",{text = "Yes",closeMenu = true,action = function() mem(0xB25728, FIELD_BOOL, true) exitLevel() end})
	pauseplus.createOption("exitConfirmation",{text = "No",goToSubmenu = "main"})

	-- Restart Confirmation Menu (located in onTick)

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

		if v.msg and v.msg ~= "" and not v.isHidden and player:isGroundTouching() then
        	Graphics.drawImageToSceneWP(myIMG, trueX, trueY, -27)
		end
    end

	if SaveData.allMemoriesRecovered 
	and SaveData.creditsSeen
	and SaveData.allPurpleStarsFound 
	and SaveData.totalKeyholesFound == 5
	and SaveData.totalChallengesCompleted == 5
	and SaveData.conceptuaryUnlocked
	and SaveData.audibletteUnlocked then
		SaveData.fullyComplete = true
	end

	if pauseplus.getSelectionValue("settings","Show Challenge Status") and not GameData.cutscene then
		if Level.filename() ~= "1-1 Clear Pipe Prairie.lvlx" 
		and Level.filename() ~= "3-1 Paddlewheel Peril.lvlx" 
		and Level.filename() ~= "3-2 Super Sticky Swamp.lvlx" 
		and Level.filename() ~= "3-3 Lightweight Library.lvlx" 
		and Level.filename() ~= "!B-1 Swooper Drop Sneak.lvlx"
		and Level.filename() ~= "!Credits.lvlx"
		and Level.filename() ~= "!Memory Center.lvlx"
		and Level.filename() ~= "!The Realm of Recollection.lvlx"
		and Level.filename() ~= "!Title Screen.lvlx"
		and Level.filename() ~= "!Final Cutscene.lvlx" then
			textplus.print{
				text = "<color lightgreen>Challenge Status</color><br>No challenge in this level.",
				priority = 5,
				x = 5,
				y = 550,
				xscale = 2,
				yscale = 2,
				priority = 2
			}
			textplus.print{
				text = "<color black>Challenge Status<br>No challenge in this level.</color>",
				priority = 5,
				x = 7,
				y = 552,
				xscale = 2,
				yscale = 2,
				priority = 1
			}
		end
    end

	-- Antizip makes the player teleport upwards if they take damage while pressing down. WHY?!
	if player.forcedState == FORCEDSTATE_POWERDOWN_SMALL and player.downKeyPressing then
		antizip.enabled = false
	else
		antizip.enabled = true
	end
end

function onLoadSection20()
	respawnRooms.reset(false)
end

function onTickEnd()
	local hijackedValue = mem(0x00B2C5A8, FIELD_WORD)
	if hijackedValue > 0 then
		mem(0x00B2C5A8, FIELD_WORD, 0)
		SaveData.coins = math.clamp(SaveData.coins + hijackedValue, 0, coinlimit)
	end
end

function onTick()
	-- Restart Confirmation Menu (changes based on whether or not a checkpoint is active)
	if Checkpoint.getActive() then
		pauseplus.createSubmenu("restartConfirmation",{headerText = "<align center>Would you like to return<br>to the latest checkpoint<br>or the start of the memory?</align>"})
		pauseplus.createOption("restartConfirmation",{text = "Checkpoint",closeMenu = true,action = function() player:kill() end})
		pauseplus.createOption("restartConfirmation",{text = "Start of Memory",closeMenu = true,action = function() Level.load(Level.filename()) Checkpoint.reset() end})
		pauseplus.createOption("restartConfirmation",{text = "Nevermind",goToSubmenu = "main"})
	else
		pauseplus.createSubmenu("restartConfirmation",{headerText = "<align center>Restart the memory?<br>All progress up until<br>this point will be lost.</align>"})
		pauseplus.createOption("restartConfirmation",{text = "Yes",closeMenu = true,action = function() Level.load(Level.filename()) Checkpoint.reset() end})
		pauseplus.createOption("restartConfirmation",{text = "No",goToSubmenu = "main"})
	end

	Defines.player_hasCheated = false
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
        if v.timer == 59 then
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

	for _,v in NPC.iterate(31) do
        if isCol(v) and v:mem(0x138, FIELD_WORD) ~= 4 and v:mem(0x12C, FIELD_WORD) == 0 then
            v:kill(HARM_TYPE_VANISH)
        end
    end
end

function respawnRooms.onPostReset(fromRespawn)
	if fromRespawn then
        respawnRooms.deathCoins = {}
		player.powerup = 2
		setHeight()
    end
end

function onPostNPCKill(npc, reason)
	if npc.id == 31 then
	  	local effect = Animation.spawn(75, npc.x + npc.width*0.5, npc.y + npc.height*0.5)
	  	effect.x, effect.y = effect.x - effect.width*0.5, effect.y - effect.height*0.5
	end 
end

function onExitLevel()
	GameData.usedSetPowerup = false
	GameData.usedAccessibility = false
	pauseplus.canPause = true

	if not Misc.inEditor() then
		Checkpoint.reset()
	end

	local totalProg = SaveData.totalMemoriesRecovered*2 + SaveData.starcoins + SaveData.totalKeyholesFound + SaveData.totalChallengesCompleted + audibletteUnlockedVar + conceptuaryUnlockedVar + creditsSeenVar
    Progress.value = (totalProg/MAX_VALUE)*100
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