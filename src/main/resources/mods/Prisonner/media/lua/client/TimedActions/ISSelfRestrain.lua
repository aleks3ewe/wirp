--***********************************************************
--**                    Tchernobill                        **
--***********************************************************

require "mods.Prisonner.media.lua.shared.PrisonnerCommons"
require "TimedActions/ISBaseTimedAction"
require "Restrain_keybinding"

ISSelfRestrain = ISBaseTimedAction:derive("ISSelfRestrain");

ISSelfRestrain.allowedActions = {
["ISEnterVehicle"]=true,
["ISExitVehicle"]=true
}

function ISSelfRestrain:isValid()
    return true
end

function ISSelfRestrain:waitToStart()
    return false
end

function ISSelfRestrain:update()
    --in case an surrender action was broken by shove or other action:
    if self.character:getCharacterActions():isEmpty() and not Restrain.isRestrainedByItem(self.character) then
        self:setActionAnim("surrender")--surrender action is also default action
        if Restrain.Verbose then print ("ISSelfRestrain:update surrender anim request= "..tostring(self.character:getCharacterActions():isEmpty() and "empty anim" or "animated").." restrainingItem= "..tostring(Restrain.isRestrainedByItem(self.character) and "yes" or "no")) end
    end
    
    --TODO restrain all other actions: ensure nothing available to non admin can do ISTimedActionQueue.clear
    --speed can be modified by adding an invisible wornbag with high speed reduction
    
    if self.subAction then
        if not self.subAction:isValid() then
            self.subAction:stop()--this is shitty, it could break the restraint.. which could be interesting anyway
        else
            self.subAction:update()
        end
        
    end
end

function ISSelfRestrain.OnServerCommand(mod, command, args)
    if mod ~= Prisonner.ModKey then return end

    if not ISSelfRestrain.instance then return end--todo log

    ISSelfRestrain.onDetectedCommand(ISSelfRestrain.instance, mod, command, args);
end

function ISSelfRestrain:onDetectedCommand(mod, command, args)
    if Restrain.Verbose then print ("ISSelfRestrain:onDetectedCommand mod= "..tostring(mod or "nil").." command= "..tostring(command or "nil")) end
    if not self.character:getModData().isRestrained and command == "Restrain" then--and player == self.character ?
        local itemType = nil;
        if args then
            itemType = args.restrainingItem
            if Restrain.Verbose then print ("ISSelfRestrain:onDetectedCommand Restrain restrainingItem = "..tostring(args.restrainingItem or "nil")) end
        else
            if Restrain.Verbose then print ("ISSelfRestrain:onDetectedCommand Restrain args = nil") end
        end
        self:doOverride(itemType)
    elseif self.character:getModData().isRestrained and command == "Free" then--and player == self.character ?
        local releaserPlayerOnlineID = nil
        if args then
            releaserPlayerOnlineID = args.source;
        end
        self:releaseOverride(releaserPlayerOnlineID);
    end
end

function ISSelfRestrain:start()
    local isRestrainedByItem = Restrain.isRestrainedByItem(self.character);
    if Restrain.Verbose then print ("ISSelfRestrain:start "..tostring(isRestrainedByItem and "HC worn" or "No restraining item.")) end

    if not isRestrainedByItem then
        self:setActionAnim("surrender")--surrender action is also default action
    end
    self:doSurrender()--discard all Timed Actions
    --self.character:setAsleep(false); --?? totest
    --self.character:setbFalling(true);--?? totest
    --self.character:setForceShove(true);--?? totest
    --self.character:setFallOnFront(true);--?? totest
    --self.character:setHitFromBehind(true);--?? totest
    --self.character:setBumpDone(true);--?? totest
    --self.character:setBumpFall(true);--?? totest
    --self.character:fallenOnKnees();--?? totest
end

function ISSelfRestrain:stop()
    if Restrain.Verbose then print ("ISSelfRestrain:stop") end
    
    self:releaseOverride()
    self:releaseSurrender()
    if self.subAction then self.subAction:forceStop() end
    --ISSelfRestrain.stopSubAction(subaction)--overkill? yes and dangerous for the self.action restart at character level
    self.subAction = nil
    if self.BaseTimedActionStop ~= nil then ISBaseTimedAction.stop = self.BaseTimedActionStop end
    self.BaseTimedActionStop = nil
    ISBaseTimedAction.forceStop(self);--stop anim action
    ISSelfRestrain.instance = nil;
end

function ISSelfRestrain:perform()
    if Restrain.Verbose then print ("ISSelfRestrain:perform") end
    self:stop();
end

function ISSelfRestrain:new(characterNum)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.character = getSpecificPlayer(characterNum);
    o.stopOnWalk = false;
    o.stopOnRun = false;
    o.maxTime = 1147483646;--keep some margin on max int for the moodles time penalties
    o.hookedOnCommands = false;
    ISSelfRestrain.instance = o;--store single static instance for function to method forward.. stupid me.
    return o;
end


--actions override
function ISSelfRestrain:doSurrender()
    if not self.upperLayeradd then
        self.upperLayeradd = ISTimedActionQueue.add --store the previous clear function
        ISTimedActionQueue.add = ISSelfRestrain.add --replace the clear with a dummy one
    end
    if not self.hookedOnCommands then
        Events.OnServerCommand.Add(ISSelfRestrain.OnServerCommand);
        self.hookedOnCommands = true;
    end
end
function ISSelfRestrain:releaseSurrender()
    if self.hookedOnCommands then
        Events.OnServerCommand.Remove(ISSelfRestrain.OnServerCommand);
        self.hookedOnCommands = false;
    end
    if self.upperLayeradd then
        ISTimedActionQueue.add = self.upperLayeradd
        self.upperLayeradd = nil
    end
end

function ISSelfRestrain:doOverride(itemType)
    if not self.upperLayerClear then
        self.upperLayerClear = ISTimedActionQueue.clear --store the previous clear function
        ISTimedActionQueue.clear = ISSelfRestrain.clear --replace the clear with a dummy one
    end
    
    local useRestrainingItem = Restrain.useRestrainingItem();
    local isRestrainedByItem = Restrain.isRestrainedByItem(self.character);
    
    if Restrain.Verbose then print ("ISSelfRestrain:doOverride HC "..tostring(useRestrainingItem and "active" or "inactive").." "..tostring(isRestrainedByItem and "worn" or "absent")) end
    
    if not useRestrainingItem or not isRestrainedByItem then
        self.character:dropHandItems();
    end
    Restrain.inhibitKeyBinding()
    self.character:setIgnoreAimingInput(true);
    self.character:getModData().isRestrained = true

    playerdataClient.updatePlayer(self.character:getUsername(), "isRestrained", true);
    
    if useRestrainingItem and not isRestrainedByItem and itemType then
        local handcuffItem = self.character:getInventory():AddItem(itemType);--create the same item type as the restrainer
        self.character:setPrimaryHandItem(handcuffItem)
        self.character:setSecondaryHandItem(handcuffItem)--TODO ensure this is dual wield item
        if self.action then 
            self.action:stopTimedActionAnim();
            if Restrain.Verbose then print ("ISSelfRestrain:doOverride stop anim action") end
        end
        ISInventoryPage.renderDirty = true
    end
end

function ISSelfRestrain:releaseOverride(releaserPlayerOnlineID)
    self.character:getModData().isRestrained = nil
    
    playerdataClient.updatePlayer(self.character:getUsername(), "isRestrained", false);

    self.character:setIgnoreAimingInput(false)--TODO ensure it must be set to true..
    Restrain.exhibitKeyBinding()
    if self.upperLayerClear then
        ISTimedActionQueue.clear = self.upperLayerClear
        self.upperLayerClear = nil
    end
    
    local useRestrainingItem = Restrain.useRestrainingItem();
    if Restrain.Verbose then print ("ISSelfRestrain:releaseOverride "..tostring(useRestrainingItem and "HC active" or "HC inactive")) end
    if useRestrainingItem then
        local restrainingItem = Restrain.getRestrainingItem(self.character);
        if Restrain.Verbose then print ("ISSelfRestrain:releaseOverride "..tostring(isRestrainedByItem and "HC worn" or "HC not worn")) end
        if restrainingItem then
            if releaserPlayerOnlineID then--todo ensure this is a player ? in case NPCs are created with capacity to free us. would we want the item on ground ?
                local restrainingItemType = restrainingItem:getFullType();
                self.character:setPrimaryHandItem(nil);
                self.character:setSecondaryHandItem(nil);
                self.character:getInventory():DoRemoveItem(restrainingItem);
                sendClientCommand(self.character, 'Prisonner', 'CreateItem', {target=releaserPlayerOnlineID,itemType=restrainingItemType});--remove and recreate into releaser inventory
            else
                self.character:dropHandItems();--drop on ground
            end

            self:setActionAnim("surrender");--surrender action for simple state machine despite the fact it is not optimal
        end
    end
end

ISSelfRestrain.clear = function(character)
    local self = ISSelfRestrain.instance
    if not self then return end--shit error
    if self.character == character then
        return ISTimedActionQueue.getTimedActionQueue(character)
    end
    return nil
end

ISSelfRestrain.add = function(action)
    local self = ISSelfRestrain.instance
    if not self then return end--shit error
    if not self.upperLayeradd then return end
    if not self.character == action.character then self.upperLayeradd(action) end
    if ISSelfRestrain.allowedActions[action.Type] and self.upperLayeradd and not self.subAction and action:isValid() then
        --todo add the action before SelfRestrain or play it as a subaction like ISSelfRestrain were a composite
        if not self.BaseTimedActionStop then
            self.BaseTimedActionStop = ISBaseTimedAction.stop;
            ISBaseTimedAction.stop = ISSelfRestrain.stopSubAction;--inhibit queue reset from subaction (smells fishy)
        end
        if not self.BaseTimedActionPerform then
            self.BaseTimedActionPerform = ISBaseTimedAction.perform;
            ISBaseTimedAction.perform = ISSelfRestrain.stopSubAction;--inhibit queue reset from subaction (smells fishy)
        end

        self.subAction = action;
        self.subAction:begin()--should I start it instead?
        if Restrain.Verbose then print ("ISSelfRestrain:add subaction began "..action.Type) end
    end
    if action == self and self.upperLayeradd then--lol just handling part of the fishy state that I should correct instead.
        self.upperLayeradd(self)--go back in the bugged queue. should I inhibit queue tick instead ?
    end
end

function ISSelfRestrain:releaseSubAction()
    self.subAction = nil;
    if self.BaseTimedActionStop then ISBaseTimedAction.stop = self.BaseTimedActionStop; end
    if self.BaseTimedActionPerform then ISBaseTimedAction.perform = self.BaseTimedActionPerform; end
    self.BaseTimedActionStop = nil
    self.BaseTimedActionPerform = nil
end
function ISSelfRestrain.stopSubAction(subaction)
    if Restrain.Verbose then print ("ISSelfRestrain:stopSubAction subaction stopped "..subaction.Type) end
    local self = ISSelfRestrain.instance
    if not self or not self.subAction then return end--shit error
    if self.subAction == subaction then
        self:releaseSubAction()
        if self.character and self.action then
            self.character:StartAction(self.action);--Yeepah! that's done
            
            if Restrain.Verbose then print ("ISSelfRestrain:stopSubAction subaction stopped surrender restarted Yeepah! "..subaction.Type) end
        else
            if Restrain.Verbose then print ("ISSelfRestrain:stopSubAction subaction stopped surrender not restarted "..subaction.Type) end
        end
    else
        if Restrain.Verbose then print ("ISSelfRestrain:stopSubAction subaction not stopped surrender not restarted "..subaction.Type) end
    end
end

