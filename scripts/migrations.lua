-- Yes, this is basically a recreation of the vanilla mechanics. Meh

local handler = { }

local statistics = require("scripts.statistics")

local migrations = {
    ["0.1.0"] = function()
        -- When this mod is added to an existing save then existing
        -- players need to be added to the tables
        for _, player in pairs(game.players) do
            statistics.setup_player(player)
        end
    end,
    ["0.2.8"] = function()
        -- We're changing to only store if victory has been reached. Not by who
        if storage.finished and type(storage.finished) == "table" then
            storage.finished = next(storage.finished) ~= nil
        end
    end,
    ["0.2.12"] = function()
        for _, player in pairs(game.players) do
            local player_data = storage.statistics.players[player.index]
            if player_data.distance_walked > 10000 * 1000 then
                -- Resetting because this is likely bad data. Or at least should
                -- be in 99% percent of cases.
                player_data.distance_walked = 0
                -- We could let the player know, but this might just confuse the player.
                -- Let's do it silently, muhuhahaha
            end
        end
    end,
    ["0.2.13"] = function()
        for _, player in pairs(game.players) do
            local player_data = storage.statistics.players[player.index]
            player_data.distance_jetpacked = 0
        end
    end,
    ["0.3.0"] = function()
        for _, player in pairs(game.players) do
            local player_data = storage.statistics.players[player.index]
            player_data.times_on_surfaces = { }
        end
    end,
}

local function handle_migrations(event)
    -- A list of all migrations ran
    ---@type table<string, boolean>
    storage.migrations = storage.migrations or { }

    for migration_name, migration in pairs(migrations) do
        if not storage.migrations[migration_name] then
            log("Running migration: '"..migration_name.."'")
            migration()
            storage.migrations[migration_name] = true
        end
    end
end

handler.on_init = handle_migrations
handler.on_configuration_changed = handle_migrations

return handler