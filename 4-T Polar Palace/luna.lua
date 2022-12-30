function onStart()
    GameData.awardCoins = false
end

function onExitLevel()
    GameData.awardCoins = true
end