local ffi = require("ffi")
local libmongoc = ffi.load(ffi.os == "OSX" and "libmongoc-1.0.dylib" or "libmongoc-1.0.so")

local cursor_destroy 		= libmongoc.mongoc_cursor_destroy
local cursor_more			= libmongoc.mongoc_cursor_more
local cursor_next 			= libmongoc.mongoc_cursor_next
local cursor_error			= libmongoc.mongoc_cursor_error

local mongoc_cursor = {}

local meta = {
	__index = mongoc_cursor,
	__tostring = function (self)        
    end,
    __gc = function ( self )
    end
}

function mongoc_cursor.new(ptr)
	local obj = {}
	obj.ptr = ptr
	if not obj.ptr then
		error( 'failed mongoc_cursor.new ptr is null\n')
	end
	return setmetatable(obj, meta)
end

function mongoc_cursor:destroy()
	cursor_destroy(self.ptr)
end

function mongoc_cursor:more()
	return cursor_more(self.ptr)
end

function mongoc_cursor:next(bson)
	return cursor_next(self.ptr, bson)
end

function mongoc_cursor:error(error)
	return cursor_error(self.ptr, error)
end

return mongoc_cursor