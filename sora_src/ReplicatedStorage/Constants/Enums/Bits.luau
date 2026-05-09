local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LyncTyping = require(ReplicatedStorage.Constants.Typing.Lync)
local Lync = require(ReplicatedStorage.Packages.Lync) :: LyncTyping.LyncLib

local function bits(n: number): number
    return 2^n - 1
end

local enums = {}

--- 8-bits
enums.n8 = bits(8)
--- 16-bits
enums.n16 = bits(16)
--- 32-bits
enums.n32 = bits(32)
--- 64-bits
enums.n64 = bits(64)
--- Unsigned 32-bit integer.
enums.ui32Lync = Lync.float(0, enums.n32, 1)
--- Signed 32-bit integer.
enums.i32Lync = Lync.int(-(2^31), 2^31 - 1)
--- Unsigned 64-bit float.
enums.uf64Lync = Lync.float(0, enums.n64, 1)
--- Signed 64-bit float (includes -f64 as min).
enums.f64Lync = Lync.float(-enums.n64, enums.n64, 1)

return table.freeze(enums)