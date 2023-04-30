Restrain = Restrain or {}
Restrain.Verbose = Restrain.Verbose or false--set to true for logs

function Restrain.isKeyInhibited(keyName)
    if not keyName then return false end
    
    --if keyName == "Main Menu" then return false end --for now keep escape
    
    if keyName == "Forward" then return false end
    if keyName == "Backward" then return false end
    if keyName == "Left" then return false end
    if keyName == "Right" then return false end
    if keyName == "Zoom in" then return false end
    if keyName == "Zoom out" then return false end
    if keyName == "Pause" then return false end
    if keyName == "Normal Speed" then return false end
    if keyName == "Fast Forward x1" then return false end
    if keyName == "Fast Forward x2" then return false end
    if keyName == "Fast Forward x3" then return false end
    if keyName == "Take screenshot" then return false end
    if keyName == "Toggle Safety" then return false end
    if keyName == "Toggle chat" then return false end
    if keyName == "Alt toggle chat" then return false end
    if keyName == "Switch chat stream" then return false end
    if keyName == "Enable voice transmit" then return false end
    if keyName == "Shout" then return false end
    if keyName == "emote" then return false end
    if keyName == "Toggle Lua Debugger" then return false end
    if keyName == "ToggleLuaConsole" then return false end
    if keyName == "ToggleGodModeInvisible" then return false end
    if keyName == "ToggleModelsEnabled" then return false end
    if keyName == "ToggleAnimationText" then return false end
    if keyName == "Toggle Survival Guide" then return false end
    if keyName == "Display FPS" then return false end
    if keyName == "surrender" then return false end
    if keyName == "Crouch" then return false end
    --if keyName == "Interact" then return false end--this inhibits everything called with mouse click & 'E' key. with the exception of lights
    return true;
end


local keyBindingMemo = nil
function Restrain.inhibitKeyBinding()
    --if Restrain.Verbose then print ("Restrain.inhibitKeyBinding") end
    if not keyBindingMemo then
        keyBindingMemo = {}
        for i,v in ipairs(keyBinding) do
            --if Restrain.Verbose then print ("Restrain.inhibitKeyBinding keyBinding "..tostring(v.value or 'nil').." / "..tostring(v.key or 'nil')) end
            if v.key and v.key ~= 0 and Restrain.isKeyInhibited(v.value) then
                keyBindingMemo[v.value] = v.key;
                v.key = 0
                getCore():addKeyBinding(v.value, v.key)
                if Restrain.Verbose then print ("Restrain.inhibitKeyBinding "..v.value.." from "..keyBindingMemo[v.value].." to "..v.key) end

                --below are just toggle settings, we do not care
                --if v.value == "Run" then getCore():setToggleToRun(0) end --do it like the gameOption.apply does
                --if v.value == "Sprint" then getCore():setOptiondblTapJogToSprint(0) end --do it like the gameOption.apply does
            end
        end
    end
end

function Restrain.exhibitKeyBinding()
    --if Restrain.Verbose then print ("Restrain.exhibitKeyBinding") end
    if keyBindingMemo then
        for i,v in ipairs(keyBinding) do
            --if Restrain.Verbose then print ("Restrain.exhibitKeyBinding keyBinding"..tostring(v.value or 'nil').." / "..tostring(v.key or 'nil')) end
            if v.key == 0 and v.value and keyBindingMemo[v.value] then
                v.key = keyBindingMemo[v.value];
                getCore():addKeyBinding(v.value, v.key)
                if Restrain.Verbose then print ("Restrain.exhibitKeyBinding "..v.value.." from ".. 0 .." to "..v.key) end
            end
        end
        keyBindingMemo = nil
    end
end
