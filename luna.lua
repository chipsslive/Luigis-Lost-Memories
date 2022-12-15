--local rooms = require("rooms")
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

pauseplus.createDefaultMenu()

local starcoin = require("npcs/AI/starcoin")
SaveData.starcoins = starcoin.getEpisodeCollected()

SaveData.coins = SaveData.coins or 0
local coinEffects
GameData.cutscene = false

local coin = Graphics.loadImage(Misc.resolveFile("coin1.png"))

function onStart()
	SaveData.coins = 0
    player.character = CHARACTER_LUIGI
    hudoverride.visible.lives = false
    hudoverride.visible.score = false
	hudoverride.visible.coins = false
	hudoverride.visible.itembox = false
	hudoverride.visible.starcoins = true

	if Level.filename() ~= "!Memory Center.lvlx" and Level.filename() ~= "!The Realm of Recollection.lvlx" then
        pauseplus.createOption("main",{text = "Exit Memory",action = pauseplus.exitLevel}, 2)
    end
end

function onTick()
	player.reservePowerup = 0
    SaveData.coins = SaveData.coins + mem(0x00B2C5A8,FIELD_WORD)
	mem(0x00B2C5A8,FIELD_WORD,0)
	
	if SaveData.coins > 99999 then
		SaveData.coins = 99999
	end

	-- Instead of awarding score, this code adds to the coin count
	coinEffects = Effect.get(79)

	for _,v in pairs(coinEffects) do
		--if v.parent == 
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
end

function respawnRooms.onPostReset(fromRespawn)
	if SaveData.coins >= 10 then
		SaveData.coins = SaveData.coins - 10
	else
		SaveData.coins = 0
	end
end

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

local isPauseActive = false
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

--[[function onDraw()
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