--[[
	Digging routine for hole expansion
]]--

local comp = require("component");
local robot = comp.robot;
local robotapi = require("robot");
local sides = require("sides");
local nav = require("navigationlib");
local navcomp = comp.navigation;
local os = require("os");
local computer = require("computer");

--[[ SETTINGS ]]--

-- Distance to the initial dig position
-- from the reference waypoint
local INITIAL_DIG_POSITION = {4, -14, 0};

-- Distance to the final dig position from
-- the reference waypoint
local FINAL_DIG_POSITION = {-14, -16, 9};

-- Restoring waypoint name
local RESTORING_WAYPOINT_NAME = "test";

-- Emptying inventory waypoint side
local EMPTY_INVENTORY_SIDE = sides.left;

-- Minimum percentage of energy to keep working
local MIN_ENERGY_PERCENTAGE = 0.1;

-- Time to wait to fully charge in seconds
local TIME_CHARGING = 10;

--[[ INTERNAL FUNCTIONS ]]--

-- Charges energy capacitor and empties the inventory
function restoreAndGoBack()
	local facing = navcomp.getFacing();
	local xRet, yRet, zRet = nav.getWaypoint(RESTORING_WAYPOINT_NAME);
	nav.goTo(xRet, yRet, zRet);
	emptyInv();
	os.sleep(TIME_CHARGING);
	nav.goTo((xRet * -1), (yRet * -1), (zRet * -1));
	nav.faceSide(facing);
end

-- Empties inventory and returns to the position it was
function emptyInv()
	nav.faceSide(EMPTY_INVENTORY_SIDE);
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
	local disWay = {};
	disWay[1], disWay[2], disWay[3] = nav.getWaypoint(RESTORING_WAYPOINT_NAME);
	local dis = distanceAToB(disWay, INITIAL_DIG_POSITION);
	nav.goTo(dis[1], dis[2], dis[3]);
end

-- Calculates the distance from the a point to the b point
function distanceAToB(a, b)
	local dist = {(a[1] - b[1]), (a[2] - b[2]), (a[3] - b[3])};
	return dist;
end

-- Moves in a different direction given by direction number
-- and deals with facing the right direction after it
function diferentDirectionMove(actualDirections, direction)
	if(not (actualDirections[direction] == sides.top or actualDirections[direction] == sides.bottom)) then
		nav.faceSide(actualDirections[direction]);
		work(sides.front);
		robot.move(sides.front);
	else
		work(actualDirections[direction]);
		correctMove(actualDirections[direction]);
	end
	for i = direction - 1, 1, -1 do
		actualDirections[i] = nav.oposite(actualDirections[i]);
	end
	if(not (actualDirections[1] == sides.top or actualDirections[1] == sides.bottom)) then
		nav.faceSide(actualDirections[1]);
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
function move(miningDirections, actualDirections)
	local wayDis = {};
	wayDis[1], wayDis[2], wayDis[3] = nav.getWaypoint(RESTORING_WAYPOINT_NAME);
	local stopDis = {};
	local disToFinal = distanceAToB(wayDis, FINAL_DIG_POSITION);
	local disToInitial = distanceAToB(wayDis, INITIAL_DIG_POSITION);
	local notFound = true;
	local j = 1;
	for i = 1, 3, 1 do
		while(notFound) do
			if(miningDirections[j] == actualDirections[i]) then
				notFound = false;
				if(j%2 == 0) then
					stopDis[i] = disToInitial[i];
				else
					stopDis[i] = disToFinal[i];
				end
			end
			j = j + 1;
		end
		notFound = true;
		j = 1;
	end
	if(stopDis[sideToCoord(actualDirections[1])] == 0) then
		if(stopDis[sideToCoord(actualDirections[2])] == 0) then
			if(stopDis[sideToCoord(actualDirections[3])] == 0) then
				return false;
			else
				diferentDirectionMove(actualDirections, 3);
			end
		else
			diferentDirectionMove(actualDirections, 2);
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
		robotapi.swingUp();
		robotapi.drainUp();
	elseif(direction == sides.bottom) then
		robotapi.swingDown();
		robotapi.drainDown();
	else
		robotapi.swing();
		robotapi.drain();
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
	print("DEBUG: Distances:", values[1], values[2], values[3]);
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
	print("DEBUG: Directions:", result[1], result[2], result[3], result[4], result[5], result[6]);
	return result;
end

-- Main execution
function main()
	print("Begining the preparations...");
	goToInitial();
	local miningDirections = getMiningDirections();
	local actualDirections = {miningDirections[1], miningDirections[3], miningDirections[5]};
	if(not (actualDirections[1] == sides.top or actualDirections[1] == sides.bottom)) then
		nav.faceSide(actualDirections[1]);
	end
	print("Preparations done, starting digging routine.");
	while(move(miningDirections, actualDirections)) do
		energyCheck();
		spaceCheck();
	end
	nav.goToWaypoint(RESTORING_WAYPOINT_NAME);
	print("Digging routine successfully finished.");
end

main();

-- V8