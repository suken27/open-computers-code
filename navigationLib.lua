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
	while(not (nav.getFacing() == sides.left)) do
		robot.turnRight();
	end
end

-- Faces to negative X coordinate
function faceNegativeX()
	while(not (nav.getFacing() == sides.right)) do
		robot.turnRight();
	end
end

-- Faces to positive Z coordinate
function facePositiveZ()
	while(not (nav.getFacing() == sides.front)) do
		robot.turnRight();
	end
end

-- Faces to negative Z coordinate
function faceNegativeZ()
	while(not (nav.getFacing() == sides.back)) do
		robot.turnRight();
	end
end

-- Goes to a given X position given by the difference 
-- with the actual position
function goToX(xDif)
	if(xDif == 0 or xDif == nil) then
		return;
	end
	local value = math.abs(xDif);
	if(xDif < 0) then
		faceNegativeX();
	else
		facePositiveX();
	end
	for i=1, value, 1 do
		robot.forward();
	end
end

-- Goes to a given Z position given by the difference 
-- with the actual position
function goToZ(zDif)
	if(zDif == 0 or zDif == nil) then
		return;
	end
	local value = math.abs(zDif);
	if(zDif < 0) then
		faceNegativeZ();
	else
		facePositiveZ();
	end
	for i=1, value, 1 do
		robot.forward();
	end
end

-- Goes to a given Y position given by the difference 
-- with the actual position
function goToY(yDif)
	if(yDif == 0 or yDif == nil) then
		return;
	end
	local value = math.abs(yDif);
	
	if(yDif < 0) then
		for i=1, value, 1 do
			robot.down();
		end
	else
		for i=1, value, 1 do
			robot.up();
		end
	end
end

--[[ MODULE FUNCTIONS ]]--

-- Goes to a position given by the difference with
-- the actual position
function navigationlib.goTo(xDif, yDif, zDif)
	goToX(xDif);
	goToZ(zDif);
	goToY(yDif);
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
		error("Side: '" + side + "' is not valid.");
	end
end

return navigationlib;
