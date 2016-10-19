modutils = {}

function modutils.get_depmod(modname)
-- Get dependency object  (depmod)

-- Definition of returning object attributes
	local depmod = {
		modname,      -- module name from get_depmod
		deplist = {}, -- depends.txt parsed
	}


-- Definition of returning object methods
	function depmod.check_depmod(checknode)
		-- check if the node (checknode) is from dependent module
		local delimpos = string.find(checknode, ":")
		if delimpos then
			local checkmodname = string.sub(checknode, 1,  delimpos - 1)
			for name, ref in pairs(depmod.deplist) do
				if name == checkmodname then
					return true
				end
			end
			return false
		end
	end

-- Full returning object attributes
	depmod.modname = modname

-- local variable definition
	local depentry = {} -- Entry in deplist
	local depmodname -- temp value
	local modpath = minetest.get_modpath(modname)
	if not modpath then
		return nil -- module not found
	end
	local dependsfile = io.open(modpath.."/depends.txt")
	if dependsfile then
		for dependsline in dependsfile:lines() do
			if  string.sub(dependsline, -1) == "?" then
				depentry.required = false
				depmodname = string.sub(dependsline, 1, -2)
			else
				depentry.required = true
				depmodname = dependsline
			end
			depmod.deplist[depmodname] = depentry
		end
	end

	return depmod
end
