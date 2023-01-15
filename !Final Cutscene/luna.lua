local customCamera   = require("customCamera")
local slm            = require("simpleLayerMovement")
local pauseplus      = require("pauseplus")
local warpTransition = require("warpTransition")
local littleDialogue = require("littleDialogue")
local textplus       = require("textplus")

warpTransition.levelStartTransition = warpTransition.TRANSITION_FADE
warpTransition.transitionSpeeds[warpTransition.TRANSITION_FADE] = 200

local alpha = 0.3
local zoomout = false
local timer = 0
local pauseTimer = false
local dialogue

function onStart()
    GameData.cutscene = true
    pauseplus.canPause = false

    slm.addLayer{name = "Float 1",speed = 96,verticalMovement = slm.MOVEMENT_COSINE,verticalSpeed = 76,verticalDistance = 0.1}
    slm.addLayer{name = "Float 2",speed = 96,verticalMovement = slm.MOVEMENT_COSINE,verticalSpeed = 76,verticalDistance = -0.1}
end

function onTick()
    for k, v in pairs(player.keys) do
        player.keys[k] = false
    end
    
    if not pauseTimer then
        timer = timer + 1
    end

    if timer == 280 then
        pauseTimer = true
        timer = 281
        dialogue = littleDialogue.create{
            text = "<boxStyle madelyn>Greetings, Luigi. As you may notice from your surroundings, a catastrophic event has occured.<page>My home system was destroyed in the process. I am speaking to you via a remote backup server.<page>At some point during your endeavor inside the consciousness, this planet suffered a violent attack from Wart.<page>While I am aware that your mission was to travel to the Cyber Metropolis and confront him, I strongly advise against doing so.<page>Throughout your time in that capsule, his power has only grown, and his next movements continue to be unpredictable.<page>It is in your best interest to retreat to the Mushroom Kingdom immediately.<page>In your current state, the chance of death is extremely high, and without a ship to travel with, that chance increases tenfold.<page>I am not programmed to show sympathy, but if I was, I would feel quite sorry for you.<page>In the words of my creator:<br><br>You can't win 'em all.<page>Farewell, Luigi.",
            pauses = false,
            silentOpen = true
        }
    end

    if timer == 281 and dialogue.state == littleDialogue.BOX_STATE.REMOVE then
        pauseTimer = false
    end

    if timer == 350 then
        SFX.play("heartbeat.mp3")
        triggerEvent("Change Background 1")
        zoomout = true
    end

    if timer == 500 then
        SFX.play("heartbeat.mp3")
    end

    if timer == 760 then
        Level.load("!Title Screen.lvlx")
    end
end

function onExitLevel()
    GameData.cutscene = false
    SaveData.creditsSeen = true
end

function onDraw()
    if timer < 250 then
        player:setFrame(49 * player.direction)
    else
        player:setFrame(15 * player.direction)
    end

    if timer < 500 then
        Graphics.drawScreen{
            width = 10000,
            height = 10000,
            color = Color.black..alpha
        }
    else
        Graphics.drawScreen{
            width = 10000,
            height = 10000,
            color = Color.black
        }
        textplus.print{
            x = 195,
            y = 285,
            text = "Not all adventures end how you wanted them to.",
            xscale = 2,
            yscale = 2,
            color = Color.white,
            priority = 10,
        }

        if not musicSeized then
            Audio.SeizeStream(-1)
            musicSeized = true
        end
        Audio.MusicStop()
    end

    if zoomout then
        customCamera.defaultZoom = 0.5
    end
end