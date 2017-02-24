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
	if def.base_material then
		return false
	end

	-- not supported node types for carpets
	if def.drawtype == "liquid"    or
	   def.drawtype == "firelike"  or
	   def.drawtype == "airlike"   or
	   def.drawtype == "plantlike" or
	   def.drawtype == "nodebox"   or
	   def.drawtype == "raillike"  then
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
