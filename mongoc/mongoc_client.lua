local libmongoc = require 'mongoc.libmongoc-wrap'

local mongoc_init 			= libmongoc.mongoc_init
local mongoc_cleanup 		= libmongoc.mongoc_cleanup
local client_new 			= libmongoc.mongoc_client_new
local client_get_database 	= libmongoc.mongoc_client_get_database
local client_find_databases = libmongoc.mongoc_client_find_databases
local client_get_collection = libmongoc.mongoc_client_get_collection
local client_command 		= libmongoc.mongoc_client_command
local client_command_simple = libmongoc.mongoc_client_command_simple
local client_destroy 		= libmongoc.mongoc_client_destroy

local ffi = require 'ffi'
local ffi_gc = ffi.gc
local ffi_new = ffi.new

local mongoc_database 	= require 'mongoc.mongoc_database'
local mongoc_collection	= require 'mongoc.mongoc_collection'
local mongoc_cursor 	= require 'mongoc.mongoc_cursor'

local mongoc_client = {}

local meta = {
	__index = mongoc_client,
	__tostring = function (self)        
    end,
    __gc = function ( self )
    end
}

-- 生成连接字符串
local function exchangeDBString( auth_info )
    local host = auth_info.host
    local port = auth_info.port
    local user = auth_info.user
    local pwd = auth_info.pwd
    local db = auth_info.db or "admin"
    local new_str = "mongodb://"
    if user ~= '' and pwd ~= '' then
        new_str = new_str..user..":"..pwd.."@"
    end
	new_str = new_str..host
    if port ~= '' then
         new_str = new_str..":"..port
    end
    new_str=new_str.."/"..db.."?authMechanism=SCRAM-SHA-1"
    return new_str
end

-- 如：mongoc_client.new({host = "192.168.30.11, port = "27022", user = "a", pwd = "1"})
-- 或mongoc_client.new("mongodb://dev:asdf@192.168.30.11:27022/test?authMechanism=SCRAM-SHA-1")
function mongoc_client.new(authuristr)
	if type(authuristr) == "table" then
		-- 生成连接字符串
		authuristr = exchangeDBString(authuristr)
	end
	local obj = {}
	if authuristr then
		obj.ptr = client_new(authuristr)
	end
	if not obj.ptr then
		error( 'failed to parse SCRAM uri\n')
	end
	local function gc_func (p)
	    ffi.free(p)
	    obj.destroy(obj)
	end
	obj.re = ffi_gc(ffi_new('int[?]', 0), gc_func)
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

function mongoc_client:find_databases()
	local er = ffi_new('bson_error_t')
	local ptr = client_find_databases(self.ptr, er)
	if ptr then
		return mongoc_cursor.new(ptr)
	else
		return nil, er.message
	end
end

function mongoc_client:get_collection(db_name, collection)
	local ptr = client_get_collection(self.ptr, db_name, collection)
	return ptr and mongoc_collection.new(ptr) or nil
end

function mongoc_client:command(db_name, query, fields, skip, limit, batch_size, flags, read_prefs)
	local ptr = client_command(self.ptr, db_name, flags, skip or 0, limit or 0, batch_size or 0, query, fields, read_prefs)
	return ptr and mongoc_cursor.new(ptr) or nil
end

function mongoc_client:command_simple(db_name, command, reply, read_prefs)
	local er = ffi_new('bson_error_t')
	local ptr = client_command_simple(self.ptr, db_name, command, read_prefs, reply, er)
	if ptr then
		return mongoc_cursor.new(ptr)
	else
		return nil, er.message
	end
end

function mongoc_client:destroy()
	client_destroy(self.ptr)
end

return mongoc_client
