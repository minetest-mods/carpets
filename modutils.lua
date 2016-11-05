local modutils = {}

local function check_depend(this, modname)
	local depends = this.depends
	if depends[modname] then
		return true
	else
		return false
	end
end

function modutils.get_depend_checker(modname)
	-- Definition of returning object attributes
	local this = { }
	this.modname = modname
	this.depends = {} -- depends.txt parsed
	this.check_depend = check_depend -- method

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
		end
		this.depends[line] = true
	end

	return this
end

return modutils
