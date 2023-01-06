local npcManager = require("npcManager")
local lineguide = require("lineguide")

local colliders = require("colliders")
local vectr = require("vectr")

local rocks = {}
local npcID = NPC_ID;

lineguide.registerNpcs(npcID)

--***************************************************************************************************
--                                                                                                  *
--              DEFAULTS AND NPC CONFIGURATION                                                      *
--                                                                                                  *
--***************************************************************************************************

local rockSettings = {
	id = npcID, 
	gfxwidth = 32, 
	gfxheight = 32, 
	width = 32, 
	height = 32, 
	frames = 2,
	framespeed = 4, 
	framestyle = 1,
	score = 3,
	jumphurt = 1,
	nofireball = 1,
	spinjumpsafe = true,
	luahandlesspeed=true,

	bounceheight = 3.25
}

local configFile = npcManager.setNpcSettings(rockSettings);

npcManager.registerHarmTypes(npcID, 	
{HARM_TYPE_FROMBELOW, HARM_TYPE_NPC, HARM_TYPE_HELD, HARM_TYPE_TAIL, HARM_TYPE_SWORD, HARM_TYPE_LAVA}, 
{[HARM_TYPE_FROMBELOW]=174,
[HARM_TYPE_NPC]=174,
[HARM_TYPE_HELD]=174,
[HARM_TYPE_TAIL]=174,
[HARM_TYPE_LAVA]={id=13, xoffset=0.5, xoffsetBack = 0, yoffset=1, yoffsetBack = 1.5}});

function rocks.onInitAPI()
	npcManager.registerEvent(npcID, rocks, "onTickNPC")
end

--*********************************************
--                                            *
--              	  AI                      *
--                                            *
--*********************************************

local function blockFilter(a)
	return not (a.isHidden or a:mem(0x5A, FIELD_WORD) ~= 0 or Block.LAVA_MAP[a.id]);
end

local function findAndRemove(list, obj)
	for k,v in ipairs(list) do
		if v == obj then
			table.remove(list, k)
			break
		end
	end
end

function rocks.onTickNPC(v)
	if Defines.levelFreeze then return end
	
	-- reset + don't run the code if it's offscreen/grabbed/reserved
	if (v:mem(0x12A, FIELD_WORD) <= 0 or v:mem(0x12C, FIELD_WORD) > 0 or v:mem(0x136, FIELD_BOOL) or v:mem(0x138, FIELD_WORD) > 0) then	
		v.ai1 = 0; -- AI value used for digging chucks holding the rock
		v.ai2 = 0; -- has done big bounce yet
		return
	end	
	
	-- initialize data
	local data = v.data._basegame
	
	if (data.collider == nil) then
		data.collider = colliders.Box(v.x, v.y, v.width, v.height + 2)
	end
			
	if (data.spdvec == nil) then
		data.spdvec = vector.v2(v.speedX, v.speedY);
	end
		
	-- here comes the collision code. please, run while you still can
	
	-- collider update
	data.collider.x = v.x;
	data.collider.y = v.y;
	
	local hitAblock,_,blockList = colliders.collideBlock(data.collider,colliders.BLOCK_SOLID..colliders.BLOCK_SEMISOLID..colliders.BLOCK_HURT..colliders.BLOCK_PLAYER, blockFilter)
	if not hitAblock then
		local tmpNPCList = NPC.getIntersecting(data.collider.x, data.collider.y, data.collider.x + data.collider.width, data.collider.y + data.collider.height)
		for k,n in ipairs(tmpNPCList) do
			if n ~= v then
				local configFile = NPC.config[n.id]
				if configFile.npcblocktop or configFile.playerblocktop then
					if (not n.isHidden) and n:mem(0x12A, FIELD_WORD) > 0 and n:mem(0x12C, FIELD_WORD) == 0 and n:mem(0x138, FIELD_WORD) == 0 and n:mem(0x64, FIELD_BOOL) == false then
						table.insert(blockList, n)
						hitAblock = true
					end
				end
			end
		end
	end

	if hitAblock and v.ai1 == 0 then
		local inNormal = nil;
		local success = nil;
		local pt = vectr.v2(v.x+(0.5*v.width),v.y+(0.5*v.height));
		local dir = vectr.down2*(v.height*0.5+32);
		
		repeat
			local p,_,n,o = colliders.raycast(pt,dir,blockList)
			if not p then
				break
			end
			if (n.x ~= 0 or n.y ~= 0) then 
				inNormal = n; 
				success = p
			else
				findAndRemove(blockList, o);
			end
		until (inNormal ~= nil or #blockList == 0);
		
		if (not success) and #blockList > 0 then
			local success1,pt1,n1,_ = colliders.raycast(pt-vectr.v2(v.width*0.5,0),dir,blockList)
				
			local success2,pt2,n2,_ = colliders.raycast(pt+vectr.v2(v.width*0.5,0),dir,blockList)
				
			success = success1 or success2;
					
			if(success1 and not success2) then
				inNormal = n1;
			elseif(success2 and not success1) then
				inNormal = n2;
			elseif(success1 and success2) then
				if(pt2.y < pt1.y) then
					inNormal = n2;
				else
					inNormal = n1;
				end
			end
		end
			
		if success and (inNormal.x ~= 0 or inNormal.y ~= 0) then
			--inNormal.x = -inNormal.x;

			local inDirection = vectr.v2(v.speedX,v.speedY)	
					
			-- Hacky workaround for vanilla physics overriding things
			if (v.speedX == 0 and v.speedY == 0) then
				inDirection = data.spdvec;
			end

			-- hell

			local Result = inDirection - 2 * inDirection:project(inNormal)
			local cfg = NPC.config[v.id]
			local spdvec = vectr.v2(math.clamp(Result.x, -NPC.config[npcID].speed, NPC.config[npcID].speed), -math.abs(cfg.bounceheight) + v.ai2 - 1.25)
			v.speedX, v.speedY = spdvec.x, spdvec.y;
					
			if v.ai2 == 0 then
				v.ai2 = 1.25;
			end
		end
	end
		
	data.spdvec.x = v.speedX;
	data.spdvec.y = v.speedY;
end

lineguide.properties[npcID] = {lineSpeed = 3}

return rocks;