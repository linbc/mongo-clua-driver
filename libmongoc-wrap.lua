local ffi = require("ffi")
local libmongoc = ffi.load(ffi.os == "OSX" and "libmongoc-1.0.dylib" or "libmongoc-1.0.so")

local libbson = require "libbson-wrap"

--from...
ffi.cdef[[

typedef struct _mongoc_index_opt_t mongoc_index_opt_t;
typedef struct _mongoc_write_concern_t mongoc_write_concern_t;
typedef struct _mongoc_update_flags_t mongoc_update_flags_t;
typedef struct _mongoc_remove_flags_t mongoc_remove_flags_t;
typedef struct _mongoc_find_and_modify_opts_t mongoc_find_and_modify_opts_t;
typedef struct _mongoc_database_t mongoc_database_t;

void
mongoc_init (void);

void
mongoc_cleanup (void);

]]

--from mongoc-log.h
ffi.cdef[[

typedef enum
{
   MONGOC_LOG_LEVEL_ERROR,
   MONGOC_LOG_LEVEL_CRITICAL,
   MONGOC_LOG_LEVEL_WARNING,
   MONGOC_LOG_LEVEL_MESSAGE,
   MONGOC_LOG_LEVEL_INFO,
   MONGOC_LOG_LEVEL_DEBUG,
   MONGOC_LOG_LEVEL_TRACE,
} mongoc_log_level_t;

typedef void (*mongoc_log_func_t) (mongoc_log_level_t  log_level,
                                   const char         *log_domain,
                                   const char         *message,
                                   void               *user_data);

void mongoc_log_set_handler (mongoc_log_func_t  log_func,
                             void              *user_data);

void mongoc_log_default_handler (mongoc_log_level_t  log_level,
                                 const char         *log_domain,
                                 const char         *message,
                                 void               *user_data);

]]

--from mongoc-read-prefs.h
ffi.cdef[[

typedef enum
{
   MONGOC_READ_PRIMARY             = (1 << 0),
   MONGOC_READ_SECONDARY           = (1 << 1),
   MONGOC_READ_PRIMARY_PREFERRED   = (1 << 2) | MONGOC_READ_PRIMARY,
   MONGOC_READ_SECONDARY_PREFERRED = (1 << 2) | MONGOC_READ_SECONDARY,
   MONGOC_READ_NEAREST             = (1 << 3) | MONGOC_READ_SECONDARY,
} mongoc_read_mode_t;


typedef struct _mongoc_read_prefs_t mongoc_read_prefs_t;


]]

--from mongo-flags.h
ffi.cdef[[

typedef enum
{
   MONGOC_QUERY_NONE              = 0,
   MONGOC_QUERY_TAILABLE_CURSOR   = 1 << 1,
   MONGOC_QUERY_SLAVE_OK          = 1 << 2,
   MONGOC_QUERY_OPLOG_REPLAY      = 1 << 3,
   MONGOC_QUERY_NO_CURSOR_TIMEOUT = 1 << 4,
   MONGOC_QUERY_AWAIT_DATA        = 1 << 5,
   MONGOC_QUERY_EXHAUST           = 1 << 6,
   MONGOC_QUERY_PARTIAL           = 1 << 7,
} mongoc_query_flags_t;

typedef enum
{
   MONGOC_INSERT_NONE              = 0,
   MONGOC_INSERT_CONTINUE_ON_ERROR = 1 << 0,
} mongoc_insert_flags_t;

]]

--from mongoc-cursor.h
ffi.cdef[[
typedef struct _mongoc_cursor_t mongoc_cursor_t;

void             mongoc_cursor_destroy               (mongoc_cursor_t       *cursor);
bool             mongoc_cursor_more                  (mongoc_cursor_t       *cursor);
bool             mongoc_cursor_next                  (mongoc_cursor_t       *cursor,
                                                      const bson_t         **bson);
bool             mongoc_cursor_error                 (mongoc_cursor_t       *cursor,
                                                      bson_error_t          *error);

]]

--from mongoc-collection.h
ffi.cdef[[

typedef struct _mongoc_collection_t mongoc_collection_t;

void                          mongoc_collection_destroy              (mongoc_collection_t           *collection);
mongoc_cursor_t              *mongoc_collection_command              (mongoc_collection_t           *collection,
                                                                      mongoc_query_flags_t           flags,
                                                                      uint32_t                       skip,
                                                                      uint32_t                       limit,
                                                                      uint32_t                       batch_size,
                                                                      const bson_t                  *command,
                                                                      const bson_t                  *fields,
                                                                      const mongoc_read_prefs_t     *read_prefs) /*BSON_GNUC_WARN_UNUSED_RESULT*/;
bool                          mongoc_collection_command_simple       (mongoc_collection_t           *collection,
                                                                      const bson_t                  *command,
                                                                      const mongoc_read_prefs_t     *read_prefs,
                                                                      bson_t                        *reply,
                                                                      bson_error_t                  *error);
int64_t                       mongoc_collection_count                (mongoc_collection_t           *collection,
                                                                      mongoc_query_flags_t           flags,
                                                                      const bson_t                  *query,
                                                                      int64_t                        skip,
                                                                      int64_t                        limit,
                                                                      const mongoc_read_prefs_t     *read_prefs,
                                                                      bson_error_t                  *error);
int64_t                       mongoc_collection_count_with_opts      (mongoc_collection_t           *collection,
                                                                      mongoc_query_flags_t           flags,
                                                                      const bson_t                  *query,
                                                                      int64_t                        skip,
                                                                      int64_t                        limit,
                                                                      const bson_t                  *opts,
                                                                      const mongoc_read_prefs_t     *read_prefs,
                                                                      bson_error_t                  *error);
bool                          mongoc_collection_drop                 (mongoc_collection_t           *collection,
                                                                      bson_error_t                  *error);
bool                          mongoc_collection_drop_index           (mongoc_collection_t           *collection,
                                                                      const char                    *index_name,
                                                                      bson_error_t                  *error);
bool                          mongoc_collection_create_index         (mongoc_collection_t           *collection,
                                                                      const bson_t                  *keys,
                                                                      const mongoc_index_opt_t      *opt,
                                                                      bson_error_t                  *error);

mongoc_cursor_t              *mongoc_collection_find_indexes         (mongoc_collection_t           *collection,
                                                                      bson_error_t                  *error);
mongoc_cursor_t              *mongoc_collection_find                 (mongoc_collection_t           *collection,
                                                                      mongoc_query_flags_t           flags,
                                                                      uint32_t                       skip,
                                                                      uint32_t                       limit,
                                                                      uint32_t                       batch_size,
                                                                      const bson_t                  *query,
                                                                      const bson_t                  *fields,
                                                                      const mongoc_read_prefs_t     *read_prefs) /*BSON_GNUC_WARN_UNUSED_RESULT*/;
bool                          mongoc_collection_insert               (mongoc_collection_t           *collection,
                                                                      mongoc_insert_flags_t          flags,
                                                                      const bson_t                  *document,
                                                                      const mongoc_write_concern_t  *write_concern,
                                                                      bson_error_t                  *error);
bool                          mongoc_collection_update               (mongoc_collection_t           *collection,
                                                                      mongoc_update_flags_t          flags,
                                                                      const bson_t                  *selector,
                                                                      const bson_t                  *update,
                                                                      const mongoc_write_concern_t  *write_concern,
                                                                      bson_error_t                  *error);
bool                          mongoc_collection_save                 (mongoc_collection_t           *collection,
                                                                      const bson_t                  *document,
                                                                      const mongoc_write_concern_t  *write_concern,
                                                                      bson_error_t                  *error);
bool                          mongoc_collection_remove               (mongoc_collection_t           *collection,
                                                                      mongoc_remove_flags_t          flags,
                                                                      const bson_t                  *selector,
                                                                      const mongoc_write_concern_t  *write_concern,
                                                                      bson_error_t                  *error);
bool                          mongoc_collection_rename               (mongoc_collection_t           *collection,
                                                                      const char                    *new_db,
                                                                      const char                    *new_name,
                                                                      bool                           drop_target_before_rename,
                                                                      bson_error_t                  *error);
bool                          mongoc_collection_find_and_modify_with_opts (mongoc_collection_t                 *collection,
                                                                           const bson_t                        *query,
                                                                           const mongoc_find_and_modify_opts_t *opts,
                                                                           bson_t                              *reply,
                                                                           bson_error_t                        *error);
bool                          mongoc_collection_find_and_modify      (mongoc_collection_t           *collection,
                                                                      const bson_t                  *query,
                                                                      const bson_t                  *sort,
                                                                      const bson_t                  *update,
                                                                      const bson_t                  *fields,
                                                                      bool                           _remove,
                                                                      bool                           upsert,
                                                                      bool                           _new,
                                                                      bson_t                        *reply,
                                                                      bson_error_t                  *error);
]]

--from mongoc-database.h
ffi.cdef[[
void                          mongoc_database_destroy              (mongoc_database_t            *database);

mongoc_cursor_t              *mongoc_database_command              (mongoc_database_t            *database,
                                                                    mongoc_query_flags_t          flags,
                                                                    uint32_t                      skip,
                                                                    uint32_t                      limit,
                                                                    uint32_t                      batch_size,
                                                                    const bson_t                 *command,
                                                                    const bson_t                 *fields,
                                                                    const mongoc_read_prefs_t    *read_prefs);

bool                          mongoc_database_command_simple       (mongoc_database_t            *database,
                                                                    const bson_t                 *command,
                                                                    const mongoc_read_prefs_t    *read_prefs,
                                                                    bson_t                       *reply,
                                                                    bson_error_t                 *error);

mongoc_cursor_t              *mongoc_database_find_collections     (mongoc_database_t            *database,
                                                                    const bson_t                 *filter,
                                                                    bson_error_t                 *error);

mongoc_collection_t          *mongoc_database_get_collection       (mongoc_database_t            *database,
                                                                    const char                   *name);
]]

--from mongo-client.h
ffi.cdef[[
typedef struct _mongoc_client_t mongoc_client_t;

mongoc_client_t               *mongoc_client_new                  (const char                   *uri_string);

mongoc_cursor_t               *mongoc_client_command              (mongoc_client_t              *client,
                                                                   const char                   *db_name,
                                                                   mongoc_query_flags_t          flags,
                                                                   uint32_t                      skip,
                                                                   uint32_t                      limit,
                                                                   uint32_t                      batch_size,
                                                                   const bson_t                 *query,
                                                                   const bson_t                 *fields,
                                                                   const mongoc_read_prefs_t    *read_prefs);

bool                           mongoc_client_command_simple       (mongoc_client_t              *client,
                                                                   const char                   *db_name,
                                                                   const bson_t                 *command,
                                                                   const mongoc_read_prefs_t    *read_prefs,
                                                                   bson_t                       *reply,
                                                                   bson_error_t                 *error);

void                           mongoc_client_destroy              (mongoc_client_t              *client);

mongoc_database_t             *mongoc_client_get_database         (mongoc_client_t              *client,
                                                                   const char                   *name);

mongoc_collection_t           *mongoc_client_get_collection       (mongoc_client_t              *client,
                                                                   const char                   *db,
                                                                   const char                   *collection);

mongoc_cursor_t               *mongoc_client_find_databases       (mongoc_client_t              *client,
                                                                   bson_error_t                 *error);


]]

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

    libmongoc.mongoc_collection_insert(coll, 0, row, nil, nil)
  end
end

--测试查找
local function test_mongo_find(coll )
  local query = ffi.gc(libbson.bson_new(), libbson.bson_destroy)
  local cursor = libmongoc.mongoc_collection_find(coll, 0, 0, 0, 0, query, nil, nil)

  local doc = ffi.new('const bson_t*[1]')--ffi.typeof("bson_t *[?]")
  while libmongoc.mongoc_cursor_next(cursor, doc) do
    local cstr = libbson.bson_as_json(doc[0], nil)
    print(ffi.string(cstr))
    libbson.bson_free(cstr)
  end

  local er = ffi.new('bson_error_t[1]')
  libmongoc.mongoc_cursor_destroy(cursor)
end

function test_mongo_c_driver( )
  --参考：http://api.mongodb.org/c/1.3.0/tutorial.html#find
  --日志处理函数
  local printLog = ffi.cast('mongoc_log_func_t', function ( log_level, log_domain, message, user_data )
    --print(log_level, ffi.string(log_domain), ffi.string(message))
  end)
  libmongoc.mongoc_log_set_handler(printLog,nil)

  local authuristr = "mongodb://user,=:pass@127.0.0.1/test?authMechanism=SCRAM-SHA-1"
  libmongoc.mongoc_init()
  local  client = libmongoc.mongoc_client_new(authuristr)
  if not client then
    error( 'failed to parse SCRAM uri\n')
  end

  local collection = libmongoc.mongoc_client_get_collection(client, 'test', 'test')
  --测试插入
--  test_mongo_insert(collection)
  test_mongo_find(collection)
  libmongoc.mongoc_collection_destroy(collection)

  libmongoc.mongoc_client_destroy(client)
  libmongoc.mongoc_cleanup()

  --日志函数记得回收
  printLog:free()
end

--test_mongo_c_driver()

return libmongoc
