-- Written by Chipss

-- Library loading
local littleDialogue     = require("littleDialogue")
local warpTransition     = require("warpTransition")
local extraNPCProperties = require("extraNPCProperties")
local pauseplus          = require("pauseplus")
local portalOpen         = require("portalOpen")
local portalOpen2        = require("portalOpen2")
local audiblette         = require("audiblette")
local particles          = require("particles")
local slm                = require("simpleLayerMovement")
local starcoin           = require("npcs/AI/starcoin")
local variableOverflow   = require("variableOverflow")
local respawnRooms       = require("respawnRooms")
local stats              = require("statsMisc")
local textplus           = require("textplus")

-- Floating Luigi head stuff (scrapped)

--local head = Graphics.loadImageResolved("LuigiHead.png");

local sprite
local v = vector.right2
v.x = 0.5
v.y = 0.5

local sprite1X = -200096
local sprite1Y = -200416

-- Unlocking the Audiblette and Conceptuary variables/questions
-- Variables can be found in variableOverflow.lua

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

local creditText = "No"
local audibletteText = "No"
local conceptuaryText = "No"

if SaveData.creditsSeen then
    creditText = "Yes"
end

if SaveData.conceptuaryUnlocked then
    conceptuaryText = "Yes"
end

if SaveData.audibletteUnlocked then
    audibletteText = "Yes"
end

-- Variables for Keyhole status in dialogue

local keyhole1FoundText = ""
local keyhole2FoundText = ""
local keyhole3FoundText = ""
local keyhole4FoundText = ""
local keyhole5FoundText = ""

if SaveData.keyhole1Found then
    keyhole1FoundText = " <color purple>(Found!)</color>"
end
if SaveData.keyhole2Found then
    keyhole2FoundText = " <color purple>(Found!)</color>"
end
if SaveData.keyhole3Found then
    keyhole3FoundText = " <color purple>(Found!)</color>"
end
if SaveData.keyhole4Found then
    keyhole4FoundText = " <color purple>(Found!)</color>"
end
if SaveData.keyhole5Found then
    keyhole5FoundText = " <color purple>(Found!)</color>"
end

-- For the question titled 'tangeroombaInitial', check the bottom of onTick() (it needs to be updated in realtime)

littleDialogue.registerAnswer("tangeroombaCompletion",{text = "Where are the keyholes?" ,addText = "Fine, just a few small hints! Think with your noggin! What could they mean?<br><br><color purple>1. </color>Good Hat, Bad Weather"..keyhole1FoundText.."<br><color purple>2. </color>A Shocking Discovery"..keyhole2FoundText.."<br><color purple>3. </color>Rodents Run Wild"..keyhole3FoundText.."<br><color purple>4. </color>Knowledge and Boos"..keyhole4FoundText.."<br><color purple>5. </color>Above Loose Dirt"..keyhole5FoundText.."<br><br>Now scram! I wasn't supposed to tell you any of that!<page>Actually, if you keep quiet, I can tell you a bit more...<question tangeroombaInitial>"})
littleDialogue.registerAnswer("tangeroombaCompletion",{text = "What are the challenges?",addText = "Challenges are optional criteria you can complete within memories just for the fun of it! Each one even has its own achievement! Which one would you like to view the criteria for?<question tangeroombaChallenge>"})
littleDialogue.registerAnswer("tangeroombaCompletion",{text = "Nevermind"               ,addText = "Alrighty, anything else then?<question tangeroombaInitial>"})

-- All intro-related variables + questions
-- Variables can be found in variableOverflow.lua

littleDialogue.registerAnswer("introQuestion",{text = "Let's do it!",addText = "HOORAY! Let's get this party started!",chosenFunction = function() startPortalSpawn = true end})
littleDialogue.registerAnswer("introQuestion",{text = "Stuck in my mind!",addText = "Aw, man. Well, if you change your mind. I'll be waiting here for eternity.",chosenFunction = function() talkedToBloomba = true end})
littleDialogue.registerAnswer("introQuestion2",{text = "I'm ready!",addText = "HOORAY! Let's get this party started!",chosenFunction = function() startPortalSpawn = true end})
littleDialogue.registerAnswer("introQuestion2",{text = "My mind is nicer!",addText = "Ugh, I guess I can't force you to do this. I am really bored, though."})

-- Other stuff that is relevant after progression

local maroonba2
local ceruloomba
local allMemoriesMsgMaroonba = "<speakerName Maroonba>Wowza! Would you look at that! You recovered every last one of those memories!<page>Well, actually, there are still plenty of them left unrecovered, but your amnesia was so strong that I'm fairly sure we'll never be able to find those, even inside the Realm of Recollection.<page>Ah, well, at least we tried, right? Maybe you should go talk to Ceruloomba now?"
local allMemoriesMsgCeruloomba = "<setPos 220 30 0.5 0><speakerName Ceruloomba>Huh? Oh, so you finally recovered 'em all, eh? About time! I feel like I'm two steps away from my grave at this point, and I'm immortal!<page>Anyways, now that you've done that, it's time for you to enter the 'Memory Amalgamation.'<page>Every person attempting to leave their consciousness has to do it! Think of this as a sort of... rite of passage.<page>So, whaddya think? You ready to take the plunge?<question enterAmalgamation>"

local mauvoomba
local emitConfetti = false
local allPurpleStarsMsg = "<speakerName Mauvoomba>Ah, Master Luigi! You've found all the Purple Stars! Magnificent!<page>Huh? What's that? Your reward?<page>Well, about that. There... isn't one.<page>I was told by the higher-ups to blame something called 'avoiding scope creep.'<page>Not sure what that means, though.<page>Regardless, we have to celebrate somehow! Here, check this out!"
local startConfettiTimer = false
local confettiTimer = 0

littleDialogue.registerAnswer("enterAmalgamation",{text = "I'm ready!",addText = "Don't screw up out there kid. Your future depends on it.",chosenFunction = function() Level.load("!Memory Amalgamation.lvlx") end})
littleDialogue.registerAnswer("enterAmalgamation",{text = "That sounds scary!",addText = "What a quitter! You should be ashamed of yourself, dimwit."})

littleDialogue.registerAnswer("enterAmalgamationAfterCredits",{text = "Let's do it!",addText = "Enjoy it kid. You earned this.",chosenFunction = function() Level.load("!Memory Amalgamation.lvlx") end})
littleDialogue.registerAnswer("enterAmalgamationAfterCredits",{text = "Not right now.",addText = "No worries. This time's just for fun anyway."})

local afterCreditsMsgCeruloomba = "<setPos 220 30 0.5 0><speakerName Ceruloomba>Hey kid. Sorry I was so rude to ya' before. Hopefully you can forgive me, I'm working through some stuff.<page>You did good out there in the Memory Amalgamation. If you'd like, I can send ya' through it again. Whaddya think?<question enterAmalgamationAfterCredits>"
local afterCreditsMsgMaroonba = "<speakerName Maroonba>So, you conquered the Memory Amalgamation? That's no small feat! Congratulations, Master Luigi!<page>There's still plenty to do here in the Realm of Recollection. Why don't you go talk to Tangeroomba and find out?"

local hundo = Graphics.loadImageResolved("hundo.png")
local hundoAlpha = 0
local hundoMsgMaroonba = "<speakerName Maroonba>Master Luigi! Look! Up in the sky! Who put those numbers there? Was that you?"

local glitchPortal
local section4Opacity = 0
local fade = false
local showGlitchPortal = false
local startGlitchPortalSequenceTimer = false
local glitchPortalSequenceTimer = 0
local greenBloomba
local mossMessage1 = "<speakerName Moss>I have nothing left to say to you. They took everything from me. Now, you must see what I deal with."
local mossMessage2 = "<speakerName Moss>I must admit. I underestimated you greatly. The fact that you faced your Repressed Memories and managed to recover them all is respectable.<page>You know, you are much better than them. They don't understand the work I endure.<page>But regardless, I am listening to them, and staying away. Just like they asked. They don't want to hear my side of the story."
local superLockPlayer = false

function getRepressedRecoveredCount()
    local list = {}
    for k,v in ipairs(stats.repressedLevelList) do
        if SaveData.levelStats[stats.repressedLevelList[k].filename] and SaveData.levelStats[stats.repressedLevelList[k].filename].beaten then
            table.insert(list, v)
        end
    end
    return list
end

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

local foundKeyhole = false
local keyholeTextTimer = 0

function onStart()
    superLockPlayer = true
    if GameData.inRepressedMemory then
        player:teleport(-119542, -120100, true)
        playMusic(-1) -- p-switch music (just used as a "placeholder")
        playMusic(player.section) -- actually restart the section's music
        GameData.inRepressedMemory = false
    end

    if #getRepressedRecoveredCount() >= 9 then
        SaveData.allRepressedMemoriesRecovered = true
    end

    -- Very janky keyhole achievement fix
    if GameData.exitedWithKeyhole then
        GameData.ach_AllKeyholes:setCondition(GameData.lastCondition,true)
        GameData.ach_HundredPercent:setCondition(4,math.max(SaveData.totalKeyholesFound, GameData.ach_HundredPercent:getCondition(4).value))
        GameData.exitedWithKeyhole = false

        foundKeyhole = true
    end

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

    -- 100% text in the sky

    hundo = Sprite.box{
        texture = hundo,
        x = -199880,
        y = -200568
    }

    -- A bunch of layers

    chuck             = Layer.get("chuck")
    originalSigns     = Layer.get("originalSigns")
    otherSigns        = Layer.get("otherSigns")
    portal            = Layer.get("portal")
    otherBloombas     = Layer.get("otherBloombas")
    maroonba          = Layer.get("maroonba")
    defaultBloombas   = Layer.get("defaultBloombas")
    conceptuaryWarp   = Layer.get("conceptuaryWarp")
    audibletteWarp    = Layer.get("audibletteWarp")
    audibletteLock    = Layer.get("audibletteLock")
    conceptuaryLock   = Layer.get("conceptuaryLock")
    audibletteNPC     = Layer.get("audibletteNPC")
    conceptuaryNPC    = Layer.get("conceptuaryNPC")
    glitchPortalCover = Layer.get("glitchPortalCover")

    -- Intro initializations

    if SaveData.introFinished == false then
        showAsleep = true
        portal:hide(true)
        maroonba:show(true)
        defaultBloombas:hide(true)
        pauseplus.canPause = false
    end

    if SaveData.basementFound then
        glitchPortalCover:hide(true)
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

function onLoadSection4()
    if SaveData.basementFound then
        glitchPortalCover:hide(true)
    end
end

function onTick()
    -- Check if intersected with boomobox

    for k,v in ipairs(BGO.getIntersecting(player.x, player.y, player.x + player.width, player.y + player.height)) do
        if v.id == 283 then
            local gfxHeight = NPC.config[v.id].gfxheight - v.height
            if gfxHeight < 0 then gfxHeight = 0 end
                
            local trueX = (v.x + 0.5 * v.width) - (0.5 * myIMG.width) 
            local trueY = (v.y - 8 - gfxHeight) - myIMG.height + 36

            Graphics.drawImageToSceneWP(myIMG, trueX, trueY, -30)

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

    -- Get NPC in the basement

    for _,v in ipairs(extraNPCProperties.getWithTag("greenBloomba")) do
        greenBloomba = v
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

    if SaveData.allMemoriesRecovered then
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

    if SaveData.allMemoriesRecovered and not SaveData.fullyComplete then
        if SaveData.creditsSeen then
            for _,v in ipairs(extraNPCProperties.getWithTag("defaultRedBloomba")) do
                v.msg = afterCreditsMsgMaroonba
            end
        else
            for _,v in ipairs(extraNPCProperties.getWithTag("defaultRedBloomba")) do
                v.msg = allMemoriesMsgMaroonba
            end
        end
    end

    if SaveData.fullyComplete then
        for _,v in ipairs(extraNPCProperties.getWithTag("defaultRedBloomba")) do
            v.msg = hundoMsgMaroonba
        end
    end

    if not emitConfetti and not startConfettiTimer and SaveData.allPurpleStarsFound then
		for _,v in ipairs(extraNPCProperties.getWithTag("mauvoomba")) do
            v.msg = allPurpleStarsMsg
        end
    end

    if SaveData.basementFound and not SaveData.allRepressedMemoriesRecovered then
        for _,v in ipairs(extraNPCProperties.getWithTag("greenBloomba")) do
            v.msg = mossMessage1
        end
    elseif SaveData.allRepressedMemoriesRecovered then
        for _,v in ipairs(extraNPCProperties.getWithTag("greenBloomba")) do
            v.msg = mossMessage2
        end
    end

    -- Chuck's Return Service Handling 
    -- (this was written a long time ago and is very bad but it functions so I'm keeping it)

    if launch then
        GameData.ach_Chuck:collect()
        timer = timer + 1
        player.speedX = -300000 -- this is absolute overkill but its funny
        player.speedY = -1.8
        if not triggered then
            -- Chuck is hidden to play the effect (effect-805.png)
            chuck:hide(true)
            -- I have to hide the signs containing messages because Lock Controls holds the UP button (this is the only place I do this anymore I know it's bad lol)
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

    -- Changes Text in Tangeroomba dialogue

    littleDialogue.deregisterQuestion("tangeroombaInitial")
    littleDialogue.deregisterQuestion("tangeroombaChallenge")

    if SaveData.creditsSeen then
        creditText = "Yes"
    end
    
    if SaveData.conceptuaryUnlocked then
        conceptuaryText = "Yes"
    end
    
    if SaveData.audibletteUnlocked then
        audibletteText = "Yes"
    end

    if SaveData.challenge1Completed then
        littleDialogue.registerAnswer("tangeroombaChallenge",{text = "Challenge #1 <color lightgreen>(Completed!)</color>",addText = "Let's see 'ere. Ah, there we go!<br><br><color purple>Challenge #1</color><br><br>Recover the memory 'Lightweight Library' in less than 2 minutes!<br><br>Wanna see another challenge?<question tangeroombaChallenge>"})
    else
        littleDialogue.registerAnswer("tangeroombaChallenge",{text = "Challenge #1",addText = "Let's see 'ere. Ah, there we go!<br><br><color purple>Challenge #1</color><br><br>Recover the memory 'Lightweight Library' in less than 2 minutes!<br><br>Wanna see another challenge?<question tangeroombaChallenge>"})
    end
    if SaveData.challenge2Completed then
        littleDialogue.registerAnswer("tangeroombaChallenge",{text = "Challenge #2 <color lightgreen>(Completed!)</color>",addText = "Let's see 'ere. Ah, there we go!<br><br><color purple>Challenge #2</color><br><br>Recover the memory 'Paddlewheel Peril' without touching a single coin!<br><br>Wanna see another challenge?<question tangeroombaChallenge>"})
    else
        littleDialogue.registerAnswer("tangeroombaChallenge",{text = "Challenge #2",addText = "Let's see 'ere. Ah, there we go!<br><br><color purple>Challenge #2</color><br><br>Recover the memory 'Paddlewheel Peril' without touching a single coin!<br><br>Wanna see another challenge?<question tangeroombaChallenge>"})
    end    
    if SaveData.challenge3Completed then
        littleDialogue.registerAnswer("tangeroombaChallenge",{text = "Challenge #3 <color lightgreen>(Completed!)</color>",addText = "Let's see 'ere. Ah, there we go!<br><br><color purple>Challenge #3</color><br><br>Recover the memory 'Swooper Drop Sneak' without ever facing left!<br><br>Wanna see another challenge?<question tangeroombaChallenge>"})
    else
        littleDialogue.registerAnswer("tangeroombaChallenge",{text = "Challenge #3",addText = "Let's see 'ere. Ah, there we go!<br><br><color purple>Challenge #3</color><br><br>Recover the memory 'Swooper Drop Sneak' without ever facing left!<br><br>Wanna see another challenge?<question tangeroombaChallenge>"})
    end
    if SaveData.challenge4Completed then
        littleDialogue.registerAnswer("tangeroombaChallenge",{text = "Challenge #4 <color lightgreen>(Completed!)</color>",addText = "Let's see 'ere. Ah, there we go!<br><br><color purple>Challenge #4</color><br><br>Recover the memory 'Clear Pipe Prairie' without taking damage AND without killing any enemies!<br><br>Wanna see another challenge?<question tangeroombaChallenge>"})
    else
        littleDialogue.registerAnswer("tangeroombaChallenge",{text = "Challenge #4",addText = "Let's see 'ere. Ah, there we go!<br><br><color purple>Challenge #4</color><br><br>Recover the memory 'Clear Pipe Prairie' without taking damage AND without killing any enemies!<br><br>Wanna see another challenge?<question tangeroombaChallenge>"})
    end
    if SaveData.challenge5Completed then
        littleDialogue.registerAnswer("tangeroombaChallenge",{text = "Challenge #5 <color lightgreen>(Completed!)</color>",addText = "Let's see 'ere. Ah, there we go!<br><br><color purple>Challenge #5</color><br><br>Recover the memory 'Super Sticky Swamp' in 30 jump button presses or less!<br><br>Wanna see another challenge?<question tangeroombaChallenge>"})
    else
        littleDialogue.registerAnswer("tangeroombaChallenge",{text = "Challenge #5",addText = "Let's see 'ere. Ah, there we go!<br><br><color purple>Challenge #5</color><br><br>Recover the memory 'Super Sticky Swamp' in 30 jump button presses or less!<br><br>Wanna see another challenge?<question tangeroombaChallenge>"})
    end
    littleDialogue.registerAnswer("tangeroombaChallenge",{text = "Nevermind",addText = "So, planning on taking on one of those challenges? I'm rootin' for ya'! Anything else you wanna know?<question tangeroombaInitial>"})

    littleDialogue.registerAnswer("tangeroombaInitial",{text = "What are Fragmented Memories?",addText = "Fragmented Memories are levels that had their design started, but weren't finished before the project's initial cancellation. For the most part, only the overarching mechanic of the level and its aesthetic had been established.<page>And to think some developers release stuff like this and then make you pay for the rest! Heh. What else can I tell ya' about?<question tangeroombaInitial>"})
    littleDialogue.registerAnswer("tangeroombaInitial",{text = "What is the Map of Memories?" ,addText = "The Map of Memories allows you to explore the world map of the project, which obviously was the originally intended method of traversing between levels in the game. The vast majority of the main island was completed, though completion/polish starts to taper off after launching into outer space, which was used to access the final few worlds of the game.<page>Sounds pretty useless, but a fun inclusion nonetheless! What else can I tell ya' about?<question tangeroombaInitial>"})
    littleDialogue.registerAnswer("tangeroombaInitial",{text = "What is The Conceptuary?"     ,addText = "The Conceptuary holds a collection of every piece of art, whether that be for concept or promotional purposes, created for the game. Most of them were created by galaxy, while the piece of art at the far end of the building was created by FurballArts.<page>I'm not really the type that stands around staring at art, but maybe it's your cup of tea? Can I inform you of anything else?<question tangeroombaInitial>"})
    littleDialogue.registerAnswer("tangeroombaInitial",{text = "What is The Audiblette?"      ,addText = "The Audiblette is a collection of every piece of unused music in the game. These can range from fully mixed and mastered tracks to very early renditions that never made it any further. The cool thing about this building is that playing a track inside will have it ring out throughout the entire Realm of Recollection!<page>I love me some tunes! I've heard The Audiblette has some great ones! What else can I tell ya' about?<question tangeroombaInitial>"})
    littleDialogue.registerAnswer("tangeroombaInitial",{text = "Know any secrets?"            ,addText = "I'm glad you asked! While the Realm of Recollection isn't the biggest area within your brain, it still has some stuff to hide. Apparently, it's rumored that another Bloomba lives somewhere within this realm. Based on what I've heard, they were exiled years and years ago for reasons unbeknownst to me. Unfortunately, I materialized long after this happened so I don't know much about the situation. Not that I'd recommend it, but perhaps you could find them?<page>Anything else ya' wanna know?<question tangeroombaInitial>"})
    if SaveData.fullyComplete then
        littleDialogue.registerAnswer("tangeroombaInitial",{text = "Check Completion Status"  ,addText = "Holy canoli! You've done it all, Master Luigi! I'm proud of ya', really!<br><br><color purple>Memories Recovered: </color>"..SaveData.totalMemoriesRecovered.."/17<br><color purple>Purple Stars Found: </color>"..SaveData.starcoins.."/43<br><color purple>Keyholes Found: </color>"..SaveData.totalKeyholesFound.."/5<br><color purple>Challenges Completed: </color>"..SaveData.totalChallengesCompleted.."/5<br><color purple>Audiblette Unlocked?: </color>"..audibletteText.."<br><color purple>Conceptuary Unlocked?: </color>"..conceptuaryText.."<br><color purple>Credits Seen?: </color>"..creditText.."<br><br>Can I tell ya' anything else?<question tangeroombaCompletion>"})
    else
        littleDialogue.registerAnswer("tangeroombaInitial",{text = "Check Completion Status"  ,addText = "Ah! You didn't strike me as a completionist! Take a look!<br><br><color purple>Memories Recovered: </color>"..SaveData.totalMemoriesRecovered.."/17<br><color purple>Purple Stars Found: </color>"..SaveData.starcoins.."/43<br><color purple>Keyholes Found: </color>"..SaveData.totalKeyholesFound.."/5<br><color purple>Challenges Completed: </color>"..SaveData.totalChallengesCompleted.."/5<br><color purple>Audiblette Unlocked?: </color>"..audibletteText.."<br><color purple>Conceptuary Unlocked?: </color>"..conceptuaryText.."<br><color purple>Credits Seen?: </color>"..creditText.."<br><br>Can I tell ya' anything else?<question tangeroombaCompletion>"})
    end
    littleDialogue.registerAnswer("tangeroombaInitial",{text = "Nevermind"})

    -- Basement sequence

    if startGlitchPortalReveal then
        Graphics.drawScreen{color = Color.black.. section4Opacity,priority = 6}
        if section4Opacity < 1 and not fade then
            section4Opacity = section4Opacity + 0.07
            player.speedX = 0
            lockPlayer = true
            SFX.play("glitchPortalFadeout.mp3")
        else
            showGlitchPortal = true
            fade = true
        end

        if fade and section4Opacity > 0 then
            section4Opacity = section4Opacity - 0.01
            player.x = -119552
            startGlitchPortalSequenceTimer = true
        end

        if startGlitchPortalSequenceTimer then
            glitchPortalSequenceTimer = glitchPortalSequenceTimer + 1

            if glitchPortalSequenceTimer == 90 then
                SFX.play("glitchPortalRevealed.mp3")
            end

            if glitchPortalSequenceTimer == 290 then
                littleDialogue.create{
                    text = "<speakerName Moss>I am called Moss. Remember the name when you experience all the memories you attempted to leave behind.",
                    pauses = true,
                    speakerObj = greenBloomba
                }
                SaveData.basementFound = true
                GameData.ach_Exiled:collect()
                lockPlayer = false
            end
        end
    end

    if showGlitchPortal then
        glitchPortalCover:hide(true)
    end
end

function onEvent(eventName)
    -- This spawns the chuck swinging his bat effect. The event doesn't trigger anywhere else anymore

    if eventName == "Lock Controls" then
        Effect.spawn(805,-158214,-160222)
    end
end

playerLockTimer = 0

-- Stuff for Audiblette speakers

local scale = 1
local raiseScale = true
local lowerScale = false

-- Exclamation Mark Image

local exclamation = Graphics.loadImageResolved("exclamation.png")
local touching = false

-- Alpha value for keyhole found text

local textAlpha = 1

function onDraw()
    -- For when a player enters this level after finding a keyhole

    if foundKeyhole then
        keyholeTextTimer = keyholeTextTimer + 1

        textplus.print{
            text = "You found a keyhole!",
            priority = 5,
            x = 12,
            y = 12,
            xscale = 2,
            yscale = 2,
            color = Color.black * textAlpha
        }
        textplus.print{
            text = "You found a keyhole!",
            priority = 5,
            x = 10,
            y = 10,
            xscale = 2,
            yscale = 2,
            color = Color.lightgreen * textAlpha
        }
        textplus.print{
            text = "<br>Keyholes Found: "..tostring(SaveData.totalKeyholesFound).."/5",
            priority = 5,
            x = 12,
            y = 12,
            xscale = 2,
            yscale = 2,
            color = Color.black * textAlpha
        }
        textplus.print{
            text = "<br>Keyholes Found: "..tostring(SaveData.totalKeyholesFound).."/5",
            priority = 5,
            x = 10,
            y = 10,
            xscale = 2,
            yscale = 2,
            color = Color.white * textAlpha
        }

        if keyholeTextTimer > 250 then
            if textAlpha > 0 then
                textAlpha = textAlpha - 0.01
            end
        end 
    end

    -- Exclamation marks over NPC heads with new dialogue

    for k,v in NPC.iterateIntersecting(player.x, player.y, player.x + player.width, player.y + player.height) do
        if (v.id == 760 or v.id == 759 or v.id == 758) and not v.isHidden then
            touching = true
        end
    end

    if #NPC.getIntersecting(player.x, player.y, player.x + player.width, player.y + player.height) == 0 then
        touching = false
    end

    for k,v in ipairs(NPC.get()) do
        -- Ceruloomba (after recovering all memories)
        if v.id == 760 and SaveData.allMemoriesRecovered and not SaveData.creditsSeen and not v.isHidden then
            local gfxHeight = NPC.config[v.id].gfxheight - v.height
            if gfxHeight < 0 then gfxHeight = 0 end
                
            local trueX = (v.x + 0.5 * v.width) - (0.5 * exclamation.width) 
            local trueY = (v.y - 8 - gfxHeight) - exclamation.height + 38

            if not touching then
                Graphics.drawImageToSceneWP(exclamation, trueX+4, trueY-38, -30)
            end
        end
        -- Mauvoomba (after collecting all purple stars)
        if v.id == 759 and SaveData.allPurpleStarsFound and not SaveData.seenPurpleStarReward and not v.isHidden then
            local gfxHeight = NPC.config[v.id].gfxheight - v.height
            if gfxHeight < 0 then gfxHeight = 0 end
                
            local trueX = (v.x + 0.5 * v.width) - (0.5 * exclamation.width) 
            local trueY = (v.y - 8 - gfxHeight) - exclamation.height + 38

            if not touching then
                Graphics.drawImageToSceneWP(exclamation, trueX+4, trueY-38, -30)
            end
        end
        -- Maroonba (after seeing the credits)
        if v.id == 758 and SaveData.creditsSeen and not SaveData.talkedToMaroonbaAfterCredits and not v.isHidden then
            local gfxHeight = NPC.config[v.id].gfxheight - v.height
            if gfxHeight < 0 then gfxHeight = 0 end
                
            local trueX = (v.x + 0.5 * v.width) - (0.5 * exclamation.width) 
            local trueY = (v.y - 8 - gfxHeight) - exclamation.height + 38

            if not touching then
                Graphics.drawImageToSceneWP(exclamation, trueX+4, trueY-38, -30)
            end
        end
    end

    -- Need to use this to prevent somehow dying in this level
    playerLockTimer = playerLockTimer + 1
    if playerLockTimer == 3 then
        superLockPlayer = false
    end
    if superLockPlayer then
        for k, v in pairs(player.rawKeys) do
            player.rawKeys[k] = false
        end
    end

    if SaveData.fullyComplete and hundo.isHidden then
        hundo:show(true)
    end

    -- Speakers

    local sine = 1 + math.abs(math.sin(lunatime.drawtick() * 0.07)) * 0.3

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

    local sine = -math.sin(lunatime.drawtick() * 0.03) * 4

    if SaveData.fullyComplete then
        hundo:draw{priority = -60, sceneCoords = true, color = Color.white..hundoAlpha}
        if hundoAlpha < 1 then
            hundoAlpha = hundoAlpha + 0.02
        end

        hundo.y = -200568 + sine
    end
end

function littleDialogue.onMessageBox(eventObj,text,playerObj,npcObj)
    checkCoins()
    
    boxObj = littleDialogue.create{
        text = text,
        speakerObj = npcObj or playerObj or player,
    }

    eventObj.cancelled = true
    
    if text == allPurpleStarsMsg and SaveData.allPurpleStarsFound then
        startConfettiTimer = true
        mauvoomba.msg = "<speakerName Mauvoomba>I could do this for hours!"
        SaveData.seenPurpleStarReward = true
    end

    if text == afterCreditsMsgMaroonba and SaveData.creditsSeen then
        SaveData.talkedToMaroonbaAfterCredits = true
    end

    if player.section == 4 and not SaveData.basementFound then
        startGlitchPortalReveal = true
    end
end

function onExitLevel()
    player.mount = 0
end