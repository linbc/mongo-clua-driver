local ffi = require("ffi")
local libmongoc = ffi.load(ffi.os == "OSX" and "libmongoc-1.0.dylib" or "libmongoc-1.0.so")

local mongoc_init 			= libmongoc.mongoc_init
local mongoc_cleanup 		= libmongoc.mongoc_cleanup
local client_new 			= libmongoc.mongoc_client_new
local client_get_database 	= libmongoc.mongoc_client_get_database
local client_find_databases = libmongoc.mongoc_client_find_databases
local client_get_collection = libmongoc.mongoc_client_get_collection
local client_command 		= libmongoc.mongoc_client_command
local client_command_simple = libmongoc.mongoc_client_command_simple
local client_destroy 		= libmongoc.mongoc_client_destroy

local mongoc_client = {}

local meta = {
	__index = mongoc_client,
	__tostring = function (self)        
    end,
    __gc = function ( self )
    end
}

function mongoc_client.new( ptr, authuristr)
	local obj = {}
	obj.ptr = ptr
	if (not ptr) and authuristr then
		obj.ptr = ffi.gc(client_new(authuristr), client_destroy)
	end
	if not obj.ptr then
		error( 'failed to parse SCRAM uri\n')
	end
	return setmetatable(obj, meta)
end

mongoc_client_is_mongoc_init = false

function mongoc_client.mongoc_init()
	if not mongoc_client_is_mongoc_init then
		mongoc_init()
		mongoc_client_is_mongoc_init = true
	end
end

function mongoc_client.mongoc_cleanup()
	mongoc_cleanup()
end

function mongoc_client:get_database(db_name)
	local ptr = client_get_database(self.ptr, db_name)
	return ptr and mongoc_database.new(ptr) or nil
end

function mongoc_client:find_databases(bson_error)
	local ptr = client_find_databases(self.ptr, bson_error)
	return ptr and mongoc_cursor.new(ptr) or nil
end

function mongoc_client:get_collection(db_name, collection)
	local ptr = client_get_collection(self.ptr, db_name, collection)
	return ptr and mongoc_collection.new(ptr) or nil
end

function mongoc_client:command(db_name, flags, skip, limit, batch_size, query, fields, read_prefs)
	local ptr = client_command(self.ptr, db_name, flags, skip, limit, batch_size, query, fields, read_prefs)
	return ptr and mongoc_cursor.new(ptr) or nil
end

function mongoc_client:command_simple(db_name, command, read_prefs, reply, error)
	local ptr = client_command_simple(self.ptr, db_name, command, read_prefs, reply, error)
	return ptr and mongoc_cursor.new(ptr) or nil
end

return mongoc_client