local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Attributes = ReplicatedStorage.Constants.Attributes

local places = require(Attributes.Places)

return {
    legacy = {
        [places.mainPlace] = "_CF_RLEASE_DATA",
        [places.testPlace] = "_CF_TEST_DATA",
    },
    modern = {
        [places.mainPlace] = "CF_Player",
        [places.testPlace] = "CF_Tester",
        [places.devPlace] = "CF_Dev",
    },
}