local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

local config = Settings(modpath .. "/settings.txt")

local carpet_proto = {
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	node_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, -0.45, 0.5}
	},
	groups = {
		snappy = 2,
		flammable = 3,
		oddly_breakable_by_hand = 3,
		choppy = 2
	}
}

if config:get_bool("WoolFeeling") then
	carpet_proto.sounds = default.node_sound_defaults()
	carpet_proto.groups = {snappy = 2, choppy = 2, oddly_breakable_by_hand = 3, flammable = 3}
end

function carpets.register(recipe, def)
	local node = table.copy(carpet_proto)
	if def then
		for k,v in pairs(def) do
			node.k = v
		end
	else
		def = {}
	end

	local recipe_def = minetest.registered_nodes[recipe]
	node.description = def.description or recipe_def.description.." Carpet"
	node.tiles  = table.copy(def.tiles or recipe_def.tiles or {})
	node.sounds = table.copy(def.sounds or recipe_def.sounds or {})
	if def.groups then
		node.groups = table.copy(def.groups)
	end

	if node.tiles[6] then
		node.tiles = {node.tiles[6]}
	end
	node.base_material = recipe
	node.shape_type = "carpet"

	if config:get_bool("FallingCarpet") and node.groups.falling_node == nil then
		node.groups.falling_node = 1
	elseif node.groups.falling_node == 1 then
		node.groups.falling_node = 0
	end

	local name = "carpet:" .. (node.name or recipe:gsub(":", "_"))
	node.name = nil

	if config:get_bool("NoFlyCarpet") then
		local previous_on_place = node.on_place or minetest.item_place
		node.on_place = function(itemstack, placer, pointed_thing, ...)
			if not pointed_thing then
				return
			end

			local above = pointed_thing.above
			local under = pointed_thing.under
			local under_node = minetest.get_node(under)

			if above.y == (under.y + 1) and under_node.name == name then
				return
			end
			return previous_on_place(itemstack, placer, pointed_thing, ...)
		end
	end

	minetest.register_node(":" .. name, node)

	minetest.register_craft({
		output = name .. " 32",
		recipe = {
			{"group:wool", "group:wool", "group:wool"},
			{"group:wool", recipe, "group:wool"}
		}
	})
end
