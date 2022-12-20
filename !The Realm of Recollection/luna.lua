local littleDialogue = require("littleDialogue")

local head = Graphics.loadImageResolved("LuigiHead.png");

local currentRotation = 0
local sprite
local v = vector.right2
v.x = 0.5
v.y = 0.5

local initialX = 100
local initialY = 620

local x = 100
local y = -10

local launch = false
local triggered = false
local timer = 0

local chuck
littleDialogue.registerAnswer("chuckQuestion",{text = "Yeah!",chosenFunction = function() launch = true end})
littleDialogue.registerAnswer("chuckQuestion",{text = "Not Yet!"})

function onStart()
    player.powerup = 2
    sprite = Sprite.box{
        texture = head,
        x = x,
        y = y,
        pivot = v,
    }

    chuck = Layer.get("chuck")
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
            triggerEvent("Lock Controls")
            triggered = true
        end
        if timer == 7 then
            SFX.play(9)
        end
        if timer > 100 then
            launch = false
            triggered = false
            timer = 0
            triggerEvent("Unlock Controls")
            chuck:show(true)
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