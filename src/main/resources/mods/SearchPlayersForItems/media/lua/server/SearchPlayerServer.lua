
if isClient() then return end

-- Module is SearchPlayer
-- commands are requestServerItems
--              requestClientItems
--              respondServerItems
--              respondClientItems

local function OnClientCommand(module, command, player, args)
	if module == "SearchPlayer" then
        local otherPlayer = getPlayerByOnlineID(args[1]);
        if command == "requestServerItems" then
            print("A player " .. player:getDisplayName() .. " is requesting info from " .. otherPlayer:getDisplayName())
            -- Send a request to the searched player
            sendServerCommand(otherPlayer, module, "requestClientItems", { player:getOnlineID() })
        elseif command == "respondServerItems" then
            -- Send a response to the original searching player
            sendServerCommand(player, module, "respondClientItems", { })
        end

  end
end

Events.OnClientCommand.Add(OnClientCommand)