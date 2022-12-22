local littleDialogue = require("littleDialogue")
local warpTransition = require("warpTransition")
local extraNPCProperties = require("extraNPCProperties")

-- Floating Luigi head stuff

local head = Graphics.loadImageResolved("LuigiHead.png");

local sprite
local v = vector.right2
v.x = 0.5
v.y = 0.5

local initialX = 100
local initialY = 620

local x = 100
local y = -10

-- Chuck's Return Service related variables + questions

local launch = false
local triggered = false
local timer = 0

local chuck
littleDialogue.registerAnswer("chuckQuestion",{text = "Yeah!",chosenFunction = function() launch = true end})
littleDialogue.registerAnswer("chuckQuestion",{text = "Not Yet!"})

-- All intro-related variables + questions

local introTimer = 0
local stopIntroTimer = false
local sleepLuigi
local awakeLuigi
local portal
local playerStart = false
local talkedToBloomba = false
local opacity = 0
local sfx1Played = false
local otherBloombas
local reduceOpacity1 = false
local maroonba
local portalCutsceneTimerStart =  false
local portalCutsceneTimer = 0
local orangeBloomba
local blueBloomba
local redBloomba
local purpleBloomba
local orangeMessage
local blueMessage
local redMessage
local purpleMessage
reduceOpacity2 = false

littleDialogue.registerAnswer("introQuestion",{text = "Let's do it!",addText = "HOORAY! Let's get this party started!",chosenFunction = function() startPortalSpawn = true end})
littleDialogue.registerAnswer("introQuestion",{text = "Stuck in my mind!",addText = "Aw, man. Well, if you change your mind. I'll be waiting here for eternity.",chosenFunction = function() talkedToBloomba = true end})
littleDialogue.registerAnswer("introQuestion2",{text = "I'm ready!",addText = "HOORAY! Let's get this party started!",chosenFunction = function() startPortalSpawn = true end})
littleDialogue.registerAnswer("introQuestion2",{text = "My mind is nicer!",addText = "Ugh, I guess I can't force you to do this. I am really bored, though."})

function onStart()
    player.powerup = 2
    sprite = Sprite.box{
        texture = head,
        x = x,
        y = y,
        pivot = v,
    }

    chuck = Layer.get("chuck")
    originalSigns = Layer.get("originalSigns")
    otherSigns = Layer.get("otherSigns")
    sleepLuigi = Layer.get("sleepLuigi")
    awakeLuigi = Layer.get("awakeLuigi")
    portal = Layer.get("portal")
    otherBloombas = Layer.get("otherBloombas")
    maroonba = Layer.get("maroonba")

    if SaveData.introFinished == false then
        sleepLuigi:show(true)
        portal:hide(true)
        maroonba:show(true)
    end

    -- Assign each colored Bloomba to its own variable

    for _,v in ipairs(NPC.get()) do
        if v.id == 761 then
            orangeBloomba = v
        elseif v.id == 758 and v.isHidden then
            redBloomba = v
        elseif v.id == 759 then
            purpleBloomba = v
        elseif v.id == 760 then
            blueBloomba = v
        end
    end
end

if SaveData.introFinished == false then
    warpTransition.levelStartTransition = warpTransition.TRANSITION_FADE
    warpTransition.transitionSpeeds[warpTransition.TRANSITION_FADE] = 200
end

function onTick()
    x = x + 0.2
    y = y - 0.2

    if y < -20 then
        y = initialY
        x = initialX
    end

    if launch then
        timer = timer + 1
        player.speedX = -200000
        player.speedY = -2
        if not triggered then
            chuck:hide(true)
            originalSigns:hide(true)
            otherSigns:show(true)
            triggerEvent("Lock Controls")
            triggered = true
        end
        if timer == 7 then
            SFX.play(9)
        end
        if timer > 100 then
            launch = false
            triggered = false
            originalSigns:show(true)
            otherSigns:hide(true)
            timer = 0
            SFX.play(37)
            triggerEvent("Unlock Controls")
            chuck:show(true)
        end
    end

    if SaveData.introFinished == false then
        if stopIntroTimer == false then
            introTimer = introTimer + 1
        end
        --Text.print(introTimer, 100, 100)

        if introTimer == 55 then
            sleepLuigi:hide(true)
            awakeLuigi:show(true)
        end

        if introTimer == 90 then
            littleDialogue.create{
                text = "<boxStyle madelyn>Hello again, Luigi. You are now located within your own consciousness. Here, you can begin the Yesterday Network recovery process.<page>The Bloombas, a species born from a materialization of your pure mind, will be your guide from this point onwards.<page>Farewell, for now.",
                pauses = true,
                silentOpen = true
            }
        end

        if introTimer < 91 then
            triggerEvent("Lock Controls")
            player:mem(0x11E, FIELD_WORD, 0)
        elseif introTimer > 91 and (player.rawKeys.left == KEYS_PRESSED or player.rawKeys.right == KEYS_PRESSED or player.rawKeys.down == KEYS_PRESSED or player.rawKeys.jump == KEYS_PRESSED or player.rawKeys.altJump == KEYS_PRESSED) and playerStart == false then
            triggerEvent("Unlock Controls")
            player:mem(0x11E, FIELD_WORD, 1)
            awakeLuigi:hide(true)
            stopIntroTimer = true
            playerStart = true
            --SaveData.introFinished = true
        end

        if playerStart == false then
            player:setFrame(-50 * player.direction)
        end
    end

    if talkedToBloomba == true then
        for _,v in ipairs(extraNPCProperties.getWithTag("introBloomba")) do
            v.msg = "<speakerName Maroonba>Master Luigi! Have you finally come to your senses and decided to recover your memories?<question introQuestion2>"
        end
        talkedToBloomba = false
    end

    if startPortalSpawn then
        for _,v in ipairs(extraNPCProperties.getWithTag("introBloomba")) do
            v.msg = ""
        end
        if sfx1Played == false then
            SFX.play(61)
            sfx1Played = true
            triggerEvent("Lock Controls")
        end
        Graphics.drawScreen{color = Color.white.. opacity,priority = 6}
        if opacity < 1 and reduceOpacity1 == false then
            opacity = opacity + 0.1
            player.speedX = 0
            player.speedY = 0
        end

        if opacity >= 1 and portalCutsceneTimerStart == false then
            otherBloombas:show(true)
            awakeLuigi:show(true)
            maroonba:hide(true)
            player.x = -199856
            player.y = -200244
            reduceOpacity1 = true
        end

        if reduceOpacity1 then
            player:setFrame(-50 * player.direction)
            if opacity > 0 and portalCutsceneTimerStart == false then
                opacity = opacity - 0.01
            else
                portalCutsceneTimerStart = true
            end
        end

        if portalCutsceneTimerStart then
            portalCutsceneTimer = portalCutsceneTimer + 1
        end

        if portalCutsceneTimer == 10 then
            SFX.play("rumble.wav")
        elseif portalCutsceneTimer > 10 and reduceOpacity2 == false then
            if opacity < 1 then
                opacity = opacity + 0.003
            end
        end

        if portalCutsceneTimer == 10 then
            orangeMessage = littleDialogue.create{
                text = "Woohoo! Let's do this!",
                uncontrollable = true,
                pauses = false,
                speakerObj = orangeBloomba
            }
        end

        if portalCutsceneTimer == 120 then
            blueMessage = littleDialogue.create{
                text = "Finally! Mental stimulation!",
                uncontrollable = true,
                pauses = false,
                speakerObj = blueBloomba
            }
        end

        if portalCutsceneTimer == 220 then
            purpleMessage = littleDialogue.create{
                text = "*casting magic spell noises*",
                uncontrollable = true,
                pauses = false,
                speakerObj = purpleBloomba
            }
        end

        if portalCutsceneTimer == 330 then
            redMessage = littleDialogue.create{
                text = "Get Ready! Here it comes!",
                uncontrollable = true,
                pauses = false,
                speakerObj = redBloomba
            }
        end

        if portalCutsceneTimer == 450 then
            orangeMessage:progress()
            blueMessage:progress()
            purpleMessage:progress()
            redMessage:progress()
            otherBloombas:hide(true)
            portal:show(true)
        end

        if portalCutsceneTimer == 500 then
            reduceOpacity2 = true
        end

        if reduceOpacity2 then
            if opacity > 0 then
                opacity = opacity -0.004
            end
        end

        if portalCutsceneTimer == 750 then
            SFX.play("portalRevealed.wav")
        end
    end
end

function onEvent(eventName)
    if eventName == "Lock Controls" then
        Effect.spawn(805,-158214,-160222)
    end
end

function onDraw()
	sprite:draw{priority = -99.1}
    sprite:rotate(0.7)
    sprite.x = x
    sprite.y = y
end