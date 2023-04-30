
if isClient() then return; end;

playerdataServer = {};
playerdataServer.Verbose = false
--[[--======== Players ========--
]]--

function playerdataServer.addSetPlayer(_username, _playerData)
end

--[[--======== Event ========--
]]--
playerdataServer.OnClientCommand = function(_module, _command, _player, _packet)
    if playerdataServer.Verbose then print(_module .. " - asdfasdfasdf - " .. _command); end
    if _module ~= "BPplayerData" then return; end;
    if (_command ~= "addSetPlayer" and _command ~= "updatePlayer" and _command ~= "updatePlayerInventory") or (not _packet) then
        if playerdataServer.Verbose then print("aborted function call in playerdataServer " .. (_command or "missing _command.") .. (_packet or "missing _packet.")); end
    else
        if playerdataServer.Verbose then print("gambiarra teste: 4.1 " .. tostring(_player:getUsername())); end
        local bpdata = ModData.getOrCreate("BPplayerData")
        if _command == "addSetPlayer" then
            bpdata[_player:getUsername()] = _packet;
        elseif not bpdata[_packet["user"]] then
            if playerdataServer.Verbose then print("aborted function call in playerdataServer " ..  "missing addSetPlayer for " .. _packet["user"]); end
        elseif _command == "updatePlayer" then
            bpdata[_packet["user"]][_packet["item"]] = _packet["value"];
        elseif _command == "updatePlayerInventory" then
            if playerdataServer.Verbose then print("gambiarra teste 4.2"); end
            bpdata[_packet["user"]]["inventory"] = _packet["inventory"];
            if playerdataServer.Verbose then print(tostring(ModData.getOrCreate("BPplayerData")[_packet["user"]]["inventory"])); end
            if playerdataServer.Verbose then print("gambiarra teste 4.2"); end
        end
        ModData.transmit("BPplayerData");
        --sendServerCommand(_module, _command, BPplayerData);
    end;
end

Events.OnClientCommand.Add(playerdataServer.OnClientCommand);