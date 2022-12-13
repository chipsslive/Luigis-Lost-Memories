local clearPipeFix = {}

registerEvent(clearPipeFix, "onInputUpdate")

function clearPipeFix.onInputUpdate() 
    if player.speedX > 15 then
        player.keys.right = true
        Text.print("A",32,96)
    end
end

return clearPipeFix