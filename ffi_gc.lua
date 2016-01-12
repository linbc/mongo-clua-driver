local ffi = require 'ffi'
local ffi_gc = ffi.gc
local ffi_new = ffi.new

local ffi_gc = {}

local meta = {
	__index = gc_test,
	__tostring = function (self)        
    end,
    __gc = function ( self )
    end
}

function ffi_gc.new()
	local obj = {}
	local function gc_func (p)
	    ffi.free(p)
	    obj.destroy(obj)
	end
	obj.re = ffi_gc(ffi_new('int[?]', 0), gc_func)
	return setmetatable(obj, meta)
end


function ffi_gc:destroy()
	print 'gc_test:destroy'
end

return ffi_gc