require "prefabutil"

local branches =
 {
	SCIENCE = 3,
	MAGIC = 0, 
	ANCIENT = 0,
			}

local function onnear(inst)
    inst.Light:Enable(true)
end

local function onfar(inst)    
       inst.Light:Enable(false)
end
			
local function onhammered(inst, worker)
	inst.components.lootdropper:DropLoot()
	SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
	inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")
	inst:Remove()
end

local function onhit(inst, worker)
	inst.AnimState:PlayAnimation("hit")
	inst.AnimState:PushAnimation(inst.components.prototyper.on and "proximity_loop" or "idle", true)
end

local function sparks(inst,x)
	--local num = 0
	
	--inst:DoPeriodicTask(.75, function()
	--if num <= x then
	--num = num+1
	for i =0,x do
	local pos = Vector3(inst.Transform:GetWorldPosition())
	pos.y = pos.y + 1 + math.random()*1.5
	local spark = SpawnPrefab("sparks")
	spark.Transform:SetPosition(pos:Get())
	end
	--end)
end


	
	local function onturnon(inst)
		inst.AnimState:PlayAnimation("proximity_loop", true)
		
		inst.SoundEmitter:PlaySound("dontstarve/common/researchmachine_lvl2_idle_LP","idlesound")
	end

	local function onturnoff(inst)
	    inst.AnimState:PushAnimation("idle", true)
		inst.SoundEmitter:KillSound("idlesound")
	end

	local assets = 
	{
		Asset("ANIM", "anim/wezlamachine.zip"),
	}


local function fn(Sim)
	local inst = CreateEntity()
		local trans = inst.entity:AddTransform()
		local anim = inst.entity:AddAnimState()

		inst.entity:AddSoundEmitter()
		local minimap = inst.entity:AddMiniMapEntity()
		minimap:SetIcon( "wezlamachine.tex" )
		minimap:SetPriority( 5 )

	    
		MakeObstaclePhysics(inst, .7)
	    
		anim:SetBank("wezlamachine")
		anim:SetBuild("wezlamachine")
		anim:PlayAnimation("idle")

		inst:AddTag("prototyper")
        inst:AddTag("structure")
        inst:AddTag("level3")

		local s = .8
		inst.Transform:SetScale(s,s,s)
		
		inst:AddComponent("inspectable")
		inst:AddComponent("prototyper")
		inst.components.prototyper.onturnon = onturnon
		inst.components.prototyper.onturnoff = onturnoff
		
		inst.components.prototyper.trees = branches
		inst.components.prototyper.onactivate = function() sparks(inst,5)
			inst.AnimState:PlayAnimation("use")
			--inst.AnimState:PushAnimation("idle")
			inst.AnimState:PushAnimation("proximity_loop", true)
			inst.SoundEmitter:PlaySound("dontstarve/common/researchmachine_lvl2_run","sound")

			inst:DoTaskInTime(1.5, function() 
				inst.SoundEmitter:KillSound("sound")
				inst.SoundEmitter:PlaySound("dontstarve/common/researchmachine_lvl2_ding","sound")		
			end)
		end
		
		inst:ListenForEvent( "onbuilt", function()
			sparks(inst,5)
			inst.components.prototyper.on = true
			anim:PlayAnimation("place")
			--anim:PushAnimation("idle")
			anim:PushAnimation("proximity_loop", true)
			inst.SoundEmitter:PlaySound("dontstarve/common/researchmachine_lvl2_place")
			inst.SoundEmitter:PlaySound("dontstarve/common/researchmachine_lvl2_idle_LP","idlesound")				
		end)		

		inst:AddComponent("lootdropper")
		inst:AddComponent("workable")
		inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
		inst.components.workable:SetWorkLeft(4)
		inst.components.workable:SetOnFinishCallback(onhammered)
		inst.components.workable:SetOnWorkCallback(onhit)		
		MakeSnowCovered(inst, .01)
		
		
		local light = inst.entity:AddLight()
        inst.Light:Enable(false)
        inst.Light:SetRadius(2.5)
        inst.Light:SetFalloff(1)
        inst.Light:SetIntensity(.8)
        inst.Light:SetColour(235/255,121/255,12/255)
		
		inst:AddComponent( "playerprox" )
        inst.components.playerprox:SetDist(3,4)
        inst.components.playerprox:SetOnPlayerNear(onnear)    
        inst.components.playerprox:SetOnPlayerFar(onfar)
		

	return inst
end
--Using old prefab names
	return Prefab( "common/objects/wezlamachine", fn, assets),
		MakePlacer( "common/wezlamachine_placer", "wezlamachine", "wezlamachine", "idle" )
		
	

		
		
