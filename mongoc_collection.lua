local ffi = require("ffi")
local libmongoc = ffi.load(ffi.os == "OSX" and "libmongoc-1.0.dylib" or "libmongoc-1.0.so")

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
	return setmetatable(obj, meta)
end

function mongoc_collection:command(flags, skip, limit, batch_size, command, fields, read_prefs)
	return collection_command(self.ptr, flags, skip, limit, batch_size, command, fields, read_prefs)
end

function mongoc_collection:command_simple(command, read_prefs, reply, error)
	return collection_command_simple(self.ptr, command, read_prefs, reply, error)
end

function mongoc_collection:count(flags, query, skip, limit, read_prefs, error)
	return collection_count(self.ptr, flags, query, skip, limit, read_prefs, error)
end

function mongoc_collection:count_with_opts(flags, query, skip, limit, opts, read_prefs, error)
	return collection_count_with_opts(self.ptr, flags, query, skip, limit, opts, read_prefs, error)
end

function mongoc_collection:drop(error)
	return collection_drop(self.ptr, error)
end

function mongoc_collection:drop_index(index_name, error)
	return collection_drop_index(self.ptr, index_name, error)
end

function mongoc_collection:create_index(keys, opt, error)
	return collection_create_index(self.ptr, keys, opt, error)
end

function mongoc_collection:find_indexes(error)
	local ptr = collection_find_indexes(self.ptr, error)
	return ptr and mongoc_cursor.new(ptr) or nil
end

function mongoc_collection:find(flags, skip, limit, batch_size, query, fields, read_prefs)
	local ptr = collection_find(self.ptr, flags, skip, limit, batch_size, query, fields, read_prefs)
	return ptr and mongoc_cursor.new(ptr) or nil
end

function mongoc_collection:insert(flags, document, write_concern, error)
	return collection_insert(self.ptr, flags, document, write_concern, error)
end

function mongoc_collection:update(flags, selector, update, write_concern, error)
	return collection_update(self.ptr, flags, selector, update, write_concern, error)
end

function mongoc_collection:save(document, write_concern, error)
	return collection_save(self.ptr, document, write_concern, error)
end

function mongoc_collection:remove(flags, selector, write_concern, error)
	return collection_remove(self.ptr, flags, selector, write_concern, error)
end

function mongoc_collection:rename(new_db, new_name, drop_target_before_rename, error)
	return collection_rename(self.ptr, new_db, new_name, drop_target_before_rename, error)
end

function mongoc_collection:find_and_modify_with_opts(query, opts, reply, error)
	return collection_find_and_modify_with_opts(self.ptr, query, opts, reply, error)
end

function mongoc_collection:find_and_modify(query, sort, update, fields, _remove, upsert, _new, reply, error)
	return collection_find_and_modify(self.ptr, query, sort, update, fields, _remove, upsert, _new, reply, error)
end

function mongoc_collection:destroy()
	collection_destroy(self.ptr)
end

return mongoc_collection