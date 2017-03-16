carpets = {}

local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

dofile(modpath .. "/api.lua")

local modutils = dofile(modpath .. "/modutils.lua")
local depmod = modutils.get_depend_checker(modname)

local function filter(name, def)
	-- disable carpets from loaded modules but not defined in dependency
	if not depmod:check_depend_by_itemname(name) then
		return false
	end

	-- disable carpets for blocks without description
	if def.description == nil or def.description == "" then
		return false
	end

	-- no 3rd hand carpets
	local ignore_groups = {
		not_in_creative_inventory = true,
		carpet = true,
		door = true,
		fence = true,
		stair = true,
		slab = true,
		wall = true,
		micro = true,
		panel = true,
		slope = true,
	}
	for k,v in pairs(def.groups) do
		if ignore_groups[k] then
			return false
		end
	end

	-- not supported node types for carpets
	local ignore_drawtype = {
		liquid = true,
		firelike = true,
		airlike = true,
		plantlike = true,
		nodebox = true,
		raillike = true,
	}
	if ignore_drawtype[def.drawtype] then
		return false
	end

	-- no carpet for signs, rail, ladder
	if def.paramtype2 == "wallmounted" then
		return false
	end

	-- all checks passed
	return true
end

-- main execution
for name, def in pairs(minetest.registered_nodes) do
	if filter(name, def) then
		carpets.register(name)
	end
end
