local assets =
{
	Asset("ANIM", "anim/vshake.zip"),
	Asset("ATLAS", "images/inventoryimages/vshake.xml"),
    Asset("IMAGE", "images/inventoryimages/vshake.tex"),
}

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("vshake")
    inst.AnimState:SetBuild("vshake")
    inst.AnimState:PlayAnimation("idle")
    
    inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("inspectable")
        	
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "vshake"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/vshake.xml"

	inst:AddComponent("fuel")
    inst.components.fuel.fueltype = "WEZLA"
    inst.components.fuel.fuelvalue = TUNING.LARGE_FUEL
	
	inst:AddComponent("edible")
	inst.components.edible.healthvalue = 30--TUNING.HEALING_LARGE*1.5
    inst.components.edible.hungervalue = 20 --TUNING.CALORIES_SMALL
	inst.components.edible.sanityvalue = 5--TUNING.SANITY_LARGE*1.5
	
	 return inst

end

return Prefab( "common/inventory/vshake", fn, assets) 