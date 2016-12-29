local assets =
{
	Asset("ANIM", "anim/wezlafuel.zip"),
	Asset("ATLAS", "images/inventoryimages/wezlafuel.xml"),
    Asset("IMAGE", "images/inventoryimages/wezlafuel.tex"),
}

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("wezlafuel")
    inst.AnimState:SetBuild("wezlafuel")
    inst.AnimState:PlayAnimation("idle")
    
    inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("inspectable")
        	
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "wezlafuel"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/wezlafuel.xml"

	inst:AddComponent("edible")
	inst.components.edible.healthvalue = 5--TUNING.HEALING_LARGE*1.5
    inst.components.edible.hungervalue = 15 --TUNING.CALORIES_SMALL
	inst.components.edible.sanityvalue = 15--TUNING.SANITY_LARGE*1.5
	
	inst:AddComponent("fuel")
    inst.components.fuel.fueltype = "WEZLA"
    inst.components.fuel.fuelvalue = TUNING.MED_FUEL
	
	inst.components.edible.oneaten = function(inst, eater)
		if math.random(1,10) >= 7 then
		if eater:HasTag("player") then
		local pt = Vector3(eater.Transform:GetWorldPosition())
		GetSeasonManager():DoLightningStrike(pt)
		eater.components.talker:Say("That was certainly shocking.")
		end
		end
	end	
	
    return inst
end

return Prefab( "common/inventory/wezlafuel", fn, assets) 