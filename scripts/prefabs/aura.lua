local assets =
{
	Asset("ANIM", "anim/aura.zip"),

}

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    
    inst.AnimState:SetBank("aura")
    inst.AnimState:SetBuild("aura")
    inst.AnimState:PlayAnimation("idle")
	
	local s = 1.5
	inst.Transform:SetScale(s,s,s)
	
	inst:DoPeriodicTask(65, function() inst:Remove() end)

    return inst
end


return Prefab( "common/inventory/aura", fn, assets)