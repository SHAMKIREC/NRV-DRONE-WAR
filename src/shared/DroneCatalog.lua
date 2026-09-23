-- Shared, game-only drone statistics. Add new models here.
local Catalog = {
 Scout = {displayName = "Scout", price = 0, maxLevel = 5, speed = 45, handling = 75, endurance = 60},
 Ranger = {displayName = "Ranger", price = 2500, maxLevel = 5, speed = 60, handling = 60, endurance = 75},
 Titan = {displayName = "Titan", price = 6500, maxLevel = 5, speed = 35, handling = 45, endurance = 95},
}
return table.freeze(Catalog)
