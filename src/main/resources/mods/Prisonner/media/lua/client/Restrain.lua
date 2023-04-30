
require "mods.Prisonner.media.lua.shared.PrisonnerCommons"
Restrain = Restrain or {}
Restrain.KEYS = { name = "Surrender", key = Keyboard.KEY_F1 }
Restrain.Verbose = Restrain.Verbose or false
Restrain.isRestrainingItemInitialized = false
Restrain.isRestrainingItemUsed = false

require "Restrain_keybinding"--require after to get log activation here

if ModOptions and ModOptions.AddKeyBinding then
    ModOptions:AddKeyBinding("[Combat]",Restrain.KEYS)
end

--functionnal call for surrender
function Restrain.isSurrendering(player)
    if Restrain.Verbose then print ("Restrain.isSurrendering player= "..tostring(player)) end
    local currentAction = ISTimedActionQueue.getTimedActionQueue(player).current
    if currentAction and currentAction.Type == "ISSelfRestrain" then
        return true
    end
    
    if ISSelfRestrain.instance then
        print ("Restrain.isSurrendering no ISSelfRestrain in queue while instance exists. Smells fishy !");
        if not currentAction then
            print ("Restrain.isSurrendering probably got a bugged action, cleared queue log TODO correct that case. inhibit ISTimedActionQueue.onTick ?");
            ISTimedActionQueue.add(ISSelfRestrain.instance);
            return true
        end
    end
    return false
end
function Restrain.stopSurrender(player)
    if Restrain.isSurrendering(player) and not player:getModData().isRestrained then

        playerdataClient.updatePlayer(player:getUsername(), "isSurrendering", false);
        playerdataClient.updatePlayer(player:getUsername(), "inventary", nil);

        ISTimedActionQueue.getTimedActionQueue(player).current:stop()
    end
end
function Restrain.doSurrender(player)
    if not Restrain.isSurrendering(player) then

        playerdataClient.updatePlayer(player:getUsername(), "isSurrendering", true);
        playerdataClient.updatePlayerInventory(player);

        ISTimedActionQueue.add(ISSelfRestrain:new(player:getPlayerNum()))
    end
end

--key use as input
local function KeyUp(keynum)
    if Restrain.KEYS.key and keynum == Restrain.KEYS.key then -- F1
        local player = getPlayer()
        if not player then return end--Main menu with mod active
        if Restrain.isSurrendering(player) then
            if Restrain.Verbose then print ("Restrain.KeyUp stopSurrender") end
            Restrain.stopSurrender(player)
        else
            if Restrain.Verbose then print ("Restrain.KeyUp doSurrender") end
            Restrain.doSurrender(player)
        end
    end
end

--emote menu override use as input
local upperLayerEmote = ISEmoteRadialMenu.emote
function ISEmoteRadialMenu:emote(emote)
    if emote == "surrender" then
        local player = getPlayer()
        if Restrain.isSurrendering(player) then
            if Restrain.Verbose then print ("Restrain.emote stopSurrender") end
            Restrain.stopSurrender(player)
        else
            if Restrain.Verbose then print ("Restrain.emote doSurrender") end
            Restrain.doSurrender(player)
        end
    else
        upperLayerEmote(self,emote)
    end
end

Events.OnKeyPressed.Add(KeyUp);

Restrain.lastSay = 0 --all of this will be unique to each client and we don't need to worry about saving
Restrain.imageNumber = 1
Restrain.doDelete = false

Restrain.say = function(specificPlayer)
	local calendarInstance = Calendar.getInstance()
	
	if (calendarInstance:getTimeInMillis() - Restrain.lastSay > 5000) then --overhead messages fade after 5 seconds
		local bubbleTexture = "media/textures/bubble1.png"
		
		processSayMessage("[img=" .. bubbleTexture .. "]") --Regular 'Say' function doesn't show for other players in MP
		
		Restrain.lastSay = calendarInstance:getTimeInMillis() --set lastSay so we cna wait 5000 milliseconds before showing the chat bubble
	end
end

Restrain.onAddMessage = function(message, tabId)
	local specificPlayer = getSpecificPlayer(0)
	if (specificPlayer == nil) then
		return
	end
	
	local messageText = message:getText()
	
	if (messageText == "[img=media/textures/bubble1.png]") then --quicker to do 3 exact string matches than use string.find
		Restrain.doDelete = true
	elseif (Restrain.doDelete) then
		Restrain.doDelete = false
	end
end
Events.OnAddMessage.Add(Restrain.onAddMessage)

Restrain.deleteMessage = function()
	local chatTextInstance = ISChat.instance.chatText
	if (chatTextInstance == nil) then
		return
	end
	
	local chatTextInstanceLines = chatTextInstance.chatTextLines
	local scrolledToBottom = (chatTextInstance:getScrollHeight() <= chatTextInstance:getHeight()) or (chatTextInstance.vscroll and chatTextInstance.vscroll.pos == 1) --check scroll before removing lines
	local newText = ""
	local searchText = "img=media/textures/bubble" --use this string to find/remove from chat
	chatTextInstance.text = ""
	
	for i, v in ipairs(chatTextInstanceLines) do --loop once to remove img lines
		if (string.find(v, searchText)) then --it is quicker to do string.find here as the chatTextLines (v) are not plain strings, it would be more expensive to calculate the exact string
			table.remove(chatTextInstanceLines, i)
		end
	end
	
	for i, v in ipairs(chatTextInstanceLines) do --loop once to display correct lines/line breaks
		if i == #chatTextInstanceLines then
			v = string.gsub(v, " <LINE> $", "") --remove <LINE> (line break) if at last line
		end
		
		newText = newText .. v
	end
	
	chatTextInstance.text = newText
	chatTextInstance:paginate()
	
	if scrolledToBottom then
		chatTextInstance:setYScroll(-10000) --vanilla code
	end
	
	Restrain.doDelete = false
end

Restrain.checkChatting = function(specificPlayer)
    if specificPlayer:getModData().isRestrained then
        if not Restrain.isRestrainedByItem(specificPlayer) then
            Restrain.say(specificPlayer)
        end
    end
    
    if (Restrain.doDelete) then
        Restrain.deleteMessage()
    end
end

Events.OnPlayerUpdate.Add(Restrain.checkChatting)

function Restrain.useRestrainingItem()
    if not Restrain.isRestrainingItemInitialized then-- parse item list only once for perf purpose
        Restrain.isRestrainingItemInitialized = true
        Restrain.isRestrainingItemUsed = Restrain.doesRestrainingItemExist()
    end

    return Restrain.isRestrainingItemUsed
end


function Restrain.isRestrainedByItem(player)
    local item = Restrain.getRestrainingItem(player)
    return item ~= nil
end

--item that is currently restraining
function Restrain.getRestrainingItem(player)
    if not player then return nil end
    local phi = player:getPrimaryHandItem()
    if not phi then return nil end
    
    if phi:hasTag(Prisonner.itemTag) then
        --if Restrain.Verbose then print ("Restrain.getRestrainingItem "..phi:getFullType()) end
        return phi
    end
    --if Restrain.Verbose then print ("Restrain.getRestrainingItem None.") end
    return nil
end

--item that could restrain
function Restrain.getRestrainableItem(player)
    local playerInv = player:getInventory();
    local it = playerInv:getItems()
    local initialInvLastIt = it:size()-1;
    for i = 0, initialInvLastIt do
        local item = it:get(i)
        if item:hasTag(Prisonner.itemTag) then
            return item
        end
    end
    return nil
end

--beware with many items added by mods this could take VERY long.
--beware with many tags added by vanilla this could take longer over time (over PZ versions).
function Restrain.doesRestrainingItemExist()
    local items = getScriptManager():getAllItems();
    for i=0,items:size()-1 do--for each item
        local item = items:get(i);
        local strList = item:getTags();
        for tagIter=0,strList:size()-1 do--for each tag of the item
            if strList:get(tagIter) == Prisonner.itemTag then
                return true
            end
        end
    end
    return false
end

--Do non real time stuff asap (during initial black screen)
function Restrain.initRestrainingItem(player)
    if player ~= nil and player == getPlayer() then
        Restrain.useRestrainingItem()
        Events.OnPlayerUpdate.Remove(Restrain.initRestrainingItem)
    end
end
Events.OnPlayerUpdate.Add(Restrain.initRestrainingItem)