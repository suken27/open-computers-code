--[[
	Common robot navigation functionality.
]]--

local robot = require("robot");
local comp = require("component");
local sides = require("sides");
local waypoint = require("waypoint");
local nav = require("nav");
local navcomp = comp.navigation;

local clsNavlib = {};

clsNavlib.title = "Navigation Library";
clsNavlib.shortTitle = "navlib";
clsNavlib.version = 0.1000;

--[[ OBJECT VARIABLES ]]--

clsNavlib.w = {};
clsNavlib.m = {};

--[[ LOCAL FUNCTIONS ]]--

--[[ METHODS ]]--

function clsNavlib:new()
	local object = {};
	setmetatable(object, self)
	self.__index = self
	return object
end

function clsNavlib:setNav(navObject)
	if(type(navObject ~= "table") then
		error("The given parameter was not a table.");
	end
	if(not navObject.title or navObject.title ~= "Navigation Library") then
		error("The given parameter was not a navigation object.");
	end
	self.m = navObject;
end

function clsNavlib:setWaypoint(waypointObject)
	if(type(waypointObject ~= "table") then
		error("The given parameter was not a table.");
	end
	if(not waypointObject.title or waypointObject.title ~= "Waypoint Library") then
		error("The given parameter was not a waypoint object.");
	end
	self.w = waypointObject;
end

function clsNavlib:go(coords)
	-- TODO I need to know how is the nav:go working
	-- if {1, 0, 0} is a distance or a relative position
end

-- Faces to positive X coordinate
function clsNavlib:facePositiveX()
	local facing = navcomp.getFacing();
	if(facing == sides.right) then
		robot.turnAround();
	elseif(facing == sides.front) then
		robot.turnLeft();
	elseif(facing == sides.back) then
		robot.turnRight();
	end
end

-- Faces to negative X coordinate
function clsNavlib:faceNegativeX()
	local facing = navcomp.getFacing();
	if(facing == sides.left) then
		robot.turnAround();
	elseif(facing == sides.front) then
		robot.turnRight();
	elseif(facing == sides.back) then
		robot.turnLeft();
	end
end

-- Faces to positive Z coordinate
function clsNavlib:facePositiveZ()
	local facing = navcomp.getFacing();
	if(facing == sides.back) then
		robot.turnAround();
	elseif(facing == sides.right) then
		robot.turnLeft();
	elseif(facing == sides.left) then
		robot.turnRight();
	end
end

-- Faces to negative Z coordinate
function clsNavlib:faceNegativeZ()
	local facing = navcomp.getFacing();
	if(facing == sides.front) then
		robot.turnAround();
	elseif(facing == sides.right) then
		robot.turnRight();
	elseif(facing == sides.left) then
		robot.turnLeft();
	end
end

-- Faces a given side
function clsNavlib:faceSide(side)
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
function clsNavlib:oposite(side)
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

function clsNavlib:getFacing()
	return navcomp.getFacing();
end

return clsNavlib;
