local libmongoc = require 'libmongoc-wrap'

local cursor_destroy 		= libmongoc.mongoc_cursor_destroy
local cursor_more			= libmongoc.mongoc_cursor_more
local cursor_next 			= libmongoc.mongoc_cursor_next
local cursor_error			= libmongoc.mongoc_cursor_error

local ffi = require 'ffi'
local ffi_gc = ffi.gc
local ffi_new = ffi.new

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
	local function gc_func (p)
	    print('gc_func', p[0])
	    ffi.free(p)
	    self:destroy()
	end
	self.re = ffi_gc(ffi_new('int[?]',64), gc_func)
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
	local bson_error_t = ffi.new('bson_error_t')
	local b = cursor_error(self.ptr, bson_error_t)
	return b, bson_error_t.message
end

return mongoc_cursor