--!nocheck

local RepS = game:GetService("ReplicatedStorage")
local RS = game:GetService("RunService")

local Signal = require(RepS.HarukaShared.Shared.Signal)

local HarukaTypeWriter = {}
HarukaTypeWriter.__index = HarukaTypeWriter


function HarukaTypeWriter.new()
	local self = setmetatable({}, HarukaTypeWriter)

	self.Stopped = false
	self.Running = false

	self.OnTyperFinished = Signal.new()
	self.OnUTFUpdated = Signal.new()

	return self
end


--[[
	Queue a task to type text
]]
function HarukaTypeWriter:TypeText(text: string)
	self:Stop()

	self.Stopped = false
	self.Running = true

	text = string.gsub(text, "<br%s*/>", "\n")
	text = string.gsub(text, "<[^<>]->", "")

	local index = 0
	for first, last in utf8.graphemes(text) do
		if self.Stopped then break end

		index += 1

		self.OnUTFUpdated:Fire(index)
		task.wait(0.01)
	end


	self.Running = false
	self.OnTyperFinished:Fire()
end


function HarukaTypeWriter:Stop()
	self.Paused = false
	self.Stopped = true

	while self.Running do
		RS.Heartbeat:Wait()
	end
end



function HarukaTypeWriter:IsTyping()
	return self.Running
end


function HarukaTypeWriter:Destroy()
	self.Paused = false
	self.Stopped = true

	self.OnTyperFinished:Destroy()
	self.OnUTFUpdated:Destroy()

	while self.Running do
		RS.Heartbeat:Wait()
	end
end

return HarukaTypeWriter
