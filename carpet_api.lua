local config = Settings(minetest.get_modpath("carpets").."/settings.txt")

local carpet_proto = {
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	node_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, -0.45, 0.5}
	},
}

if config:get_bool("WoolFeeling") then
	local wool = minetest.registered_nodes["wool:white"]
	carpet_proto.sounds = wool.sounds
	carpet_proto.groups = wool.groups
end


function carpets.register(recipe, def)
	local node = {}

	if def then
		for k, v in pairs(def) do
			node[k] = v
		end
	end

	for k, v in pairs(carpet_proto) do
		node[k] = v
	end

	local recipe_def = minetest.registered_nodes[recipe]

	node.description = node.description or recipe_def.description.." Carpet"
	node.tiles       = node.tiles       or recipe_def.tiles
	if node.tiles[6] then  -- prefer "front" site for carpet
		node.tiles = {node.tiles[6]}
	end

	node.sounds      = node.sounds      or recipe_def.sounds
	node.groups      = node.groups      or recipe_def.groups or {}

	node.groups.leafdecay = nil

	if config:get_bool("FallingCarpet") and node.groups.falling_node == nil then
		node.groups.falling_node = 1
	elseif node.groups.falling_node == 1 then
		node.groups.falling_node = 0
	end

	local name = "carpet:"..(node.name or recipe:gsub(":", "_"))
	node.name = nil

	if config:get_bool("NoFlyCarpet") then
		local previous_on_place = node.on_place or minetest.item_place
		node.on_place = function(itemstack, placer, pointed_thing, ...)
			if not pointed_thing then return end

			local above = pointed_thing.above
			local under = pointed_thing.under
			local under_node = minetest.get_node(under)

			if above.y == under.y + 1 and under_node.name == name then
				return
			end
			return previous_on_place(itemstack, placer, pointed_thing, ...)
		end
	end

	minetest.register_node(":"..name, node)

	minetest.register_craft({
		output = name.." 32",
		recipe = {{"group:wool", "group:wool", "group:wool"},
			  {"group:wool", recipe, "group:wool"}}
	})
end
