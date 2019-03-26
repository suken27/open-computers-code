--[[
	Common robot navigation functionality.
]]--

local robot = require("robot")
local comp = require("component")
local sides = require("sides")
local nav = comp.navigation

local navigationLib = {};

-- Faces to positive X coordinate
function navigationLib.facePositiveX()
	while(not (nav.getFacing() == sides.left)) do
		robot.turnRight();
	end
end

-- Faces to negative X coordinate
function navigationLib.faceNegativeX()
	while(not (nav.getFacing() == sides.right)) do
		robot.turnRight();
	end
end

-- Faces to positive Z coordinate
function navigationLib.facePositiveZ()
	while(not (nav.getFacing() == sides.front)) do
		robot.turnRight();
	end
end

-- Faces to negative Z coordinate
function navigationLib.faceNegativeZ()
	while(not (nav.getFacing() == sides.back)) do
		robot.turnRight();
	end
end

-- Goes to a given X position given by the difference 
-- with the actual position
function navigationLib.goToX(xDif)
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
function navigationLib.goToZ(zDif)
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
function navigationLib.goToY(yDif)
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
function navigationLib.goTo(xDif, yDif, zDif)
	goToX(xDif);
	goToZ(zDif);
	goToY(yDif);
end

navigationLib.goTo(5, 6, 7)
navigationLib.goTo(-5, -6, -7)

return navigationLib
