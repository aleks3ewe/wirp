-- Module is SearchPlayer
-- commands are requestServerItems
--              requestClientItems
--              respondServerItems
--              respondClientItems

local function predicateWeapon(item)
	return item:isInPlayerInventory()
	-- return item:IsWeapon() and item:getActualWeight() >= 1
end

local function OnServerCommand(module, command, args)
    if module == "SearchPlayer" then
        if command == "requestClientItems" then
            local player = getPlayer();
            local otherPlayer = getPlayerByOnlineID(args[1])
            local playerInv = player:getInventory();
            local items = playerInv:getAllEval(predicateWeapon);
            
            if items and items:size() > 0 then
                for i=1,items:size() do
                    local item = items:get(i-1)
                    --print(item:getName())
                    tradingUISendAddItem(player, otherPlayer, item);
                end
            end
        end
    end
end

Events.OnServerCommand.Add(OnServerCommand)