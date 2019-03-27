--[[
	Common robot navigation functionality.
]]--

local navigationlib = {};

local robot = require("robot");
local comp = require("component");
local sides = require("sides");
local nav = comp.navigation;

-- Faces to positive X coordinate
function navigationlib.facePositiveX()
	while(not (nav.getFacing() == sides.left)) do
		robot.turnRight();
	end
end

-- Faces to negative X coordinate
function navigationlib.faceNegativeX()
	while(not (nav.getFacing() == sides.right)) do
		robot.turnRight();
	end
end

-- Faces to positive Z coordinate
function navigationlib.facePositiveZ()
	while(not (nav.getFacing() == sides.front)) do
		robot.turnRight();
	end
end

-- Faces to negative Z coordinate
function navigationlib.faceNegativeZ()
	while(not (nav.getFacing() == sides.back)) do
		robot.turnRight();
	end
end

-- Goes to a given X position given by the difference 
-- with the actual position
function navigationlib.goToX(xDif)
	if(xDif == 0) then
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
function navigationlib.goToZ(zDif)
	if(zDif == 0) then
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
function navigationlib.goToY(yDif)
	if(yDif == 0) then
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
	local waypoints = nav.findWaypoints(200);
	local length = table.getn(waypoints);
	for i=1, length, 1 do
		if(waypoints[i].label == name) then
			return waypoints[i].position[1], waypoints[i].position[2], waypoints[i].position[3];
		end
	end
	return nil;
end

navigationlib.getWaypoint(test);

return navigationlib;
