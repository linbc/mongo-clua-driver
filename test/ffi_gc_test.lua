--package.path = package.path..';../*.lua'

local ffi_gc = require 'ffi_gc'
local a = ffi_gc.new()
print(collectgarbage("collect"))
print(collectgarbage("count"))
a = nil
print(collectgarbage("count"))
print(collectgarbage("collect"))
print(collectgarbage("count"))