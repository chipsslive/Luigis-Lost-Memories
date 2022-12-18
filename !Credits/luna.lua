local textplus = require("textplus")
local pauseplus = require("pauseplus")
local autoscroll = require("autoscroll")
local slm = require("simpleLayerMovement")
local lineguide = require("lineguide")

lineguide.registerNPCs(10)
lineguide.properties[10] = {
        lineSpeed = 1,
    }

slm.addLayer{name = "coin 1",speed = 96,verticalMovement = slm.MOVEMENT_COSINE,verticalSpeed = 64,verticalDistance = 0.2}
slm.addLayer{name = "coin 2",speed = 96,verticalMovement = slm.MOVEMENT_COSINE,verticalSpeed = 64,verticalDistance = 0.4}
slm.addLayer{name = "coin 3",speed = 96,verticalMovement = slm.MOVEMENT_COSINE,verticalSpeed = 64,verticalDistance = 0.6}
slm.addLayer{name = "coin 4",speed = 96,verticalMovement = slm.MOVEMENT_COSINE,verticalSpeed = 64,verticalDistance = 0.8}
slm.addLayer{name = "coin 5",speed = 96,verticalMovement = slm.MOVEMENT_COSINE,verticalSpeed = 64,verticalDistance = 1}

local creditsFinished = false
local textLayouts = {}
local scrollY = 600
local alpha = 0

pauseplus.canPause = false

local fonts = {
    [0] = textplus.loadFont("textplus/font/11.ini"),
    [1] = textplus.loadFont("bigFont.ini"),
}

local text = {
    1,"LUIGIS LOST MEMORIES",
    0,"",
    0,"",
    0,"",
    1,"LEAD DEVELOPER",
    0,"",
    0,"Chipss",
    0,"",
    1,"LEVEL DESIGNERS",
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
    0,"Witchking666",
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
    0,"SilverDeoxys563",
    0,"Marina",
    0,"Elbow",
    0,"PROX",
    0,"AxelVoss",
    0,"",
    1,"MUSIC",
    0,"",
    0,"Red&Green",
    0,"@Rewitkin",
    0,"galaxy",
    0,"Punji",
    0,"leitakcoc",
    0,"JerryCoxalot",
    0,"Eric Matyas",
    0,"Moose",
    0,"HaruMKT",
    0,"Shady Cicada",
    0,"Newer Team",
    0,"Nintendo",
    0,"Westfall Studios",
    0,"Square Enix",
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
    0,"",
    1,"BETA TESTING",
    0,"",
    0,"Launchstar",
    0,"galaxy",
    0,"Ruben",
    0,"Chipss"
}

local final = "THANKS FOR PLAYING!"
local layout2

function onStart()
    autoscroll.scrollRight(0.5)
    GameData.cutscene = true

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

    layout2 = textplus.layout(final,nil,{font = fonts[1],color = white,xscale = 4,yscale = 4})
end

function onDraw()
    local layout = textLayouts[0]

    local y = scrollY

    for _,layout in ipairs(textLayouts) do
        textplus.render{layout = layout,priority = 6,x = 250,y=y}

        y = y + layout.height + 4
    end

    if creditsFinished then
        textplus.render{layout = layout2, color = Color.white * alpha, priority = -1,x = 120,y=250}
    end
end

local noStop = true

function onTick()
    exitState = Level.winState() > 0

    scrollY = scrollY - 0.51

    if creditsFinished then
        if alpha < 1 and noStop then
            alpha = alpha + 0.01
        end
    end
end