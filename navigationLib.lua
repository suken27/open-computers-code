--[[
	Common robot navigation functionality.
]]--

local navigationlib = {};

local robot = require("robot");
local comp = require("component");
local sides = require("sides");
local nav = comp.navigation;

--[[ SETTINGS ]]--

local WAYPOINT_SEARCH_RANGE = 200;

--[[ INTERNAL FUNCTIONS ]]--

-- Faces to positive X coordinate
function facePositiveX()
	local facing = nav.getFacing();
	if(facing == sides.right) then
		robot.turnAround();
	elseif(facing == sides.front) then
		robot.turnLeft();
	elseif(facing == sides.back) then
		robot.turnRight();
	end
end

-- Faces to negative X coordinate
function faceNegativeX()
	local facing = nav.getFacing();
	if(facing == sides.left) then
		robot.turnAround();
	elseif(facing == sides.front) then
		robot.turnRight();
	elseif(facing == sides.back) then
		robot.turnLeft();
	end
end

-- Faces to positive Z coordinate
function facePositiveZ()
	local facing = nav.getFacing();
	if(facing == sides.back) then
		robot.turnAround();
	elseif(facing == sides.right) then
		robot.turnLeft();
	elseif(facing == sides.left) then
		robot.turnRight();
	end
end

-- Faces to negative Z coordinate
function faceNegativeZ()
	local facing = nav.getFacing();
	if(facing == sides.front) then
		robot.turnAround();
	elseif(facing == sides.right) then
		robot.turnRight();
	elseif(facing == sides.left) then
		robot.turnLeft();
	end
end

-- Returns the distance to a given waypoint name
-- (a distance per coordinate)
function navigationlib.getWaypoint(name)
	local waypoints = nav.findWaypoints(WAYPOINT_SEARCH_RANGE);
	local i = 1;
	while(not (waypoints[i] == nil)) do
		if(waypoints[i].label == name) then
			return waypoints[i].position[1], waypoints[i].position[2], waypoints[i].position[3];
		end
		i = i + 1;
	end
	return nil;
end

-- Goes to a given waypoint
function navigationlib.goToWaypoint(name)
	navigationlib.goTo(navigationlib.getWaypoint(name));
end

-- Faces a given side
function navigationlib.faceSide(side)
	if(side == sides.back) then
		faceNegativeZ();
	elseif(side == sides.front) then
		facePositiveZ();
	elseif(side == sides.right) then
		faceNegativeX();
	elseif(side == sides.left) then
		facePositiveX();
	else
		error("Side is not valid.");
	end
end

-- Gives the oposite direction
function navigationlib.oposite(side)
	if(side == sides.left) then
		return sides.right;
	elseif(side == sides.right) then
		return sides.left;
	elseif(side == sides.front) then
		return sides.back;
	elseif(side == sides.back) then
		return sides.front;
	elseif(side == sides.top) then
		return sides.bottom;
	elseif(side == sides.bottom) then
		return sides.top;
	else
		error("Side:", side, "is not valid.");
	end
end

function navigationlib.getFacing()
	return nav.getFacing();
end

return navigationlib;
