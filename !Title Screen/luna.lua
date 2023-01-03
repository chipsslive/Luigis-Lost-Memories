local warpTransition = require("warpTransition")
local dropShadows = require("dropShadows")
local textplus = require("textplus")
local littleDialogue = require("littleDialogue")
local pauseplus = require("pauseplus")

pauseplus.canPause = false

local triggerExit = false
local sfxPlayed = false
local musicSeized = false
local opacity = 0

-- Game logo
local logo = Graphics.loadImageResolved("logo.png")

local x = 110
local y = 140
local movementTimer = 0

local alpha = 0
local timer = 0

local newTimer = 0

-- Stuff for the text
local portalFont = textplus.loadFont("portalFont.ini")
local alpha2 = 0

-- Initialize stuff needed for floating Bloombas

local bloombaRed = Graphics.loadImageResolved("bloombaRed.png");
local bloombaOrange = Graphics.loadImageResolved("bloombaOrange.png");
local bloombaBlue = Graphics.loadImageResolved("bloombaBlue.png");
local bloombaPurple = Graphics.loadImageResolved("bloombaPurple.png");

local spriteOrange
local spriteRed
local spriteBlue
local spritePurple
local v = vector.right2
v.x = 0.5
v.y = 0.5

-- Initial floating Bloomba positions

local bloombaX = 10
local bloombaY = 100
local initialBloombaX = 200
local initialBloombaY = 100

local bloombaXRed = 730
local bloombaYRed = 350
local initialBloombaXRed = 730
local initialBloombaYRed = 350

local bloombaXBlue = 270
local bloombaYBlue = 500
local initialBloombaXBlue = 270
local initialBloombaYBlue = 500

local bloombaXPurple = 700
local bloombaYPurple = 120
local initialBloombaXPurple = 700
local initialBloombaYPurple = 120

-- Easy way to add fade in
warpTransition.levelStartTransition = warpTransition.TRANSITION_FADE
warpTransition.transitionSpeeds[warpTransition.TRANSITION_FADE] = 200

function onStart()
    GameData.cutscene = true
    GameData.seenTitle = true

    -- Initialize floating Bloomba sprites

    spriteOrange = Sprite.box{
        texture = bloombaOrange,
        x = bloombaX,
        y = bloombaY,
        pivot = v,
    }
    spriteRed = Sprite.box{
        texture = bloombaRed,
        x = bloombaX,
        y = bloombaY,
        pivot = v,
    }
    spriteBlue = Sprite.box{
        texture = bloombaBlue,
        x = bloombaX,
        y = bloombaY,
        pivot = v,
    }
    spritePurple = Sprite.box{
        texture = bloombaPurple,
        x = bloombaX,
        y = bloombaY,
        pivot = v,
    }
end

function onTick()
    -- Lock and hide the player

    player:setFrame(-50 * player.direction)
    for k, v in pairs(player.keys) do
        player.keys[k] = false
    end

    timer = timer + 1

    -- Draw logo and text

    if timer > 200 then
        Graphics.drawImageWP(logo, x, y, alpha, -50)
        if alpha < 1 and not triggerExit then
            alpha = alpha + 0.01
        end

        movementTimer = movementTimer + 1
        y = math.cos(0.02 * movementTimer)*3 + 140
    end

    if timer > 350 then
        textplus.print{
            x = 165,
            y = 450,
            text = "Press any button to start!",
            color = Color.white * alpha2,
            font = portalFont,
            priority = -50
        }

        if alpha2 < 1 and not triggerExit then
            alpha2 = alpha2 + 0.01
        end

        for k, v in pairs(player.rawKeys) do
            if player.rawKeys[k] == KEYS_PRESSED then
                triggerExit = true
                if not sfxPlayed then
                    SFX.play("startGame.wav")
                    sfxPlayed = true
                end
            end
        end
    end

    -- Hide logos and text

    if triggerExit then
        if not musicSeized then
            Audio.SeizeStream(-1)
            musicSeized = true
        end
        
        Audio.MusicStop()

        if alpha > 0 then
            alpha = alpha - 0.01
            alpha2 = alpha2 - 0.01
        end

        Graphics.drawScreen{color = Color.black.. opacity,priority = 2}
        if opacity < 1 then
            opacity = opacity + 0.008
        else
            if not stopTimer then
                newTimer = newTimer + 1
            end
            if newTimer == 20 then
                newTimer = newTimer + 1
                if SaveData.introFinished then
                    Level.load("!The Realm of Recollection.lvlx")
                else
                    stopTimer = true
                    littleDialogue.create{
                        text = "Quick question before you start! Have you played this game before?<question playedBefore>",
                        pauses = false,
                        forcedPosX = 400,
                        forcedPosY = 300,
                        settings = {typewriterEnabled = false}
                    }
                end
            end
            if hasPlayedBefore ~= nil then
                stopTimer = false
            end
            if newTimer == 100 then
                if hasPlayedBefore then
                    playedBefore()
                else
                    notPlayedBefore()
                end
            end
        end
    end
end

littleDialogue.registerAnswer("playedBefore",{text = "Yes",addText = "Cool! Want me to skip the intro sequence for ya'?<question confirmSkipIntro>"})
littleDialogue.registerAnswer("playedBefore",{text = "No",chosenFunction = function() hasPlayedBefore = false end})

littleDialogue.registerAnswer("confirmSkipIntro",{text = "Yes",chosenFunction = function() hasPlayedBefore = true end})
littleDialogue.registerAnswer("confirmSkipIntro",{text = "No",chosenFunction = function() hasPlayedBefore = false end})

function playedBefore()
    SaveData.introFinished = true
    Level.load("!The Realm of Recollection.lvlx")
end

function notPlayedBefore()
    Level.load("!Memory Center.lvlx")
end

function onDraw()
    -- Draw and rotate floating Bloomba sprites

    --[[spriteOrange:draw{priority = -60}
    spriteOrange:rotate(0.7)
    spriteOrange.x = bloombaX
    spriteOrange.y = bloombaY

    spriteRed:draw{priority = -60}
    spriteRed:rotate(0.7)
    spriteRed.x = bloombaXRed
    spriteRed.y = bloombaYRed

    spritePurple:draw{priority = -60}
    spritePurple:rotate(0.7)
    spritePurple.x = bloombaXPurple
    spritePurple.y = bloombaYPurple

    spriteBlue:draw{priority = -60}
    spriteBlue:rotate(0.7)
    spriteBlue.x = bloombaXBlue
    spriteBlue.y = bloombaYBlue

    bloombaX = bloombaX + 0.2
    bloombaY = bloombaY + 0.03

    bloombaXRed = bloombaXRed - 0.1
    bloombaYRed = bloombaYRed + 0.04

    bloombaXPurple = bloombaXPurple + 0.1
    bloombaYPurple = bloombaYPurple - 0.2]]
end