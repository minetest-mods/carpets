local modutils = {}

function modutils.get_modname_by_itemname(itemname)
	local def = minetest.registered_items[itemname]
	if def then
		return def.mod_origin
	else --not loaded item
		local delimpos = string.find(itemname, ":")
		if delimpos then
			return string.sub(itemname, 1,  delimpos - 1)
		else
			return nil
		end
	end
end

function modutils.get_depend_checker(modname)
	local self = {
		modname = modname,
		depends = {} -- depends.txt parsed
	}

	-- Check if dependency exists to mod modname
	function self:check_depend(modname, deptype)
		if self.depends[modname] then
			if not deptype then  --"required" or "optional" only
				return true
			else
				return (self.depends[modname] == deptype)
			end
		else
			return false
		end
	end

	--Check if dependency exists to item origin mod
	function self:check_depend_by_itemname(itemname, deptype)
		local modname = modutils.get_modname_by_itemname(itemname)
		if modname then
			return self:check_depend(modname, deptype)
		else
			return false
		end
	end

	-- get module path
	local modpath = minetest.get_modpath(modname)
	if not modpath then
		return nil -- module not found
	end

	-- read the depends file
	local dependsfile = io.open(modpath .. "/depends.txt")
	if not dependsfile then
		return nil
	end

	-- parse the depends file
	for line in dependsfile:lines() do
		if line:sub(-1) == "?" then
			line = line:sub(1, -2)
			self.depends[line] = "optional"
		else
			self.depends[line] = "required"
		end
	end
	dependsfile:close()
	return self
end

return modutils
