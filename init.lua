carpets = {}

local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

dofile(modpath .. "/api.lua")

local depends = (function()
	local file = io.open(modpath .. "/depends.txt")
	if not file then
		return
	end

	local depends = {}
	for line in file:lines() do
		if line:sub(-1) == "?" then
			line = line:sub(1, -2)
		end
		depends[line] = true
	end

	file:close()

	return depends
end)()

local function filter(name, def)
	-- disable carpets from loaded modules but not defined in dependency
	if not depends[def.mod_origin] then
		return false
	end

	-- disable carpets for blocks without description
	if def.description == nil or def.description == "" then
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
