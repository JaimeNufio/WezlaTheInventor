local assets=
{ 
    Asset("ANIM", "anim/tstaff.zip"),
    Asset("ANIM", "anim/swap_tstaff.zip"), 

--    Asset("ATLAS", "images/inventoryimages/wgun.xml"),
--    Asset("IMAGE", "images/inventoryimages/wgun.tex"),
}


local function fn()

	local function OnEquip(inst, owner)
		owner.AnimState:OverrideSymbol("swap_object", "swap_tstaff", "tstaff")
		owner.AnimState:Show("ARM_carry") 
		owner.AnimState:Hide("ARM_normal") 		
    end

    local function OnUnequip(inst, owner) 
        owner.AnimState:Hide("ARM_carry") 
        owner.AnimState:Show("ARM_normal") 
    end

	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    MakeInventoryPhysics(inst)
	
	inst.fuck = false
	inst:AddTag("nopunch")

	
    anim:SetBank("tstaff")
    anim:SetBuild("tstaff")
    anim:PlayAnimation("idle")
	
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "wgun"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/wgun.xml"
    
    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip( OnEquip )
    inst.components.equippable:SetOnUnequip( OnUnequip )
	
	--[[
	inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetOnFinished(onfinished)
	inst.components.finiteuses:SetMaxUses(50)
    inst.components.finiteuses:SetUses(50)
	]]
	
	--[[
	inst:AddComponent("fueled")
    inst.components.fueled.fueltype = "WEZLA"
    inst.components.fueled:InitializeFuelLevel(100)
    inst.components.fueled.maxfuel = 100
    inst.components.fueled:SetDepletedFn(onfinished(inst))
    inst.components.fueled.ontakefuelfn = takefuel(inst)
    inst.components.fueled.accepting = true
	]]

	--[[
    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(inst.damagecurrent)
    inst.components.weapon:SetRange(10, 20)
    inst.components.weapon:SetOnAttack(weatherstate)
	inst.components.weapon:SetProjectile("")
	]]

    return inst
end

return  Prefab("common/inventory/tstaff", fn, assets, prefabs)