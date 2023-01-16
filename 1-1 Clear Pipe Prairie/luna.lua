local clearPipeFix = require("clearPipeFix")
local spawnzones = require("spawnzones")
clearpipe = require("blocks/ai/clearpipe")
clearpipe_npc = require("npcs/ai/clearpipeNPC")
local respawnRooms = require("respawnRooms")
local pauseplus = require("pauseplus")
local textplus = require("textplus")

local restrictedChallengeNPCs = table.map({2,3,311,312,313,316,333,850})
local permittedHarmTypes = table.map({HARM_TYPE_PROJECTILE_USED,HARM_TYPE_VANISH})
local challengeFailed = false
local checkpointStatus = false

function onCheckpoint()
	checkpointStatus = challengeFailed
end

table.insert(clearpipe_npc.ids, 312)
clearpipe_npc.ids_map[312] = true
clearpipe.registerPipe(1, "END", "VERT", {true, true, false, false})

local hasRemoverBGOs = 0

function loadFile(name)
	return Misc.resolveFile(name)
end

clearpipe.sfx = loadFile("sfx_clearpipe.ogg")
clearpipe_npc.sfx = clearpipe.sfx

local extraPadding = 256

function onStart()
    for _,v in NPC.iterate() do
        v.section = Section.getIdxFromCoords(v.x - extraPadding, v.y - extraPadding, v.width + extraPadding*2, v.height + extraPadding*2)
    end

	hasRemoverBGOs = #BGO.get(752)
end

function onTick()
    if hasRemoverBGOs > 0 then
		for k,v in ipairs(NPC.get(-1,player.section)) do
			if not v.friendly and v:mem(0x12A, FIELD_WORD) > 0 then
				for _,u in ipairs(BGO.getIntersecting(v.x + 2,v.y + 2,v.x + v.width - 2,v.y + v.height - 2)) do
					if u.id == 752 then
						v:kill(9)
					end
				end
			end
		end
	end
end

function onPostNPCKill(killedNPC,harmType)
	if killedNPC.id == 319 then
	  	local effect = Animation.spawn(176, killedNPC.x + killedNPC.width*0.5, killedNPC.y + killedNPC.height*0.5)
	  	effect.x, effect.y = effect.x - effect.width*0.5, effect.y - effect.height*0.5
	end 

	if killedNPC.id == 320 then
		local effect = Animation.spawn(10, killedNPC.x + killedNPC.width*0.5, killedNPC.y + killedNPC.height*0.5)
		effect.x, effect.y = effect.x - effect.width*0.5, effect.y - effect.height*0.5
  	end 

	if (restrictedChallengeNPCs[killedNPC.id]) then
		if not (permittedHarmTypes[harmType]) then
			challengeFailed = true
		end
	end

	if killedNPC.id == 1000 then
        if not challengeFailed and not GameData.usedAccessibility and not SaveData.challenge4Completed then
            GameData.ach_Challenge4:collect()
            SaveData.challenge4Completed = true
            SaveData.totalChallengesCompleted = SaveData.totalChallengesCompleted + 1
        end
    end
end

function respawnRooms.onPostReset(fromRespawn)
    if Checkpoint.getActive() == nil then
        challengeFailed = false
	else
		challengeFailed = checkpointStatus
	end
end

function onPlayerHarm()
	challengeFailed = true
end

local challengeFailedText = "No"

function onDraw()
	if challengeFailed then
		challengeFailedText = "Yes"
	else
		challengeFailedText = "No"
	end
	if pauseplus.getSelectionValue("settings","Show Challenge Status") then
        textplus.print{
			text = "<color lightgreen>Challenge Status</color><br>Failed?: "..challengeFailedText,
			priority = 5,
			x = 5,
			y = 550,
            xscale = 2,
            yscale = 2,
            priority = 2
		}
        textplus.print{
			text = "<color black>Challenge Status<br>Failed?: "..challengeFailedText.."</color>",
			priority = 5,
			x = 7,
			y = 552,
            xscale = 2,
            yscale = 2,
            priority = 1
		}
    end
end