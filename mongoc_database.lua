local libmongoc = require 'libmongoc-wrap'

local database_command 			= libmongoc.mongoc_database_command
local database_command_simple	= libmongoc.mongoc_database_command_simple
local database_find_collections	= libmongoc.mongoc_database_find_collections
local database_get_collection	= libmongoc.mongoc_database_get_collection
local database_destroy 			= libmongoc.mongoc_database_destroy

local ffi = require 'ffi'
local ffi_gc = ffi.gc
local ffi_new = ffi.new

local mongoc_database = {}

local meta = {
	__index = mongoc_database,
	__tostring = function (self)        
    end,
    __gc = function ( self )
    end
}

function mongoc_database.new(ptr)
	local obj = {}
	obj.ptr = ptr
	if not obj.ptr then
		error( 'failed mongoc_database.new ptr is null\n')
	end
	local function gc_func (p)
	    print('gc_func', p[0])
	    ffi.free(p)
	    self:destroy()
	end
	self.re = ffi_gc(ffi_new('int[?]',64), gc_func)
	return setmetatable(obj, meta)
end

function mongoc_database:command(flags, skip, limit, batch_size, command, fields, read_prefs)
	local ptr = database_command(self.ptr, flags, skip, limit, batch_size, command, fields, read_prefs)
	return ptr and mongoc_cursor.new(ptr) or nil
end

function mongoc_database:command_simple(command, read_prefs, reply)
	local bson_error_t = ffi.new('bson_error_t')
	local b = database_command_simple(self.ptr, command, read_prefs, reply, bson_error_t)
	return b, bson_error_t.message
end

function mongoc_database:find_collections(filter)
	local bson_error_t = ffi.new('bson_error_t')
	local ptr = database_find_collections(self.ptr, filter, bson_error_t)
	return ptr and mongoc_cursor.new(ptr) or (nil, bson_error_t.message)
end

function mongoc_database:get_collection(collection)
	local ptr = database_get_collection(self.ptr, collection)
	return ptr and mongoc_collection.new(ptr) or nil
end

function mongoc_database:destroy()
	database_destroy(self.ptr)
end

return mongoc_database