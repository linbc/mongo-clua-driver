
local libbson = require 'libbson-wrap'

local bson_new = libbson.bson_new
local bson_reinit = libbson.bson_reinit
local bson_destory = libbson.bson_destory

local bson_append_double = libbson.bson_append_double
local bson_append_int64 = libbson.bson_append_int64
local bson_append_null = libbson.bson_append_null
local bson_append_int32 = libbson.bson_append_int32
local bson_append_oid = libbson.bson_append_oid
local bson_append_utf8 = libbson.bson_append_utf8

local bson_iter_init = libbson.bson_iter_init
local bson_iter_next = libbson.bson_iter_next
local bson_iter_key = libbson.bson_iter_key
local bson_iter_type = libbson.bson_iter_type
local bson_iter_double = libbson.bson_iter_double
local bson_iter_utf8 = libbson.bson_iter_utf8
local bson_iter_int32 = libbson.bson_iter_int32
local bson_iter_int64 = libbson.bson_iter_int64


local bson = {}

local bson_meta = {
	__index = function ( self )
	end,
	__tostring = function (self)        
    end,
    __gc = function ( self )
    end
}


function bson.new( ptr )
	local obj = {}
	obj.ptr = ptr
	if not ptr then
		obj.ptr = ffi.gc( bson_new(), bson_destroy)
	end
	return setmetatable(obj, bson_meta)
end

function bson:re_init( self )
	return bson_reinit(self.ptr)
end

function bson:append_double( self, key, value )
	assert(type(value) == 'number')
	return bson_append_double(self.ptr, key, string.len(key), value)
end

function bson:append_int64( self, key, value )
	assert(type(value) == 'number')
	return bson_append_int64(self.ptr, key, string.len(key), value)
end

function bson:append_int32( self, key, value )
	assert(type(value) == 'number')
	return bson_append_int32(self.ptr, key, string.len(key), value)
end

function bson:append_utf8( self, key, value )
	assert(type(value) == 'string')
	return bson_append_utf8(self.ptr, key, string.len(key), value)
end

function bson:append_value( self, key, value )
	
end

--传入key直接返回值,如果为空则返回nil
function bson:read_value( self, key )
	local iter = ffi.gc( ffi.new('bson_iter_t'), ffi.free)
	bson_iter_init (iter, assert(self.ptr))
	while bson_iter_next(iter) do
		local key = ffi.string( bson_iter_key(iter) )
		local t = bson_iter_type(iter)
		if t == libbson.BSON_TYPE_DOUBLE then
			return bson_iter_double(iter)
		elseif t == libbson.BSON_TYPE_UTF8 then
			local buflen = ffi.gc( ffi.new("uint32_t[1]", 1), ffi.free)
			local utf8 = bson_iter_utf8(iter, buflen)
			return ffi.string(utf8)
		elseif t == libbson.BSON_TYPE_INT32 then
			return bson_iter_int32(iter)
		elseif t == libbson.BSON_TYPE_INT64 then
			return bson_iter_int64(iter))
		else
			error('Does not support:',key,	t)
		end
	end
end

return bson
