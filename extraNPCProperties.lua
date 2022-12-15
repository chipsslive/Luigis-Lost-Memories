local extraNPCProperties = {}


local SPAWNING_BEHAVIOUR = {
    DEFAULT = 0,
    DONT_DESPAWN = 1,
    SPAWNED_IF_IN_SECTION = 2,
}

local INVINCIBLE_TO = {
    NOTHING = 0,
    EVERYTHING = 1,
    PLAYER = 2,
    NPCS = 3,
}


local defaultPropertiesMap = {
    spawningBehaviour = SPAWNING_BEHAVIOUR.DEFAULT,
    invincibleTo = INVINCIBLE_TO.NOTHING,
    noblockcollision = false,
    tag = "",

    exclusiveSpawn = false,
}

local propertiesList = table.unmap(defaultPropertiesMap)


extraNPCProperties.relevantNPCs = {}

local activeSectionMap = {}
local taggedMap = {}



function extraNPCProperties.getWithTag(tag)
    local npcs = taggedMap[tag]

    if npcs == nil then
        return {}
    end

    -- Remove any invalid ones before returning
    for i = #npcs, 1, -1 do
        if not npcs[i].isValid then
            table.remove(npcs,i)
        end
    end

    return npcs
end


local function getData(v)
    v.data.extraNPCProperties = v.data.extraNPCProperties or {}
    return v.data.extraNPCProperties,v.data._settings._global
end


function extraNPCProperties.onInitAPI()
    registerEvent(extraNPCProperties,"onStart","onStart",false)
    registerEvent(extraNPCProperties,"onTick")

    registerEvent(extraNPCProperties,"onNPCHarm")

    registerEvent(extraNPCProperties,"onNPCGenerated")


    registerEvent(extraNPCProperties,"onReset","onStart",false)
end


local function isRelevant(v)
    local settings = v.data._settings._global

    for _,name in ipairs(propertiesList) do
        if settings[name] ~= nil and settings[name] ~= defaultPropertiesMap[name] then
            return true
        end
    end

    return false
end


local function addToRelevant(v)
    local data,settings = getData(v)

    table.insert(extraNPCProperties.relevantNPCs,v)

    if settings.tag ~= nil and settings.tag ~= "" then
        taggedMap[settings.tag] = taggedMap[settings.tag] or {}

        table.insert(taggedMap[settings.tag],v)
    end
end


local function doSectionFix(v)
    -- Check the section, because redigit's own logic suuucks

    -- Actually in the bounds (yes, redigit messed even this check up!)
    local sectionObj = Section.getFromCoords(v)

    if sectionObj ~= nil then
        v.section = sectionObj.idx
        return
    end

    -- If that fails, find the closest section centre
    local closestSection = 0
    local closestDistance = math.huge

    for _,sectionObj in ipairs(Section.get()) do
        local b = sectionObj.boundary

        local sectionX = (b.right + b.left) * 0.5
        local sectionY = (b.bottom + b.top) * 0.5

        local xDistance = (sectionX - (v.x + v.width *0.5))
        local yDistance = (sectionY - (v.y + v.height*0.5))
        local totalDistance = math.sqrt(xDistance*xDistance + yDistance*yDistance)

        if totalDistance < closestDistance then
            closestSection = sectionObj.idx
            closestDistance = totalDistance
        end
    end

    v.section = closestSection
end



function extraNPCProperties.onStart()
    for _,v in NPC.iterate() do
        if isRelevant(v) then
            addToRelevant(v)
        end

        doSectionFix(v)
    end
end

local respawnRooms = require("respawnRooms")

function respawnRooms.onPostReset(fromRespawn)
    for _,v in NPC.iterate() do
        if isRelevant(v) then
            addToRelevant(v)
        end

        doSectionFix(v)
    end
end

local function perNPCLogic(v)
    local data,settings = getData(v)

    if settings.exclusiveSpawn and v.isGenerator and (data.mostRecentGenerated ~= nil and data.mostRecentGenerated.isValid) then
        v.generatorTimer = 0
        v:mem(0x74,FIELD_BOOL,false)
    end

    if activeSectionMap[v.section] and ((v.despawnTimer > 0 and settings.spawningBehaviour == SPAWNING_BEHAVIOUR.DONT_DESPAWN) or settings.spawningBehaviour == SPAWNING_BEHAVIOUR.SPAWNED_IF_IN_SECTION) then
        v.despawnTimer = math.max(10,v.despawnTimer)
        v:mem(0x124,FIELD_BOOL,true)
    end

    v.noblockcollision = v.noblockcollision or settings.noblockcollision
end



function extraNPCProperties.onTick()
    activeSectionMap = table.map(Section.getActiveIndices())

    for k = #extraNPCProperties.relevantNPCs, 1, -1 do
        local v = extraNPCProperties.relevantNPCs[k]

        if v.isValid then
            perNPCLogic(v)
        else
            table.remove(extraNPCProperties.relevantNPCs,k)
        end
    end
end


function extraNPCProperties.onNPCHarm(eventObj,v,reason,culprit)
    local data,settings = getData(v)

    if settings.invincibleTo == INVINCIBLE_TO.EVERYTHING
    or (type(culprit) == "Player" and settings.invincibleTo == INVINCIBLE_TO.PLAYER)
    or (type(culrpit) == "NPC"    and settings.invincibleTo == INVINCIBLE_TO.NPCS  )
    then
        eventObj.cancelled = true
    end
end

function extraNPCProperties.onNPCGenerated(generator,generatedNPC)
    local generatorData = getData(generator)
    local generatedNPCData = getData(generatedNPC)

    generatorData.mostRecentGenerated = generatedNPC
    generatedNPCData.cameFromGenerator = generator

    if isRelevant(generatedNPC) then
        addToRelevant(generatedNPC)
    end
end


return extraNPCProperties