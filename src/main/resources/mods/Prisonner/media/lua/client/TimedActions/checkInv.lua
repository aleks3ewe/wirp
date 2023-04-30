
require "TimedActions/ISBaseTimedAction"

ISCheckInv = ISBaseTimedAction:derive("ISCheckInv");

function ISCheckInv:isValid()
	return true;
end

function ISCheckInv:update()
end

function ISCheckInv:start()
end

function ISCheckInv:stop()
    ISBaseTimedAction.stop(self);
end

function ISCheckInv:perform()
    -- needed to remove from queue / start next.

	if math.abs(self.character:getX() - self.targetPlayer:getX()) <= 2 and math.abs(self.character:getY() - self.targetPlayer:getY()) <= 2 then
		ISBaseTimedAction.perform(self);
		processSayMessage(tostring(self.currentItem));
	else
		ISBaseTimedAction.stop(self);
	end
end

function ISCheckInv:new(player, time, currentItem, targetP)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.character = getPlayerByOnlineID(player);
	o.targetPlayer = targetP;
	o.stopOnWalk = true;
	o.stopOnRun = true;
	o.maxTime = time;
    o.currentItem = currentItem;
	return o;
end
