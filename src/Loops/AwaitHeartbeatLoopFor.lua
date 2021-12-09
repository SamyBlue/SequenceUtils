local RunService = game:GetService("RunService")
local clock = RunService:IsRunning() and time or os.clock

local AwaitHeartbeatLoopFor = function (timeLength, inputFunction, callback) --yields current thread until completion
	local connection
	local initTime = clock()

	local bindable = Instance.new("BindableEvent")
	local callbackRan = false

	connection = RunService.Heartbeat:Connect(function (timeStep)
		local timePassed = clock() - initTime

		if timePassed < timeLength then
			inputFunction(timePassed, timeStep, timePassed / timeLength)
		else
			if callbackRan == true or callback == nil then
				if bindable ~= nil then
					bindable:Fire()
				end
				if connection ~= nil then
					connection:Disconnect()
					connection = nil
				end
			else
				callbackRan = true -- In case callback throws an error -> connection disconnects on next heartbeat
				callback()
				
				if bindable ~= nil then
					bindable:Fire()
				end
				if connection ~= nil then
					connection:Disconnect() -- Disconnects after callback for proper ordering
					connection = nil
				end
			end
		end
	end)

	bindable.Event:Wait()
	bindable:Destroy()
end

return AwaitHeartbeatLoopFor