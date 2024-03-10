local addonName = "Improved Fire Logic & API"
resource.AddWorkshop("2805142659")
local ENTITY = FindMetaTable("Entity")
if file.Exists("ulib/shared/hook.lua", "LUA") then
	include("ulib/shared/hook.lua")
end
local PRE_HOOK = PRE_HOOK or HOOK_MONITOR_HIGH
local WaterLevel, IsOnFire, GetMaterialType, EntIndex = ENTITY.WaterLevel, ENTITY.IsOnFire, ENTITY.GetMaterialType, ENTITY.EntIndex
local Alive = FindMetaTable("Player").Alive
local Run, Add
do
	local _obj_0 = hook
	Run, Add = _obj_0.Run, _obj_0.Add
end
local CurTime = CurTime
local flammableMaterials = list.GetForEdit("IFL - Flammable Materials", false)
flammableMaterials[MAT_BLOODYFLESH] = true
flammableMaterials[MAT_ALIENFLESH] = true
flammableMaterials[MAT_ANTLION] = true
flammableMaterials[MAT_FOLIAGE] = true
flammableMaterials[MAT_PLASTIC] = true
flammableMaterials[MAT_GRASS] = true
flammableMaterials[MAT_FLESH] = true
flammableMaterials[MAT_WOOD] = true
flammableMaterials[MAT_DIRT] = true
local IsFlammableModel = nil
do
	local cache = {
		[""] = false
	}
	IsFlammableModel = function(entity)
		local modelPath = entity:GetModel()
		if not modelPath then
			return false
		end
		local result = cache[modelPath]
		if result == nil then
			result = false
			local value = util.GetModelInfo(modelPath)
			if value ~= nil then
				value = value.ModelKeyValues
				if value ~= nil then
					value = util.KeyValuesToTable(value)
					if value ~= nil then
						value = value.fire_interactions
						if value ~= nil then
							result = value.flammable == "yes"
						end
					end
				end
			end
			cache[modelPath] = result
		end
		return result
	end
	ENTITY.IsFlammableModel = IsFlammableModel
end
Add("AllowEntityIgnite", "Default Fire Logic", function(entity)
	if WaterLevel(entity) > 1 then
		return false
	end
	if entity:IsNPC() then
		return
	end
	if entity:IsPlayer() then
		if Alive(entity) then
			return
		end
		return false
	end
	if IsFlammableModel(entity) then
		return
	end
	if not flammableMaterials[GetMaterialType(entity)] then
		return false
	end
end)
timer.Simple(0.25, function()
	local sourceIgnite = ENTITY.SourceIgnite
	if not isfunction(sourceIgnite) then
		sourceIgnite = ENTITY.Ignite
		ENTITY.SourceIgnite = sourceIgnite
	end
	local igniteEntity = nil
	do
		local Create, Remove, Exists
		do
			local _obj_0 = timer
			Create, Remove, Exists = _obj_0.Create, _obj_0.Remove, _obj_0.Exists
		end
		Add("EntityRemoved", addonName, function(entity)
			local timerName = "Source::IgniteEntity #" .. EntIndex(entity)
			if Exists(timerName) then
				Remove(timerName)
				return
			end
		end, PRE_HOOK)
		igniteEntity = function(entity, length, radius)
			Create("Source::IgniteEntity #" .. EntIndex(entity), length, 1, function()
				if entity:IsValid() then
					return entity:Extinguish()
				end
			end)
			return sourceIgnite(entity, length, radius)
		end
	end
	ENTITY.Ignite = function(entity, length, radius, force)
		if not force and (IsOnFire(entity) or Run("AllowEntityIgnite", entity) == false) then
			return false
		end
		if not length then
			length = 1
		end
		if not radius then
			radius = 0
		end
		entity.m_fIgniteStart = CurTime()
		entity.m_fIgniteLength = length
		entity.m_iIgniteRadius = radius
		igniteEntity(entity, length, radius)
		return true
	end
	local sourceExtinguish = ENTITY.SourceExtinguish
	if not isfunction(sourceExtinguish) then
		sourceExtinguish = ENTITY.Extinguish
		ENTITY.SourceExtinguish = sourceExtinguish
	end
	ENTITY.Extinguish = function(entity, force)
		if not (force or IsOnFire(entity)) then
			return false
		end
		if not force and Run("AllowEntityExtinguish", entity) == false then
			if entity.m_fIgniteStart and (CurTime() - entity.m_fIgniteStart) < (entity.m_fIgniteLength + 0.25) then
				entity.m_fIgniteStart = CurTime()
				igniteEntity(entity, entity.m_fIgniteLength or 1, entity.m_iIgniteRadius or 0)
			end
			return false
		end
		entity.m_fLastExtinguish = CurTime()
		sourceExtinguish(entity)
		Run("EntityExtinguished", entity)
		return true
	end
end)
do
	local IsSolid = ENTITY.IsSolid
	Add("EntityTakeDamage", addonName, function(entity, damageInfo)
		if IsOnFire(entity) then
			if not IsSolid(entity) or (entity:IsPlayer() and not Alive(entity)) then
				entity:Extinguish(true)
				return
			end
			return Run("EntityBurns", entity, damageInfo)
		end
	end, PRE_HOOK_RETURN or HOOK_MONITOR_HIGH)
end
Add("EntityBurns", "Water Extinguish", function(entity, damageInfo)
	if WaterLevel(entity) > 1 and entity:Extinguish() then
		return true
	end
end)
do
	local Length = FindMetaTable("Vector").Length
	local GetVelocity = ENTITY.GetVelocity
	Add("EntityBurns", "Hight Speed Extinguish", function(entity, damageInfo)
		if Length(GetVelocity(entity)) > (entity:IsPlayer() and 800 or 1500) and entity:Extinguish() then
			return true
		end
	end)
end
do
	local ifl_water_extinguish_sound = CreateConVar("ifl_water_extinguish_sound", "1", bit.bor(FCVAR_ARCHIVE, FCVAR_NOTIFY), "If enabled, extinguishing entities in water will emit specific sound.", 0, 1)
	local CHAN_STATIC = CHAN_STATIC
	local random = math.random
	return Add("OnEntityWaterLevelChanged", "Water Extinguish", function(entity, oldWaterLevel, newWaterLevel)
		if newWaterLevel > 1 and oldWaterLevel < newWaterLevel and entity:Extinguish() and ifl_water_extinguish_sound:GetBool() then
			return entity:EmitSound("General.StopBurning", random(50, 75), random(60, 180), 1, CHAN_STATIC, 0, 1)
		end
	end, PRE_HOOK)
end
