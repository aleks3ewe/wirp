Restrain = Restrain or {}
Restrain.Verbose = Restrain.Verbose or false--set to true for logs


if ISObjectClickHandler then
    --remove click ability when restrained: does work for solo player in own hosted local server but I am not confident for real MP
    local upperLayerdoClick = ISObjectClickHandler.doClick
    ISObjectClickHandler.doClick = function (object, x, y)
        if Restrain.Verbose then print("ISObjectClickHandler.doClick "..tostring(object or "nil").." "..tostring(x or "nil").." "..tostring(y or "nil")) end
        if Restrain and Restrain.isSurrendering(getSpecificPlayer(0)) and getSpecificPlayer(0):getModData().isRestrained then
            return
        end
        
        upperLayerdoClick(object, x, y);
    end
    
    
    local upperLayerdoClickSpecificObject = ISObjectClickHandler.doClickSpecificObject
    function ISObjectClickHandler.doClickSpecificObject(object, playerNum, playerObj)
        if Restrain.Verbose then print("ISObjectClickHandler.doClickSpecificObject "..tostring(object or "nil").." "..tostring(playerNum or "nil").." "..tostring(playerObj or "nil")) end
        if Restrain and Restrain.isSurrendering(getSpecificPlayer(0)) and getSpecificPlayer(0):getModData().isRestrained then
            return
        end
        
        upperLayerdoClickSpecificObject(object, playerNum, playerObj);
    end
end