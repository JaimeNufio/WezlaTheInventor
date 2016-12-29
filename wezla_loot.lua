
local function AddOreLoot(prefab)
	prefab.components.lootdropper:AddChanceLoot('ore',.7)
end

local function AddIronLoot(prefab)
	prefab.components.lootdropper:AddChanceLoot('iron',.7)
end

AddPrefabPostInit("rock_flintless", AddOreLoot)


AddPrefabPostInit("bishop", AddIronLoot)
AddPrefabPostInit("rook", AddIronLoot)
AddPrefabPostInit("knight", AddIronLoot)
