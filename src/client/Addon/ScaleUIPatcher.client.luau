
local Players = game:GetService("Players")

local plr = Players.LocalPlayer
local plrGui = plr.PlayerGui


type StrokeInfo = { Thickness: number, UIScale: UIScale? }
type ScaleInfo = { Scale: number, UIScale: UIScale? }


local camera = workspace.CurrentCamera


local normalPath2ds: { [Path2D]: StrokeInfo } = {}
local normalScales: { [ImageLabel]: ScaleInfo } = {}

local DESIGN_VP_SIZE = Vector2.new(1172, 478.4)


--// Helper functions

local function _calScreenRatio() : number
	local x = camera.ViewportSize.X / DESIGN_VP_SIZE.X
	local y = camera.ViewportSize.Y / DESIGN_VP_SIZE.Y

	local ratio = (x + y) / 2
	return ratio
end
local function _updatePath2D(path2d: Path2D, info: {
	Thickness: number,
	UIScale: UIScale?
})
	local scale = 1
	if info.UIScale then scale = info.UIScale.Scale end

    local finalThickness = info.Thickness * _calScreenRatio() * scale
    finalThickness = math.clamp(finalThickness, 1, 999)

    stroke.Thickness = finalThickness
end
local function _updateSliceScale(imageLabel: ImageLabel, info: {
    Scale: number,
    UIScale: UIScale?
})
    local scale = 1
    if info.UIScale then scale = info.UIScale.Scale end

    local finalScale = info.Scale * _calScreenRatio() * scale
    finalScale = math.clamp(finalScale, 0.1, 999)

    imageLabel.SliceScale = finalScale
end




local function _updateSize()
	for path2d, info in normalPath2ds do
		if not path2d.Parent then
			normalPath2ds[path2d] = nil
		else
			_updatePath2D(path2d, info)
		end
	end
    for imageLabel, info in normalScales do
        if not imageLabel.Parent then
            normalScales[imageLabel] = nil
        else
            _updateSliceScale(imageLabel, info)
        end
    end
end
local function _descendantAdded(added: Instance)
	if added:IsA("Path2D")
		and not added:GetAttribute("_ScaleUIPatcher_Transformed") then

        normalPath2ds[added] = {
            Thickness = added.Thickness,
            UIScale = added:FindFirstAncestorOfClass("UIScale")
        }
        _updatePath2D(added, normalPath2ds[added])


		added:SetAttribute("_ScaleUIPatcher_Transformed", true)

    elseif added:IsA("ImageLabel")
        and not added:GetAttribute("_ScaleUIPatcher_Transformed")
        and added.ScaleType == Enum.ScaleType.Slice then

        normalScales[added] = {
            Scale = added.SliceScale,
            UIScale = added:FindFirstAncestorOfClass("UIScale")
        }
        _updateSliceScale(added, normalScales[added])

        added:SetAttribute("_ScaleUIPatcher_Transformed", true)
	end
end


--// Init

for _, child: Instance in plrGui:GetDescendants() do
	_descendantAdded(child)
end
plrGui.DescendantAdded:Connect(_descendantAdded)


workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(_updateSize)