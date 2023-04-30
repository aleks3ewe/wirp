--***********************************************************
--**                    ROBERT JOHNSON                     **
--***********************************************************

require "TimedActions/ISBaseTimedAction"

SearchPlayerAction = ISBaseTimedAction:derive("SearchPlayerAction");


function SearchPlayerAction:isValid()
	return self.character:getAccessLevel() ~= "None" or (self.otherPlayerX == self.otherPlayer:getX() and self.otherPlayerY == self.otherPlayer:getY());
end

function SearchPlayerAction:waitToStart()
    if self.character:isSeatedInVehicle() then
        return false
    end
    self.character:faceThisObject(self.otherPlayer)
    return self.character:shouldBeTurning()
end

function SearchPlayerAction:update()
    self.character:faceThisObject(self.otherPlayer)
    if math.abs(self.character:getX() - self.otherPlayer:getX()) > 2 or math.abs(self.character:getY() - self.otherPlayer:getY()) > 2 then
        ISBaseTimedAction.forceStop(self);
    end
end

function SearchPlayerAction:start()
    self:setActionAnim("MedicalCheck")
end

function SearchPlayerAction:stop()
    ISBaseTimedAction.stop(self);
end

function SearchPlayerAction:perform()

    local playerNum = self.character:getPlayerNum()
    local x = getPlayerScreenLeft(playerNum) + 70
    local y = getPlayerScreenTop(playerNum) + 50

    local ui = nil
    ui = SearchPlayerUI:new(50,50,500,500, self.character, self.otherPlayer)
    ui:initialise()
    ui:addToUIManager();

    -- needed to remove from queue / start next.
    ISBaseTimedAction.perform(self);
end

function SearchPlayerAction:new(character, otherPlayer)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.character = character;
	o.otherPlayer = otherPlayer;
    o.otherPlayerX = otherPlayer:getX();
    o.otherPlayerY = otherPlayer:getY();
    o.stopOnWalk = true;
	o.stopOnRun = true;
	o.maxTime = 400 - (character:getPerkLevel(Perks.Nimble) * 10);
    o.forceProgressBar = true;
    if character:isTimedActionInstant() then
        o.maxTime = 2;
    end
	return o;
end

local createFn = ISAdminPanelUI.create;
ISAdminPanelUI.create = function(self)
    createFn(self)

    if getAccessLevel() == "observer" then
        self.itemListBtn.enable = false;
    end
end;

local updateButtonsFn = ISAdminPanelUI.updateButtons;
ISAdminPanelUI.updateButtons = function(self)
    updateButtonsFn(self)

    if getAccessLevel() == "observer" then
        self.itemListBtn.enable = false;
    end
end;

