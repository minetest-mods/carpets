local modutils = {}

-- class methods
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

-- object methods
local function check_depend(this, modname, deptype)
	local depends = this.depends
	if depends[modname] then
		if not deptype then  --"required" or "optional" only
			return true
		else
			return (depends[modname] == deptype)
		end
	else
		return false
	end
end

local function check_depend_by_itemname(this, itemname, deptype)
	local modname = modutils.get_modname_by_itemname(itemname)
	if modname then
		return this:check_depend(modname, deptype)
	else
		return false
	end
end

function modutils.get_depend_checker(modname)
	-- Definition of returning object attributes
	local this = { }
	this.modname = modname
	this.depends = {} -- depends.txt parsed
	this.check_depend = check_depend
	this.check_depend_by_itemname = check_depend_by_itemname


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
			this.depends[line] = "optional"
		else
			this.depends[line] = "required"
		end
	end

	return this
end

return modutils
