local libmongoc = require 'libmongoc-wrap'

local collection_command 					= libmongoc.mongoc_collection_command
local collection_command_simple				= libmongoc.mongoc_collection_command_simple
local collection_count						= libmongoc.mongoc_collection_count
local collection_count_with_opts			= libmongoc.mongoc_collection_count_with_opts
local collection_drop 						= libmongoc.mongoc_collection_drop
local collection_drop_index 				= libmongoc.mongoc_collection_drop_index
local collection_create_index 				= libmongoc.mongoc_collection_create_index
local collection_find_indexes 				= libmongoc.mongoc_collection_find_indexes
local collection_find 						= libmongoc.mongoc_collection_find
local collection_insert 					= libmongoc.mongoc_collection_insert
local collection_update 					= libmongoc.mongoc_collection_update
local collection_save 						= libmongoc.mongoc_collection_save
local collection_remove 					= libmongoc.mongoc_collection_remove
local collection_rename 					= libmongoc.mongoc_collection_rename
local collection_find_and_modify_with_opts 	= libmongoc.mongoc_collection_find_and_modify_with_opts
local collection_find_and_modify 			= libmongoc.mongoc_collection_find_and_modify
local collection_destroy 					= libmongoc.mongoc_collection_destroy

local ffi = require 'ffi'
local ffi_gc = ffi.gc
local ffi_new = ffi.new

local mongoc_collection = {}

local meta = {
	__index = mongoc_collection,
	__tostring = function (self)        
    end,
    __gc = function ( self )
    end
}

function mongoc_collection.new(ptr)
	local obj = {}
	obj.ptr = ptr
	if not obj.ptr then
		error( 'failed mongoc_collection.new ptr is null\n')
	end
	local function gc_func (p)
	    print('gc_func', p[0])
	    ffi.free(p)
	    self:destroy()
	end
	self.re = ffi_gc(ffi_new('int[?]',64), gc_func)
	return setmetatable(obj, meta)
end

function mongoc_collection:command(flags, skip, limit, batch_size, command, fields, read_prefs)
	return collection_command(self.ptr, flags, skip, limit, batch_size, command, fields, read_prefs)
end

function mongoc_collection:command_simple(command, read_prefs, reply)
	local bson_error_t = ffi.new('bson_error_t')
	local b = collection_command_simple(self.ptr, command, read_prefs, reply, bson_error_t)
	return b, bson_error_t.message
end

function mongoc_collection:count(flags, query, skip, limit, read_prefs)
	local bson_error_t = ffi.new('bson_error_t')
	local v = collection_count(self.ptr, flags, query, skip, limit, read_prefs, bson_error_t)
	return v, bson_error_t.message 
end

function mongoc_collection:count_with_opts(flags, query, skip, limit, opts, read_prefs)
	local bson_error_t = ffi.new('bson_error_t')
	local v = collection_count_with_opts(self.ptr, flags, query, skip, limit, opts, read_prefs, bson_error_t)
	return v, bson_error_t.message
end

function mongoc_collection:drop()
	local bson_error_t = ffi.new('bson_error_t')
	local b = collection_drop(self.ptr, bson_error_t)
	return b, bson_error_t.message
end

function mongoc_collection:drop_index(index_name)
	local bson_error_t = ffi.new('bson_error_t')
	local b = collection_drop_index(self.ptr, index_name, bson_error_t)
	return b, bson_error_t.message
end

function mongoc_collection:create_index(keys, opt)
	local bson_error_t = ffi.new('bson_error_t')
	local b = collection_create_index(self.ptr, keys, opt, bson_error_t)
	return b, bson_error_t.message
end

function mongoc_collection:find_indexes()
	local bson_error_t = ffi.new('bson_error_t')
	local ptr = collection_find_indexes(self.ptr, bson_error_t)
	return ptr and mongoc_cursor.new(ptr) or (nil, bson_error_t.message)
end

function mongoc_collection:find(flags, skip, limit, batch_size, query, fields, read_prefs)
	local ptr = collection_find(self.ptr, flags, skip, limit, batch_size, query, fields, read_prefs)
	return ptr and mongoc_cursor.new(ptr) or nil
end

function mongoc_collection:insert(flags, document, write_concern)
	local bson_error_t = ffi.new('bson_error_t')
	local b = collection_insert(self.ptr, flags, document, write_concern, bson_error_t)
	return b, bson_error_t.message
end

function mongoc_collection:update(flags, selector, update, write_concern)
	local bson_error_t = ffi.new('bson_error_t')
	local b = collection_update(self.ptr, flags, selector, update, write_concern, bson_error_t)
	return b, bson_error_t.message
end

function mongoc_collection:save(document, write_concern)
	local bson_error_t = ffi.new('bson_error_t')
	local b = collection_save(self.ptr, document, write_concern, bson_error_t)
	return b, bson_error_t.message
end

function mongoc_collection:remove(flags, selector, write_concern)
	local bson_error_t = ffi.new('bson_error_t')
	local b = collection_remove(self.ptr, flags, selector, write_concern, bson_error_t)
	return b, bson_error_t.message
end

function mongoc_collection:rename(new_db, new_name, drop_target_before_rename)
	local bson_error_t = ffi.new('bson_error_t')
	local b = collection_rename(self.ptr, new_db, new_name, drop_target_before_rename, bson_error_t)
	return b, bson_error_t.message
end

function mongoc_collection:find_and_modify_with_opts(query, opts, reply)
	local bson_error_t = ffi.new('bson_error_t')
	local b = collection_find_and_modify_with_opts(self.ptr, query, opts, reply, bson_error_t)
	return b, bson_error_t.message
end

function mongoc_collection:find_and_modify(query, sort, update, fields, _remove, upsert, _new, reply)
	local bson_error_t = ffi.new('bson_error_t')
	local b = collection_find_and_modify(self.ptr, query, sort, update, fields, _remove, upsert, _new, reply, bson_error_t)
	return b, bson_error_t.message
end

function mongoc_collection:destroy()
	collection_destroy(self.ptr)
end

return mongoc_collection