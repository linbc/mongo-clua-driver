local ffi = require 'ffi'
ffi.cdef[[
//声明一个C函数
int printf(const char *fmt, ...);
]]

--创建一个无符号整型,初始值10.2,你懂的精度必须损失 
--内存自动管理
local a = ffi.new('uint32_t',10.2)
print(tonumber(a), a, ffi.typeof(a))

--调用C函数打印一下
ffi.C.printf("%d,%s\n",a,'测试字符串')

local b = ffi.new('int64_t',10)
print(a == b and 'a == b ' or 'a ~= b', b)


------------------------------------
--测试ffi垃圾回收调用功能
--

local function gc_func (p)
    --这个肯定在最新，因为是在垃圾回收的时候执行
    print('gc_func', p[0])
    ffi.free(p)
end
--注意了，仅支持数组类型，如果是普通的cdata类型是不行的
local c = ffi.gc(ffi.new('int[?]',64), gc_func)


-----------------------------------
--如果判断一个lua_number到底是整型还是double呢？
function test_int_or_double( luaNumber )
    local a = ffi.new('int32_t',luaNumber)
    local b = ffi.new('double',luaNumber)
    print('test value:', luaNumber, 'type:', tonumber(a) == tonumber(b) and 'int32_t' or 'double')
end

test_int_or_double(1)
test_int_or_double(1.32)
