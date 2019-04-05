local component = require("component");
local nav = component.navigation;

local clsWaypoint = {};
clsWaypoint.title = "Waypoint Library";
clsWaypoint.shortTitle = "waypoint";
clsWaypoint.version = 0.1000;

--[[ OBJECT VARIABLES ]]--

clsWaypoint.waypointSearchRange = 200;
clsWaypoint.name = "";
clsWaypoint.waypointCoordinates = {0, 0, 0};

--[[ LOCAL FUNCTIONS ]]--

--[[ METHODS ]]--

-- Constructor
function clsWaypoint:new(name, coords, waypointSearchRange)
	local object = {};
	if(not name or not coords) then
		error("Name and coordinates are needed.");
	end
	if(type(coords) ~= "table") then
		error("The coordinates' format is {x, y, z}.");
	end
	if(type(coords[1]) ~= "number" or type(coords[2]) ~= "number" or type(coords[3]) ~= "number") then
		error("All three coordinates need to be valid numbers.");
	end
	object.name = name;
	object.waypointCoordinates = coords;
	if(type(waypointSearchRange) == "number") then
		object.waypointSearchRange = waypointSearchRange;
	end
	setmetatable(object, self)
	self.__index = self
	return object
end

function clsWaypoint:new()
	local object = {};
	setmetatable(object, self)
	self.__index = self
	return object
end

function clsWaypoint:setName(name)
	if(not name) then
		error("A name is needed.");
	end
	self.name = name;
end

function clsWaypoint:setCoordinates(coordinates)
	if(type(coordinates) ~= "table") then
		error("The coordinates' format is {x, y, z}.");
	end
	if(type(coordinates[1]) ~= "number" or type(coordinates[2]) ~= "number" or type(coordinates[3]) ~= "number") then
		error("All three coordinates need to be valid numbers.");
	end
	self.waypointCoordinates = coordinates;
end

function clsWaypoint:setWaypointSearchRange(searchRange)
	if(not type(searchRange) == "number" or searchRange < 0) then
		error("The waypoint search range must be a positive number.");
	end
	self.waypointSearchRange = searchRange;
end

-- Returns the distance to this waypoint
function clsWaypoint:getWaypoint()
	local waypoints = nav.findWaypoints(self.waypointSearchRange);
	local i = 1;
	while(not (waypoints[i] == nil)) do
		if(waypoints[i].label == self.name) then
			local result = {waypoints[i].position[1], waypoints[i].position[2], waypoints[i].position[3]};
			return result;
		end
		i = i + 1;
	end
	error("The waypoint is not in range");
end

-- Calculates the distance from the robot to a given coordinates
function clsWaypoint:distance(coords)
	local result = {};
	local actual = self:getWaypoint();
	local fixedCoords = {self.waypointCoordinates[1] - coords[1], self.waypointCoordinates[2] - coords[2], self.waypointCoordinates[3] - coords[3]};
	for i = 1, 3, 1 do
		result[i] =  actual[i] - fixedCoords[i];
	end
	return result;
end

return clsWaypoint;