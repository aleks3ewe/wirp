function onSearchPlayerContextSelected(worldobjects, playerObj, otherPlayer)
    --print(playerObj:getDisplayName() .. " обыскивает " .. otherPlayer:getDisplayName());
    --print(playerObj:getDisplayName() .. " : " .. playerObj:getOnlineID())
    --print(otherPlayer:getDisplayName() .. " : " .. otherPlayer:getOnlineID())
    if luautils.walkAdj(playerObj, otherPlayer:getCurrentSquare()) then
        ISTimedActionQueue.add(SearchPlayerAction:new(playerObj, otherPlayer))
    end
end

function searchPlayerContextOption(player, context, worldObjects)
    local playerObj = getSpecificPlayer(player);
    local playerInv = playerObj:getInventory();
    
    local otherPlayer = nil;

    local square;

    for i, v in ipairs(worldObjects) do
        local movingObjects = v:getSquare():getMovingObjects()
        square = v:getSquare();
        for i = 0, movingObjects:size() - 1 do
            local o = movingObjects:get(i)
            if instanceof(o, "IsoPlayer") then
                otherPlayer = o;
                break
            end
        end
    end

    if otherplayer == nil then
        for x=square:getX()-1,square:getX()+1 do
            for y=square:getY()-1,square:getY()+1 do
                local sq = getCell():getGridSquare(x,y,square:getZ());
                if sq then
                    for i=0,sq:getMovingObjects():size()-1 do
                        local o = sq:getMovingObjects():get(i)
                        if instanceof(o, "IsoPlayer") and (o ~= playerObj) then
                            otherPlayer = o
                        end
                    end
                end
            end
        end
    end

    if otherPlayer and otherPlayer ~= playerObj and not otherPlayer:isAsleep() and isClient() then
        local text = getText("UI_SearchStub", "a person");
        local option = context:addOption(text, worldobjects, onSearchPlayerContextSelected, playerObj, otherPlayer)
        if math.abs(playerObj:getX() - otherPlayer:getX()) > 2 or math.abs(playerObj:getY() - otherPlayer:getY()) > 2 then
            local tooltip = ISWorldObjectContextMenu.addToolTip();
            option.notAvailable = true;
            tooltip.description = getText("UI_SearchingGetCloser");
            option.toolTip = tooltip;
        end
    end
end

Events.OnFillWorldObjectContextMenu.Add(searchPlayerContextOption)