local textplus = require("textplus")

-- Used for waking up sequence
local start = false
local alpha = 0
local timer = 0
local drawFirstText = false
local levelBegins = false

-- Layers for MADELYN sequence
local powerButton
local cameraBounds
local button1

-- Timers for MADELYN sequence
local mt1 = 0
local mt2 = 0

local startmt1 = false
local startmt2 = false

-- Message Box Variables

local m

function onStart()
    player.powerup = 2

    powerButton = Layer.get("powerButton")
    cameraBounds = Layer.get("camerabounds")
    button1 = Layer.get("Button1")
end

function onEvent(eventName)
    if eventName == "Start Timer" then
        start = true
    end
end

function onTick()
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

    if startmt1 then
        mt1 = mt1 + 1
        if mt1 > 420 then
            button1:show(true) 
        end
    end

    if startmt2 then
        mt2 = mt2 + 1
        if mt2 == 480 then
            advanceMadelyn(m)
            madelyn3()
        end
    end
end

function onDraw()
    if timer > 160 then
        if player.rawKeys.jump == KEYS_PRESSED then
            triggerEvent("Jump")
            levelBegins = true
            start = false
        end
    end

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

local littleDialogue = require("littleDialogue")

-- Powering on MADELYN
littleDialogue.registerAnswer("powerOn",{text = "Yes",chosenFunction = function() powerButton:hide(true) cameraBounds:show(true) madelyn3() startmt1 = true end})
littleDialogue.registerAnswer("powerOn",{text = "No"})

-- Advance 1
littleDialogue.registerAnswer("adv1",{text = "Yes",chosenFunction = function() advanceMadelyn(m) madelyn2() button1:hide(true) end})
littleDialogue.registerAnswer("adv1",{text = "No"})

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
        forcedPosX = 360,
        forcedPosY = 310,
        style = "smw",
        silentOpen = true,
        settings = {priority = -40}
    }
end

function madelyn4()
    m = littleDialogue.create{
        text = "<color green>Memory<br>Arrangement<br>Device<br></color>",
        uncontrollable = true,
        pauses = false,
        forcedPosX = 360,
        forcedPosY = 310,
        style = "smw",
        silentOpen = true,
        settings = {priority = -40}
    }
end

function advanceMadelyn(m)
    m:progress()
end
