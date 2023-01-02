local bloombaRed = Graphics.loadImage("bloombaRed.png")
local bloombaOrange = Graphics.loadImage("bloombaOrange.png")
local bloombaBlue = Graphics.loadImage("bloombaBlue.png")
local bloombaPurple = Graphics.loadImage("bloombaPurple.png")

local redX = 330
local redY = 300

local orangeX = 364
local orangeY = 300

local blueX = 398
local blueY = 300

local purpleX = 432
local purpleY = 300

local timer = 0
local movementTimerRed = 0
local movementTimerOrange = 0
local movementTimerBlue = 0
local movementTimerPurple = 0

local opacity = 0

function onDraw()
    if bloombaRed == nil or bloombaOrange == nil or bloombaBlue == nil or bloombaPurple == nil then
        return
    end

    Graphics.drawImage(bloombaRed, redX, redY, opacity)
    Graphics.drawImage(bloombaOrange, blueX, blueY, opacity)
    Graphics.drawImage(bloombaBlue, orangeX, orangeY, opacity)
    Graphics.drawImage(bloombaPurple, purpleX, purpleY, opacity)

    if opacity < 1 then
        opacity = opacity + 0.02
    end

    redY = math.cos(0.1 * movementTimerRed)*3 + 300
    
    if timer > 20 then
        orangeY = math.cos(0.1 * movementTimerOrange)*3 + 300
        movementTimerOrange = movementTimerOrange + 1
    end
    if timer > 40 then
        blueY = math.cos(0.1 * movementTimerBlue)*3 + 300
        movementTimerBlue = movementTimerBlue + 1
    end
    if timer > 60 then
        purpleY = math.cos(0.1 * movementTimerPurple)*3 + 300
        movementTimerPurple = movementTimerPurple + 1
    end

    timer = timer + 1
    movementTimerRed = movementTimerRed + 1
end