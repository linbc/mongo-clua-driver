local ffi = require("ffi")
local libbson = ffi.load(ffi.os == "OSX" and "libbson-1.0.dylib" or "libbson-1.0.so")

--from bson-memory.h
ffi.cdef[[

void  bson_free           (void   *mem);

]]

--from bson-types.h
ffi.cdef[[

typedef enum
{
   BSON_TYPE_EOD = 0x00,
   BSON_TYPE_DOUBLE = 0x01,
   BSON_TYPE_UTF8 = 0x02,
   BSON_TYPE_DOCUMENT = 0x03,
   BSON_TYPE_ARRAY = 0x04,
   BSON_TYPE_BINARY = 0x05,
   BSON_TYPE_UNDEFINED = 0x06,
   BSON_TYPE_OID = 0x07,
   BSON_TYPE_BOOL = 0x08,
   BSON_TYPE_DATE_TIME = 0x09,
   BSON_TYPE_NULL = 0x0A,
   BSON_TYPE_REGEX = 0x0B,
   BSON_TYPE_DBPOINTER = 0x0C,
   BSON_TYPE_CODE = 0x0D,
   BSON_TYPE_SYMBOL = 0x0E,
   BSON_TYPE_CODEWSCOPE = 0x0F,
   BSON_TYPE_INT32 = 0x10,
   BSON_TYPE_TIMESTAMP = 0x11,
   BSON_TYPE_INT64 = 0x12,
   BSON_TYPE_MAXKEY = 0x7F,
   BSON_TYPE_MINKEY = 0xFF,
} bson_type_t;

typedef struct _bson_oid_t bson_oid_t;
typedef struct _bson_error_t
{
   uint32_t domain;
   uint32_t code;
   char     message[504];
} bson_error_t;
typedef struct _bson_t bson_t;
typedef struct {char __[128];} bson_iter_t;
typedef long long time_t;

]]

--from bson-iter.h
ffi.cdef[[

bool
bson_iter_init (bson_iter_t  *iter,
                const bson_t *bson);

bool
bson_iter_init_find (bson_iter_t  *iter,
                     const bson_t *bson,
                     const char   *key);

bool
bson_iter_next (bson_iter_t *iter);

const bson_oid_t *
bson_iter_oid (const bson_iter_t *iter);

int32_t
bson_iter_int32 (const bson_iter_t *iter);

int64_t
bson_iter_int64 (const bson_iter_t *iter);

double
bson_iter_double (const bson_iter_t *iter);

const char *
bson_iter_key (const bson_iter_t *iter);

const char *
bson_iter_utf8 (const bson_iter_t *iter,
                uint32_t          *length);

bool
bson_iter_bool (const bson_iter_t *iter);

bson_type_t
bson_iter_type (const bson_iter_t *iter);

]]

--from bson.h
ffi.cdef[[

bson_t *
bson_new (void);

void
bson_reinit (bson_t *b);

void
bson_destroy (bson_t *bson);

void
bson_copy_to (const bson_t *src,
              bson_t       *dst);

char *
bson_as_json (const bson_t *bson,
              size_t       *length);

bool
bson_init_from_json (bson_t        *bson,
                     const char    *data,
                     //ssize_t        len,
                     long 			len,
                     bson_error_t  *error);

bool
bson_append_double (bson_t     *bson,
                    const char *key,
                    int         key_length,
                    double      value);

bool
bson_append_int64 (bson_t      *bson,
                   const char  *key,
                   int          key_length,
                   int64_t value);

bool
bson_append_null (bson_t     *bson,
                  const char *key,
                  int         key_length);

bool
bson_append_int32 (bson_t      *bson,
                   const char  *key,
                   int          key_length,
                   int32_t value);

bool
bson_append_oid (bson_t           *bson,
                 const char       *key,
                 int               key_length,
                 const bson_oid_t *oid);  

bool
bson_append_utf8 (bson_t     *bson,
                  const char *key,
                  int         key_length,
                  const char *value,
                  int         length);

bool
bson_append_time_t (bson_t     *bson,
                    const char *key,
                    int         key_length,
                    time_t      value);                                                    
]]


local function test_libbson_cfunction( )
	--构造一个bson对象{a:1, b:-1, c:0.1, d:"linbc"}
	local doc = libbson.bson_new()

	--开始构造文档
	local key = 'k_int'
	libbson.bson_append_int32(doc, key, string.len(key), 1)
	key = 'k_int64'
	libbson.bson_append_int64(doc, key, string.len(key), -1)
	key = 'k_double'
	libbson.bson_append_double(doc, key, string.len(key), 0.1)
	key = 'k_utf8'
	libbson.bson_append_utf8(doc, key, string.len(key), 'linbc', 5)

	--开始从档里读数据了
	local iter = ffi.gc( ffi.new('bson_iter_t'), ffi.free)
	libbson.bson_iter_init (iter, doc)
	while libbson.bson_iter_next(iter) do
		local key = ffi.string( libbson.bson_iter_key(iter) )
		local t = libbson.bson_iter_type(iter)
		if t == libbson.BSON_TYPE_DOUBLE then
			print(key,	t, libbson.bson_iter_double(iter))
		elseif t == libbson.BSON_TYPE_UTF8 then
			local buflen = ffi.gc( ffi.new("uint32_t[1]", 1), ffi.free)
			local utf8 = libbson.bson_iter_utf8(iter, buflen)
			print(key,	t, ffi.string(utf8))
		elseif t == libbson.BSON_TYPE_INT32 then
			print(key,	t, libbson.bson_iter_int32(iter))
		elseif t == libbson.BSON_TYPE_INT64 then
			print(key,	t, libbson.bson_iter_int64(iter))
		else
			error('Does not support:',key,	t)
		end
	end

	libbson.bson_destroy(doc)
end

return libbson

