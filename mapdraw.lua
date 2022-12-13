local mapdraw = {}

local cam = Camera.get()[1]

local timer = {}
local currentframe = {}
local frames = {}
local framespeed = {}

local function Animate(n, frames2, framespeed2)
    frames[n] = frames2
    framespeed[n] = framespeed2
    timer[n] = timer[n] + 1            
    for i=0,(frames[n] - 1) do
        if timer[n] >= (framespeed[n] * i) and timer[n] < (framespeed[n] * (i + 1)) then
            currentframe[n] = i
        end
    end
    if timer[n] >= framespeed[n] * (frames[n]) then
        timer[n] = 0
    end
end

function mapdraw.Draw(atype, ind, aimage, resx, resy, priority, frames2, framespeed2, n, offsetx, offsety)
    local image = Graphics.loadImage(""..aimage..".png")
    if timer[n] == nil then
        timer[n] = 0
    end
    Animate(n, frames2, framespeed2)
    if offsetx == nil then
        offsetx = 0
    end
    if offsety == nil then
        offsety = 0
    end
    for index,t in ipairs(atype.get(ind)) do
        t.width = 0
        t.height = 0
        if t.isValid or t.visible then
            if (t.x - cam.x) == math.clamp((t.x - cam.x), 32, 736) and (t.y - cam.y) == math.clamp((t.y - cam.y), 64, 568) then
                Graphics.draw{
                    type = RTYPE_IMAGE,
                    image = image,
                    x = (t.x - cam.x) + offsetx,
                    y = (t.y - cam.y) + offsety,
                    priority = priority,
                    sourceX = 0,
                    sourceY = currentframe[n] * resy,
                    sourceWidth = resx,
                    sourceHeight = resy, 
                }
            end
        end
    end
end

return mapdraw
