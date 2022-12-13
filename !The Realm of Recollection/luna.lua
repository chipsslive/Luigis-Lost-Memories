local head = Graphics.loadImageResolved("LuigiHead.png");

local currentRotation = 0
local sprite
local v = vector.right2
v.x=0.5
v.y=0.5

local initialX = 100
local initialY = 620

local x = 100
local y = -10

function onStart()
    sprite = Sprite.box{
        texture = head,
        x = x,
        y = y,
        pivot = v,
    }
end

function onTick()
    x = x + 0.2
    y = y - 0.2

    if y < -20 then
        y = initialY
        x = initialX
    end
end

function onDraw()
	sprite:draw{priority = -99.1}
    sprite:rotate(0.7)
    sprite.x = x
    sprite.y = y
end