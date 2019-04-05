--[[
	Digging routine
]]--

local comp = require("component");
local robot = comp.robot;
local robotapi = require("robot");
local sides = require("sides");
local navlib = require("navlib");
local nav = require("nav");
local os = require("os");
local computer = require("computer");
local waypoint = require("waypoint");

local clsDig = {};
clsDig.title = "Dig Routine";
clsDig.shortTitle = "dig";
clsDig.version = 0.1000;

--[[ OBJECT VARIABLES ]]--

clsDig.initialDigPosition = {};
clsDig.finalDigPosition = {};
clsDig.restoringWaypointCoords = {};
clsDig.restoringWaypointName = {};
clsDig.emptyInventorySide = 0;
clsDig.minEnergyPercentage = 0.2;
clsDig.timeCharging = 20;
clsDig.w = {};
clsDig.m = nav:new();

--[[ SETTINGS ]]--

local INITIAL_DIG_POSITION = {850, 20, -756};
local FINAL_DIG_POSITION = {853, 19, -758};

-- Restoring waypoint coordinates
local RESTORING_WAYPOINT_COORDS = {854, 4, -753};

-- Restoring waypoint name
local RESTORING_WAYPOINT_NAME = "test";

-- Emptying inventory waypoint side
local EMPTY_INVENTORY_SIDE = sides.left;

-- Minimum percentage of energy to keep working
local MIN_ENERGY_PERCENTAGE = 0.2;

-- Time to wait to fully charge in seconds
local TIME_CHARGING = 20;

local w = waypoint:new(RESTORING_WAYPOINT_NAME, RESTORING_WAYPOINT_COORDS);
local m = nav:new();

--[[ LOCAL FUNCTIONS ]]--

function go(distance)
	navlib.faceSide(sides.front);
	m:setPos({-1, 0, 0});
	m:setPos(0);
	m:putMap({-1, 0, 0}, {});
	m:go({distance[3], distance[1] * -1, distance[2]});
end

-- Charges energy capacitor and empties the inventory
function restoreAndGoBack()
	local facing = navlib.getFacing();
	local wayp = w:getWaypoint();
	go(wayp);
	emptyInv();
	os.sleep(TIME_CHARGING);
	go({wayp[1] * -1, wayp[2], wayp[3] * -1});
	navlib.faceSide(facing);
end

-- Empties inventory and returns to the position it was
function emptyInv()
	navlib.faceSide(EMPTY_INVENTORY_SIDE);
	local invSlots = robot.inventorySize();
	for i=1, invSlots, 1 do
		robot.select(i);
		robot.drop(sides.front);
	end
	robot.select(1);
end

-- Inventory check
function spaceCheck()
	local invSlots = robot.inventorySize();
	for i=1, invSlots, 1 do
		if robot.count(i) == 0 then
			return;
		end
	end
	-- if this executes, the inventory is full
	print("Inventory full, going to the storage system.");
	restoreAndGoBack();
end

-- Energy check
function energyCheck()
	local maxEnergy = computer.maxEnergy();
	local energy = computer.energy();
	local minLevel = maxEnergy * MIN_ENERGY_PERCENTAGE;
	if(energy < minLevel) then
		print("Energy low, going to charge.");
		restoreAndGoBack();
	end
end

-- Goes to the initial position
function goToInitial()
	local dis = w:distance(INITIAL_DIG_POSITION);
	go(dis);
end

-- Calculates the distance from the a point to the b point
function distanceAToB(a, b)
	local dist = {(b[1] - a[1]), (b[2] - a[2]), (b[3] - a[3])};
	return dist;
end

-- Moves in a different direction given by direction number
-- and deals with facing the right direction after it
function diferentDirectionMove(actualDirections, actualDirections2, direction)
	if(not (actualDirections[direction] == sides.top or actualDirections[direction] == sides.bottom)) then
		navlib.faceSide(actualDirections[direction]);
		work(sides.front);
		robot.move(sides.front);
	else
		work(actualDirections[direction]);
		correctMove(actualDirections[direction]);
	end
	for i = direction - 1, 1, -1 do
		actualDirections[i] = navlib.oposite(actualDirections[i]);
		actualDirections2[i] = not actualDirections2[i];
	end
	if(not (actualDirections[1] == sides.top or actualDirections[1] == sides.bottom)) then
		navlib.faceSide(actualDirections[1]);
	end
end

-- Returns the corresponding axis from a given side
function sideToCoord(side)
	if(side == sides.left or side == sides.right) then
		return 1;
	elseif(side == sides.top or side == sides.bottom) then
		return 2;
	elseif(side == sides.front or side == sides.back) then
		return 3;
	else
		error("Something went wrong.");
	end
end

-- Moves to the next position to mine, it recieves
-- the local state of the movement and the minning
-- direction
function move(miningDirections, actualDirections, actualDirections2)
	local stopDis = {};
	local disToFinal = w:distance(FINAL_DIG_POSITION);
	local disToInitial = w:distance(INITIAL_DIG_POSITION);
	local notFound = true;
	local j = 1;
	for i = 1, 3, 1 do
		if(actualDirections2[i]) then
			stopDis[i] = disToFinal[sideToCoord(actualDirections[i])];
		else
			stopDis[i] = disToInitial[sideToCoord(actualDirections[i])];
		end
	end
	if(stopDis[1] == 0) then
		if(stopDis[2] == 0) then
			if(stopDis[3] == 0) then
				return false;
			else
				diferentDirectionMove(actualDirections, actualDirections2, 3);
			end
		else
			diferentDirectionMove(actualDirections, actualDirections2, 2);
		end
	else
		work(actualDirections[1]);
		correctMove(actualDirections[1]);
	end
	return true;
end

-- Mines the block and stores the fluid in a given direction
function work(direction)
	if(direction == sides.top) then
		_, substance = robotapi.detectUp();
		if(substance == "solid" or substance == "replaceable" or substance == "passable") then
			robotapi.swingUp();
		elseif(substance == "liquid") then
			robotapi.drainUp();
		end
	elseif(direction == sides.bottom) then
		_, substance = robotapi.detectDown();
		if(substance == "solid" or substance == "replaceable" or substance == "passable") then
			robotapi.swingDown();
		elseif(substance == "liquid") then
			robotapi.drainDown();
		end
	else
		_, substance = robotapi.detect();
		if(substance == "solid" or substance == "replaceable" or substance == "passable") then
			robotapi.swing();
		elseif(substance == "liquid") then
			robotapi.drain();
		end
	end
end

function correctMove(direction)
	if(direction == sides.top or direction == sides.bottom) then
		robot.move(direction);
	else
		robot.move(sides.front);
	end
end

-- Returns the ordered mining directions.
function getMiningDirections()
	local d = distanceAToB(INITIAL_DIG_POSITION, FINAL_DIG_POSITION);
	local values = {math.abs(d[1]), math.abs(d[2]), math.abs(d[3])};
	for i = 1, 3, 1 do
		for j = i+1, 3, 1 do
			if(values[i] < values[j]) then
				local aux = values[i];
				values[i] = values[j];
				values[j] = aux;
			end
		end
	end
	local result = {};
	local asigned = {false, false, false};
	for i = 1, 3, 1 do
		if(math.abs(d[1]) == values[i] and not asigned[1]) then
			asigned[1] = true;
			if(d[1] > 0) then
				result[i*2-1] = sides.left;
				result[i*2] = sides.right;
			else
				result[i*2-1] = sides.right;
				result[i*2] = sides.left;
			end
		elseif(math.abs(d[2]) == values[i] and not asigned[2]) then
			asigned[2] = true;
			if(d[2] > 0) then
				result[i*2-1] = sides.top;
				result[i*2] = sides.bottom;
			else
				result[i*2-1] = sides.bottom;
				result[i*2] = sides.top;
			end
		elseif(math.abs(d[3]) == values[i] and not asigned[3]) then
			asigned[3] = true;
			if(d[3] > 0) then
				result[i*2-1] = sides.front;
				result[i*2] = sides.back;
			else
				result[i*2-1] = sides.back;
				result[i*2] = sides.front;
			end
		else
			error("Something went wrong.");
		end
	end
	return result;
end

-- Main execution
function main()
	print("Begining the preparations...");
	goToInitial();
	local miningDirections = getMiningDirections();
	local actualDirections = {miningDirections[1], miningDirections[3], miningDirections[5]};
	local actualDirections2 = {true, true, true};
	if(not (actualDirections[1] == sides.top or actualDirections[1] == sides.bottom)) then
		navlib.faceSide(actualDirections[1]);
	end
	print("Preparations done, starting digging routine.");
	while(move(miningDirections, actualDirections, actualDirections2)) do
		energyCheck();
		spaceCheck();
	end
	go(w:getWaypoint());
	print("Digging routine successfully finished.");
end

--[[ METHODS ]]--

functioni clsDig:new()

end

function clsDig:dig()

end

main();