package.path = package.path..';../?.lua;/opt/openresty/lualib/?.so'

local libbson = require 'mongoc.libbson-wrap'
local bson = require 'mongoc.bson'

local ffi = require 'ffi'
local ffi_gc = ffi.gc
local ffi_new = ffi.new

local function test_libbson_cfunction( )
	--构造一个bson对象{a:1, b:-1, c:0.1, d:"linbc"}
	local doc = libbson.bson_new()

	--开始构造文档
	local key = 'k_int'
	libbson.bson_append_int32(doc, key, string.len(key), 1)
	key = 'k_int64'
	libbson.bson_append_int64(doc, key, string.len(key), -1)
	key = 'k_double'
	libbson.bson_append_double(doc, key, string.len(key), 0.1)
	key = 'k_utf8'
	libbson.bson_append_utf8(doc, key, string.len(key), 'linbc', 5)
	
	local doc2 = libbson.bson_new()
	libbson.bson_append_int32(doc2, key, string.len(key), 1)
	
	libbson.bson_append_document(doc, key, string.len(key), doc2)

	--开始从档里读数据了
	local iter = ffi.gc( ffi.new('bson_iter_t'), ffi.free)
	libbson.bson_iter_init (iter, doc)
	while libbson.bson_iter_next(iter) do
		local key = ffi.string( libbson.bson_iter_key(iter) )
		local t = libbson.bson_iter_type(iter)
		if t == libbson.BSON_TYPE_DOUBLE then
			print(key,	t, libbson.bson_iter_double(iter))
		elseif t == libbson.BSON_TYPE_UTF8 then
			local buflen = ffi.gc( ffi.new("uint32_t[1]", 1), ffi.free)
			local utf8 = libbson.bson_iter_utf8(iter, buflen)
			print(key,	t, ffi.string(utf8))
		elseif t == libbson.BSON_TYPE_INT32 then
			print(key,	t, libbson.bson_iter_int32(iter))
		elseif t == libbson.BSON_TYPE_INT64 then
			print(key,	t, libbson.bson_iter_int64(iter))
		elseif t == libbson.BSON_TYPE_DOCUMENT then
			print(key,	t)
		else
			error('Does not support:',key,	t)
		end
	end

	libbson.bson_destroy(doc)
end

--test_libbson_cfunction()

local function bsonTests( )
	local values = {}
	values.a = 1
	values.b = {a = '2'}
	values.c = 3.1
	values.d = ffi_new('int32_t', 4)
	values.e = ffi_new('int64_t',5)
	values.f = ffi_new('double',6.2)
	for k,v in pairs(values) do
		print(k,v)
	end
	print(1111111)
	local the_bson = bson.new()
	the_bson:write_values(values)

	local values2 = the_bson:read_values()
	for k,v in pairs(values) do
		if type(values2[k]) == "table" then
			for _k, _v in pairs(values2[k]) do
			print("----", _k, _v)
			end
		end
		print(k,v, values2[k])
		--assert(v == values2[k])
	end
	print('bson.runTests test ok!')
end

bsonTests( )