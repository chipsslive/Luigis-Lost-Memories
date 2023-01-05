local clearPipeFix = {}

registerEvent(clearPipeFix, "onInputUpdate")

function clearPipeFix.onInputUpdate() 
    if player.speedX > 15 then
        player.keys.right = true
    end
end

return clearPipeFix