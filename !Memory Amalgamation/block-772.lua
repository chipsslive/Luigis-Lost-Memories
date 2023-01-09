local blockmanager = require("blockmanager")

local block = {}

local blockID = BLOCK_ID

--disable vanilla collision
blockmanager.setBlockSettings({
    id = blockID,
	frames = 1,
	framespeed = 8,
	playerfilter = -1,
	ceilingslope = 1
})


return block