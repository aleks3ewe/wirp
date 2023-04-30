
if isServer() then return; end;

-------------------------------------------------
-------------------------------------------------
playerdataClient = {};
playerdataClient.Verbose = false
BPplayerData = {};

--[[--======== Data ========--]]--

function playerdataClient.init()
	BPplayerData = ModData.getOrCreate("BPplayerData");
end
Events.OnInitGlobalModData.Add(playerdataClient.init)

--[[--======== Player ========--]]--

function playerdataClient.addSetPlayer(_username, _playerData)
	if playerdataClient.Verbose then print("gambiarra teste: 1 " .. _username); end
	sendClientCommand("BPplayerData", "addSetPlayer", _playerData);
end

function playerdataClient.updatePlayer(_username, _dataItem, _value)
	if playerdataClient.Verbose then print("gambiarra teste: 1 " .. _username); end
	local _data = {};
	_data["user"] = _username;
	_data["item"] = _dataItem;
	_data["value"] = _value;

	sendClientCommand("BPplayerData", "updatePlayer", _data);
end

function playerdataClient.updatePlayerInventory(_player)
	if playerdataClient.Verbose then print("teste: 1 " .. _player:getUsername()); end
	local _data = {};
	_data["user"] = _player:getUsername();
	_data["inventory"] = {};
	
    local _inventoryList = _player:getInventory():getItems();
	local _size = _inventoryList:size();

    local array = {};

    for i = 0, _size - 1 do
        local _CurrentItem = _inventoryList:get(i);
        if playerdataClient.Verbose then print("inventory " .. _CurrentItem:getDisplayName()); end
        table.insert(array, _CurrentItem:getDisplayName());
	end

    local counter = #array;
    while counter > 1 do
        local index = ZombRand(1, counter)
        array[index], array[counter] = array[counter], array[index]
        counter = counter - 1
    end

    for i = 1, #array do
		table.insert(_data["inventory"], array[i]);
	end

	sendClientCommand("BPplayerData", "updatePlayerInventory", _data);
end


local function OnReceiveGlobalModData(_module, _packet)
	if _module ~= "BPplayerData" then return; end;
	-- print("SERVER" .. _module)
	if (not _packet) then
		if playerdataClient.Verbose then print("aborted OnReceiveGlobalModData in trueClient " .. (_packet or "missing _packet.")); end
	else
		if playerdataClient.Verbose then print("RECEBIDOOOOOOOOOOOOOOOOOOOOOOOOOO"); end
		ModData.add(_module, _packet);
	end;
end

Events.OnReceiveGlobalModData.Add(OnReceiveGlobalModData)