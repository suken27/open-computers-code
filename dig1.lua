--[[
	Digging routine for hole expansion
]]--

local robot = require("robot");
local comp = require("component");
local sides = require("sides");
local nav = require("navigationlib");
local os = require("os");

--[[ SETTINGS ]]--

-- Distance to the initial dig position
local initialDigPosition = {};

-- Restoring waypoint name
local RESTORING_WAYPOINT_NAME = "test";

-- Emptying inventory waypoint side
local EMPTY_INVENTORY_SIDE = sides.left;

-- Minimum percentage of energy to keep working
local MIN_ENERGY_PERCENTAGE = 0.1;

-- Time to wait to fully charge
local TIME_CHARGING = 10000;

--[[ INTERNAL FUNCTIONS ]]--

-- charges energy capacitor and empties the inventory
function restoreAndGoBack()
	local xRet, yRet, zRet = nav.getWaypoint(RESTORING_WAYPOINT_NAME);
	nav.goTo(xRet, yRet, zRet);
	emptyInv();
	os.sleep(TIME_CHARGING)
	nav.goTo(xRet * -1, yRet * -1, zRet * -1);
end

-- empties inventory and returns to the position it was
function emptyInv()
	nav.faceSide(EMPTY_INVENTORY_SIDE);
	local invSlots = robot.inventorySize();
	for i=1, invSlots, 1 do
		robot.select(i);
		robot.drop();
	end
	robot.select(1);
end

-- inventory check
function spaceCheck()
	local invSlots = robot.inventorySize();
	for i=1, invSlots, 1 do
		if robot.count(i) == 0 then
			return;
		end
	end
	-- if this executes, the inventory is full
	print("Inventory full, going to the storage system.")
	restoreAndGoBack();
end

-- energy check
function energyCheck()
	local maxEnergy = computer.maxEnergy();
	local energy = computer.energy();
	local minLevel = maxEnergy * MIN_ENERGY_PERCENTAGE;
	if(energy < minLevel) then
		print("Energy low, going to charge.");
		restoreAndGoBack();
	end
end

-- goes to the initial position
function goToInitial()

end

-- moves to the next position to mine
function move()
	
end

-- mines the block upwards or stores the liquid upwards
function mine()
	robot.swingUp()
	robot.drainUp()
end

-- main execution
function main()
	emptyInv();
end

print("Starting digging routine")
main()
print("Ending digging routine")