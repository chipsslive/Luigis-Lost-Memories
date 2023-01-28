local textplus       = require("textplus")
local pauseplus      = require("pauseplus")
local autoscroll     = require("autoscroll")
local slm            = require("simpleLayerMovement")
local lineguide      = require("lineguide")
local spawnzones     = require("spawnzones")
local dropShadows    = require("dropShadows")
local warpTransition = require("warpTransition")

warpTransition.levelStartTransition = warpTransition.TRANSITION_FADE
warpTransition.transitionSpeeds[warpTransition.TRANSITION_FADE] = 150

-- There are two variants of coins used in the level, so only register 1 to lineguides

lineguide.registerNpcs(10)
lineguide.properties[10] = {lineSpeed = 1}

-- 'Jump rope' coin movement effect    

slm.addLayer{name = "coin 1",speed = 96,verticalMovement = slm.MOVEMENT_COSINE,verticalSpeed = 64,verticalDistance = 0.2}
slm.addLayer{name = "coin 2",speed = 96,verticalMovement = slm.MOVEMENT_COSINE,verticalSpeed = 64,verticalDistance = 0.4}
slm.addLayer{name = "coin 3",speed = 96,verticalMovement = slm.MOVEMENT_COSINE,verticalSpeed = 64,verticalDistance = 0.6}

-- A bunch of initilization for text stuff

local creditsFinished = false
local textLayouts = {}
local scrollY = 600
local alpha = 0
local timer = 0
local opacity = 0

-- Game logo

local logo = Graphics.loadImageResolved("logo.png")

pauseplus.canPause = false

local fonts = {
    [0] = textplus.loadFont("pauseFont.ini"),
    [1] = textplus.loadFont("MKDS.ini"),
}

local text = {
    1,"LUIGI'S LOST MEMORIES",
    0,"",
    0,"",
    0,"",
    1,"LEAD DEVELOPER",
    0,"",
    0,"Chipss",
    0,"",
    1,"LEVEL DESIGN",
    0,"",
    0,"Chipss",
    0,"Achy",
    0,"",
    1,"GRAPHICS",
    0,"",
    0,"Achy",
    0,"Mr. Greenman",
    0,"Vito",
    0,"PsychLantern (Digo)",
    0,"galaxy",
    0,"FurballArts",
    0,"leitakcoc",
    0,"DDP",
    0,"Chipss",
    0,"BlueKecleon15",
    0,"Enjl",
    0,"Mariofan230",
    0,"Mr. Pixelator",
    0,"Valterri",
    0,"AirShip/AirSheep",
    0,"SleepyVA",
    0,"Natsu",
    0,"Squishy Rex",
    0,"FireSeraphim",
    0,"Wonolf",
    0,"Void",
    0,"Gate/Gatete",
    0,"Marina",
    0,"Elbow",
    0,"AxelVoss",
    0,"",
    1,"MUSIC",
    0,"",
    0,"Red&Green",
    0,"@Rewitkin",
    0,"galaxy",
    0,"Noodle",
    0,"Punji",
    0,"leitakcoc",
    0,"JerryCoxalot",
    0,"Eric Matyas",
    0,"Moose",
    0,"HaruMKT",
    0,"Shady Cicada",
    0,"Izuna",
    0,"Dippy",
    0,"Newer Team",
    0,"Nintendo",
    0,"SEGA",
    0,"Westfall Studios",
    0,"Square Enix",
    0,"OMOCAT",
    0,"VLDC",
    0,"Shining Gate Software",
    0,"",
    1,"SCRIPTING",
    0,"",
    0,"MrDoubleA",
    0,"IAmPlayer",
    0,"Vito",
    0,"Chipss",
    0,"AndrewPixel",
    0,"8luestorm",
    0,"Enjl",
    0,"KBM-Quine",
    0,"SetaYoshi",
    0,"Sambo",
    0,"JustOneMGuy",
    0,"Marioman2007",
    0,"Hoeloe",
    0,"EeveeEuphoria",
    0,"",
    1,"TESTING",
    0,"",
    0,"Launchstar",
    0,"galaxy",
    0,"leitakcoc",
    0,"tg online",
    0,"Vito"
}

local final = "Thank you for playing!"
local final2 = "<align center>Luigi's Lost Memories<br>Development Team</align>"
local layout2
local layout3
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

local bloombaX = -199800
local bloombaY = -200400

local bloombaXRed = -198200
local bloombaYRed = -200560

local bloombaXBlue = 0
local bloombaYBlue = 0

local bloombaXPurple = -197280
local bloombaYPurple = -199728

-- Animation at end of level

local endingStart
local endingLoop

local endingStartImg = Graphics.loadImageResolved("endingStart.png")
local endingLoopImg = Graphics.loadImageResolved("endingLoop.png")

function onStart()
    endingStart = Sprite.box{
        texture = endingStartImg,
        frames = 38,
        x = -197216,
        y = -200600
    }

    endingLoop = Sprite.box{
        texture = endingLoopImg,
        frames = 8,
        x = -197216,
        y = -200600
    }

    autoscroll.scrollRight(0.5)
    player.powerup = 2
    GameData.cutscene = true

    -- Give all text table entries a layout and font

    for i = 1,#text,2 do
        local fontID = text[i]
        local font = fonts[fontID]
        local text = text[i+1]

        if text == "" then
            text = " "
        end

        local layout = textplus.layout(text,nil,{font = font,color = white,xscale = 2,yscale = 2})

        table.insert(textLayouts,layout)
    end

    -- Layout for ending text

    layout2 = textplus.layout(final,nil,{font = fonts[0],color = white,xscale = 2,yscale = 2})
    layout3 = textplus.layout(final2,nil,{font = fonts[0],color = white,xscale = 2,yscale = 2})

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
    timer = timer + 1
    scrollY = scrollY - 0.57
    
    -- Triggers roughly 4 beats after the last note of the song

    if timer == 4960 then
        creditsFinished = true
        SFX.play("reveal.mp3")
    end

    if creditsFinished then
        if alpha < 1 then
            alpha = alpha + 0.02
        end
    end

    -- Keeps janky autoscroll clipping from happening and prevents softlock/player death

    if player:mem(0x148, FIELD_WORD) > 0 and player:mem(0x14C, FIELD_WORD) > 0 then
        player.y = player.y - 2
    end

    -- Bloomba movement properties

    bloombaX = bloombaX + 0.2
    bloombaY = bloombaY - 0.2

    bloombaXRed = bloombaXRed - 0.2
    bloombaYRed = bloombaYRed + 0.25

    bloombaXPurple = bloombaXPurple - 0.2
    bloombaYPurple = bloombaYPurple - 0.25
end

local curFrameStart = 1
local curFrameLoop = 1

local frameTimerStart = 0
local frameTimerLoop = 0

local finalOpacity = 0

function onDraw()
    -- Setup and draw credits text

    local layout = textLayouts[0]

    local y = scrollY

    for _,layout in ipairs(textLayouts) do
        textplus.render{layout = layout,priority = 6,x = 400 - layout.width*0.5,y=y}

        y = y + layout.height + 4
    end

    -- Render Game Logo

    if creditsFinished then
        Graphics.drawImageWP(logo, 110, 140, alpha, 6)

        if not musicSeized then
            Audio.SeizeStream(-1)
            musicSeized = true
        end
        Audio.MusicStop()

        if timer >= 5500 then
            -- Fadeout at very end of level
            Graphics.drawScreen{color = Color.black.. opacity,priority = 7}
            if opacity < 1 then
                opacity = opacity + 0.005
            else
                endingStart:draw{priority = 7.5, sceneCoords = true, frame = curFrameStart}

                frameTimerStart = frameTimerStart + 1

                if frameTimerStart == 6 then
                    curFrameStart = curFrameStart + 1
                    frameTimerStart = 0
                end

                if curFrameStart == 24 and frameTimerStart == 0 then
                    SFX.play("lightOn.mp3")
                end

                if curFrameStart == 30 and frameTimerStart == 0 then
                    SFX.play("endOfCredits.wav")
                end

                if curFrameStart >= 38 then
                    endingLoop:draw{priority = 7.6, sceneCoords = true, frame = curFrameLoop}
                    frameTimerLoop = frameTimerLoop + 1
                    if frameTimerLoop == 8 then
                        curFrameLoop = curFrameLoop + 1
                        frameTimerLoop = 0
                    end
            
                    if curFrameLoop > 8 then
                        curFrameLoop = 1
                    end

                    if alpha2 < 1 then
                        alpha2 = alpha2 + 0.01
                    end
                    
                    textplus.render{layout = layout2, color = Color.white * alpha2, priority = 8,x = 200,y=180}
                    textplus.render{layout = layout3, color = Color.white * alpha2, priority = 8,x = 200,y=380}
                end
            end
        end

        if timer > 6300 then
            Graphics.drawScreen{color = Color.black.. finalOpacity, priority = 10}

            if finalOpacity < 1.1 then
                finalOpacity = finalOpacity + 0.01
            else
                Level.load("!Final Cutscene.lvlx")
            end
        end
    end

    -- Draw and rotate floating Bloomba sprites

    spriteOrange:draw{priority = -99, sceneCoords = true}
    spriteOrange:rotate(0.7)
    spriteOrange.x = bloombaX
    spriteOrange.y = bloombaY

    spriteRed:draw{priority = -99, sceneCoords = true}
    spriteRed:rotate(0.7)
    spriteRed.x = bloombaXRed
    spriteRed.y = bloombaYRed

    spritePurple:draw{priority = -99, sceneCoords = true}
    spritePurple:rotate(0.7)
    spritePurple.x = bloombaXPurple
    spritePurple.y = bloombaYPurple
end