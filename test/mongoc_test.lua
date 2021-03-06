package.path = package.path..';../?.lua;/opt/openresty/lualib/?.so'
local ffi = require 'ffi'
local bson = require 'mongoc.bson'
local libbson = require 'mongoc.libbson-wrap'
local mongoc_client   = require 'mongoc.mongoc_client'

--测试插入
local function test_mongo_insert( coll )
  ffi.cdef[[
    int rand(void);
    void srand(unsigned seed);
    time_t time(void*);
  ]]

  for i=1,100 do
    local values = {}
    values.a = 1
    values.b = '2'
    values.c = 3.1
    local the_bson = bson.new()
    the_bson:write_values(values)
    local name = string.format('linbc%d',i)
    the_bson:append_utf8('name', name)
    the_bson:append_int32('age', ffi.C.rand()%99)
    coll:insert(the_bson.ptr, 0, nil, nil)
  end
end

--测试查找
local function test_mongo_find(coll )
  local query = bson.new()
  local cursor = coll:find(query.ptr, nil, 0, 0, 0, 0, nil)

  local doc = ffi.new('const bson_t*[1]')--ffi.typeof("bson_t *[?]")
  while cursor:next(doc) do
    local cstr = libbson.bson_as_json(doc[0], nil)
    print(ffi.string(cstr))
    libbson.bson_free(cstr)
  end
end

function test_mongo_c_driver( )
  --参考：http://api.mongodb.org/c/1.3.0/tutorial.html#find
  --日志处理函数
  -- local printLog = ffi.cast('mongoc_log_func_t', function ( log_level, log_domain, message, user_data )
  --   --print(log_level, ffi.string(log_domain), ffi.string(message))
  -- end)
  -- libmongoc.mongoc_log_set_handler(printLog,nil)

  local authuristr = "mongodb://dev:asdf@192.168.30.11:27022/test?authMechanism=SCRAM-SHA-1"
  local  client = mongoc_client.new(authuristr)
  if not client then
    error( 'failed to parse SCRAM uri\n')
  end

  local collection = client:get_collection('test', 'test')
  --测试插入
--  test_mongo_insert(collection)
  test_mongo_find(collection)
  mongoc_client:mongoc_cleanup()

  --日志函数记得回收
  -- printLog:free()
end

--test_mongo_c_driver()

local mongoc_wrap   = require 'mongoc.mongo'


--测试插入
local function test_mongo_wrap_insert( coll )
  ffi.cdef[[
    int rand(void);
    void srand(unsigned seed);
    time_t time(void*);
  ]]

  for i=1,10 do
    local values = {}
    values.a = i
    values.b = '2'
    values.c = 3.1
    values.name = string.format('linbc%d',i)
    values.age = ffi.C.rand()%99 
    coll:insert(values)
  end
end

--测试查找
local function test_mongo_wrap_find(coll )
    local cursor = coll:find(nil, nil, 0, 0, 0, 0, nil)
    function f0()
        local doc = ffi.new('const bson_t*[1]')--ffi.typeof("bson_t *[?]")
        local b = cursor.cursor:next(doc)
        print(b)
        while b do
            b = cursor.cursor:next(doc)
            print(b)
            local cstr = libbson.bson_as_json(doc[0], nil)
            print(ffi.string(cstr))
            libbson.bson_free(cstr)
        end
    end
    function f1()
        local b = cursor:hasNext()
        while b do
            local t = cursor:next()
            for k,v in pairs(t) do
                print( k,v )
            end
            b = cursor:hasNext()
        end
    end
    f1()
end

--测试更新
local function test_mongo_wrap_update( coll )
    ffi.cdef[[
      int rand(void);
      void srand(unsigned seed);
      time_t time(void*);
    ]]
    local values = {}
    values.a = 1
    values.name = 'linbc--'
    coll:update(nil,  { ["$set"] = values} , true)
   
    values = {}
    values.a = 2
    values.name = 'linbc--'
    coll:insert(values)

    local wheres = {}
    wheres.name = 'linbc--'
    values = {}
    values.a = 100
    values.name = 'linbc--'
    coll:update(wheres, { ["$set"] = values} , true, true)
end

function test_mongo_c_driver_wrap( ... )
  local authuristr = "mongodb://dev:asdf@192.168.30.11:27022/test?authMechanism=SCRAM-SHA-1"
  local mongoc_wrap = mongoc_wrap.new(authuristr)
  if not mongoc_wrap then
    error( 'failed to parse SCRAM uri\n')
  end
  local database_wrap = mongoc_wrap:getDB('test')
  local collection_wrap = database_wrap['test']

  --test_mongo_wrap_insert(collection_wrap)
  --test_mongo_wrap_find(collection_wrap)
  test_mongo_wrap_update(collection_wrap)

  mongoc_client:mongoc_cleanup()

end

test_mongo_c_driver_wrap()
