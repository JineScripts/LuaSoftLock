local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Settings
local AIM_FOV = 60 -- degrees field of view for aim assist
local AIM_RANGE = 100 -- studs max distance to consider targets
local AIM_SMOOTHNESS = 0.2 -- how fast the camera adjusts (0-1, higher is faster)

local aiming = false

-- Detect when player is touching and holding screen
UserInputService.TouchStarted:Connect(function(touch, gameProcessed)
    if gameProcessed then return end
    aiming = true
end)

UserInputService.TouchEnded:Connect(function(touch, gameProcessed)
    if gameProcessed then return end
    aiming = false
end)

local function getClosestTarget()
    local closestPlayer = nil
    local closestAngle = AIM_FOV
    local cameraCFrame = camera.CFrame
    local cameraPosition = cameraCFrame.Position
    local cameraLookVector = cameraCFrame.LookVector

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= localPlayer
            and player.Team ~= localPlayer.Team -- team check here
            and player.Character
            and player.Character:FindFirstChild("Head") then

            local head = player.Character.Head
            local directionToTarget = (head.Position - cameraPosition).Unit
            local distance = (head.Position - cameraPosition).Magnitude

            if distance <= AIM_RANGE then
                local angle = math.deg(math.acos(cameraLookVector:Dot(directionToTarget)))
                if angle < closestAngle then
                    closestAngle = angle
                    closestPlayer = player
                end
            end
        end
    end
    return closestPlayer
end

RunService.RenderStepped:Connect(function(deltaTime)
    if aiming then
        local target = getClosestTarget()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            local headPos = target.Character.Head.Position
            local cameraPos = camera.CFrame.Position

            local desiredLookVector = (headPos - cameraPos).Unit
            local currentLookVector = camera.CFrame.LookVector

            -- Smoothly interpolate between current look direction and target direction
            local newLookVector = currentLookVector:Lerp(desiredLookVector, AIM_SMOOTHNESS)

            -- Create new camera CFrame with smoothed look vector
            local newCameraCFrame = CFrame.new(cameraPos, cameraPos + newLookVector)

            camera.CFrame = newCameraCFrame
        end
    end
end)
