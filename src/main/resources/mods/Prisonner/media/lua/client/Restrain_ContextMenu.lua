
require "mods.Prisonner.media.lua.client.Restrain"

Restrain.solodebug = false;

--remove trade action that would free ourselves. I would prefer to remove the button but I won't mess with createMenu insides
local upperLayerOnTrade = ISWorldObjectContextMenu.onTrade
ISWorldObjectContextMenu.onTrade = function(worldobjects, playerObj, otherPlayerObj)
    if Restrain.isSurrendering(playerObj) or Restrain.isSurrendering(otherPlayerObj) then return end
    
    upperLayerOnTrade(worldobjects, playerObj, otherPlayerObj)
end

--remove sit down action that would stuck us on ground.
local upperLayerOnSitOnGround = ISWorldObjectContextMenu.onSitOnGround
ISWorldObjectContextMenu.onSitOnGround = function(playerNum)
    if Restrain.Verbose then print ("Restrain.onSitOnGround "..tostring(playerNum)) end
    if Restrain.isSurrendering(getSpecificPlayer(playerNum)) then return end
    
    upperLayerOnSitOnGround(playerNum)
end

--add contextual option to restrain
local upperLayerCreateMenu = ISWorldObjectContextMenu.createMenu
ISWorldObjectContextMenu.createMenu = function(player, worldobjects, x, y, test)
    local context = upperLayerCreateMenu(player, worldobjects, x, y, test)
    
    --contextual option for action on other
    local playerObj = getSpecificPlayer(player)

    if clickedPlayer and clickedPlayer ~= playerObj and isClient() then
        if math.abs(playerObj:getX() - clickedPlayer:getX()) <= 2 and math.abs(playerObj:getY() - clickedPlayer:getY()) <= 2 then
            if Restrain.Verbose then print("distancia within limits."); end
            createMenuNew(context, clickedPlayer, playerObj);
        else
            if Restrain.Verbose then print("distance too important."); end
        end        
    elseif Restrain.solodebug then--just for standalone pseudo MP tests before MP tests
        createMenuNew(context, playerObj, playerObj);
    end
    
    return context
end

function createMenuNew(context, clickedPlayer, playerObj)
    local pData = ModData.getOrCreate("BPplayerData")
    local playerUserName = clickedPlayer:getUsername()
    local userNamePData = pData[playerUserName]
    --enable check inventory
    if userNamePData.isSurrendering and SandboxVars.Prisonner.Inspect then
        local option3 = context:addOption(getText("ContextMenu_Inventary", playerUserName), playerObj, ISWorldObjectContextMenu.onInventaryCheck, clickedPlayer);
    end

    --check if this is surrender and not restrained
    if userNamePData.isSurrendering and userNamePData.isRestrained == false then
        local tooltip = nil
        local restrainingItem = nil
        
        local useRestrainingItem = Restrain.useRestrainingItem()
        if useRestrainingItem then
            restrainingItem = Restrain.getRestrainableItem(playerObj)
        end
        if Restrain.Verbose then print("ISWorldObjectContextMenu createMenuNew "..tostring(restrainingItem and "has restrainingItem" or "nil").." "..tostring(Restrain.useRestrainingItem() and "use restrainingItem" or "not using restraining item")); end
        
        if useRestrainingItem and not restrainingItem then--require a restraining item that is not available
            tooltip = ISToolTip:new();
            tooltip:initialise();
            tooltip:setVisible(true);
            tooltip.description = getText("Tooltip_noRestrainingItem")
            local option2 = context:addOption(getText("ContextMenu_Restrain", playerUserName), playerObj, ISWorldObjectContextMenu.fake)
            option2.toolTip = tooltip
            option2.notAvailable = true
        else
            local option2 = context:addOption(getText("ContextMenu_Restrain", playerUserName), playerObj, ISWorldObjectContextMenu.onRestrain, clickedPlayer, restrainingItem)
        end
    end

    --check if will need to be restrain
    if userNamePData.isRestrained then
        local option1 = context:addOption(getText("ContextMenu_Free", playerUserName), playerObj, ISWorldObjectContextMenu.onFree, clickedPlayer )
    end

end

ISWorldObjectContextMenu.onInventaryCheck = function (playerObj, clickedPlayer)
    local array = ModData.getOrCreate("BPplayerData")[clickedPlayer:getUsername()]["inventory"];

    if Restrain.Verbose then print("INICIANDO O INV " .. tostring(#array)); end

    for i = 1, #array do
        ISTimedActionQueue.add(ISCheckInv:new(playerObj:getOnlineID(), 50, array[i], clickedPlayer));
    end
end

ISWorldObjectContextMenu.onRestrain = function (playerObj, clickedPlayer, restrainingItem)
    if Restrain.Verbose then print("humm 1"); end
    local itemType = nil
    if restrainingItem then
        itemType = restrainingItem:getFullType();
        playerObj:getInventory():DoRemoveItem(restrainingItem);
    end
    sendClientCommand(playerObj, 'Prisonner', 'Restrain', {target=clickedPlayer:getOnlineID(), restrainingItem=itemType});
    if Restrain.Verbose then print("ISWorldObjectContextMenu onRestrain "..tostring(itemType or "nil")); end
end

ISWorldObjectContextMenu.fake = function (playerObj, clickedPlayer)
    if Restrain.Verbose then print("ISWorldObjectContextMenu Fake Restrain"); end
end

ISWorldObjectContextMenu.onFree = function (playerObj, clickedPlayer)
    sendClientCommand(playerObj, 'Prisonner', 'Free', {target=clickedPlayer:getOnlineID()});
end