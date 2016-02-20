local mongoc_client   = require 'mongoc_client'

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
		local the_bson = bson.new()
		the_bson:write_values(wheres)
		return collection:count(the_bson.ptr)
	end
	return 0
end

---------------------------------------------------
--collection
---------------------------------------------------
--@values: 	插入的数据
function mongo_collection_wrap:insert(values)
	local the_bson = bson.new()
	the_bson:write_values(values)
	self.collection:insert(the_bson.ptr)
end

--@wheres: 	查询的条件
function mongo_collection_wrap:delete(wheres)
	local the_bson = bson.new()
	the_bson:write_values(wheres)
	self.collection:remove(the_bson.ptr)
end

--@wheres: 	查询的条件
--@values: 	更新的数据
--@flags: 	
function mongo_collection_wrap:update(wheres, values, flags)
	local selector_bson = bson.new()
	selector_bson:write_values(wheres)
	local update_bson = bson.new()
	update_bson:write_values(values)
	--TODO flags true --如果不存在则变成插入
	self.collection:update(selector_bson.ptr, update_bson.ptr, flags)
end

--@wheres: 	查询的条件
--@fields: 	返回的字段 
--@limit: 	返回记录数 
--@skip: 	返回记录开始索引
function mongo_collection_wrap:find(wheres, fields, limit, skip)
	local wheres_bson = bson.new()
	wheres_bson:write_values(wheres)
	local fields_bson = bson.new()
	fields_bson:write_values(fields)
	local cursor_wrap = nil
	local cursor = self.collection:find(wheres_bson.ptr, fields_bson.ptr, skip, limit)
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
	return self:find(wheres.ptr, fields.ptr, 1)
end

---------------------------------------------------
--cursor
---------------------------------------------------
function mongo_cursor_wrap:hasNext()
	return self.cursor:more()
end

function mongo_cursor_wrap:next()
	local the_bson = bson.new()
	self.cursor:next(the_bson.ptr)
	return the_bson:read_values()
end

return mongo_wrap
