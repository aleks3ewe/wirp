
require "mods.Prisonner.media.lua.shared.PrisonnerCommons"

function Prisonner.OnServerCommand(mod, command, args)
    if mod ~= Prisonner.ModKey then return end
    
    if command == "CreateItem" then
        if args then
            local player = getPlayerByOnlineID(args.target)--should be getPlayer() ?
            local itemType = args.item
            if player and itemType then
                player:getInventory():AddItem(itemType);--create the same item type
            end
        end
    end
end

Events.OnServerCommand.Add(Prisonner.OnServerCommand);