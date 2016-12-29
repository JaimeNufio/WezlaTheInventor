require("stategraphs/commonstates")

local events=
{    
    EventHandler("death", function(inst) inst.sg:GoToState("death") end),
    EventHandler("doattack", function(inst) 
        if not inst.components.health:IsDead() and (inst.sg:HasStateTag("hit") or not inst.sg:HasStateTag("busy")) then 
            inst.sg:GoToState("attack") 

        end 
    end),
    CommonHandlers.OnDeath(),
    --CommonHandlers.OnAttacked(),
    EventHandler("attacked", function(inst) 
        if not inst.components.health:IsDead() and not 
            inst.sg:HasStateTag("attack") then
            inst.sg:GoToState("hit") 
        end 
    end)
}

local states=
{   
    State{
        name = "idle",
        tags = {"idle", "canrotate"},
        onenter = function(inst)
            inst.AnimState:PushAnimation("idle",false)
            --inst.AnimState:PlayAnimation("idle_loop", true)
        end, 
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },
    
	State{
        name = "death",
        tags = {"busy"},
        
        onenter = function(inst)
            inst.AnimState:PlayAnimation("death")      
            inst.components.lootdropper:DropLoot(Vector3(inst.Transform:GetWorldPosition()))            
        end,

        timeline = 
        {
            TimeEvent(17*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/eyeballturret/pop") end)
        },
    },    
        
    State{
        name = "hit",
        tags = {"hit"},
        
        onenter = function(inst) inst.AnimState:PlayAnimation("hit") end,
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },        
    },

    State
    { 
        name = "attack",
        tags = {"attack", "canrotate"},
        onenter = function(inst)
            inst.components.lighttweener:StartTween(nil, 0, .65, .7, nil, 0, function(inst, light) if light then light:Enable(true) end end)
            inst.components.lighttweener:StartTween(nil, 3.5, .9, .9, nil, .66, inst.dotweenin)
            --inst.AnimState:PushAnimation("atk")
			inst.AnimState:PlayAnimation("atk",true)
            inst.SoundEmitter:PlaySound("dontstarve/creatures/eyeballturret/charge")
        end,        
        timeline=
        {
            TimeEvent(22*FRAMES, function(inst) 
                inst.components.combat:StartAttack()
                inst.components.combat:DoAttack()
                inst.SoundEmitter:PlaySound("dontstarve/creatures/eyeballturret/shoot")
            end),
        },
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },   
}
    
return StateGraph("SGwcannon", states, events, "idle")

