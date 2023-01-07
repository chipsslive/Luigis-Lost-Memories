-- Written by Chipss

-- Library loading
local littleDialogue     = require("littleDialogue")
local warpTransition     = require("warpTransition")
local extraNPCProperties = require("extraNPCProperties")
local pauseplus          = require("pauseplus")
local portalOpen         = require("portalOpen")
local audiblette         = require("audiblette")
local particles          = require("particles")
local slm                = require("simpleLayerMovement")

-- Floating Luigi head stuff (scrapped)

--local head = Graphics.loadImageResolved("LuigiHead.png");

local sprite
local v = vector.right2
v.x = 0.5
v.y = 0.5

local sprite1X = -200096
local sprite1Y = -200416

-- Unlocking the Audiblette and Conceptuary variables/questions

local audibletteWarp
local audibletteLock
local audibletteNPC
local unlockedAudiblette
local conceptuaryWarp
local conceptuaryLock
local conceptuaryNPC
local unlockedConceptuary

function checkCoins()
    littleDialogue.deregisterQuestion("unlockConceptuaryQuestion")
    littleDialogue.deregisterQuestion("unlockAudibletteQuestion")
    if SaveData.coins >= 1000 then
        littleDialogue.registerAnswer("unlockConceptuaryQuestion",{text = "Take my money!",addText = "Exquisite! I will remove the lock at once!",chosenFunction = function() subtractCoins(1000) unlockedConceptuary = true checkCoins() end})
        littleDialogue.registerAnswer("unlockAudibletteQuestion",{text = "Take my money!",addText = "Exquisite! I will remove the lock at once!",chosenFunction = function() subtractCoins(1000) unlockedAudiblette = true checkCoins() end})
    else
        littleDialogue.registerAnswer("unlockConceptuaryQuestion",{text = "Take my money!",addText = "Bah! You do not even possess the required funds. Be gone!"})
        littleDialogue.registerAnswer("unlockAudibletteQuestion",{text = "Take my money!",addText = "Bah! You do not even possess the required funds. Be gone!"})
    end

    littleDialogue.registerAnswer("unlockConceptuaryQuestion",{text = "I have to pay my mortage!",addText = "That's what they all say!"})
    littleDialogue.registerAnswer("unlockAudibletteQuestion",{text = "I have to pay my mortage!",addText = "That's what they all say!"})
end

-- Chuck's Return Service related variables + questions

local launch = false
local triggered = false
local timer = 0

local chuck
littleDialogue.registerAnswer("chuckQuestion",{text = "Yeah!",chosenFunction = function() launch = true end})
littleDialogue.registerAnswer("chuckQuestion",{text = "Not Yet!"})

-- Tangeroomba Dialogue

littleDialogue.registerAnswer("tangeroombaInitial",{text = "What are Fragmented Memories?",addText = "Fragmented Memories are levels that had their design started, but weren't finished before the project's initial cancellation. For the most part, only the overarching mechanic of the level and its aesthetic had been established.<page>What else can I tell ya' about?<question tangeroombaInitial>"})
littleDialogue.registerAnswer("tangeroombaInitial",{text = "What are Alternate Memories?" ,addText = "Since the project's development really spanned over the course of three years with multiple revamps, renames, and reiterations, Alternate Memories contain the pile of levels that were scrapped from inclusion in the final product due to quality concerns or other reasons.<page>What else can I tell ya' about?<question tangeroombaInitial>"})
littleDialogue.registerAnswer("tangeroombaInitial",{text = "What is the Map of Memories?" ,addText = "The Map of Memories allows you to explore the world map of the project, which obviously was the originally intended method of traversing between levels in the game. The vast majority of the main island was completed, though completion/polish starts to taper off after launching into outer space, which was used to access the final few worlds of the game.<page>What else can I tell ya' about??<question tangeroombaInitial>"})
littleDialogue.registerAnswer("tangeroombaInitial",{text = "What is The Conceptuary?"     ,addText = "The Conceptuary holds a collection of every piece of art, whether that be for concept or promotional purposes, created for the game. Most of them were created by galaxy, while the piece of art at the far end of the building was created by FurballArts.<page>What else can I tell ya' about?<question tangeroombaInitial>"})
littleDialogue.registerAnswer("tangeroombaInitial",{text = "What is The Audiblette?"      ,addText = "The Audiblette is a collection of every piece of unused music in the game. These can range from fully mixed and mastered tracks to very early renditions that never made it any further. The cool thing about this building is that playing a track inside will have it ring out throughout the entire Realm of Recollection!<page>What else can I tell ya' about?<question tangeroombaInitial>"})
littleDialogue.registerAnswer("tangeroombaInitial",{text = "Nevermind"})

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
local portalCutsceneTimerStart = false
local portalCutsceneTimer = 0
local orangeBloomba
local blueBloomba
local redBloomba
local purpleBloomba
local orangeMessage
local blueMessage
local redMessage
local purpleMessage
local reduceOpacity2 = false
local defaultBloombas
local defaultRedBloomba
local hidePlayer = false
local lockPlayer = false
local doEarthquake = false
local currentQuakeIntensity = 2.5

littleDialogue.registerAnswer("introQuestion",{text = "Let's do it!",addText = "HOORAY! Let's get this party started!",chosenFunction = function() startPortalSpawn = true end})
littleDialogue.registerAnswer("introQuestion",{text = "Stuck in my mind!",addText = "Aw, man. Well, if you change your mind. I'll be waiting here for eternity.",chosenFunction = function() talkedToBloomba = true end})
littleDialogue.registerAnswer("introQuestion2",{text = "I'm ready!",addText = "HOORAY! Let's get this party started!",chosenFunction = function() startPortalSpawn = true end})
littleDialogue.registerAnswer("introQuestion2",{text = "My mind is nicer!",addText = "Ugh, I guess I can't force you to do this. I am really bored, though."})

-- Other stuff that is relevant after progression

local maroonba2
local ceruloomba
local allMemoriesMsgMaroonba = "<speakerName Maroonba>Wowza! Would you look at that! You recovered every last one of those memories!<page>Well, actually, there are still plenty of them left unrecovered, but your amnesia was so strong that I'm fairly sure we'll never be able to find those, even inside the Realm of Recollection.<page>Ah, well, at least we tried, right?"
local allMemoriesMsgCeruloomba = "<speakerName Ceruloomba>Huh? Oh, so you finally recovered 'em all, eh? About time! I feel like I'm two steps away from my grave at this point, and I'm immortal!<page>Anyways, now that you've done that, it's time for you to enter the 'Memory Amalgamation.'<page>Every person attempting to leave their consciousness has to do it! Think of this as a sort of... rite of passage.<page>So, whaddya say kid? You ready to take the plunge?<question enterAmalgamation>"

local mauvoomba
local emitConfetti = false
local allPurpleStarsMsg = "<speakerName Mauvoomba>Ah, Master Luigi! You've found all the Purple Stars! Magnificent!<page>Huh? What's that? Your reward?<page>Well, about that. There... isn't one.<page>I was told by the higher-ups to blame something called 'avoiding scope creep.'<page>Not sure what that means, though.<page>Regardless, we have to celebrate somehow! Here, check this out!"
local startConfettiTimer = false
local confettiTimer = 0

littleDialogue.registerAnswer("enterAmalgamation",{text = "I'm ready!",addText = "Don't screw up out there kid. Your future depends on it.",chosenFunction = function() Level.load("!Memory Amalgamation.lvlx") end})
littleDialogue.registerAnswer("enterAmalgamation",{text = "That sounds scary!",addText = "What a quitter! You should be ashamed of yourself, dimwit."})

littleDialogue.registerAnswer("enterAmalgamationAfterCredits",{text = "Let's do it!",addText = "Enjoy it kid. You earned this.",chosenFunction = function() Level.load("!Memory Amalgamation.lvlx") end})
littleDialogue.registerAnswer("enterAmalgamationAfterCredits",{text = "Not right now.",addText = "No worries. This time's just for fun anyway."})

local afterCreditsMsgCeruloomba = "<speakerName Ceruloomba>Hey kid. Sorry I was so rude to ya' before. Hopefully you can forgive me, I'm working through some stuff.<page>You did good out there in the Memory Amalgamation. If you'd like, I can send ya' through it again. Whaddya think?<question enterAmalgamationAfterCredits>"

local hundo
local hundoMsgMaroonba = "<speakerName Maroonba>Master Luigi! Look! Up in the sky! Who put those numbers there? Was that you?"

-- Confetti particle emitter

local confetti = particles.Emitter(0, 0, "p_confetti.ini")

-- Speakers inside the Audiblette

local speakers
local speaker1
local speaker2
local speaker3
local speaker4
local speakerImg = Graphics.loadImageResolved("speaker.png")
local myIMG = Graphics.loadImageResolved("talkImage.png")

function onStart()
    slm.addLayer{name = "hundo",speed = 96,verticalMovement = slm.MOVEMENT_COSINE,verticalSpeed = 76,verticalDistance = 0.1}

    -- This is needed to allow the world map to be accessed from the hub
    mem(0xB25728, FIELD_BOOL, true)
    
    -- See if player can afford to unlock Conceptuary/Audiblette
    checkCoins()

    player.powerup = 2
    --[[sprite = Sprite.box{
        texture = head,
        x = sprite1X,
        y = sprite1Y,
        pivot = v,
    }]]

    -- Speakers inside the Audiblette

    speakers = BGO.get(239)

    speaker1 = Sprite.box{
        texture = speakerImg,
        x = speakers[1].x + 16,
        y = speakers[1].y + 16,
        pivot = {0.5,0.5}
    }

    speaker2 = Sprite.box{
        texture = speakerImg,
        x = speakers[2].x + 16,
        y = speakers[2].y + 16,
        pivot = {0.5,0.5}
    }

    speaker3 = Sprite.box{
        texture = speakerImg,
        x = speakers[3].x + 16,
        y = speakers[3].y + 16,
        pivot = {0.5,0.5}
    }

    speaker4 = Sprite.box{
        texture = speakerImg,
        x = speakers[4].x + 16,
        y = speakers[4].y + 16,
        pivot = {0.5,0.5}
    }

    -- A bunch of layers (some aren't even used anymore)

    chuck           = Layer.get("chuck")
    originalSigns   = Layer.get("originalSigns")
    otherSigns      = Layer.get("otherSigns")
    sleepLuigi      = Layer.get("sleepLuigi")
    awakeLuigi      = Layer.get("awakeLuigi")
    portal          = Layer.get("portal")
    otherBloombas   = Layer.get("otherBloombas")
    maroonba        = Layer.get("maroonba")
    defaultBloombas = Layer.get("defaultBloombas")
    conceptuaryWarp = Layer.get("conceptuaryWarp")
    audibletteWarp  = Layer.get("audibletteWarp")
    audibletteLock  = Layer.get("audibletteLock")
    conceptuaryLock = Layer.get("conceptuaryLock")
    audibletteNPC   = Layer.get("audibletteNPC")
    conceptuaryNPC  = Layer.get("conceptuaryNPC")
    hundo           = Layer.get("hundo")

    -- Intro initializations

    if SaveData.introFinished == false then
        showAsleep = true
        portal:hide(true)
        maroonba:show(true)
        defaultBloombas:hide(true)
        pauseplus.canPause = false
    end

    -- Check if Conceptuary/Audiblette are unlocked

    if SaveData.conceptuaryUnlocked then
        conceptuaryWarp:show(true)
        conceptuaryLock:hide(true)
        conceptuaryNPC:hide(true)
    end
    if SaveData.audibletteUnlocked then
        audibletteWarp:show(true)
        audibletteLock:hide(true)
        audibletteNPC:hide(true)
    end
end

if SaveData.introFinished == false then
    warpTransition.levelStartTransition = warpTransition.TRANSITION_FADE
    warpTransition.transitionSpeeds[warpTransition.TRANSITION_FADE] = 200
end

function onTick()
    -- Check if intersected with boomobox

    for k,v in ipairs(BGO.getIntersecting(player.x, player.y, player.x + player.width, player.y + player.height)) do
        if v.id == 283 then
            local gfxHeight = NPC.config[v.id].gfxheight - v.height
            if gfxHeight < 0 then gfxHeight = 0 end
                
            local trueX = (v.x + 0.5 * v.width) - (0.5 * myIMG.width) 
            local trueY = (v.y - 8 - gfxHeight) - myIMG.height + 36

            Graphics.drawImageToSceneWP(myIMG, trueX, trueY, -40)

            if player.rawKeys.up == KEYS_PRESSED then
                audiblette.open()
            end
        end
    end

    -- Confetti stuff

    for _,v in ipairs(extraNPCProperties.getWithTag("mauvoomba")) do
        mauvoomba = v
        confetti:Attach(mauvoomba, true, true)
    end

    if startConfettiTimer then
        confettiTimer = confettiTimer + 1
        if confettiTimer > 20 then
            emitConfetti = true
            startConfettiTimer = false
        end
    end

    if emitConfetti then
        confetti:Emit(1)
    end

    -- Stuff related to what happens after recovering every memory

    for _,v in ipairs(extraNPCProperties.getWithTag("defaultRedBloomba")) do
        maroonba2 = v
    end

    for _,v in ipairs(extraNPCProperties.getWithTag("blueBloomba")) do
        ceruloomba = v
    end

    -- Check if Conceptuary/Audiblette have just been unlocked
    if unlockedConceptuary then
        conceptuaryWarp:show(true)
        conceptuaryLock:hide(false)
        conceptuaryNPC:hide(true)
        SFX.play("destroyLock.wav")
        SaveData.conceptuaryUnlocked = true
        GameData.ach_Conceptuary:collect()
        GameData.ach_HundredPercent:setCondition(6,true)
        unlockedConceptuary = false
    elseif unlockedAudiblette then
        audibletteWarp:show(true)
        audibletteLock:hide(false)
        audibletteNPC:hide(true)
        SFX.play("destroyLock.wav")
        SaveData.audibletteUnlocked = true
        GameData.ach_Audiblette:collect()
        GameData.ach_HundredPercent:setCondition(5,true)
        unlockedAudiblette = false
    end

    -- For Ceruloomba and Mauvoomba's completion requirements

    if GameData.ach_AllMemories.collected and SaveData.allMemoriesRecovered then
        if SaveData.creditsSeen then
            for _,v in ipairs(extraNPCProperties.getWithTag("blueBloomba")) do
                v.msg = afterCreditsMsgCeruloomba
            end
        else
            for _,v in ipairs(extraNPCProperties.getWithTag("blueBloomba")) do
                v.msg = allMemoriesMsgCeruloomba
            end
        end
    end

    if GameData.ach_AllMemories.collected and SaveData.allMemoriesRecovered and not SaveData.fullyComplete then
		for _,v in ipairs(extraNPCProperties.getWithTag("defaultRedBloomba")) do
            v.msg = allMemoriesMsgMaroonba
        end
    end

    if GameData.ach_HundredPercent.collected and SaveData.fullyComplete then
        for _,v in ipairs(extraNPCProperties.getWithTag("defaultRedBloomba")) do
            v.msg = hundoMsgMaroonba
        end
    end

    if GameData.ach_AllPurpleStars.collected and not emitConfetti and not startConfettiTimer and SaveData.allPurpleStarsFound then
		for _,v in ipairs(extraNPCProperties.getWithTag("mauvoomba")) do
            v.msg = allPurpleStarsMsg
        end
    end

    -- Chuck's Return Service Handling 
    -- (this was written a long time ago and is very bad but it functions so I'm keeping it)

    if launch then
        timer = timer + 1
        player.speedX = -300000 -- this is absolute overkill but its funny
        player.speedY = -1.8
        if not triggered then
            -- Chuck is hidden to play the effect (effect-805.png)
            chuck:hide(true)
            -- I have to hide the signs containing messages because Lock Controls holds the UP button
            originalSigns:hide(true)
            otherSigns:show(true)
            triggerEvent("Lock Controls")
            if player.y < -160242 then
                player.y = player.y + 32
            end
            triggered = true
        end
        if timer == 7 then
            SFX.play(9)
        end
        if timer > 120 then
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

    -- Everything below this line in onTick() is relating to intro sequence

    if SaveData.introFinished == false then
        GameData.cutscene = true
        if introTimer == 0 then
            lockPlayer = true
            hidePlayer = true
        end

        if stopIntroTimer == false then
            introTimer = introTimer + 1
        end

        if introTimer == 55 then
            showAsleep = false
            showAwake = true
        end

        if introTimer == 90 then
            littleDialogue.create{
                text = "<boxStyle madelyn>Hello again, Luigi. You are now located within your own consciousness. Here, you can begin the Yesterday Network recovery process.<page>The Bloombas, a species born from a materialization of your pure mind, will be your guide from this point onwards.<page>Farewell, for now.",
                pauses = true,
                silentOpen = true
            }
        end

        if introTimer > 91 and (player.rawKeys.left == KEYS_PRESSED or player.rawKeys.right == KEYS_PRESSED or player.rawKeys.down == KEYS_PRESSED or player.rawKeys.jump == KEYS_PRESSED or player.rawKeys.altJump == KEYS_PRESSED) and stopIntroTimer == false then
            stopIntroTimer = true
            hidePlayer = false
            lockPlayer = false
            showAwake = false
        end
    else
        if GameData.cutscene then
            GameData.cutscene = false
        end
    end

    -- Checks if the player has already spoken to the first Bloomba before. If true, shortens its talking message significantly

    if talkedToBloomba == true then
        for _,v in ipairs(extraNPCProperties.getWithTag("introBloomba")) do
            v.msg = "<speakerName Maroonba>Master Luigi! Have you finally come to your senses and decided to recover your memories?<question introQuestion2>"
        end
        talkedToBloomba = false
    end

    if startPortalSpawn then
        -- Sound effect that plays right when the first white flash happens

        if sfx1Played == false then
            SFX.play(61)
            sfx1Played = true
            lockPlayer = true
        end

        Graphics.drawScreen{color = Color.white.. opacity,priority = 6}

        -- First white flash, teleporting player to portal location

        if opacity < 1 and reduceOpacity1 == false then
            opacity = opacity + 0.1
            player.speedX = 0
            player.speedY = 0
        end

        -- Everything that happens at the peak of the first white flash, when screen is fully opaque white

        if opacity >= 1 and portalCutsceneTimerStart == false then
            otherBloombas:show(true)
            showAwake = true
            maroonba:hide(true)
            player.x = -199851
            player.y = -200256
            reduceOpacity1 = true
            hidePlayer = true

            -- Assign each colored Bloomba to its own variable

            for _,v in ipairs(extraNPCProperties.getWithTag("orangeBloomba")) do
                orangeBloomba = v
            end
            for _,v in ipairs(extraNPCProperties.getWithTag("redBloomba")) do
                redBloomba = v
            end
            for _,v in ipairs(extraNPCProperties.getWithTag("purpleBloomba")) do
                purpleBloomba = v
            end
            for _,v in ipairs(extraNPCProperties.getWithTag("blueBloomba")) do
                blueBloomba = v
            end
        end

        -- Fading out the first white flash

        if reduceOpacity1 then
            if opacity > 0 and portalCutsceneTimerStart == false then
                opacity = opacity - 0.01
            else
                portalCutsceneTimerStart = true
            end
        end

        -- Start new timer for cutscene that creates portal

        if portalCutsceneTimerStart then
            portalCutsceneTimer = portalCutsceneTimer + 1
        end

        -- Sequence of events following the first white flash

        if portalCutsceneTimer == 10 then
            SFX.play("rumble.wav")
            doEarthquake = true
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

        -- Peak of second time white fills the screen

        if portalCutsceneTimer == 450 then
            orangeMessage:progress()
            blueMessage:progress()
            purpleMessage:progress()
            redMessage:progress()
            otherBloombas:hide(true)
            portal:show(true)
            defaultBloombas:show(true)
            for _,v in ipairs(extraNPCProperties.getWithTag("defaultRedBloomba")) do
                defaultRedBloomba = v
            end
        end

        if portalCutsceneTimer == 500 then
            reduceOpacity2 = true
        end

        -- Fade out second white screen

        if doEarthquake then
            Defines.earthquake = currentQuakeIntensity
        end

        if reduceOpacity2 then
            if opacity > 0 then
                opacity = opacity -0.004
            end
            if currentQuakeIntensity > 0.01 then
                currentQuakeIntensity = currentQuakeIntensity - 0.01
            else
                currentQuakeIntensity = 0
                doEarthquake = false
            end
        end

        -- Sound played after second white screen is faded out

        if portalCutsceneTimer == 750 then
            SFX.play("portalRevealed.wav")
        end

        -- Final introductory Bloomba message

        if portalCutsceneTimer == 850 then
            littleDialogue.create{
                text = "And there you have it! Use that portal to recover your memories.<page>If you have any questions about the details, just talk to Tangeroomba right above you.",
                pauses = true,
                speakerObj = defaultRedBloomba
            }
            SaveData.introFinished = true
        end

        -- Locks the player in place until they decide to move, then intro is considered finished

        if portalCutsceneTimer > 850 and (player.rawKeys.left == KEYS_PRESSED or player.rawKeys.right == KEYS_PRESSED or player.rawKeys.down == KEYS_PRESSED or player.rawKeys.jump == KEYS_PRESSED or player.rawKeys.altJump == KEYS_PRESSED) then
            hidePlayer = false
            lockPlayer = false
            pauseplus.canPause = true
            portalCutsceneTimer = 0
            portalCutsceneTimerStart = false
            startPortalSpawn = false
            showAwake = false
        end
    end

    -- If I don't put this at the bottom, there is a weird graphical glitch when unhiding the player. I have no idea why

    if hidePlayer then
        player:setFrame(-50 * player.direction)
    end

    -- Self explanatory, locks player controls

    if lockPlayer then
        for k, v in pairs(player.keys) do
            player.keys[k] = false
        end
    end

    -- Setting player frames for cutscene purposes

    if showAwake then
        player:setFrame(15 * player.direction)
    elseif showAsleep then
        player:setFrame(49 * player.direction)
    end
end

function onEvent(eventName)
    -- This spawns the chuck swinging his bat effect. The event triggers elsewhere but not anywhere where the bat effect can be seen at an incorrect timer

    if eventName == "Lock Controls" then
        Effect.spawn(805,-158214,-160222)
    end
end

-- pls don't mind this jank
local teleported = false

local scale = 1
local raiseScale = true
local lowerScale = false

function onDraw()
    --[[if teleported == false then
        player.x = -199856
        player.y = -200240
        teleported = true
    end ]]

    if SaveData.fullyComplete and hundo.isHidden then
        hundo:show(true)
    end

    -- Speakers

    local sine = 1 + math.abs(math.sin(lunatime.drawtick() * 0.07)) * 0.3

    if sine > 1.3 then
        sine = 1.3
    end

    speaker1:draw{priority = -30,sceneCoords = true}
    speaker2:draw{priority = -30,sceneCoords = true}
    speaker3:draw{priority = -30,sceneCoords = true}
    speaker4:draw{priority = -30,sceneCoords = true}

    if audiblette.currentlyPlaying ~= "Default" then
        speaker1.transform.scale = {sine,sine}
        speaker2.transform.scale = {sine,sine}
        speaker3.transform.scale = {sine,sine}
        speaker4.transform.scale = {sine,sine}
    else
        speaker1.transform.scale = {1,1}
        speaker2.transform.scale = {1,1}
        speaker3.transform.scale = {1,1}
        speaker4.transform.scale = {1,1}
    end

    -- This is a failsafe

    if player.powerup ~= 2 then
        player.powerup = 2
    end

    -- More confetti stuff

    confetti:Draw(-1)

    -- Draw Luigi head sprite and start rotating
	--sprite:draw{priority = -99, sceneCoords = true}
    --sprite:rotate(0.7)

    -- Return Luigi head to bottom of screen when it passes the top (pseudo looping effect)

    --[[if sprite.y < -20 then
        y = 200
        x = 200
    end]]
end

function littleDialogue.onMessageBox(eventObj,text,playerObj,npcObj)
    littleDialogue.create{
        text = text,
        speakerObj = npcObj or playerObj or player,
    }

    eventObj.cancelled = true
    
    if text == allPurpleStarsMsg and GameData.ach_AllPurpleStars.collected and SaveData.allPurpleStarsFound then
        startConfettiTimer = true
        mauvoomba.msg = "<speakerName Mauvoomba>I could do this for hours!"
    end
end
