local assets=
{
	Asset("ANIM", "anim/wteddy.zip"),
	Asset("ATLAS", "images/inventoryimages/wteddy.xml"),
    Asset("IMAGE", "images/inventoryimages/wteddy.tex"),
	Asset("ATLAS", "images/inventoryimages/wteddydown.xml"),
    Asset("IMAGE", "images/inventoryimages/wteddydown.tex"),
}

local prefabs = 
{
	""
}

local Cry = {"Heh. That tickcles.","Say could you stop that?","That's kinda annoyng.",
	"Well, you're really rustling my jimmies.","Could you stop hiting that?","Well this isn't ideal",
	"Master, can you cast them away?","Well that's not very friendly.","Huh, I could barely feel that.",
	"I don't understand this \"Pain\" of yours."
	}


local items = {"patches","berries"}

local count = 0
local form = 0

	local life = 1
	
local function OnAttacked(inst, data)
	count = count+1
	life = inst.components.health:GetPercent()

	inst.components.talker:Say(Cry[math.random(#Cry)])

	local x = Vector3(inst.Transform:GetWorldPosition())
	
	if inst.components.health:GetPercent() >= .65 then	
				inst.AnimState:PlayAnimation("idle")	
	else
		form = form+1	
		if form == 10 then
			form = 0
			for i = 1,math.random(0,3) do
				local spawn = SpawnPrefab("taffy")
				spawn.Transform:SetPosition(x:Get())
			end
		end
		
		inst.AnimState:SetBank("wteddy_dead")
		inst.AnimState:PlayAnimation("idle")
		inst.components.inventoryitem.imagename = "wteddydown"
		inst.components.inventoryitem.atlasname = "images/inventoryimages/wteddydown.xml"
		local test = math.random(1, 20)
			if test >= 15 then
				local spawn = SpawnPrefab("beefalowool")
				spawn.Transform:SetPosition(x:Get())	
			elseif test <= 5 then
				local spawn = SpawnPrefab("manrabbit_tail")
				spawn.Transform:SetPosition(x:Get())
			end
		
	end
end

local function oneat()
print("Teddy ate.")
end

local function OnGetItemFromPlayer(inst, giver, item)
	print("recognized")
	if item:HasTag("patch") then
	print("accepting")
	inst.components.health:SetPercent(1)  
	inst.components.talker:Say("Thanks for the patches, mister!")
	inst.AnimState:SetBank("wteddy")
    inst.AnimState:SetBuild("wteddy")
	inst.components.inventoryitem.imagename = "wteddy"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/wteddy.xml"
    end
end
	
local function OnRefuseItem()
	print("not accepting")
end

local function fn(Sim)

	local inst = CreateEntity()
	--local inst.strike = 0
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    
    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("wteddy")
    inst.AnimState:SetBuild("wteddy")
    inst.AnimState:PlayAnimation("idle")
    
	inst:AddComponent("knownlocations")
    inst:AddComponent("combat")
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(5000)
    --inst.components.health:StartRegen(TUNING.CHESTER_HEALTH_REGEN_AMOUNT, TUNING.CHESTER_HEALTH_REGEN_PERIOD)
    inst:AddTag("noauradamage")
	inst:AddTag("companion")
    inst:AddTag("character")
	
    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "wteddy"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/wteddy.xml"	
	
	inst:AddTag("animal")
    inst:AddTag("prey")
	
    inst:ListenForEvent("attacked", OnAttacked)
	
	--Talks
	inst:AddComponent("talker")
    inst.components.talker.fontsize = 50
    inst.components.talker.font = TALKINGFONT
    inst.components.talker.colour = Vector3(0.8, 0, 0, 1)
    inst.components.talker.offset = Vector3(0,40,0)
    inst.components.talker.symbol = "swap_object"
	

	--inst:DoPeriodicTask(5,talk(inst))

	inst:AddComponent("trader")

		
	inst.components.trader:SetAcceptTest(
		function(inst, item)
			return item.components.tradable.goldvalue > 0
		end)
	
    inst.components.trader.onrefuse = OnRefuseItem	
    inst.components.trader.onaccept = OnGetItemFromPlayer

	inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.SEWINGKIT_USES)
    inst.components.finiteuses:SetUses(TUNING.SEWINGKIT_USES)
    inst.components.finiteuses:SetOnFinished( onfinished )
	
    return inst
end

return Prefab( "common/inventory/wteddy", fn, assets, prefabs)
