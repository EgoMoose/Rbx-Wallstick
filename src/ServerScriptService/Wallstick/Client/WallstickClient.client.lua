local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Wallstick = ReplicatedStorage:WaitForChild("Wallstick")
local ReplicationEvent = Wallstick:WaitForChild("Remotes"):WaitForChild("ReplicatePhysics")

