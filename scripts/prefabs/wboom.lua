local assets=
{
	Asset("ANIM", "anim/wboom.zip"),
	Asset("ANIM", "anim/swap_wboom.zip"),
	Asset("ATLAS", "images/inventoryimages/wboom.xml"),
    Asset("IMAGE", "images/inventoryimages/wboom.tex"),
}

    
local prefabs =
{"explode_small"
}

local function OnFinished(inst)
   -- inst.AnimState:PlayAnimation("used")
    inst:ListenForEvent("animover", function() inst:Remove() end)
end

local function OnEquip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_object", "swap_wboom", "swap_wboom")
    owner.AnimState:Show("ARM_carry") 
    owner.AnimState:Hide("ARM_normal") 
end

local function OnDropped(inst)
    inst.AnimState:PlayAnimation("idle")
end

local function OnUnequip(inst, owner) 
    owner.AnimState:Hide("ARM_carry") 
    owner.AnimState:Show("ARM_normal") 
end

local function OnThrown(inst, owner, target)
  if target ~= owner then
        owner.SoundEmitter:PlaySound("dontstarve/wilson/boomerang_throw")
    end
    inst.AnimState:PlayAnimation("spin_loop", true)
	--inst.Transform:SetRotation(target.Transform.direction)--test
end

local function OnCaught(inst, catcher)
    if catcher then
        if catcher.components.inventory then
            if inst.components.equippable and not catcher.components.inventory:GetEquippedItem(inst.components.equippable.equipslot) then
				catcher.components.inventory:Equip(inst)
			else
                catcher.components.inventory:GiveItem(inst)
            end
            catcher:PushEvent("catch")
        end
    end
end

local function ReturnToOwner(inst, owner)
    if owner and not (inst.components.finiteuses and inst.components.finiteuses:GetUses() < 1) then
        owner.SoundEmitter:PlaySound("dontstarve/wilson/boomerang_return")
        inst.components.projectile:Throw(owner, owner)
    end
end

function boom(target,inst)
	local x = 3
	local count = 0
	
	inst:DoPeriodicTask(.15, function()
	if count <= x then
		local pos = Vector3(target.Transform:GetWorldPosition())
		inst.SoundEmitter:PlaySound("dontstarve/common/blackpowder_explo")

		local explode = SpawnPrefab("explode_small")
		explode:AddComponent("explosive")
		--explode.components.explosive.explosivedamage = TUNING.GUNPOWDER_DAMAGE
		explode.Transform:SetPosition(pos.x, pos.y, pos.z)

		explode.AnimState:SetBloomEffectHandle( "shaders/anim.ksh" )
		explode.AnimState:SetLightOverride(1)
		
		count = count+1
	end		
	end)
	--print("Total Explosive Damage Done: "..x*TUNING.GUNPOWDER_DAMAGE)

	end


local function OnHit(inst, owner, target)
 if owner == target then
        OnDropped(inst)
		boom(owner,inst)
    else
        ReturnToOwner(inst, owner)
    end
	
    local impactfx = SpawnPrefab("impact")
    if impactfx then
	    local follower = impactfx.entity:AddFollower()
	    follower:FollowSymbol(target.GUID, target.components.combat.hiteffectsymbol, 0, 0, 0 )
        impactfx:FacePoint(inst.Transform:GetWorldPosition())
		boom(target,inst)
    end


end


local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst .entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)
    RemovePhysicsColliders(inst)
	inst.entity:AddSoundEmitter()
    
    anim:SetBank("wboom")
    anim:SetBuild("wboom")
    anim:PlayAnimation("idle")
    anim:SetRayTestOnBB(true);
    
    inst:AddTag("projectile")
    inst:AddTag("thrown")
	
    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(150)
    inst.components.weapon:SetRange(TUNING.BOOMERANG_DISTANCE, TUNING.BOOMERANG_DISTANCE+2)
    -------
    
    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(10)
    inst.components.finiteuses:SetUses(10)
    
    inst.components.finiteuses:SetOnFinished(OnFinished)

    inst:AddComponent("inspectable")
    
    inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(20)
    inst.components.projectile:SetCanCatch(true)
    inst.components.projectile:SetOnThrownFn(OnThrown)
    inst.components.projectile:SetOnHitFn(OnHit)
    inst.components.projectile:SetOnMissFn(ReturnToOwner)
    inst.components.projectile:SetOnCaughtFn(OnCaught)
    
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnDroppedFn(OnDropped)
    inst.components.inventoryitem.imagename = "wboom"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/wboom.xml"
    
    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)
    
    return inst
end

return Prefab( "common/inventory/wboom", fn, assets) 
