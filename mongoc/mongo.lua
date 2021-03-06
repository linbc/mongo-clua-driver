local ffi = require 'ffi'
local ffi_gc = ffi.gc
local ffi_new = ffi.new

local bson = require 'mongoc.bson'
local mongoc_client   = require 'mongoc.mongoc_client'

local mongo_wrap = {}
local mongo_wrap_meta = {
	__index = function(self, key)
		return rawget(mongo_wrap, key) or self:getDB(key)
	end,
	__tostring = function (self)        
    end,
    __gc = function ( self )
    end
}

local mongo_database_wrap = {}
local mongo_database_wrap_meta = {
	__index = function (self, key)
		return rawget(mongo_database_wrap, key) or self:getCollection(key)
	end,
	__tostring = function (self)        
    end,
    __gc = function ( self )
    end
}

local mongo_collection_wrap = {}
local mongo_collection_wrap_meta = {
	__index = mongo_collection_wrap,
	__tostring = function (self)        
    end,
    __gc = function ( self )
    end
}

local mongo_cursor_wrap = {}
local mongo_cursor_wrap_meta = {
	__index = function(self, key)
		return rawget(mongo_cursor_wrap, key) or self.cursor[key]
	end,
	__tostring = function (self)        
    end,
    __gc = function ( self )
    end
}

--@tb: 	table
function getBsonPtrByTable( tb )
	local the_bson = bson.new()
	if tb ~= nil then
		the_bson:write_values(tb)
	end
	return the_bson.ptr
end

---------------------------------------------------
--client
---------------------------------------------------
--@authuristr: 	连接字符串
function mongo_wrap.new( authuristr )
	mongoc_client:mongoc_init()
    local self = setmetatable({} , mongo_wrap_meta)
	self.client = mongoc_client.new(authuristr)
    return self
end

--@name: 	库名称
function mongo_wrap:getDB( name )
	local database_wrap = nil
	local db = self.client:get_database(name)
	if db ~= nil then
		database_wrap = {}
		database_wrap.database = db
		setmetatable(database_wrap, mongo_database_wrap_meta)
	end
	return database_wrap
end

---------------------------------------------------
--database
---------------------------------------------------
--@name: 	集合名称（表名）
function mongo_database_wrap:getCollection(name)
	local collection_wrap = nil
	local collection = self.database:get_collection(name)
	if collection ~= nil then
		collection_wrap = {}
		collection_wrap.collection = collection
		setmetatable(collection_wrap, mongo_collection_wrap_meta)
	end
	return collection_wrap
end

--@name: 		查询的表名
--@wheres: 		查询的条件
function mongo_database_wrap:count(name, wheres)
	local collection = self.database:get_collection(name)
	if collection ~= nil then
		return collection:count(getBsonPtrByTable(wheres))
	end
	return 0
end

---------------------------------------------------
--collection
---------------------------------------------------
--@values: 	插入的数据
function mongo_collection_wrap:insert(values)
	self.collection:insert(getBsonPtrByTable(values))
end

--@wheres: 	查询的条件
function mongo_collection_wrap:delete(wheres)
	self.collection:remove(getBsonPtrByTable(wheres))
end

--@wheres: 	查询的条件
--@values: 	更新的数据
--@upsert: 	如果不存在则插入
--@multi:   更新多条数据
function mongo_collection_wrap:update(wheres, values, upsert, multi )
    local flags = (upsert and 1 or 0) + (multi and 2 or 0)
	--TODO flags true --如果不存在则变成插入
	self.collection:update(getBsonPtrByTable(wheres), getBsonPtrByTable(values), flags)
end

--@wheres: 	查询的条件
--@fields: 	返回的字段 
--@limit: 	返回记录数 
--@skip: 	返回记录开始索引
function mongo_collection_wrap:find(wheres, fields, limit, skip)
	local cursor_wrap = nil
	local cursor = self.collection:find(getBsonPtrByTable(wheres), getBsonPtrByTable(fields), skip, limit)
	if cursor ~= nil then
		cursor_wrap = {}
		cursor_wrap.cursor = cursor
		setmetatable(cursor_wrap, mongo_cursor_wrap_meta)
	end
	return cursor_wrap
end

--@wheres: 	查询的条件
--@fields: 	返回的字段 
function mongo_collection_wrap:findOne(wheres, fields)
	local cursor = coll:find(wheres, fields, 1)
	return cursor:next()
end


---------------------------------------------------
--cursor
---------------------------------------------------
mongo_wrap.__end = false
mongo_wrap.__next = nil

function mongo_cursor_wrap:hasNext()
    if not self.__next and not self.__end then
		local doc = ffi_new('const bson_t*[1]')
		self.__end = not self.cursor:next(doc)
		if not self.__end then
            local the_bson = bson.new(doc[0])
		    self.__next = the_bson:read_values()
        end
	end
    return self.__next ~= nil
end

function mongo_cursor_wrap:next()
	if self.__next == nil then
		self:hasNext()
	end
	local r = self.__next
	self.__next = nil
	return r
end

return mongo_wrap
