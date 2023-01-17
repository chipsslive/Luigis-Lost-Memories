--[[
    by Marioman2007 for Luigi's Lost Memories
    NOT TO BE USED WITHOUT PERMISSION!
]]

local textplus = require("textplus")

local stats = {}

stats.LVL_LOST = 1
stats.LVL_FRAG = 2
stats.LVL_ALT  = 3
stats.LVL_MAP  = 4

stats.CON_START_LVL = 1
stats.CON_START_MAP = 2
stats.CON_UNLOCK    = 3

SaveData.spentStars   = SaveData.spentStars or 0
SaveData.unlockedTabs = SaveData.unlockedTabs or {[stats.LVL_LOST] = true, [stats.LVL_FRAG] = false, [stats.LVL_ALT] = false, [stats.LVL_MAP] = false}
SaveData.levelStats   = SaveData.levelStats or {}
SaveData.levelStats[Level.filename()] = SaveData.levelStats[Level.filename()] or {beaten = false, timer = 0, bestTime = -1}

stats.font      = textplus.loadFont("portalFont.ini")
stats.fontGreen = textplus.loadFont("portalFontGreen.ini")
stats.fontRed = textplus.loadFont("portalFontRed.ini")
stats.smallFont = textplus.loadFont("textplus/font/4.ini")
stats.listOffsetX   = 36
stats.listOffsetY   = 28
stats.leastPriority = 6
stats.timerPriority = 5.9
stats.displayBestTime = false
stats.displayTimer    = false

stats.movement = {}
stats.movement.title   = {type = 0, position =   -4, origin =   -4, goal =  18, speed =  1.5}
stats.movement.tabs    = {type = 0, position = -213, origin = -213, goal =  12, speed =  15}
stats.movement.list    = {type = 0, position =  346, origin =  346, goal = 124, speed = -15}
stats.movement.details = {type = 0, position =  660, origin =  660, goal = 540, speed = -8}

-- Audiblette stuff
stats.movement.audibletteTitle = {type = 0, position = -4, origin = -4, goal = 18, speed = 1.5}
stats.movement.trackList       = {type = 0, position = -4, origin = -4, goal = 18, speed = 1.5}
stats.movement.currentTrack    = {type = 0, position = 18, origin = 18, goal = -4, speed = 1.5}

stats.unusedMusic = {
    {filename = "unusedMusic/Noodle - Boss Jingle.ogg",                name = "Boss Jingle",              artist = "Noodle"},
    {filename = "unusedMusic/Noodle - Boss Theme.ogg",                 name = "Boss Theme",               artist = "Noodle"},
    {filename = "unusedMusic/Noodle - Unfinished Trailer Theme.ogg",   name = "Unfinished Trailer Theme", artist = "Noodle"},
    {filename = "unusedMusic/Noodle - Victory Jingle.ogg",             name = "Victory Jingle",           artist = "Noodle"},
    {filename = "unusedMusic/Noodle - NewerSMBWii Castle Remix.ogg",   name = "NewerSMBWii Castle Remix", artist = "Noodle"},
    {filename = "unusedMusic/Noodle - SMM2 SMB1 Forest Remix.ogg",     name = "SMM2 SMB1 Forest Remix",   artist = "Noodle"},
    {filename = "unusedMusic/galaxy - Chainlink Charge Remix.ogg",     name = "Chainlink Charge Remix",   artist = "galaxy"},
    {filename = "unusedMusic/galaxy - Island Athletic.ogg",            name = "Island Athletic",          artist = "galaxy"},
    {filename = "unusedMusic/galaxy - Space Junk Galaxy Remix.ogg",    name = "Space Junk Galaxy Remix",  artist = "galaxy"},
    {filename = "unusedMusic/JerryCoxalot - Haunted Desert Theme.mp3", name = "Haunted Desert Theme",     artist = "JerryCoxalot"},
    {filename = "unusedMusic/leitakcoc - Desert Theme.mp3",            name = "Desert Theme",             artist = "leitakcoc"},
}

stats.notEnough = "You need more Purple Stars to access this sector of memory recovery."
stats.pressJump = "Press JUMP to activate this sector of memory recovery!"
stats.locked    = "Unlock to see the details."

stats.confText    = {
    [stats.CON_START_LVL] = "Begin recovery of this memory?",
    [stats.CON_START_MAP] = "Begin exploring the Map of Memories?",
}

function stats.spendStars(n)
    return "Are you sure?<br>This action costs<br>"..tostring(n).." Purple Stars."
end

stats.flashColor = Color.black
stats.waitPriority = 100
stats.waitTime = 32

stats.tabDetails   = {
    [stats.LVL_LOST] = {starsNeeded =  0, text = ""},
    [stats.LVL_FRAG] = {starsNeeded =  10, text = "We tried our absolute hardest, but only partial fragments of these memories could be made available for recovery."},
    [stats.LVL_ALT]  = {starsNeeded =  15, text = "We intercepted these memories as they were floating around other areas of your consciousness. They don't seem related..."},
    [stats.LVL_MAP]  = {starsNeeded =  20, text = "Hmm, this memory is very different from the others. It's going to require quite a bit more star power to access than usual."},
}

stats.mapImg  = Graphics.loadImageResolved("pastPortal/map.png")
stats.mapImg2 = Graphics.loadImageResolved("pastPortal/map2.png")
stats.mapDescription = "While Luigi can't remember a large part of his adventure, the breathtaking sights of the island he visited were more than enough to bypass the effects of amnesia!"

stats.levelList = {
    {filename = "1-1 Clear Pipe Prairie.lvlx"       , name = "Clear Pipe Prairie",   type = stats.LVL_LOST,  description = "Rogue Chucks have teamed up with the Fuzzies and set up base in the prairie! Watch out for spherical projectiles!"},
    {filename = "1-2 Spring Showers.lvlx"           , name = "Spring Showers",       type = stats.LVL_LOST,  description = "Their hats either hide helpful springs or hurtful spikes. Make sure you're paying attention, even in the rain!  "},
    {filename = "1-T High Wattage Warehouse.lvlx"   , name = "High Watt Warehouse",  type = stats.LVL_LOST,  description = "You can just FEEL the electricity surging throughout this building. It may even kill you!"},
    {filename = "2-2 Monty Mole Mines.lvlx"         , name = "Monty Mole Mines",     type = stats.LVL_LOST,  description = "Befriend the Monty Moles and ride on their backs across the dangerous spikes! Watch out for their kids, though. Vicious."},
    {filename = "2-3 Bone Dry Bridge.lvlx"          , name = "Bone Dry Bridge",      type = stats.LVL_LOST,  description = "The Kremlings have invaded the desert canyon! Use the propeller block to brave the large and dangerous canyon gaps."},
    {filename = "3-1 Paddlewheel Peril.lvlx"        , name = "Paddlewheel Peril",    type = stats.LVL_LOST,  description = "You've seen this purple liquid before. If it's anything like last time, you're in for a good old case of death if you come into contact with it."},
    {filename = "3-2 Super Sticky Swamp.lvlx"       , name = "Super Sticky Swamp",   type = stats.LVL_LOST,  description = "The slimy blocks of this swampland severely impede the height of your jump. Beware of falling Scuttlebugs!"},
    {filename = "3-3 Lightweight Library.lvlx"      , name = "Lightweight Library",  type = stats.LVL_LOST,  description = "Have your insides warped and transparentized in order to traverse this horribly designed haunted library!"},
    {filename = "3-T Tangled Temple.lvlx"           , name = "Tangled Temple",       type = stats.LVL_LOST,  description = "A huge, overgrown temple infested with Thwomps. Try not to get crushed to pulp by these metamorphic maniacs!"},
    {filename = "!A-2 Disastrous Deeps.lvlx"        , name = "Disastrous Deeps",     type = stats.LVL_LOST,  description = "When you swim where the sun doesn't shine, your safety is never certain. Here, Rammerheads coordinate their movement for more efficient travel."},
    {filename = "!B-1 Swooper Drop Sneak.lvlx"      , name = "Swooper Drop Sneak",   type = stats.LVL_LOST,  description = "By some anomaly, this cave has Swoopers sitting at the top of the food chain, hence their massive size. At least they're bouncy!"},
    {filename = "!C-1 Fragile Block Foothills.lvlx" , name = "Fragile Foothills",    type = stats.LVL_LOST,  description = "Certain areas of the dirt here are very loose, making them prime candidates for destruction to progress. Oh, and it's also Halloween?"},
    {filename = "!D-1 Pine Propultion.lvlx"         , name = "Pine Propultion",      type = stats.LVL_LOST,  description = "Nobody can explain it, but the trees in this area possess extremely strange, likely manmade, properties. I won't spoil the surprise."},
    {filename = "!A-1 Buccaneer Bay.lvlx"           , name = "Buccaneer Bay",        type = stats.LVL_FRAG,  description = "The Shyrates have laid claim to the southern coast of the island! They're not as threatening as we originally thought... "},
    {filename = "1-3 Sakura Scrapyard.lvlx"         , name = "Sakura Scrapyard",     type = stats.LVL_FRAG,  description = "As the beautiful cherry blossoms sway in the wind, an abandoned scrapyard facility buzzes on below. Is this supposed to be a metaphor?"},
    {filename = "4-T Polar Palace.lvlx"             , name = "Polar Palace",         type = stats.LVL_FRAG,  description = "Seemingly devoid of any intelligent life, the only things left roaming these hallways are sentient ice balls designed to slow you down."},
    {filename = "5-1 Toxic Tumble.lvlx"             , name = "Toxic Tumble",         type = stats.LVL_FRAG,  description = "Toxic sludge and giant barrels of radioactive material. If you ask me, I would take this over a beach resort any day of the week!"},
    {filename = "1-1 Flowing Frolic.lvlx"           , name = "Flowing Frolic",       type = stats.LVL_ALT ,  description = "Water, it doesn't get much simpler than that. Though, the pressure of the water coming from THESE pipes is so well maintained that you can stand on top of it!"},
    {filename = "1-1 Moving Meadows.lvlx"           , name = "Moving Meadows",       type = stats.LVL_ALT ,  description = "Brought on by extreme tectonic plate activity, the land in this area goes wherever it pleases, which seems to be along predefined paths in a sine wave pattern."},
    {filename = "1-1 Piranha Plant Pinch!.lvlx"     , name = "Piranha Plant Pinch", type = stats.LVL_ALT ,  description = "Some say that this level originated from one of Luigi's more generic adventures. I think they may be correct..."},
}

function stats.getByFilename(name)
    for k, v in ipairs(stats.levelList) do
        if v.filename == name then
            return v
        end
    end
end

stats.images = {
    title        = Graphics.loadImageResolved("pastPortal/title.png"),
    dark         = Graphics.loadImageResolved("pastPortal/dark.png"),
    bigStarCol   = Graphics.loadImageResolved("pastPortal/bigStarCol.png"),
    bigStarUncol = Graphics.loadImageResolved("pastPortal/bigStarUncol.png"),
    boxBig       = Graphics.loadImageResolved("pastPortal/boxBig.png"),
    boxSmall     = Graphics.loadImageResolved("pastPortal/boxSmall.png"),
    checkBig     = Graphics.loadImageResolved("pastPortal/checkBig.png"),
    checkSmall   = Graphics.loadImageResolved("pastPortal/checkSmall.png"),
    frame1       = Graphics.loadImageResolved("pastPortal/frame1.png"),
    frame2       = Graphics.loadImageResolved("pastPortal/frame2.png"),
    selector     = Graphics.loadImageResolved("pastPortal/selector.png"),
    starCol      = Graphics.loadImageResolved("pastPortal/starCol.png"),
    starUncol    = Graphics.loadImageResolved("pastPortal/starUncol.png"),
    lock         = Graphics.loadImageResolved("pastPortal/lock.png"),
    cross        = Graphics.loadImageResolved("pastPortal/cross.png"),
}

stats.SFX = {
    confirm = {id = SFX.open(Misc.resolveSoundFile("SFX/confirmLevelStart")), volume = 0.5},
    deny    = {id = SFX.open(Misc.resolveSoundFile("SFX/denyLevelStart")),    volume = 0.5},
    cursor  = {id = SFX.open(Misc.resolveSoundFile("SFX/cursor")),            volume = 0.5},
    select  = {id = SFX.open(Misc.resolveSoundFile("SFX/select")),            volume = 0.5},
    switch  = {id = SFX.open(Misc.resolveSoundFile("SFX/switchTab")),         volume = 0.5},
    unlock  = {id = SFX.open(Misc.resolveSoundFile("SFX/unlockNewTab")),      volume = 0.5},
    enter   = {id = SFX.open(Misc.resolveSoundFile("SFX/enterPortal")),       volume = 1},
    exit    = {id = SFX.open(Misc.resolveSoundFile("SFX/exitPortal")),        volume = 1},
}

-- levels in which he timer will not be shown
stats.prohibited = {
    "!The Realm of Recollection.lvlx",
    "!Credits.lvlx",
    "!Memory Center.lvlx"
}

--[[
    Call this fuction like:
    stats.registerLevel{filename = "myLevel.lvlx", name = "A cool level", description = "This level is really cool.", type = stats.LVL_LOST}
]]
function stats.registerLevel(args)
    args = args or {}
    args.name = args.name or "Untitled"
    args.description = args.description or "No description yet."
    args.type = args.type or stats.LVL_LOST
    if not args.filename then error("No level file name was provided!") end
    stats.levelList[#stats.levelList + 1] = {name = args.name, description = args.description, type = args.type}
end

function stats.formatTime(x)
    local fps     = Misc.GetEngineTPS()
    local hrs     = x / (3600 * fps)
    local mins    = x / (60 * fps) % 60
    local secs    = x / fps % 60
    local minsecs = math.floor((x % fps / fps * 1000)/10)

    local timerFormat = string.format(
        "%.2d:%.2d:%.2d:%.2d",
        hrs, mins, secs, minsecs
    )

    if x < 0 then
        return("-")
    end

    return timerFormat
end

registerEvent(stats, "onStart")
registerEvent(stats, "onTick")
registerEvent(stats, "onDraw")
registerEvent(stats, "onExitLevel")

function stats.onStart()
	if Checkpoint.getActive() then return end -- started at a checkpoint?
	SaveData.levelStats[Level.filename()].timer = 0
end

function stats.onTick()
    if player.deathTimer == 0 and not player:mem(0x13C, FIELD_BOOL) and Level.endState() == LEVEL_WIN_TYPE_NONE then
	    SaveData.levelStats[Level.filename()].timer = SaveData.levelStats[Level.filename()].timer + 1
    end
end

function stats.onDraw()
    if not table.contains(stats.prohibited, Level.filename()) then
        if stats.displayBestTime then
            textplus.print{font = stats.fontGreen, x = 400, y = 552, text = stats.formatTime(SaveData.levelStats[Level.filename()].bestTime), pivot = vector(0.5, 0), priority = stats.timerPriority}
        end

        if stats.displayTimer then
            textplus.print{font = stats.font, x = 400, y = 576, text = stats.formatTime(SaveData.levelStats[Level.filename()].timer), pivot = vector(0.5, 0), priority = stats.timerPriority}
        end
    end
end

function stats.onExitLevel(win)
    if win == LEVEL_WIN_TYPE_ROULETTE then
        if SaveData.levelStats[Level.filename()].timer < SaveData.levelStats[Level.filename()].bestTime or SaveData.levelStats[Level.filename()].bestTime < 0 then
            SaveData.levelStats[Level.filename()].bestTime = SaveData.levelStats[Level.filename()].timer
        end

        SaveData.levelStats[Level.filename()].beaten = true
        SaveData.levelStats[Level.filename()].timer = 0
    end
end

return stats