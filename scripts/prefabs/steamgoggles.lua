prefabs = {"steamgoggles"}
local test = false
local state = false
local assets={ 
    Asset("ANIM", "anim/steamgoggles.zip"),
    Asset("ANIM", "anim/steamgoggles_swap.zip"), 
	Asset("ANIM", "anim/steamgoggleson_swap.zip"), 

    Asset("ATLAS", "images/inventoryimages/steamgoggles.xml"),
    Asset("IMAGE", "images/inventoryimages/steamgoggles.tex"),
}

local function induceinsanity(val, owner)
    if owner.components.sanity then
        owner.components.sanity.inducedinsanity = val
    end
    if owner.components.sanitymonsterspawner then
        --Ensure the popchangetimer fully ticks over by running max tick time twice.
        owner.components.sanitymonsterspawner:UpdateMonsters(20)
        owner.components.sanitymonsterspawner:UpdateMonsters(20)
    end

    local pt = owner:GetPosition()
    local ents = TheSim:FindEntities(pt.x,pt.y,pt.z, 100, nil, nil, {'rabbit', 'manrabbit'})

    for k,v in pairs(ents) do
        if v.CheckTransformState ~= nil then
            v.CheckTransformState(v)
        end
    end

end

local function getitem(player, amulet, item, destroy)
    --Amulet will only ever pick up items one at a time. Even from stacks.
	if not item:HasTag("bibbit") then
    local fx = SpawnPrefab("small_puff")
    fx.Transform:SetPosition(item.Transform:GetWorldPosition())
    fx.Transform:SetScale(0.5, 0.5, 0.5)

    if destroy then
        if amulet == item then
            return --#srosen Probably don't want the amulet to destroy itself, also maybe that's great?
        end
        item:Remove()
    else
        
        if item.components.stackable then
            item = item.components.stackable:Get()
        end
        
        if item.components.trap and item.components.trap:IsSprung() then
            item.components.trap:Harvest(player)
            return
        end
        
        player.components.inventory:GiveItem(item)
    end
	end
end

local function pickup(inst, owner, destroy)
    local pt = owner:GetPosition()
    local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, TUNING.ORANGEAMULET_RANGE)
	--print("pickup?")
	if inst.day == true and not inst.components.fueled:IsEmpty() then
	--print("can pickup")
    for k,v in pairs(ents) do
        if v.components.inventoryitem and v.components.inventoryitem.canbepickedup and v.components.inventoryitem.cangoincontainer and not
            v.components.inventoryitem:IsHeld() then

            if not owner.components.inventory:IsFull() then
                --Your inventory isn't full, you can pick something up.
                getitem(owner, inst, v, destroy)
                if not destroy then return end

            elseif v.components.stackable then
                --Your inventory is full, but the item you're trying to pick up stacks. Check for an exsisting stack.
                --An acceptable stack should: Be of the same item type, not be full already and not be in the "active item" slot of inventory.
                local stack = owner.components.inventory:FindItem(function(item) return (item.prefab == v.prefab and not item.components.stackable:IsFull()
                    and item ~= owner.components.inventory.activeitem) end)
                if stack then
                    getitem(owner, inst, v, destroy)
                    if not destroy then return end
                end
            elseif destroy then
                getitem(owner, inst, v, destroy)
            end
        end
    end
	end
end

function turneverythingoff(inst,owner)
    --local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
	print("Take them off, idiot.")
	owner.AnimState:OverrideSymbol("swap_hat", "steamgoggles_swap", "swap_hat")
	owner.AnimState:Show("HAT")
	if inst.components.fueled then
		inst.components.fueled:StopConsuming()
	end
	if owner.components.sanity ~= nil then
		induceinsanity(false, owner)--owner.components.sanity:SetInducedInsanity(inst, false)
	end
	if inst.task ~= nil then
		inst.task:Cancel()
		inst.task = nil
	end
	if inst.task1 ~= nil then
		inst.task1:Cancel()
		inst.task1 = nil
	end
	inst.Light:Enable(false)
end


local function vision(inst,owner)	
	if inst.worn then
	--	print("worn")
		if not inst.components.fueled:IsEmpty() then
			--print("fuel")
			if GetClock():IsDay() then
				--print("day")
				inst.day = true
				owner.AnimState:OverrideSymbol("swap_hat", "steamgoggles_swap", "swap_hat")
				owner.AnimState:Show("HAT")
				inst.Light:Enable(false)
				if inst.components.fueled then
					inst.components.fueled:StartConsuming()
				end
				if owner.components.sanity ~= nil then
					induceinsanity(false, owner)
				end
			elseif GetClock():IsDusk() then
				inst.day = false
				--print("dusk")
				owner.AnimState:OverrideSymbol("swap_hat", "steamgoggleson_swap", "swap_hat")
				owner.AnimState:Show("HAT")
				inst.Light:SetIntensity(.3)
				inst.Light:Enable(true)
				if inst.components.fueled then
					inst.components.fueled:StartConsuming()
				end
				if owner.components.sanity ~= nil then
					induceinsanity(false, owner)
				end
			elseif GetClock():IsNight() or GetWorld():IsCave() then
				--print("night/cave")
				inst.day = false
				owner.AnimState:OverrideSymbol("swap_hat", "steamgoggleson_swap", "swap_hat")
				owner.AnimState:Show("HAT")
				inst.Light:SetIntensity(.9)
				inst.Light:Enable(true)
				if inst.components.fueled then
					inst.components.fueled:StartConsuming()
				end
			--[[	if owner.components.sanity ~= nil then
					owner.components.sanity:SetInducedInsanity(inst, true)
				end	]]		
				if GetClock():GetMoonPhase() == "full" then
			--	print("fullmoon")
					owner.AnimState:OverrideSymbol("swap_hat", "steamgoggleson_swap", "swap_hat")
					owner.AnimState:Show("HAT")
					inst.day = true
					inst.Light:SetIntensity(.9)				
					inst.Light:Enable(true)
					if inst.components.fueled then
						inst.components.fueled:StopConsuming()
					end
					if owner.components.sanity ~= nil then
						induceinsanity(true, owner)
					end
				end
			end
		else
		turneverythingoff(inst,owner)
		owner.AnimState:OverrideSymbol("swap_hat", "steamgoggles_swap", "swap_hat")
		owner.AnimState:Show("HAT")
		end
	end
end

local function miner_turnoff(inst, ranout)
    if inst.components.equippable and inst.components.equippable:IsEquipped() then
    local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
	turneverythingoff(inst,owner)
    end
	inst.worn = false
    inst.SoundEmitter:PlaySound("dontstarve/common/minerhatOut")
end


local function miner_drop(inst)
    miner_turnoff(inst)
	inst.worn = false
end

local function miner_perish(inst)
    local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
    if owner then
        owner:PushEvent("torchranout", {torch = inst})
    end
    miner_turnoff(inst,owner)
	inst.worn = false
end


local function OnEquip(inst, owner) 

    if owner:HasTag("player") then
    end
	inst.worn = true
	if inst.components.fueled:IsEmpty() then
		print("gogglesempty,wear on head")
		owner.AnimState:OverrideSymbol("swap_hat", "steamgoggles_swap", "swap_hat")
		owner.AnimState:Show("HAT")
		owner.components.talker:Say("They're out of fuel, but still stylish.")
		if inst.task ~= nil then
			inst.task:Cancel()
			inst.task = nil
		end
	else
		inst.task = inst:DoPeriodicTask(.5, function() vision(inst,owner) end)
		
		print("googlesfuled, wear on face, update")
	    owner.AnimState:OverrideSymbol("swap_hat", "steamgoggleson_swap", "swap_hat")
		owner.AnimState:Show("HAT")
	end
	if inst.components.fueled then
		inst.components.fueled:StartConsuming()
	end
	if owner.components.sanity ~= nil then
		induceinsanity(false, owner)--owner.components.sanity:SetInducedInsanity(inst, false)
	end
	
	inst.task1 = inst:DoPeriodicTask(TUNING.ORANGEAMULET_ICD, pickup, nil, owner)
end

local function OnUnequip(inst, owner)
    if owner:HasTag("player") then
    end	
    owner.AnimState:Hide("HAT")
    owner.AnimState:Hide("HAT_HAIR")
    owner.AnimState:Show("HAIR_NOHAT")
    owner.AnimState:Show("HAIR")
	if inst.components.fueled then
		inst.components.fueled:StopConsuming()        
	end
	inst.worn = false
	inst.Light:Enable(false)
    if inst.components.fueled then
        inst.components.fueled:StopConsuming()
    end
    if owner.components.sanity ~= nil then
        induceinsanity(false, owner)--owner.components.sanity:SetInducedInsanity(inst, false)
    end
	if inst.task ~= nil then
        inst.task:Cancel()
        inst.task = nil
    end
	if inst.task1 ~= nil then
        inst.task1:Cancel()
        inst.task1 = nil
    end
	end
	

local function miner_takefuel(inst)
    if inst.components.equippable and inst.components.equippable:IsEquipped() then
    end
end	
	
local function fn()
	
    local inst = CreateEntity()
	inst.entity:AddSoundEmitter()        
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()

    anim:SetBank("steamgoggles")
    anim:SetBuild("steamgoggles")
    anim:PlayAnimation("idle")
	


	MakeInventoryPhysics(inst)
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "steamgoggles"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/steamgoggles.xml"
	--inst.components.inventoryitem.keepondeath = true
	
    inst:AddComponent("fueled")
    inst.components.fueled.fueltype = "USAGE"
    inst.components.fueled:InitializeFuelLevel(TUNING.MINERHAT_LIGHTTIME)
    inst.components.fueled:SetDepletedFn(miner_perish)
    inst.components.fueled.fueltype = "WEZLA"
    inst.components.fueled.ontakefuelfn = miner_takefuel
    inst.components.fueled.accepting = true
	
    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)
	inst.components.inventoryitem:SetOnDroppedFn( miner_drop )
	--inst.components.equippable.dapperness = (TUNING.DAPPERNESS_MED)
	
	local light = inst.entity:AddLight()
	light:SetFalloff(0.2)
	light:SetIntensity(0)
	light:SetRadius(8)
	light:SetColour(0/255, 255/255, 255/255)
	
	--inst:ListenForEvent("onputininventory", topocket)
	--local owner = nil
	--local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
    --inst:ListenForEvent("ondropped", turneverythingoff(inst))
	
	--[[
	if not inst.components.characterspecific then
		inst:AddComponent("characterspecific")
	end
 
	inst.components.characterspecific:SetOwner("wezla")
	inst.components.characterspecific:SetStorable(true)
	inst.components.characterspecific:SetComment("My special goggles.")
	]]
	
	light:Enable(true)
	inst.worn = false
	inst.day = false
	
	return inst

end

return Prefab( "common/inventory/steamgoggles", fn, assets)
