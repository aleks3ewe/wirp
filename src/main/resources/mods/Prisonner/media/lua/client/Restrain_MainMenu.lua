
--remove main option when surrendering because it breaks all key inhibition.
local upperLayeronMenuItemMouseDownMainMenu = MainScreen.onMenuItemMouseDownMainMenu
MainScreen.onMenuItemMouseDownMainMenu = function(item, x, y)
    if Restrain.isSurrendering(getPlayer()) and item.internal == "OPTIONS" then return end
    
    upperLayeronMenuItemMouseDownMainMenu(item, x, y)
end
