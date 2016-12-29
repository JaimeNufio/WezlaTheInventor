local assets =
{
    Asset("ANIM", "anim/bibbitdoll.zip"),
    Asset("ANIM", "anim/swap_bibbitdoll.zip"),
	Asset("ATLAS", "images/inventoryimages/bibbitdoll.xml"),
    Asset("IMAGE", "images/inventoryimages/bibbitdoll.tex"),
}

local text = {"I wuv you!","You're my best friend!",
"Yay! Friendship!","Adventure!","Oh the places we'll go!",
"Teehee ^.^","Let's have fun!"
}

local function speak(inst)
	print("speech!")
	--inst.components.talker:Say( text[math.random(#text)] )
end

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_bibbitdoll", "swap_bibbitdoll")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
	
	inst.equipped = true
    inst.components.talker.symbol = "swap_object"	
	
	inst.task = inst:DoPeriodicTask(5,speak(inst))
	if inst.components.fueled then
		inst.components.fueled:StartConsuming()
	end	
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
	
	inst.equipped = false
    inst.components.talker.symbol = nil
	
	if inst.task ~= nil then
        inst.task:Cancel()
        inst.task = nil
    end
	if inst.components.fueled then
		inst.components.fueled:StopConsuming()
	end
end

local function perish(inst)
    inst:Remove()
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
   -- inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("bibbitdoll")
    inst.AnimState:SetBuild("bibbitdoll")
    inst.AnimState:PlayAnimation("idle")
	
    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.CANE_DAMAGE)

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
	--inst.components.inventoryitem.imagename = "bibbitdoll"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/bibbitdoll.xml"
	--inst.components.inventoryitem.keepondeath = false

    inst:AddComponent("fueled")
    inst.components.fueled.fueltype = "WEZLA"
	inst.components.fueled:InitializeFuelLevel(TUNING.SPIDERHAT_PERISHTIME*2)
    inst.components.fueled:SetDepletedFn(perish)
    --inst.components.finiteuses:SetOnFinished(onfinished)

	
    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    --inst.components.equippable.walkspeedmult = TUNING.CANE_SPEED_MULT
	inst.components.equippable.dapperness = (TUNING.DAPPERNESS_MED)
    
	inst:AddComponent("talker")
    inst.components.talker.fontsize = 30
    inst.components.talker.font = TALKINGFONT
    inst.components.talker.colour = Vector3(0.8, 0, 0, 1)
    inst.components.talker.offset = Vector3(0,0,0)
    inst.components.talker.symbol = nil--"swap_object"
	
	--inst.task = inst:DoPeriodicTask(5,speak(inst))
	
	--MakeHauntableLaunch(inst)
	inst.equipped = false
    return inst	
end

return Prefab("common/inventory/bibbitdoll", fn, assets)