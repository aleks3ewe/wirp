-------------------------------
-- donkaike                  --
-------------------------------

BPSharedStuff = {}
BPSharedStuff.tickControl = 100;
BPSharedStuff.tickStart = 0
BPSharedStuff.NEED_TO_CHECK = 0;
BPSharedStuff.Verbose = false

function BPSharedStuff.onRenderTick ()
    BPSharedStuff.tickStart = BPSharedStuff.tickStart + 1
    if BPSharedStuff.tickStart % BPSharedStuff.tickControl == 0 then
        BPSharedStuff.tickStart = 0

        if BPSharedStuff.NEED_TO_CHECK == 0 then
            BPSharedStuff.NEED_TO_CHECK = 1; --passa o primeiro
            local player = getPlayer();
            -- check if need to start restrain
            if (player:getModData().isRestrained == true) then
                if BPSharedStuff.Verbose then print("IREI BLOQUEARRRR"); end
                ISTimedActionQueue.add(ISSelfRestrain:new(player:getPlayerNum()))
                if ISSelfRestrain.instance then
                    ISSelfRestrain.instance:doOverride();
                    if BPSharedStuff.Verbose then print("BLOQUEADO??????????"); end
                end
            end
        elseif BPSharedStuff.NEED_TO_CHECK == 1 then
            local player = getPlayer();
            if BPSharedStuff.Verbose then print("NEED_TO_CHECK " .. player:getUsername()); end
            
            if  ModData.getOrCreate("BPplayerData")[player:getUsername()] == nil then

                playerdataClient.addSetPlayer(player:getUsername(), {
                    isSurrendering = false,
                    isRestrained = false,
                });

                if BPSharedStuff.Verbose then print("NEED_TO_CHECK CREATED"); end
            else
                playerdataClient.addSetPlayer(player:getUsername(), {
                    isSurrendering = ModData.getOrCreate("BPplayerData")[player:getUsername()].isRestrained, --not an error, cause if the player are restrained they will be surrender, and if not, dont need more surrender
                    isRestrained = ModData.getOrCreate("BPplayerData")[player:getUsername()].isRestrained,
                });
                if BPSharedStuff.Verbose then print("NEED_TO_CHECK SEND TO SERVER"); end
            end
            BPSharedStuff.NEED_TO_CHECK = 2;
        end
	end
end

function BPSharedStuff.startTick ()
    Events.OnTick.Add(BPSharedStuff.onRenderTick)
end

if isClient() then
    Events.OnCreatePlayer.Add(BPSharedStuff.startTick)
end
