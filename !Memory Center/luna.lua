local textplus = require("textplus")
local littleDialogue = require("littleDialogue")
local slm = require("simpleLayerMovement")
local handycam = require("handycam")
local autoscroll = require("autoscroll")

-- Used for waking up sequence
local start = false
local alpha = 0
local timer = 0
local drawFirstText = false
local levelBegins = false

-- Layers for MADELYN sequence
local powerButton
local button1
local doorLock

-- Layers for capsule sequence
local water
local capQuestion
local luigi
local sleepLuigi

-- Timers for MADELYN sequence
local mt1 = 0
local mt2 = 0
local mt3 = 0

local startmt1 = false
local startmt2 = false
local startmt3 = false

-- Locks the player inside the capsule

local lockPlayer = false

-- Variables for end of level fadeout

local fadeout = false
local opacity = 0
local musicFadeoutTimer = 64

-- Used to track splash SFX intervals
local splashTimer = 0

-- Camera for zoom in during capsule sequence
local c = handycam[1]

-- Need to draw darkness at custom priority

local darkness = require("darkness")

local darknessField = darkness.Create{
    falloff = darkness.falloff.DEFAULT,
    shadows = darkness.shadow.NONE,
    maxLights = 60,
    priorityType = darkness.priority.DISTANCE,
    bounds = nil,
    boundBlendLength = 64,
    section = -1,
    ambient = Color.fromHex(0x888888ff),
    priority = -5,
    distanceField = false,
    enabled = true
}

-- Message Box Variables

local m = littleDialogue.create{
    -- This is created just so there isn't a nil value
    text = "",
    uncontrollable = true,
    pauses = false,
    forcedPosX = 325,
    forcedPosY = 290,
    style = "smw",
    silentOpen = true,
    silent = true,
    settings = {priority = -40}
}

function onStart()
    player.powerup = 2
    GameData.cutscene = true

    -- Adding layers to variable
    powerButton = Layer.get("powerButton")
    button1 = Layer.get("Button1")
    doorLock = Layer.get("doorLock")
    doorUnlocked = Layer.get("doorUnlocked")
    water = Layer.get("water")
    capQuestion = Layer.get("capsuleQuestion")
    luigi = Layer.get("luigi")
    sleepLuigi = Layer.get("sleepLuigi")
end

-- Disable autostart on event "Start Everything" to disable intro JUMP sequence
function onEvent(eventName)
    if eventName == "Start Timer" then
        start = true
    end
end

local myLayerTimer = 0

-- Used to track splash SFX intervals
local splashTimer = 0

-- A function used for easing the camera during the capsule zoom in

function easeInOutQuad(x)
    local val = (-(math.cos(math.pi * x) - 1) / 2)
    return val
end

function onTick()
    -- Used for JUMP text at start of level
    timer = timer + 1

    if timer > 130 and start then
        drawFirstText = true
        if alpha < 1 then
            alpha = alpha + 0.01
        end
    end

    if levelBegins then
        if alpha > 0 then
            alpha = alpha - 0.01
        else
            alpha = 0
            drawFirstText = false
        end
    end

    -- Starts immediately after power button is pressed
    if startmt1 then
        mt1 = mt1 + 1
        if mt1 > 420 then
            button1:show(true) 
            startmt1 = false
            mt1 = 0
        end
    end

    -- Sequence of messages after pressing BUTTON 1

    if startmt2 then
        mt2 = mt2 + 1
        if mt2 == 490 then
            advanceMadelyn(m)
            madelyn3()
        end
        if mt2 == 900 then
            advanceMadelyn(m)
            madelyn4()
        end
        if mt2 == 1220 then
            advanceMadelyn(m)
            madelyn5()
        end
        if mt2 == 1520 then
            advanceMadelyn(m)
            madelyn6()
        end
        if mt2 == 2000 then
            advanceMadelyn(m)
            madelyn7()
        end
        if mt2 == 2350 then
            doorLock:hide(true)
            doorUnlocked:show(true)
            SFX.play("Sound1.ogg")
        end
    end

    -- Locks player after capsule is entered (it's a bit overkill I know lol)

    if lockPlayer then
        player.x = -159580
        player.y = -160220

        player.speedX = 0
        player.speedY = 0

        triggerEvent("Lock in place")
        player:mem(0x11E, FIELD_WORD, 0)
        player:setFrame(-50 * player.direction)
        luigi:show(true)
    end

    -- Starts immediately after capsule is entered

    if startmt3 then
        mt3 = mt3 + 1
        splashTimer = splashTimer + 1
        if splashTimer == 20 and mt3 < 480 then
            SFX.play("splash.ogg")
            splashTimer = 0
        end
        --[[if mt3 == 5 then
            c:transition{
                time = 8,
                ease = easeInOutQuad,
                zoom = 4,
                yOffset = -32
            }
        end]]
        if mt3 < 480 then
            myLayerTimer = myLayerTimer + 1

            water.speedY = math.cos(myLayerTimer/390)*-0.2
        else
            water.speedY = 0
        end
        if mt3 == 500 then
            luigi:hide(true)
            sleepLuigi:show(true)
        end
        if mt3 > 520 then
            fadeout = true
            if musicFadeoutTimer > 0 then
                musicFadeoutTimer = musicFadeoutTimer - 0.5
            end
            Audio.MusicVolume(musicFadeoutTimer)
        end
        if mt3 > 720 then
            Level.load("!The Realm of Recollection.lvlx")
        end
    end

    -- Fadeout at very end of level
    if fadeout then
        Graphics.drawScreen{color = Color.black.. opacity,priority = 6}
        if opacity < 1 then
            opacity = opacity + 0.005
        end
    end
end

function onDraw()
    -- Used to get rid of JUMP text at start of level
    if timer > 160 then
        if player.rawKeys.jump == KEYS_PRESSED then
            triggerEvent("Jump")
            levelBegins = true
            start = false
        end
    end

    -- Drawing of JUMP text
    if drawFirstText then
        textplus.print{
            x = -200725,
            y = -200102,
            text = "Press JUMP to wake up!",
            xscale = 2,
            yscale = 2,
            color = Color.black*alpha,
            priority = -26,
            sceneCoords = true
        }
        
        textplus.print{
            x = -200728,
            y = -200105,
            text = "Press JUMP to wake up!",
            xscale = 2,
            yscale = 2,
            color = Color.white*alpha,
            priority = -26,
            sceneCoords = true
        }

        textplus.print{
            x = -200728,
            y = -200105,
            text = "         JUMP",
            xscale = 2,
            yscale = 2,
            color = Color.yellow*alpha,
            priority = -26,
            sceneCoords = true
        }
    end
end

-- All Question Registering Below

-- Powering on MADELYN
littleDialogue.registerAnswer("powerOn",{text = "Yes",chosenFunction = function() powerButton:hide(true) autoscroll.lockScreen() madelyn1() startmt1 = true end})
littleDialogue.registerAnswer("powerOn",{text = "No"})

-- Advance 1
littleDialogue.registerAnswer("adv1",{text = "Yes",chosenFunction = function() advanceMadelyn(m) madelyn2() button1:hide(true) end})
littleDialogue.registerAnswer("adv1",{text = "No"})

-- Entering the Capsule
littleDialogue.registerAnswer("enterCapsule",{text = "Yes",chosenFunction = function() capsule() end})
littleDialogue.registerAnswer("enterCapsule",{text = "No"})

-- All MADELYN Rendering Below

function madelyn1()
    m = littleDialogue.create{
        text = "<color green>MADELYN<br>Powering on<delay 32>.<delay 32>.<delay 32>.<delay 32><br><br>Time since last<br>boot: 9854d,13h<br><br><delay 32>Press BUTTON 1<br>to advance.</color>",
        uncontrollable = true,
        pauses = false,
        forcedPosX = 355,
        forcedPosY = 300,
        style = "smw",
        silentOpen = true,
        settings = {priority = -40,}
    }
end

function madelyn2()
    startmt2 = true
    m = littleDialogue.create{
        text = "<color green>Detecting life<br>forms within set<br>vicinity<delay 32>.<delay 32>.<delay 32>.<delay 32><br><br>(1) found.<br><br>Identifying<delay 32>.<delay 32>.<delay 32>.<delay 32><br><br>Identified.</color>",
        uncontrollable = true,
        pauses = false,
        forcedPosX = 360,
        forcedPosY = 310,
        style = "smw",
        silentOpen = true,
        settings = {priority = -40}
    }
end

function madelyn3()
    m = littleDialogue.create{
        text = "<color green>Hello, Luigi. I<br>am MADELYN, but<br>my alias is an<br>acronym. Allow<br>me to display<br>it.</color>",
        uncontrollable = true,
        pauses = false,
        forcedPosX = 354,
        forcedPosY = 283,
        style = "smw",
        silentOpen = true,
        settings = {priority = -40}
    }
end

function madelyn4()
    m = littleDialogue.create{
        text = "<color green>Mind<br>Arrangement<br>Device<br>Enabling<br>Large<br>Yesterday<br>Networks</color>",
        uncontrollable = true,
        pauses = false,
        forcedPosX = 325,
        forcedPosY = 290,
        style = "smw",
        silentOpen = true,
        settings = {priority = -40}
    }
end

function madelyn5()
    m = littleDialogue.create{
        text = "<color green><align center>Yesterday<br>Network<br><br>is the technical<br>term for what<br>you humans call<delay 32><br><br>'Memories'</align></color>",
        uncontrollable = true,
        pauses = false,
        forcedPosX = 360,
        forcedPosY = 310,
        style = "smw",
        silentOpen = true,
        settings = {priority = -40}
    }
end

function madelyn6()
    m = littleDialogue.create{
        text = "<color green>My initial brain<br>scans show that<br>your Yesterday<br>Networks have<br>suffered serious<br>damage.<br><br>Luckily, I am<br>able to assist<br>you with this<br>issue.</color>",
        uncontrollable = true,
        pauses = false,
        forcedPosX = 360,
        forcedPosY = 325,
        style = "smw",
        silentOpen = true,
        settings = {priority = -40}
    }
end

function madelyn7()
    m = littleDialogue.create{
        text = "<color green>Please, proceed<br>through the door<br>on your right.<br><br>The capsule that<br>is inside may<br>prove useful to<br>you.</color>",
        uncontrollable = true,
        pauses = false,
        forcedPosX = 360,
        forcedPosY = 300,
        style = "smw",
        silentOpen = true,
        settings = {priority = -40},
    }
end

-- Gets rid of final text box on MADELYN screen as you enter the capsule room
function onLoadSection2()
    advanceMadelyn(m)
end

-- Triggered immediately after entering capsule
function capsule()
    capQuestion:hide(true)
    lockPlayer = true
    startmt3 = true
end

-- A function that is entirely unnecessary but I found easier to work with
function advanceMadelyn(m)
    m:progress()
end