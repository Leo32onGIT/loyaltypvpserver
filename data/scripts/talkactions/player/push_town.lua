local pushTown = TalkAction("/t")

function pushTown.onSay(player, words)
	-- create log
	logCommand(player, words)
	player:teleportTo(Town(35):getTemplePosition())
	player:setTown(Town(35))
	return true
end

pushTown:separator(" ")
pushTown:groupType("normal")
pushTown:register()

local pushTownAlt = TalkAction("/hub")

function pushTownAlt.onSay(player, words)
	-- create log
	logCommand(player, words)
	player:teleportTo(Town(35):getTemplePosition())
	player:setTown(Town(35))
	return true
end

pushTownAlt:separator(" ")
pushTownAlt:groupType("normal")
pushTownAlt:register()
