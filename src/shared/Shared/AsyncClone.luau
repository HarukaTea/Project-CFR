--!nocheck
--!nolint LocalUnused
--!nolint LocalShadow
--!nolint SameLineStatement
--!nolint ImplicitReturn

-- Clone large models incrementally to reduce spikes.
-- Supports Models/Folders, BaseParts (and their children like Decals, Attachments),
-- and rewires JointInstance/Constraint references after parts are placed.

--// https://devforum.roblox.com/t/3881246

local SlowClone = {}

export type StepInfo = {
	stage: string,
	done: number,
	total: number,
}

export type Options = {
	batchSize: number?,          -- how many instances to place before yielding (default 64)
	stepWait: number?,           -- seconds to wait each yield (default 0.03)
	includeConstraints: boolean?,-- rewire joints/constraints (default true)
	name: string?,               -- name for cloned root model (default "<source>_Clone")
	onStep: (StepInfo) -> (),    -- optional progress callback
	cancelToken: {cancelled: boolean}?, -- set cancelToken.cancelled=true to abort mid-clone
	pivotTo: CFrame?,            -- optional final pivot for the cloned model
}

local function isContainer(inst: Instance): boolean
	return inst:IsA("Model") or inst:IsA("Folder")
end

local function isPart(inst: Instance): boolean
	return inst:IsA("BasePart")
end

local function isJointOrConstraint(inst: Instance): boolean
	-- WeldConstraint is a Constraint subclass; JointInstance covers Weld, Motor6D, etc.
	return inst:IsA("JointInstance") or inst:IsA("Constraint")
end

local function depthFrom(root: Instance, inst: Instance): number
	local d = 0
	local p = inst.Parent
	while p and p ~= root do
		d += 1
		p = p.Parent
	end
	return d
end

function SlowClone.cloneAsync(sourceModel: Model, targetParent: Instance?, options: Options?)
	assert(sourceModel and sourceModel:IsA("Model"), "sourceModel must be a Model")

	options = options or {}
	local batchSize = options.batchSize or 64
	local stepWait = options.stepWait or 0.03
	local includeConstraints = (options.includeConstraints ~= false)
	local name = options.name or (sourceModel.Name .. "_Clone")
	local onStep = options.onStep
	local cancelToken = options.cancelToken

	local function stepYield(stage: string, done: number, total: number)
		if onStep then
			pcall(onStep, { stage = stage, done = done, total = total })
		end
		task.wait(stepWait > 0 and stepWait or 0)
	end

	-- Root clone
	local rootClone = Instance.new("Model")
	rootClone.Name = name
	rootClone.Parent = targetParent or sourceModel.Parent

	-- Mapping from original -> clone
	local map: {[Instance]: Instance} = {}
	map[sourceModel] = rootClone

	-- Collect buckets
	local containers: {Instance} = {}
	local parts: {BasePart} = {}
	local joints: {Instance} = {}

	for _, inst in ipairs(sourceModel:GetDescendants()) do
		if isContainer(inst) then
			table.insert(containers, inst)
		elseif isPart(inst) then
			table.insert(parts, inst :: BasePart)
		elseif includeConstraints and isJointOrConstraint(inst) then
			table.insert(joints, inst)
		end
	end

	-- Ensure parents before children for containers
	table.sort(containers, function(a, b)
		return depthFrom(sourceModel, a) < depthFrom(sourceModel, b)
	end)

	-- Pass 1: Create empty container nodes (Models/Folders)
	local processed = 0
	for _, orig in ipairs(containers) do
		if cancelToken and cancelToken.cancelled then
			rootClone:Destroy()
			return nil, "Cancelled"
		end
		local newContainer = Instance.new(orig.ClassName)
		newContainer.Name = orig.Name
		newContainer.Parent = map[orig.Parent] or rootClone
		map[orig] = newContainer

		processed += 1
		if processed % batchSize == 0 then
			stepYield("Containers", processed, #containers)
		end
	end
	if #containers > 0 then
		stepYield("Containers", processed, #containers)
	end

	-- Pass 2: Clone parts (strip joint/constraint children; they'll be rebuilt)
	processed = 0
	local partMap: {[BasePart]: BasePart} = {}
	for _, origPart in ipairs(parts) do
		if cancelToken and cancelToken.cancelled then
			rootClone:Destroy()
			return nil, "Cancelled"
		end

		local clonePart = origPart:Clone()
		-- Remove joint/constraint children from the part clone to avoid stale references.
		for _, ch in ipairs(clonePart:GetChildren()) do
			if ch:IsA("JointInstance") or ch:IsA("Constraint") then
				ch:Destroy()
			end
		end

		clonePart.Parent = map[origPart.Parent] or rootClone
		map[origPart] = clonePart
		partMap[origPart] = clonePart

		processed += 1
		if processed % batchSize == 0 then
			stepYield("Parts", processed, #parts)
		end
	end
	if #parts > 0 then
		stepYield("Parts", processed, #parts)
	end

	-- Helper: find the cloned counterpart of an Attachment
	local function resolveAttachmentClone(origAttachment: Attachment?): Attachment?
		if not origAttachment or not origAttachment:IsA("Attachment") then
			return nil
		end
		local parentPart = origAttachment.Parent
		if not parentPart or not parentPart:IsA("BasePart") then
			return nil
		end
		local clonedParent = partMap[parentPart]
		if not clonedParent then
			return nil
		end
		-- Most attachments are direct children; recursive search just in case
		return clonedParent:FindFirstChild(origAttachment.Name, true) :: Attachment?
	end

	-- Pass 3: Recreate joints/constraints and rewire references
	if includeConstraints then
		processed = 0
		for _, orig in ipairs(joints) do
			if cancelToken and cancelToken.cancelled then
				rootClone:Destroy()
				return nil, "Cancelled"
			end

			local clone = orig:Clone()

			-- Rewire JointInstances (e.g., Weld, Motor6D)
			if clone:IsA("JointInstance") then
				if clone.Part0 ~= nil then
					(clone :: any).Part0 = partMap[(orig :: any).Part0]
				end
				if clone.Part1 ~= nil then
					(clone :: any).Part1 = partMap[(orig :: any).Part1]
				end
			end

			-- Rewire Constraints using Attachments (BallSocket, Hinge, etc.)
			-- Many constraints have Attachment0/Attachment1; WeldConstraint uses Part0/Part1 instead.
			pcall(function()
				if (clone :: any).Attachment0 == nil and (clone :: any).Attachment1 == nil then
					-- Skip if no attachments
				else
					(clone :: any).Attachment0 = resolveAttachmentClone((orig :: any).Attachment0);
					(clone :: any).Attachment1 = resolveAttachmentClone((orig :: any).Attachment1)
				end
				if (clone :: any).Part0 == nil then
					-- Skip if no Part0
				else
					(clone :: any).Part0 = partMap[(orig :: any).Part0]
				end
				if (clone :: any).Part1 == nil then
					-- Skip if no Part1
				else
					(clone :: any).Part1 = partMap[(orig :: any).Part1]
				end
			end)

			clone.Parent = map[orig.Parent] or rootClone

			processed += 1
			if processed % batchSize == 0 then
				stepYield("Constraints", processed, #joints)
			end
		end
		if #joints > 0 then
			stepYield("Constraints", processed, #joints)
		end
	end

	-- PrimaryPart
	if sourceModel.PrimaryPart then
		local ppClone = partMap[sourceModel.PrimaryPart]
		if ppClone then
			rootClone.PrimaryPart = ppClone
		end
	end

	-- Optional final pivot
	if options.pivotTo then
		pcall(function()
			rootClone:PivotTo(options.pivotTo :: CFrame)
		end)
	end

	return rootClone
end

return SlowClone