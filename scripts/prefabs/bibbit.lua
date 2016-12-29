require "prefabutil"
local brain = require "brains/bibbitbrain"
require "stategraphs/SGbibbit"

local WAKE_TO_FOLLOW_DISTANCE = 14
local SLEEP_NEAR_LEADER_DISTANCE = 7

local assets =

{
    Asset("ANIM", "anim/bernie.zip"),
    Asset("ANIM", "anim/bibbit_build.zip"),
	Asset("ATLAS", "images/inventoryimages/bibbit.xml"),
    Asset("IMAGE", "images/inventoryimages/bibbit.tex"),
--[[
    Asset("ANIM", "anim/chester.zip"),
    Asset("ANIM", "anim/bibbit.zip"),--bibbit
]]
    Asset("SOUND", "sound/chester.fsb"),
}

local prefabs =
{
    "bibbitremote",
    "die_fx",
    "chesterlight",
    "sparklefx",
}

local function ShouldWakeUp(inst)
    return DefaultWakeTest(inst) or not inst.components.follower:IsNearLeader(WAKE_TO_FOLLOW_DISTANCE)
end

local function ShouldSleep(inst)
    --print(inst, "ShouldSleep", DefaultSleepTest(inst), not inst.sg:HasStateTag("open"), inst.components.follower:IsNearLeader(SLEEP_NEAR_LEADER_DISTANCE))
    return DefaultSleepTest(inst) and not inst.sg:HasStateTag("open") 
    and inst.components.follower:IsNearLeader(SLEEP_NEAR_LEADER_DISTANCE) 
    and GetWorld().components.clock:GetMoonPhase() ~= "full"
end


local function ShouldKeepTarget(inst, target)
    return false -- chester can't attack, and won't sleep if he has a target
end


local function OnOpen(inst)
    if not inst.components.health:IsDead() then
        inst.sg:GoToState("open")
    end
end 

local function OnClose(inst) 
    if not inst.components.health:IsDead() then
        inst.sg:GoToState("close")
    end
end 

-- eye bone was killed/destroyed
local function OnStopFollowing(inst) 
    --print("chester - OnStopFollowing")
    inst:RemoveTag("companion") 
end

local function OnStartFollowing(inst) 
    --print("chester - OnStartFollowing")
    inst:AddTag("companion") 
end

local slotpos = {	
Vector3(0,64+32+8+4,0), 
Vector3(0,32+4,0),
Vector3(0,-(32+4),0), 
Vector3(0,-(64+32+8+4),0)
}

local function OnSave(inst, data)
    data.ChesterState = inst.ChesterState
end

local function CalcSanityAura(inst, observer)
	return (TUNING.DAPPERNESS_MED)*2.75
end


local function fn()
    --print("chester - create_chester")

    local inst = CreateEntity()
    
    inst:AddTag("companion")
    inst:AddTag("character")
    inst:AddTag("scarytoprey")
    inst:AddTag("bibbit")
    inst:AddTag("notraptrigger")
    inst:AddTag("cattoy")
    inst:AddTag("fridge")
    inst:AddTag("lowcool")
    inst:AddTag("spoiler")
    inst:AddTag("animal")
    --inst:AddTag("prey")
    inst:AddTag("smallcreature")


    inst.entity:AddTransform()

    local minimap = inst.entity:AddMiniMapEntity()
    minimap:SetIcon( "chester.png" )

    --print("   AnimState")
    inst.entity:AddAnimState()
	
	inst.AnimState:SetBank("bernie")
    inst.AnimState:SetBuild("bibbit_build")
    inst.AnimState:PlayAnimation("idle_loop")
	
--[[
    inst.AnimState:SetBank("bibbit")
    inst.AnimState:SetBuild("bibbit_build")
    inst.AnimState:PlayAnimation("idle_loop")
]]
    --print("   sound")
    inst.entity:AddSoundEmitter()

    --print("   shadow")
    inst.entity:AddDynamicShadow()
    inst.DynamicShadow:SetSize( 2, 1.5 )

    --print("   Physics")
    MakeCharacterPhysics(inst, 75, .5)
    
    --print("   Collision")
    inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.WORLD)
    inst.Physics:CollidesWith(COLLISION.OBSTACLES)
    inst.Physics:CollidesWith(COLLISION.CHARACTERS)

    inst.Transform:SetFourFaced()


    --print("   Userfuncs")

    ------------------------------------------

    --print("   combat")
    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "chester_body"
    inst.components.combat:SetKeepTargetFunction(ShouldKeepTarget)
    --inst:ListenForEvent("attacked", OnAttacked)

    print("   health")
    inst:AddComponent("health")
	inst.components.health.canmurder = false
    inst.components.health:SetMaxHealth(TUNING.CHESTER_HEALTH)
    inst.components.health:StartRegen(TUNING.CHESTER_HEALTH_REGEN_AMOUNT, TUNING.CHESTER_HEALTH_REGEN_PERIOD)
    inst:AddTag("noauradamage")


    --print("   inspectable")
    inst:AddComponent("inspectable")
	inst.components.inspectable:RecordViews()
    --inst.components.inspectable.getstatus = GetStatus

    --print("   locomotor")
    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = 2.5
    inst.components.locomotor.runspeed = 3

    --print("   follower")
    inst:AddComponent("follower")
    inst:ListenForEvent("stopfollowing", OnStopFollowing)
    inst:ListenForEvent("startfollowing", OnStartFollowing)

    --print("   knownlocations")
    inst:AddComponent("knownlocations")

    --print("   burnable")
    MakeSmallBurnableCharacter(inst, "chester_body")
   --[[ 
    --("   container")
    inst:AddComponent("container")
    --inst.components.container:SetNumSlots(#slotpos_3x3)
    inst.components.container:SetNumSlots(4)
	
    inst.components.container.onopenfn = OnOpen
    inst.components.container.onclosefn = OnClose
    
    --inst.components.container.widgetslotpos = slotpos_3x3
    inst.components.container.widgetslotpos = slotpos
	
    --inst.components.container.widgetanimbank = "ui_chest_3x3"
   -- inst.components.container.widgetanimbuild = "ui_chest_3x3"
   -- inst.components.container.widgetpos = Vector3(0,200,0)
    --inst.components.container.side_align_tip = 160

    inst.components.container.widgetanimbank = "ui_cookpot_1x4"
    inst.components.container.widgetanimbuild = "ui_cookpot_1x4"
    inst.components.container.widgetpos = Vector3(200,0,0)
    inst.components.container.side_align_tip = 100
   -- inst.components.container.widgetbuttoninfo = widgetbuttoninfo
    inst.components.container.acceptsstacks = true--false

    --print("   sleeper")
    inst:AddComponent("sleeper")
    inst.components.sleeper:SetResistance(3)
    inst.components.sleeper.testperiod = GetRandomWithVariance(6, 2)
    inst.components.sleeper:SetSleepTest(ShouldSleep)
    inst.components.sleeper:SetWakeTest(ShouldWakeUp)
]]
    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aurafn = CalcSanityAura	

    --print("   sg")
    inst:SetStateGraph("SGbibbit")
    inst.sg:GoToState("idle")
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/bibbit.xml"

    --print("   brain")
    inst:SetBrain(brain)

    --inst.OnSave = OnSave
   -- inst.OnPreLoad = OnPreLoad

    inst:DoTaskInTime(1.5, function(inst)
        -- We somehow got a chester without an eyebone. Kill it! Kill it with fire!
        if not TheSim:FindFirstEntityWithTag("bibbitremote") then
            inst:Remove()
        end
    end)
	local s = .9
	inst.Transform:SetScale(s,s,s)
    --print("chester - create_chester END")
    return inst
end

return Prefab( "common/bibbit", fn, assets, prefabs) 
