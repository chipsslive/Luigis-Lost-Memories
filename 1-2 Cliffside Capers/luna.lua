local autoscroll = require("autoscroll")
local respawnRooms = require("respawnRooms")
local textplus = require("textplus")

local redCoin = Graphics.loadImage("redCoin.png")
local redCoinCount = 0

function onLoadSection9()
	autoscroll.scrollRight(1.5)
end

function onTick()
	if player.deathTimer > 0 then return end
	if player:mem(0x148, FIELD_WORD) > 0
	and player:mem(0x14c, FIELD_WORD) > 0 then
		player:kill()
	end
end

local portalFont = textplus.loadFont("portalFont.ini")

function onDraw()
	if player.section == 1 then
		Graphics.drawImageWP(redCoin,680,50,5)
		textplus.print{
			text = ""..redCoinCount.."/8",
			priority = 5,
			x = 718,
			y = 50,
			font = portalFont
		}
	end
end

function onPostNPCKill(killedNPC)
	if killedNPC.id == 152 then
		redCoinCount = redCoinCount + 1
	end
end

function respawnRooms.onPostReset(fromRespawn)
	redCoinCount = 0
end