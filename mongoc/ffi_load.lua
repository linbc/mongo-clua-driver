local ffi = require 'ffi'

local _M = {}

local function string_split(str, delimiter)
    str = tostring(str)
    delimiter = tostring(delimiter)
    if (delimiter=='') then return false end
    local pos,arr = 0, {}
    -- for each divider found
    for st,sp in function() return string.find(str, delimiter, pos, true) end do
        table.insert(arr, string.sub(str, pos, st - 1))
        pos = sp + 1
    end
    table.insert(arr, string.sub(str, pos))
    return arr
end

function _M.load( so, showmsg )
	local ar = string_split(package.path, ';')
	local o = nil
	local errs = {}
	table.foreach(ar, function(k,v)
		local try_path, count = v:gsub('?', so)
		if count == 1 then
			local status, err = pcall(function (  )
				o = ffi.load(try_path)
			end)
			table.insert(errs, err)
		end
	end)
	if not o then
		print(table.concat(errs, "\r\n"))
	end
	return o
end

return _M

