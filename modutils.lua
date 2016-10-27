-- not modutils related, will be moved to a framework, if the utils framework will be developed :/
-- The envroot is accessable by global variable with module name as name (like if used in "carpets" mod, the modutils are at carpets.modutils available)
-- Different per module environment root allow the use of diffent versions of the same tool in different mods

local currentmod = minetest.get_current_modname()
local envroot = nil

if not currentmod or currentmod == "" then --not minetest or something hacky
	envroot = _G --fallback for hacky calls, populate global
else
	if not _G[currentmod] then
		_G[currentmod] = {}
	end
	envroot = _G[currentmod]
end
-- framework stuff done. -- Now the tool
----------------------------------------

envroot.modutils = {}

-- Definition of returning object methods
local _check_depmod = function(this, checknode)
	-- check if the node (checknode) is from dependent module
	local delimpos = string.find(checknode, ":")
	if delimpos then
		local checkmodname = string.sub(checknode, 1,  delimpos - 1)
		for name, ref in pairs(this.deplist) do
			if name == checkmodname then
				return true
			end
		end
		return false
	end
end

function envroot.modutils.get_depmod(modname)

	-- Definition of returning object attributes
	local this = { }
	this.modname = modname
	this.deplist = {} -- depends.txt parsed
	this.check_depmod = _check_depmod -- method
	-- get module path
	local modpath = minetest.get_modpath(modname)
	if not modpath then
		return nil -- module not found
	end

	-- read the depends file
	local dependsfile = io.open(modpath.."/depends.txt")
	if not dependsfile then
		return nil
	end

	-- parse the depends file
	for dependsline in dependsfile:lines() do
		local depentry = {} -- Entry in deplist
		local depmodname
		if  string.sub(dependsline, -1) == "?" then
			depentry.required = false
			depmodname = string.sub(dependsline, 1, -2)
		else
			depentry.required = true
			depmodname = dependsline
		end
		this.deplist[depmodname] = depentry
	end

	return this
end
