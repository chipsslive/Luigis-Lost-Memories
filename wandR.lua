--                            _ .___     .               
-- ,  _  /   ___  , __     ___/ /   \    |   ,   .   ___ 
-- |  |  |  /   ` |'  `.  /   | |__-'    |   |   |  /   `
-- `  ^  ' |    | |    | ,'   | |  \     |   |   | |    |
--  \/ \/  `.__/| /    | `___,' /   \ / /\__ `._/| `.__/|
--Version 1.0
--written by Enjl

local wandR = {}
local walkDir = {}
walkDir[0] = function(x) return end
walkDir[1] = function(x) world.playerY = world.playerY - x end
walkDir[2] = function(x) world.playerX = world.playerX - x end
walkDir[3] = function(x) world.playerY = world.playerY + x end
walkDir[4] = function(x) world.playerX = world.playerX + x end

function wandR.onInitAPI()
	registerEvent(wandR, "onTick", "onTick", false)
	registerEvent(wandR, "onStart", "onStart", true)
end

local startX, startY

wandR.grid = 32
wandR.speed = 3

function wandR.onStart()
	startX = world.playerX%wandR.grid
	startY = world.playerY%wandR.grid
end

function wandR.onTick()
	if world.playerIsCurrentWalking then
		world.playerWalkingTimer = 5
		local speed = wandR.speed
		for k,v in pairs(Path.getIntersecting(world.playerX + 10, world.playerY + 10, world.playerX + 22, world.playerY + 22)) do
			if v.id == 23 or v.id == 26 or v.id == 32 or v.id == 6 or v.id == 36 or v.id == 73 or v.id == 74 or v.id == 31 or v.id == 22 or v.id == 54 or v.id == 64 or v.id == 63 or v.id == 77 then
				speed = math.ceil(speed/2.5)
				break
			end
		end
		for i=1, speed do
			walkDir[world.playerWalkingDirection](1)
			if (world.playerX % wandR.grid == startX) and (world.playerY % wandR.grid == startY) then --check if the player reached a tile
				world.playerWalkingTimer = 32
				break
			end
		end
		walkDir[world.playerWalkingDirection](-2) --counteract vanilla coordinate change
	else
		world.playerWalkingTimer = 0
	end
end

return wandR