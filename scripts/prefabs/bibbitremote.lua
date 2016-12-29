
local assets=
{
    Asset("ANIM", "anim/bibbitremote.zip"),
	Asset("IMAGE", "images/inventoryimages/bibbitremote.tex"),	
	Asset("ATLAS", "images/inventoryimages/bibbitremote.xml"),
}

local SPAWN_DIST = 30

local trace = function() end

local function RebuildTile(inst)
    if inst.components.inventoryitem:IsHeld() then
        local owner = inst.components.inventoryitem.owner
        inst.components.inventoryitem:RemoveFromOwner(true)
        if owner.components.container then
            owner.components.container:GiveItem(inst)
        elseif owner.components.inventory then
            owner.components.inventory:GiveItem(inst)
        end
    end
end

local function MorphShadowEyebone(inst)
    inst.AnimState:SetBuild("bibbit_eyebone_shadow_build")

    inst.openEye = "bibbit_eyebone_shadow"
    inst.closedEye = "bibbit_eyebone_closed_shadow"    


    inst.EyeboneState = "SHADOW"
    RebuildTile(inst)
end

local function MorphSnowEyebone(inst)
    inst.AnimState:SetBuild("bibbit_eyebone_snow_build")

    inst.openEye = "bibbit_eyebone_snow"
    inst.closedEye = "bibbit_eyebone_closed_snow"    

    inst.EyeboneState = "SNOW"
    RebuildTile(inst)
end

local function MorphNormalEyebone(inst)
    inst.AnimState:SetBuild("bibbit_eyebone_build")

    inst.openEye = "bibbit_eyebone"
    inst.closedEye = "bibbit_eyebone_closed"    

    inst.EyeboneState = "NORMAL"
    RebuildTile(inst)
end

local function GetSpawnPoint(pt)

    local theta = math.random() * 2 * PI
    local radius = SPAWN_DIST

	local offset = FindWalkableOffset(pt, theta, radius, 12, true)
	if offset then
		return pt+offset
	end
end

local function SpawnBibbit(inst)
    trace("bibbit_eyebone - SpawnBibbit")
    if not TheSim:FindFirstEntityWithTag("bibbit") then
	
    local pt = Vector3(inst.Transform:GetWorldPosition())
    trace("    near", pt)
        
    local spawn_pt = GetSpawnPoint(pt)
    if spawn_pt then
        trace("    at", spawn_pt)
        local bibbit = SpawnPrefab("bibbit")
        if bibbit then
            bibbit.Physics:Teleport(spawn_pt:Get())
            bibbit:FacePoint(pt.x, pt.y, pt.z)

            return bibbit
        end

    else
        -- this is not fatal, they can try again in a new location by picking up the bone again
        trace("bibbit_eyebone - SpawnBibbit: Couldn't find a suitable spawn point for bibbit")
    end
	else
	print("there is a bibbit")
	end
end



local function StopRespawn(inst)
    trace("bibbit_eyebone - StopRespawn")
    if inst.respawntask then
        inst.respawntask:Cancel()
        inst.respawntask = nil
        inst.respawntime = nil
    end
end

local function RebindBibbit(inst, bibbit)
    bibbit = bibbit or TheSim:FindFirstEntityWithTag("bibbit")
    if bibbit then

        inst.AnimState:PlayAnimation("idle", true)--idle_loop
        --inst.components.inventoryitem:ChangeImageName(inst.openEye)
        inst:ListenForEvent("death", function() inst:OnBibbitDeath() end, bibbit)

        if bibbit.components.follower.leader ~= inst then
            bibbit.components.follower:SetLeader(inst)
        end
        return true
    end
end

local function RespawnBibbit(inst)
    trace("bibbit_eyebone - RespawnBibbit")

    StopRespawn(inst)

    local bibbit = TheSim:FindFirstEntityWithTag("bibbit")
    if not bibbit then
        bibbit = SpawnBibbit(inst)
    end
    RebindBibbit(inst, bibbit)
end

local function StartRespawn(inst, time)
    StopRespawn(inst)

    local respawntime = time or 0
    if respawntime then
        inst.respawntask = inst:DoTaskInTime(respawntime, function() RespawnBibbit(inst) end)
        inst.respawntime = GetTime() + respawntime
       -- inst.AnimState:PlayAnimation("dead", true)
       -- inst.components.inventoryitem:ChangeImageName(inst.closedEye)
    end
end

local function OnBibbitDeath(inst)
    StartRespawn(inst, TUNING.CHESTER_RESPAWN_TIME)
end

local function FixBibbit(inst)
	inst.fixtask = nil
	--take an existing bibbit if there is one
	if not RebindBibbit(inst) then
        --inst.AnimState:PlayAnimation("dead", true)
        --inst.components.inventoryitem:ChangeImageName(inst.closedEye)
		
		if inst.components.inventoryitem.owner then
			local time_remaining = 0
			local time = GetTime()
			if inst.respawntime and inst.respawntime > time then
				time_remaining = inst.respawntime - time		
			end
			StartRespawn(inst, time_remaining)
		end
	end
end

local function OnPutInInventory(inst)
	if not inst.fixtask then
		inst.fixtask = inst:DoTaskInTime(1, function() FixBibbit(inst) end)	
	end
end

local function OnSave(inst, data)
    trace("bibbit_eyebone - OnSave")
    data.EyeboneState = inst.EyeboneState
    local time = GetTime()
    if inst.respawntime and inst.respawntime > time then
        data.respawntimeremaining = inst.respawntime - time
    end
end


local function OnLoad(inst, data)

    if data and data.EyeboneState then
        if data.EyeboneState == "SHADOW" then
            inst:MorphShadowEyebone()
        elseif data.EyeboneState == "SNOW" then
            inst:MorphSnowEyebone()
        end
    end

    if data and data.respawntimeremaining then
		inst.respawntime = data.respawntimeremaining + GetTime()
	end
end

local function GetStatus(inst)
    trace("smallbird - GetStatus")
    if inst.respawntask then
        return "WAITING"
    end
end





local function fn(Sim)
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    --so I can find the thing while testing
    --local minimap = inst.entity:AddMiniMapEntity()
    --minimap:SetIcon( "treasure.png" )

    inst:AddTag("bibbitremote")
    inst:AddTag("irreplaceable")
	inst:AddTag("nonpotatable")

    MakeInventoryPhysics(inst)
    
    inst.AnimState:SetBank("bibbitremote")
    inst.AnimState:SetBuild("bibbitremote")
    inst.AnimState:PlayAnimation("idle")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnPutInInventoryFn(OnPutInInventory)
    inst.components.inventoryitem.imagename = "bibbitremote"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/bibbitremote.xml"
    

    inst.EyeboneState = "NORMAL"
    inst.openEye = "bibbit_eyebone"
    inst.closedEye = "bibbit_eyebone_closed"   

   -- inst.components.inventoryitem:ChangeImageName(inst.openEye)    
    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = GetStatus
	inst.components.inspectable:RecordViews()

    inst:AddComponent("leader")

    inst.OnLoad = OnLoad
    inst.OnSave = OnSave
    inst.OnBibbitDeath = OnBibbitDeath

	inst.fixtask = inst:DoTaskInTime(1, function() FixBibbit(inst) end)

    return inst
end

return Prefab( "common/inventory/bibbitremote", fn, assets) 
