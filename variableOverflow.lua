-- Lua only allows 60 variables in a single file. This file is a workaround for that limitation.

-- I don't remember if these are used anymore
GameData.challenge1CompleteText = "No"
GameData.challenge2CompleteText = "No"
GameData.challenge3CompleteText = "No"
GameData.challenge4CompleteText = "No"
GameData.challenge5CompleteText = "No"

-- Realm of Recollection overflow variables

-- Unlocking the Audiblette and Conceptuary variables
audibletteWarp      = nil
audibletteLock      = nil
audibletteNPC       = nil
unlockedAudiblette  = nil
conceptuaryWarp     = nil
conceptuaryLock     = nil
conceptuaryNPC      = nil
unlockedConceptuary = nil

-- All intro-related variables
introTimer               = 0
stopIntroTimer           = false
portal                   = nil
playerStart              = false
talkedToBloomba          = false
opacity                  = 0
sfx1Played               = false
otherBloombas            = nil
reduceOpacity1           = false
maroonba                 = nil
portalCutsceneTimerStart = false
portalCutsceneTimer      = 0
orangeBloomba            = nil
blueBloomba              = nil
redBloomba               = nil
purpleBloomba            = nil
orangeMessage            = nil
blueMessage              = nil
redMessage               = nil
purpleMessage            = nil
reduceOpacity2           = false
defaultBloombas          = nil
defaultRedBloomba        = nil
hidePlayer               = false
lockPlayer               = false
doEarthquake             = false
currentQuakeIntensity    = 2.5