--[[
	Digging routine for hole expansion
]]--

local robot = require("robot")
local comp = require("component")
local sides = require("sides")
local nav = comp.navigation

-- goes to a given X distance
function goToX(xDis)
	if(xDis == 0) then
		return
	end
	if(xDis < 0) then
		while(not nav.getFacing() == sides.left) do
			robot.turnRight()
		end
	else
		while(not nav.getFacing() == sides.right) do
			robot.turnRight()
		end
	end
	for i=1, math.abs(xDis), 1 do
		robot.forward()
	end
end

-- goes to given distances letting the y coordinate to the end
function goToAbove(xDis, yDis, zDis)
	
end

-- empties inventory and returns to the position it was
function emptyInv()

end

-- inventory check
function spaceCheck()
	local invSlots = robot.inventorySize()
	for i=1, invSlots, 1 do
		if robot.count(i) == 0 then
			return
		end
	end
	-- if this executes, the inventory is full
	print("Inventory full, going to the storage system.")
	emptyInv()
end

-- energy check
function energyCheck()
	local maxEnergy = computer.maxEnergy()
	local energy = computer.energy()
	local minLevel = maxEnergy * 0.1
	if(energy < minLevel) then
		print("Energy low, going to charge.")
		-- TODO returning to the charger
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
	goToX(-20)
end

print("Starting digging routine")
main()
print("Ending digging routine")