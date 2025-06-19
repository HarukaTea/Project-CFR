--!nocheck

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local SSS = game:GetService("ServerScriptService")
local RepS = game:GetService("ReplicatedStorage")

local FormulaBook = require(RepS.HarukaShared.Library.FormulaBook)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local Events = require(SSS.HarukaServer.Library.ServerEvents)
local ItemLib = require(RepS.HarukaShared.Library.ItemLib)
local ServerLib = require(SSS.HarukaServer.Library.ServerLib)

local EntityBook = require(RepS.HarukaShared.Library.EntityBook)
local CharTemplate = require(SSS.HarukaServer.Library.CharTemplate)


local testerRank = if game.PlaceId == 88043509623826 or game.PlaceId == 17737750873 or game.PlaceId == 78011578174285 then 2 else 127

local wait = task.wait


export type CallbackProps = {
    Executor: Player,
    Args: { any },

    ResolveObj: () -> nil
}


local commands = {
    {
        Name = "GiveNoclip",
        Alias = "/give_noclip",

        RankReq = testerRank,
        Args = {
            {
                Name = "player_id",
                Type = "players"
            }
        },

        Callback = function(props: CallbackProps)
            for _, thatPlr: Player in props.Args[1] do
                if not thatPlr then continue end
                if not ServerLib:IsCharValid(thatPlr.Character) then continue end

                local noclip = RepS.Packages.Unloads.Noclip:Clone() :: Tool
                noclip.Parent = thatPlr.Backpack
            end


            props.ResolveObj()
        end
    },

    {
        Name = "KillPlayer",
        Alias = "/kill",

        RankReq = testerRank,
        Args = {
            {
                Name = "player_id",
                Type = "players"
            }
        },

        Callback = function(props: CallbackProps)
            for _, thatPlr: Player in props.Args[1] do
                if not thatPlr then continue end
                if not ServerLib:IsCharValid(thatPlr.Character) then continue end

                thatPlr.Character.Humanoid.Health = -1
            end

            props.ResolveObj()
        end
    },
    {
        Name = "TeleportPlayer",
        Alias = "/teleport",

        RankReq = testerRank,
        Args = {
            {
                Name = "from/player_id",
                Type = "players"
            },
            {
                Name = "to/player_id",
                Type = "player"
            }
        },

        Callback = function(props: CallbackProps)
            local destinationPlayer = Players:FindFirstChild(props.Args[2].Name)
            if not destinationPlayer then
                props.ResolveObj()
                return
            end

            for _, thatPlr: Player in props.Args[1] do
                if thatPlr == destinationPlayer then continue end


                local thatChar = thatPlr.Character
                if not ServerLib:IsCharValid(thatChar) then continue end
                if not ServerLib:IsCharValid(destinationPlayer.Character) then break end

                thatChar:PivotTo(destinationPlayer.Character.PrimaryPart.CFrame)
            end

            props.ResolveObj()
        end
    },


    {
        Name = "ChargeUlt",
        Alias = "/charge_full_ult",

        RankReq = testerRank,
        Args = {
            {
                Name = "player_id",
                Type = "players"
            }
        },

        Callback = function(props: CallbackProps)
            for _, thatPlr: Player in props.Args[1] do
                if not thatPlr then continue end
                if not ServerLib:IsCharValid(thatPlr.Character) then continue end

                thatPlr.Character:SetAttribute("ClassUltProgress", thatPlr.Character:GetAttribute("MaxClassUltProgress"))
            end

            props.ResolveObj()
        end
    },

    {
        Name = "SetBaseStat",
        Alias = "/set_base_stat",

        RankReq = testerRank,
        Args = {
            {
                Name = "player_id",
                Type = "players"
            },
            {
                Name = "stat_id",
                Type = "enum",
                EnumItems = HarukaLib.TableUtils.Keys(
                    HarukaLib.TableUtils.Filter(CharTemplate, function(val, key, tbl)
                        return string.find(key, "Base")
                    end)
                )
            },
            {
                Name = "stat_val",
                Type = "number",

                ShouldBeInteger = true,
                RangeMin = 1,
                RangeMax = 9999
            }
        },

        Callback = function(props: CallbackProps)
            for _, thatPlr: Player in props.Args[1] do
                if not thatPlr then continue end
                if not ServerLib:IsCharValid(thatPlr.Character) then continue end

                thatPlr.Character:SetAttribute(props.Args[2], props.Args[3])
            end

            props.ResolveObj()
        end
    },

    {
        Name = "GiveItem",
        Alias = "/give_item",

        RankReq = testerRank,
        Args = {
            {
                Name = "player_id",
                Type = "players"
            },
            {
                Name = "item_id",
                Type = "enum",
                EnumItems = HarukaLib.TableUtils.Merge(ItemLib:GetAllItems(), { "all" })
            },
            {
                Name = "item_amount",
                Type = "number",

                ShouldBeInteger = true,
                RangeMin = 1,
                RangeMax = 999
            }
        },

        Callback = function(props: CallbackProps)
            for _, thatPlr: Player in props.Args[1] do
                if not thatPlr then continue end

                local item = props.Args[2]
                if item == "all" then
                    local allItems = ItemLib:GetAllItems()
                    if table.find(allItems, "Dawnbreak") then
                        table.remove(allItems, table.find(allItems, "Dawnbreak"))
                    end

                    for _, itemId: string in allItems do
                        ServerLib:GiveItemDrop(thatPlr, itemId, props.Args[3])
                    end
                else
                    ServerLib:GiveItemDrop(thatPlr, item, props.Args[3])
                end
            end

            props.ResolveObj()
        end
    },

    {
        Name = "SetLevel",
        Alias = "/set_level",

        RankReq = testerRank,
        Args = {
            {
                Name = "player_id",
                Type = "players"
            },
            {
                Name = "level",
                Type = "number",

                ShouldBeInteger = true,
                RangeMin = 1,
                RangeMax = FormulaBook.PLAYER_MAX_LEVEL
            }
        },

        Callback = function(props: CallbackProps)
            for _, thatPlr: Player in props.Args[1] do
                if not thatPlr then continue end

                thatPlr:SetAttribute("PerkPoints", FormulaBook.PLAYER_POINT_PER_LEVEL * props.Args[2])
                thatPlr:SetAttribute("STRPoints", 0)
                thatPlr:SetAttribute("DEXPoints", 0)
                thatPlr:SetAttribute("INTPoints", 0)
                thatPlr:SetAttribute("VITPoints", 0)
                thatPlr:SetAttribute("Level", props.Args[2])
            end

            props.ResolveObj()
        end
    },

    {
        Name = "BanPlayerInGame",
        Alias = "/ban_player_ingame",

        RankReq = 127,
        Args = {
            {
                Name = "player_id",
                Type = "player"
            },
            {
                Name = "duration/hour",
                Type = "number",

                ShouldBeInteger = true,
                RangeMin = 1,
                RangeMax = 24 * 365 * 10
            }
        },

        Callback = function(props: CallbackProps)
            HarukaLib:BanPlayerByUserId(props.Args[1].UserId, {
                Duration = props.Args[2] * 60 * 60,
                DisplayReason = "Banned by Shroomhaven Temple",
                PrivateReason = "Banned by Shroomhaven Panel",
                ExcludeAltAccounts = false
            })
            Events.CreateNotify.Fire(props.Executor, "[Haven] Banned successfully!")

            props.ResolveObj()
        end
    },
    {
        Name = "BanPlayerGlobal",
        Alias = "/ban_player_global",

        RankReq = 127,
        Args = {
            {
                Name = "player_userid",
                Type = "string"
            },
            {
                Name = "duration/hour",
                Type = "number",

                ShouldBeInteger = true,
                RangeMin = 1,
                RangeMax = 24 * 365 * 10
            }
        },

        Callback = function(props: CallbackProps)
            local thatPlayer = Players:GetNameFromUserIdAsync(tonumber(props.Args[1]))

            Events.CreateNotify.Fire(props.Executor, "Querying player in roblox...")

            RunService.Heartbeat:Wait()
            if not thatPlayer then
                Events.CreateNotify.Fire(props.Executor, "[Error] Invalid Player Object")

                props.ResolveObj()
                return
            end

            HarukaLib:BanPlayerByUserId(tonumber(props.Args[1]), {
                Duration = props.Args[2] * 60 * 60,
                DisplayReason = "Banned by Shroomhaven Temple",
                PrivateReason = "Banned by Shroomhaven Panel",
                ExcludeAltAccounts = false
            })
            Events.CreateNotify.Fire(props.Executor, "[Haven] Banned successfully!")

            props.ResolveObj()
        end
    },
    {
        Name = "LockData",
        Alias = "/dont_save_data",

        RankReq = 127,
        Args = {
            {
                Name = "player_userid",
                Type = "player"
            },
        },

        Callback = function(props: CallbackProps)
            props.Args[1]:SetAttribute("Haruka_DataLocked", true)

            Events.CreateNotify.Fire(props.Executor, "[Haven] Data Locked!")

            props.ResolveObj()
        end
    },

    {
        Name = "ClearQuests",
        Alias = "/clear_quests",

        RankReq = testerRank,
        Args = {
            {
                Name = "player_id",
                Type = "players"
            },
        },

        Callback = function(props: CallbackProps)
            for _, thatPlr: Player in props.Args[1] do
                if not thatPlr then continue end

                thatPlr.Quests:ClearAllChildren()
            end

            props.ResolveObj()
        end
    },

    {
        Name = "UnbanPlayerGlobal",
        Alias = "/unban_player_global",

        RankReq = 127,
        Args = {
            {
                Name = "player_userid",
                Type = "string"
            }
        },

        Callback = function(props: CallbackProps)
            local thatPlayer = Players:GetNameFromUserIdAsync(tonumber(props.Args[1]))

            Events.CreateNotify.Fire(props.Executor, "Querying player in roblox...")

            RunService.Heartbeat:Wait()
            if not thatPlayer then
                Events.CreateNotify.Fire(props.Executor, "[Error] Invalid Player Object")

                props.ResolveObj()
                return
            end

            HarukaLib:UnbanPlayerByUserId(tonumber(props.Args[1]))
            Events.CreateNotify.Fire(props.Executor, "[Haven] Unbanned successfully!")

            props.ResolveObj()
        end
    },

    {
        Name = "SpawnMob",
        Alias = "/spawn_mob",

        RankReq = testerRank,
        Args = {
            {
                Name = "entity_id",
                Type = "enum",
                EnumItems = HarukaLib.TableUtils.Keys(EntityBook)
            },
            {
                Name = "level",
                Type = "number",

                ShouldBeInteger = true,
                RangeMin = 1,
                RangeMax = FormulaBook.ENEMY_MAX_LEVEL
            }
        },

        Callback = function(props: CallbackProps)
            local char = props.Executor.Character
            if not ServerLib:IsCharValid(char) then
                props.ResolveObj()
                return
            end

            local pos = ServerLib:FindGroundByRay(char.PrimaryPart.Position)

            Events.CreateNotify.Fire(props.Executor, "Spawning Entity...")

            wait(2)
            local locator = HarukaLib:CreateMockPart()
            locator.Name = props.Args[1]

            locator.Size = Vector3.new(5, 2, 5)
            locator.CFrame = CFrame.new(pos)

            locator:AddTag("EnemyLocatorEntity")
            locator:SetAttribute("NoRespawn", true)
            locator:SetAttribute("NoRandomName", true)
            locator:SetAttribute("Level", props.Args[2])

            locator.Parent = workspace.Enemies

            props.ResolveObj()
        end
    },
}


return commands