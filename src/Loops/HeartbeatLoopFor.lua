local RunService = game:GetService("RunService")
local clock = time

local HeartbeatLoopFor = function (timeLength, inputFunction, callback)
	local connection
	local initTime = clock()
	
	local callbackRan = false
	
	connection = RunService.Heartbeat:Connect(function (timeStep)
		local timePassed = clock() - initTime

		if timePassed < timeLength then
			inputFunction(timePassed, timeStep, timePassed / timeLength)
		else
			if callbackRan == true or callback == nil then
				if connection ~= nil then
					connection:Disconnect()
					connection = nil
				end
			else
				callbackRan = true -- In case callback throws an error -> connection disconnects on next heartbeat
				callback()
				
				if connection ~= nil then
					connection:Disconnect() -- Disconnects after callback for proper ordering
					connection = nil
				end
			end
		end
	end)
end

return HeartbeatLoopFor