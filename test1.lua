local robot = require("robot")

function forceForward()
	if(robot.detect()) then
		robot.swing()
	end
	robot.forward()
end

local i = 0

for i=1, 2, 1 do
	robot.up()
end

for i=0, 101, 1 do
	robot.swingUp()
	forceForward()
end

robot.swingUp()

robot.turnLeft()
forceForward()
robot.turnLeft()

for i=0, 101, 1 do
	robot.swingUp()
	forceForward()
end

robot.swingUp()

for i=1, 2, 1 do
	robot.down()
end

robot.turnRight()
robot.forward()
robot.turnRight()