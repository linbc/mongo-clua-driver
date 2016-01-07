
local libbson = require 'libbson-wrap'

local ffi = require 'ffi'
local ffi_gc = ffi.gc
local ffi_new = ffi.new


local bson_new = libbson.bson_new
local bson_reinit = libbson.bson_reinit
local bson_destroy = libbson.bson_destroy

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
	__index = bson,
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

function bson:re_init( )
	return bson_reinit(self.ptr)
end

function bson:append_double( key, value )
	--assert(type(value) == 'number')
	return bson_append_double(self.ptr, key, string.len(key), value)
end

function bson:append_int64( key, value )
	--assert(type(value) == 'number')
	return bson_append_int64(self.ptr, key, string.len(key), value)
end

function bson:append_int32( key, value )
	--assert(type(value) == 'number')
	return bson_append_int32(self.ptr, key, string.len(key), value)
end

function bson:append_utf8( key, value )
	--assert(type(value) == 'string')
	return bson_append_utf8(self.ptr, key, string.len(key), value, string.len(value))
end

--从一个lua_number中生成cdata类型
function bson:new_cdata_number( luaNumber )
	local a = ffi_new('int32_t',luaNumber)
    local b = ffi_new('double',luaNumber)
    return tonumber(a) == tonumber(b) and a or b
end

--插入值,根据值类型自动选用相应函数
function bson:append_value( key, value )
	assert(key and value)
	local typ = type(value)
	if typ == 'string' then
		return self:append_utf8(key, value)
	elseif typ == 'number' then
		local a = ffi_new('int64_t', value)
	    local b = ffi_new('double', value)
	    --如果相等则说明是整型 否则则是double
	    if tonumber(a) == tonumber(b) then
			return self:append_int64(key, a)
	    else
	    	return self:append_double(key, b)
	    end
	elseif typ == 'cdata' then
		local typ2 = tostring(ffi.typeof(value))
		if typ2 == 'ctype<int>' then
			return self:append_int32(key, value)
		elseif typ2 =='ctype<unsigned int>' or typ2 == 'ctype<int64_t>' then
			return self:append_int64(key, value)
		elseif typ2 == 'ctype<double>'  then
			return self:append_double(key, value)
		end
	end
	error(string.format('does not support: %s,%s,%s',typ, key, tonumber(value)))
end

--传入key直接返回值,如果为空则返回nil
function bson:read_value( key )
	local iter = ffi.gc( ffi.new('bson_iter_t'), ffi.free)
	bson_iter_init (iter, assert(self.ptr))
	while bson_iter_next(iter) do
		if ffi.string( bson_iter_key(iter) )== key then

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
				return bson_iter_int64(iter)
			else
				--TODO:未支持的类型在这里加一下
				error('does not support:',key,	t)
			end
		end
	end
end

function bson:read_values( )
	local iter = ffi.gc( ffi.new('bson_iter_t'), ffi.free)
	bson_iter_init (iter, assert(self.ptr))

	local values = {}
	while bson_iter_next(iter) do
		local k = ffi.string( bson_iter_key(iter) )
		local t = bson_iter_type(iter)
		local v = nil
		if t == libbson.BSON_TYPE_DOUBLE then
			v = bson_iter_double(iter)
		elseif t == libbson.BSON_TYPE_UTF8 then
			local buflen = ffi.gc( ffi.new("uint32_t[1]", 1), ffi.free)
			local utf8 = bson_iter_utf8(iter, buflen)
			v = ffi.string(utf8)
		elseif t == libbson.BSON_TYPE_INT32 then
			v = bson_iter_int32(iter)
		elseif t == libbson.BSON_TYPE_INT64 then
			v = bson_iter_int64(iter)
		else
			--TODO:未支持的类型在这里加一下
			error('does not support:',key,	t)
		end
		values[k] = v
	end
	return values
end

function bson:write_values( values )
	for k,v in pairs(values) do
		self:append_value( k,v )
	end
end

function bson.runTests( )
	local values = {}
	values.a = 1
	values.b = '2'
	values.c = 3.1
	values.d = ffi_new('int32_t', 4)
	values.e = ffi_new('int64_t',5)
	values.f = ffi_new('double',6.2)

	local the_bson = bson.new()
	the_bson:write_values(values)

	local values2 = the_bson:read_values()
	for k,v in pairs(values) do
		print(k,v)
		assert(v == values2[k])
	end
	print('bson.runTests test ok!')
end

return bson
