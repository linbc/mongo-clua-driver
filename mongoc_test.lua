local ffi = require 'ffi'
local libbson = require 'libbson-wrap'
local mongoc_client   = require 'mongoc_client'

--测试插入
local function test_mongo_insert( coll )
  ffi.cdef[[
    int rand(void);
    void srand(unsigned seed);
    time_t time(void*);
  ]]

  local row = ffi.gc(libbson.bson_new(), libbson.bson_destroy)
  for i=1,100 do
    libbson.bson_reinit(row)
    local name = string.format('linbc%d',i)
    libbson.bson_append_utf8(row, 'name', string.len('name'), name, string.len(name))
    libbson.bson_append_int32(row, 'age', string.len('age'), ffi.C.rand()%99)

    coll:insert(0, row, nil, nil)
  end
end

--测试查找
local function test_mongo_find(coll )
  local query = ffi.gc(libbson.bson_new(), libbson.bson_destroy)
  local cursor = coll:find(query, nil, 0, 0, 0, 0, nil)

  local doc = ffi.new('const bson_t*[1]')--ffi.typeof("bson_t *[?]")
  while cursor:next(doc) do
    local cstr = libbson.bson_as_json(doc[0], nil)
    print(ffi.string(cstr))
    libbson.bson_free(cstr)
  end

  local er = ffi.new('bson_error_t[1]')
end

function test_mongo_c_driver( )
  --参考：http://api.mongodb.org/c/1.3.0/tutorial.html#find
  --日志处理函数
  -- local printLog = ffi.cast('mongoc_log_func_t', function ( log_level, log_domain, message, user_data )
  --   --print(log_level, ffi.string(log_domain), ffi.string(message))
  -- end)
  -- libmongoc.mongoc_log_set_handler(printLog,nil)

  local authuristr = "mongodb://user,=:pass@127.0.0.1/test?authMechanism=SCRAM-SHA-1"
  mongoc_client:mongoc_init()
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

test_mongo_c_driver()