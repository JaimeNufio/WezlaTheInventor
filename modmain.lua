PrefabFiles = {"wezla","steamgoggles","iron","ore","wgun","wgun_charge",
"wteddy","wezlamachine","wboom","wcannon","wcannon_projectile",
"patches","wezlafuel","wgen","aura",--[["bibbitdoll",]]"vshake","wgun_tornado",
"tstaff","bibbit","bibbitremote"
--"wezlagramaphone"
}

local require = GLOBAL.require
local STRINGS = GLOBAL.STRINGS
local Recipe = GLOBAL.Recipe
local Ingredient = GLOBAL.Ingredient
local RECIPETABS = GLOBAL.RECIPETABS
local TECH = GLOBAL.TECH

Assets = {

    Asset("IMAGE", "minimap/wezlamachine.tex"),
    Asset("ATLAS", "minimap/wezlamachine.xml"),

    Asset("SOUNDPACKAGE", "sound/wezla.fev"),
    Asset("SOUND", "sound/wezla.fsb"),
	
	Asset("SOUNDPACKAGE", "sound/jocelismusic.fev"),
	Asset("SOUND", "sound/jocelismusic.fsb"),

    Asset( "IMAGE", "images/saveslot_portraits/wezla.tex" ),
    Asset( "ATLAS", "images/saveslot_portraits/wezla.xml" ),

    Asset( "IMAGE", "images/selectscreen_portraits/wezla.tex" ),
    Asset( "ATLAS", "images/selectscreen_portraits/wezla.xml" ),
	
    Asset( "IMAGE", "images/selectscreen_portraits/wezla_silho.tex" ),
    Asset( "ATLAS", "images/selectscreen_portraits/wezla_silho.xml" ),

    Asset( "IMAGE", "bigportraits/wezla.tex" ),
    Asset( "ATLAS", "bigportraits/wezla.xml" ),
	
	Asset( "IMAGE", "images/map_icons/wezla.tex" ),
	Asset( "ATLAS", "images/map_icons/wezla.xml" ),
	--tab
	Asset( "ATLAS", "images/inventoryimages/wezla_tab.xml" ),
	
	Asset("ATLAS", "images/inventoryimages/wboom.xml"),
    Asset("IMAGE", "images/inventoryimages/wboom.tex"),
	
	Asset("ATLAS", "images/inventoryimages/steamgoggles.xml"),
    Asset("IMAGE", "images/inventoryimages/steamgoggles.tex"),
	
	Asset("ATLAS", "images/inventoryimages/wteddy.xml"),
    Asset("IMAGE", "images/inventoryimages/wteddy.tex"),

	Asset("ATLAS", "images/inventoryimages/wezlamachine.xml"),
    Asset("IMAGE", "images/inventoryimages/wezlamachine.tex"),
	
	Asset("ATLAS", "images/inventoryimages/patches.xml"),
    Asset("IMAGE", "images/inventoryimages/patches.tex"),
	
	Asset("ATLAS", "images/inventoryimages/wgen.xml"),
    Asset("IMAGE", "images/inventoryimages/wgen.tex"),
	
	Asset("ATLAS", "images/inventoryimages/iron.xml"),
    Asset("IMAGE", "images/inventoryimages/iron.tex"),
	
	Asset("ATLAS", "images/inventoryimages/ore.xml"),
    Asset("IMAGE", "images/inventoryimages/ore.tex"),
	
	Asset("ATLAS", "images/inventoryimages/wezlafuel.xml"),
    Asset("IMAGE", "images/inventoryimages/wezlafuel.tex"),
	
	Asset("ATLAS", "images/inventoryimages/bibbitdoll.xml"),
    Asset("IMAGE", "images/inventoryimages/bibbitdoll.tex"),
	
	Asset("ATLAS", "images/inventoryimages/wgun.xml"),
    Asset("IMAGE", "images/inventoryimages/wgun.tex"),

	Asset("ATLAS", "images/inventoryimages/vshake.xml"),
    Asset("IMAGE", "images/inventoryimages/vshake.tex"),
	
	Asset("ATLAS", "images/inventoryimages/wcannon.xml"),
    Asset("IMAGE", "images/inventoryimages/wcannon.tex"),
}

AddMinimapAtlas("minimap/wezlamachine.xml")

--RemapSoundEvent( "dontstarve/music/music_hoedown", "music_mod/music/music_hoedown" )
RemapSoundEvent( "dontstarve/characters/wezla/death_voice", "wezla/characters/wezla/death_voice" )
RemapSoundEvent( "dontstarve/characters/wezla/hurt", "wezla/characters/wezla/hurt" )
RemapSoundEvent( "dontstarve/characters/wezla/talk_LP", "wezla/characters/wezla/talk_LP" )

local require = GLOBAL.require

GLOBAL.STRINGS.NAMES.SPELL_TAB = "WEZLA"
STRINGS.TABS.SPELL_TAB = "Wezla"
GLOBAL.RECIPETABS['WEZLA_TAB'] = {str = "WEZLA_TAB", sort=500, icon = "wezla_tab.tex", icon_atlas = "images/inventoryimages/wezla_tab.xml"}
--[[
GLOBAL.STRINGS.NAMES.BIBBITDOLL = "Bibbit Plushie"
GLOBAL.STRINGS.RECIPE_DESC.BIBBITDOLL = "A doll to keep Wezla company."
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.BIBBITDOLL = "It'll do for now."
local bibbitdollrecipe = Recipe( "bibbitdoll", { Ingredient("froglegs", 1), Ingredient("meat_dried", 1), Ingredient("beefalowool", 3) }, RECIPETABS.WEZLA_TAB, {SCIENCE = 0, MAGIC = 0, ANCIENT = 0})
bibbitdollrecipe.atlas = "images/inventoryimages/bibbitdoll.xml"
]]
GLOBAL.STRINGS.NAMES.WEZLAMACHINE = "Flying Aparatus"
GLOBAL.STRINGS.RECIPE_DESC.WEZLAMACHINE = "For those who want to further their research."
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.WEZLAMACHINE = "Imagination is the seed of invention!"
local wezlamachinerecipe = Recipe( "wezlamachine", { Ingredient("boards", 10),Ingredient("transistor", 3),Ingredient("gears", 1) }, RECIPETABS.WEZLA_TAB, {SCIENCE = 2, MAGIC = 0, ANCIENT = 0}, "wezlamachine_placer" )
wezlamachinerecipe.atlas = "images/inventoryimages/wezlamachine.xml"

GLOBAL.STRINGS.NAMES.WGEN = "Lightning Extractor"
GLOBAL.STRINGS.RECIPE_DESC.WGEN = "Extracts the essence of lightning."
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.WGEN = "I hope it rains soon!"
local wgenrecipe = Recipe( "wgen", { Ingredient("iron", 3,"images/inventoryimages/iron.xml"),Ingredient("marble", 5),Ingredient("gears", 2) }, RECIPETABS.WEZLA_TAB, {SCIENCE = 3, MAGIC = 0, ANCIENT = 0}, "wgen_placer" )
wgenrecipe.atlas = "images/inventoryimages/wgen.xml"

GLOBAL.STRINGS.NAMES.WCANNON = "Melty Marble Turret"
GLOBAL.STRINGS.RECIPE_DESC.WCANNON = "The epitome of deffensive turrets."
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.WCANNON = "I'd hate to be the one to annoy it!"
local wgunrecipe = Recipe( "wcannon", { Ingredient("iron", 10,"images/inventoryimages/iron.xml"), Ingredient("trinket_1", 1), Ingredient("gears", 3) }, RECIPETABS.WEZLA_TAB, {SCIENCE = 3, MAGIC = 0, ANCIENT = 0}, "wcannon_placer" )
wgunrecipe.atlas = "images/inventoryimages/wcannon.xml"

GLOBAL.STRINGS.NAMES.WBOOM = "Boomer Rocket"
GLOBAL.STRINGS.RECIPE_DESC.WBOOM = "50% less Rang. 100% more Rocket."
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.WBOOM = "The boomerist of the rangs!"
local wboomrecipe = Recipe( "wboom", { Ingredient("gunpowder", 1),Ingredient("trinket_5", 1),Ingredient("boomerang", 1) }, RECIPETABS.WEZLA_TAB, {SCIENCE = 3, MAGIC = 0, ANCIENT = 0}, nil, nil, nil, nil, true)
wboomrecipe.atlas = "images/inventoryimages/wboom.xml"

GLOBAL.STRINGS.NAMES.WTEDDY = "Mr. Patches"
GLOBAL.STRINGS.RECIPE_DESC.WTEDDY = "It sure can take a beating!"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.WTEDDY = "\"That's my wittle weddy bear!\""
local wteddyrecipe = Recipe( "wteddy", { Ingredient("beefalowool", 5),Ingredient("trinket_9", 1),Ingredient("manrabbit_tail", 3) }, RECIPETABS.WEZLA_TAB, {SCIENCE = 3, MAGIC = 0, ANCIENT = 0}, nil, nil, nil, nil, true)
wteddyrecipe.atlas = "images/inventoryimages/wteddy.xml"

GLOBAL.STRINGS.NAMES.PATCHES = "Patches For Patches"
GLOBAL.STRINGS.RECIPE_DESC.PATCHES = "Now with floral patterns."
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.PATCHES = "\"Don't worry patches, I'll make you good as new!\""
local patchesrecipe = Recipe( "patches", { Ingredient("silk", 4),Ingredient("petals", 12),Ingredient("stinger", 1) }, RECIPETABS.DRESS, {SCIENCE = 3, MAGIC = 0, ANCIENT = 0}, nil, nil, nil, nil, true)
patchesrecipe.atlas = "images/inventoryimages/patches.xml"

GLOBAL.STRINGS.NAMES.IRON = "Metal Sheet"
GLOBAL.STRINGS.RECIPE_DESC.IRON = "Great for inventing new machines!"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.IRON = "Sturdy building materials for science."
local wironrecipe = Recipe( "iron", { Ingredient("ore", 3, "images/inventoryimages/ore.xml") }, RECIPETABS.REFINE, {SCIENCE = 3, MAGIC = 0, ANCIENT = 0})
wironrecipe.atlas = "images/inventoryimages/iron.xml"

GLOBAL.STRINGS.NAMES.ORE = "Unobtanium Ore"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.ORE = "The building blocks to greatness!"

GLOBAL.STRINGS.NAMES.WEZLAFUEL = "Lightning Essense"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.WEZLAFUEL = "Think of the applications!"

GLOBAL.STRINGS.NAMES.STEAMGOGGLES = "Wezla's Goggles"
GLOBAL.STRINGS.RECIPE_DESC.STEAMGOGGLES = "Only for the best inventor's eyes!"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.STEAMGOGGLES = "Theyre brilliant, just like me!"

GLOBAL.STRINGS.NAMES.VSHAKE = "Volt Shake"
GLOBAL.STRINGS.RECIPE_DESC.VSHAKE = "Electrifies everything."
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.VSHAKE = "I think it's glowing..."
local vshakerecipe = Recipe( "vshake", { Ingredient("goatmilk", 1), Ingredient("trinket_8", 1), Ingredient("ice", 3) }, RECIPETABS.WEZLA_TAB, {SCIENCE = 3, MAGIC = 0, ANCIENT = 0})
vshakerecipe.atlas = "images/inventoryimages/vshake.xml"

GLOBAL.STRINGS.NAMES.WGUN = "Barometirc Blaster"
GLOBAL.STRINGS.RECIPE_DESC.WGUN = "The applied power of the elements."
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.WGUN = "This might be fun in another season, too."
local wgunrecipe = Recipe( "wgun", { Ingredient("orangegem", 1), Ingredient("trinket_6", 1), Ingredient("iron", 2, "images/inventoryimages/iron.xml") }, RECIPETABS.WEZLA_TAB, {SCIENCE = 3, MAGIC = 0, ANCIENT = 0})
wgunrecipe.atlas = "images/inventoryimages/wgun.xml"

GLOBAL.STRINGS.RECIPE_DESC.GEARS = "Bits and pieces of stuff for things."
Recipe( "gears", { Ingredient("iron", 1,"images/inventoryimages/iron.xml")}, RECIPETABS.REFINE, {SCIENCE = 3, MAGIC = 0, ANCIENT = 0})

GLOBAL.STRINGS.NAMES.BIBBIT = "Bibbit"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.BIBBIT = "Bibbit helps keep me sane!"

GLOBAL.STRINGS.NAMES.BIBBITREMOTE = "Bibbit's Control"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.BIBBITREMOTE = "Come to me my Bibbit!"

GLOBAL.STRINGS.NAMES.BIBBITREMOTEBROKEN = "Broken Bibbit's Control"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.BIBBITREMOTEBROKEN = "Hopefully he'll be back soon!"

----------------------------------------------------------

STRINGS.CHARACTER_TITLES.wezla = "The Mad Inventor"
STRINGS.CHARACTER_NAMES.wezla = "Wezla"
STRINGS.CHARACTER_DESCRIPTIONS.wezla = "*Likes to craft his own inventions. \n*Dislikes Magic; needs Bibbit to keep sane. \n*Likes eletric milk, and has neat goggles. "--"*Does not believe in Magic. \n*Energized by Eletric Milk.\n*Likes to craft with trinkets."
STRINGS.CHARACTER_QUOTES.wezla = "\"Wezla, you beautiful genius, you!\""
table.insert(GLOBAL.CHARACTER_GENDERS.MALE, "wezla")
GLOBAL.STRINGS.CHARACTERS.WEZLA = require "speech_wezla"

AddMinimapAtlas("images/map_icons/wezla.xml")
AddModCharacter("wezla")

local Fuel = {"nitre","transistor"}--,"gears","lightbulb"}

local function Wezla_fuel(inst)
	if not inst.components.fuel then
		inst:AddComponent("fuel")
	end
    inst.components.fuel.fueltype = "WEZLA"
    inst.components.fuel.fuelvalue = TUNING.TINY_FUEL
end

for i = 1, #Fuel do
AddPrefabPostInit(Fuel[i], Wezla_fuel)
print("added fuel type WEZLA to "..Fuel[i])
end


modimport "wezla_loot.lua"

---I think this should be here?
function lootdropperpostinit(inst)

	inst.GenerateLoot = function(self)
    local loots = {}
    
    if self.numrandomloot and math.random() <= (self.chancerandomloot or 1) then
		for k = 1, self.numrandomloot do
		    local loot = self:PickRandomLoot()
		    if loot then
			    table.insert(loots, loot)
			end
		end
	end
    
    if self.chanceloot then
		for k,v in pairs(self.chanceloot) do
			if math.random() < v.chance then
				table.insert(loots, v.prefab)
				self.droppingchanceloot = true
			end
		end
	end

    if self.chanceloottable then
    	local loot_table = GLOBAL.LootTables[self.chanceloottable]
    	if loot_table then
    		for i, entry in ipairs(loot_table) do
    			local prefab = entry[1]
    			local chance = entry[2]    			
				if math.random() <= chance then
					table.insert(loots, prefab)
					self.droppingchanceloot = true
				end
			end
		end
	end

	if not self.droppingchanceloot and self.ifnotchanceloot then
		self.inst:PushEvent("ifnotchanceloot")
		for k,v in pairs(self.ifnotchanceloot) do
			table.insert(loots, v.prefab)
		end
	end


    
    if self.loot then
		for k,v in ipairs(self.loot) do
			table.insert(loots, v)
		end
	end
	
	local recipe = GLOBAL.GetRecipe(self.inst.prefab)

	if recipe and not self.inst.components.norecipelootdrop then
	

		
		local percent = 1

		if self.inst.components.finiteuses then
			percent = self.inst.components.finiteuses:GetPercent()
		end

		for k,v in ipairs(recipe.ingredients) do
			local amt = math.ceil( (v.amount * TUNING.HAMMER_LOOT_PERCENT) * percent)
			for n = 1, amt do
				table.insert(loots, v.type)
			end
		end
	end
    
    return loots

    end


end	   
	   
AddComponentPostInit("lootdropper", lootdropperpostinit)


