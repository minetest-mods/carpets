dofile(minetest.get_modpath("carpets").."/carpet_api.lua")
dofile(minetest.get_modpath("carpets").."/modutils.lua")

depmod = modutils.get_depmod("carpets")


function carpet.enabledfilter(name, def)
-- disable carpets from loaded modules but not defined in dependency
	if depmod.check_depmod(name) == false then  
		return false
	end

-- disable carpets for blocks without description
	if def.description == nil or def.description == "" then
		return false
	end

-- not supported node types for carpets
	if def.drawtype == "liquid"     or
	   def.drawtype == "firelike"   or
	   def.drawtype == "airlike"    or
	   def.drawtype == "plantlike"  or
	   def.drawtype == "nodebox"  or
	   def.drawtype == "raillike"   then
		return false
	end

-- no carpet for signs, rail, ladder
	if def.paramtype2 == "wallmounted" then
		return false
	end

-- all checks passed
	return true
end


------------------------------------------------
-- main execution
for name, def in pairs(minetest.registered_nodes) do
	if carpet.enabledfilter(name, def) == true then
		carpet.register(name)
	end
end
