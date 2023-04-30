----------------------------
-- donkaike & tchernobill --
----------------------------
require "mods.Prisonner.media.lua.shared.PrisonnerCommons"

---server-side
local Commands = {};
Commands.Verbose = false
Commands.Prisonner = {};

--forward the order to the target client
function Commands.Prisonner.Restrain(player, args)
    if Commands.Verbose then print("Commands.Prisonner.Restrain from "..player:getOnlineID().." to "..args.target.." with "..tostring(args and args.restrainingItem or "no item")) end
    sendServerCommand(getPlayerByOnlineID(args.target), Prisonner.ModKey, "Restrain", {source=player:getOnlineID(), restrainingItem=args.restrainingItem});
end
function Commands.Prisonner.Free(player, args)
    sendServerCommand(getPlayerByOnlineID(args.target), Prisonner.ModKey, "Free", {source=player:getOnlineID()});
end

function Commands.Prisonner.CreateItem(player, args)
    sendServerCommand(getPlayerByOnlineID(args.target), Prisonner.ModKey, "CreateItem", {source=player:getOnlineID(), item=args.itemType, target=args.target});
end


function Commands.Prisonner.Inventary(player, args)
    --sendServerCommand(getPlayerByOnlineID(args.target), Prisonner.ModKey, "Inventary", {source=player:getOnlineID()});
    --[[local clickedPlayer = getPlayerByOnlineID(args.target);
    local _inventory = clickedPlayer:getInventory();
    local _inventoryList = clickedPlayer:getInventory():getItems();
	local _size = _inventoryList:size();

    local array = {};

    for i = 0, _size - 1 do
        local _CurrentItem = _inventoryList:get(i);
        print("inventory " .. _CurrentItem:getDisplayName());
        table.insert(array, _CurrentItem:getDisplayName());
	end

    local counter = #array;
    while counter > 1 do
        local index = ZombRand(1, counter)
        array[index], array[counter] = array[counter], array[index]
        counter = counter - 1
    end

    for i = 1, #array do
        ISTimedActionQueue.add(ISCheckInv:new(playerObj:getOnlineID(), 100, array[i]));
	end]]--
end

--receive order from a source client and dispatch
function Commands.onClientCommand(mod, command, player, args)
    if Commands[mod] and Commands[mod][command] then
        if Commands.Verbose then print ("Commands.onClientCommand "..tostring(mod or "nil").." "..tostring(command or "nil").." "..tostring(player or "nil").." "..tostring(args or "nil")); end
        Commands[mod][command](player, args)
    else
        if Commands.Verbose then print ("Commands.onClientCommand DISCARDED "..tostring(mod or "nil").." "..tostring(command or "nil").." "..tostring(player or "nil")); end
    end
end

Events.OnClientCommand.Add(Commands.onClientCommand);