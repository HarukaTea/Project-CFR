local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Lync = require(ReplicatedStorage.Packages.Lync)

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
--- Unsigned 8-bit integer. (0 to 255, 1 byte)
enums.u8Lync = Lync.int(0, enums.n8)
--- Signed 8-bit integer. (-128 to 127, 1 byte)
enums.i8Lync = Lync.int(-2^7, 2^7 - 1)
--- Unsigned 16-bit integer. (0 to 65535, 2 bytes)
enums.u16Lync = Lync.int(0, enums.n16)
--- Signed 16-bit integer. (-32768 to 32767, 2 bytes)
enums.i16Lync = Lync.int(-2^15, 2^15 - 1)
--- Unsigned 32-bit integer. (0 to 4294967295, 4 bytes)
enums.u32Lync = Lync.int(0, enums.n32)
--- Signed 32-bit integer. (-2147483648 to 2147483647, 4 bytes)
enums.i32Lync = Lync.int(-2^31, 2^31 - 1)
--- IEEE 754 half-precision float. (±65504, 2 bytes, ~3 decimal digits)
enums.f16Lync = Lync.f16
--- IEEE 754 single-precision float. (±3.4e38, 4 bytes)
enums.f32Lync = Lync.f32
--- IEEE 754 double-precision float. (±1.8e308, 8 bytes)
enums.f64Lync = Lync.f64

return table.freeze(enums)