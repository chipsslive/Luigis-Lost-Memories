--[[

    dropShadows.lua
    by MrDoubleA

]]

local dropShadows = {}


-- How opaque the drop shadows are, from 0 to 1.
dropShadows.opacity = 0.4
-- How far away the drop shadows are from their casters.
dropShadows.distance = 2

-- The maximum priority that is affected by the drop shadows.
dropShadows.frontPriority = 7
-- The priority that separates the background from the foreground.
dropShadows.backPriority = 5



local backBuffer = Graphics.CaptureBuffer(800,600)
local frontBuffer = Graphics.CaptureBuffer(800,600)

local dropShadowsShader = Shader()
dropShadowsShader:compileFromFile(nil,"dropShadows.frag")


function dropShadows.onCameraDraw(camIdx)
    local c = Camera(camIdx)

    backBuffer:captureAt(dropShadows.backPriority)
    frontBuffer:captureAt(dropShadows.frontPriority)

    Graphics.drawScreen{
        priority = dropShadows.frontPriority,shader = dropShadowsShader,uniforms = {
            backBuffer = backBuffer,frontBuffer = frontBuffer,
            cameraSize = vector(c.width,c.height),

            shadowOpacity = dropShadows.opacity,
            shadowDistance = dropShadows.distance,
        },
    }
end


function dropShadows.onInitAPI()
    registerEvent(dropShadows,"onCameraDraw")
end


return dropShadows