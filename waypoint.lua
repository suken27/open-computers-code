local component = require("component");
local navigation = component.navigation;

local clsWaypoint = {};

--[[ OBJECT VARIABLES ]]--

clsWaypoint.waypointSearchRange = 200;
clsWaypoint.name;
clsWaypoint.waypointCoordinates;

--[[ LOCAL FUNCTIONS ]]--

--[[ METHODS ]]--

-- Constructor
function clsWaypoint:new(name, coords, waypointSearchRange)
	local object = {};
	if(not name or not coords) then
		return false, "Name and coordinates are needed.";
	end
	if(type(coords) ~= "table") then
		return false, "The coordinates' format is {x, y, z}.";
	end
	if(type(coords[1]) ~= "number" or type(coords[2]) ~= "number" or type(coords[3]) ~= "number") then
		return false, "All three coordinates need to be valid numbers.";
	end
	object.name = name;
	object.coords = waypointCoordinates;
	if(type(waypointCoordinates) == "number") then
		object.waypointCoordinates = waypointSearchRange;
	end
	setmetatable(object, self)
	self.__index = self
	local ok, message = self.getWaypoint();
	if(not ok) then
		return false, message;
	end
	return object
end

-- Returns the distance to this waypoint
function clsWaypoint:getWaypoint()
	local waypoints = nav.findWaypoints(WAYPOINT_SEARCH_RANGE);
	local i = 1;
	while(not (waypoints[i] == nil)) do
		if(waypoints[i].label == self.name) then
			return waypoints[i].position[1], waypoints[i].position[2], waypoints[i].position[3];
		end
		i = i + 1;
	end
	return false, "The waypoint is not in range";
end

-- Calculates the distance from the robot to a given coordinates
function clsWaypoint:distance(coords)
	result = {};
	actual = self.getWaypoint();
	for i = 1, 3, 1 do
		result[i] = coords[i] - self.coords[i];
	end
	return result;
end

return waypoint;