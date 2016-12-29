local assets =
{
	Asset("ANIM", "anim/wgen.zip"),
	Asset("ANIM", "anim/lightning_rod_fx.zip"),
}

local prefabs = 
{
    "lightning_rod_fx","wezlafuel"
}

local function fueldrop(inst,num)
	local pt1 = Vector3(inst.Transform:GetWorldPosition())
	for k = 1, num do
		local theta = math.random() * 2 * PI
        local radius = math.random(2, 3)
        local result_offset = FindValidPositionByFan(theta, radius, 3, function(offset)
        local x,y,z = (pt1 + offset):Get()
        local ents = TheSim:FindEntities(x,y,z , 1)
        return not next(ents) 
    end)			

    if result_offset then
        local tentacle = SpawnPrefab("wezlafuel")
                
        tentacle.Transform:SetPosition((pt1 + result_offset):Get())
        local fx = SpawnPrefab("explode_small")
        local pos1 = pt1 + result_offset
        fx.Transform:SetPosition(pos1.x, pos1.y, pos1.z)

    end	
	end
end


local function onhammered(inst, worker)
	inst.components.lootdropper:DropLoot()
	SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
	inst:Remove()
	inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")
end
        
local function onhit(inst, worker)
	--inst.AnimState:PlayAnimation("hit")
	inst.AnimState:PlayAnimation("idle")--, false)
end

local function discharge(inst)
    inst.AnimState:SetBloomEffectHandle("")
	inst.charged = false
	inst.chargeleft = nil
    inst.Light:Enable(false)
    if inst.zaptask then
        inst.zaptask:Cancel()
        inst.zaptask = nil
    end
end

local function dozap(inst)
    if inst.zaptask then
        inst.zaptask:Cancel()
        inst.zaptask = nil
    end
    inst.SoundEmitter:PlaySound("dontstarve/common/lightningrod")

    local fx = SpawnPrefab("lightning_rod_fx")
    local pos = inst:GetPosition()
    fx.Transform:SetPosition(pos.x, pos.y, pos.z)

    PlayFX(Vector3(inst.Transform:GetWorldPosition() ), "lightning_rod_fx", "lightning_rod_fx", "idle")
    inst.zaptask = inst:DoTaskInTime(math.random(10, 40), dozap)
end

local function setcharged(inst)
    dozap(inst)
	inst.AnimState:SetBloomEffectHandle( "shaders/anim.ksh" )
    inst.Light:Enable(true)
	inst.charged = true
	inst.chargeleft = 3

    inst:ListenForEvent( "daycomplete", function()
        if inst.chargeleft then
            dozap(inst)
            inst.chargeleft = inst.chargeleft - 1
            if inst.chargeleft <= 0 then
                discharge(inst)--<turn off
            end
        end
    end, GetWorld())
end

local function onlightning(inst)
   -- onhit(inst)
	fueldrop(inst,math.random(2,4))
    setcharged(inst)
end

local function OnSave(inst, data)
    if inst.charged then
        data.charged = inst.charged
        data.chargeleft = inst.chargeleft
    end
end

local function OnLoad(inst, data)
    if data and data.charged and data.chargeleft then
        --setcharged(inst)
        inst.chargeleft = data.chargeleft
    end
end

local function getstatus(inst)
	if inst.charged then
		return "CHARGED"
	end
end

local function onbuilt(inst)
	--inst.AnimState:PushAnimation("place")
	inst.AnimState:PlayAnimation("idle",true)
end

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState() 
 
 	--local minimap = inst.entity:AddMiniMapEntity()
	--minimap:SetIcon( "lightningrod.png" )
	
    local light = inst.entity:AddLight()
    inst.Light:Enable(false)
	inst.Light:SetRadius(1.5)
    inst.Light:SetFalloff(1)
    inst.Light:SetIntensity(.5)
    inst.Light:SetColour(235/255,121/255,12/255)

    inst.entity:AddSoundEmitter()
    inst:AddTag("structure")
    inst:AddTag("lightningrod")

    anim:SetBank("wgen")
    anim:SetBuild("wgen")
    anim:PlayAnimation("idle")

	inst:ListenForEvent("lightningstrike", onlightning)
    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
	inst.components.workable:SetOnFinishCallback(onhammered)
	inst.components.workable:SetOnWorkCallback(onhit)
	
    inst:AddComponent("inspectable")
	inst.components.inspectable.getstatus = getstatus
    
	MakeSnowCovered(inst, .01)
	inst:ListenForEvent( "onbuilt", onbuilt)
	
    inst.OnSave = OnSave
    inst.OnLoad = OnLoad
	
	local s = 1.8
	inst.Transform:SetScale(s,s,s)
	MakeObstaclePhysics(inst, .7)
    return inst
end

return Prefab( "common/objects/wgen", fn, assets, prefabs),
	   MakePlacer("common/wgen_placer", "wgen", "wgen", "idle")  
