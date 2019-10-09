Shotgun.kSpreadVectors = {}
do
    local kShotgunRings =
    {
        { distance = 0.0, pelletCount = 1, pelletSize = 0.016, pelletDamage = 10 },
        { distance = 0.45, pelletCount = 8, pelletSize = 0.016, pelletDamage = 10 },
        { distance = 1.2, pelletCount = 8, pelletSize = 0.016, pelletDamage = 10 },
    }

    local function CalculateShotgunSpreadVectors()
        local circle = math.pi * 2.0

        for _, ring in ipairs(kShotgunRings) do

            local radiansPer = circle / ring.pelletCount
            for pellet = 1, ring.pelletCount do

                local theta = radiansPer * (pellet - 1)
                local x = math.cos(theta) * ring.distance
                local y = math.sin(theta) * ring.distance
                table.insert(Shotgun.kSpreadVectors, { vector = GetNormalizedVector(Vector(x, y, kShotgunSpreadDistance)), size = ring.pelletSize, damage = ring.pelletDamage})

            end

        end
    end

    CalculateShotgunSpreadVectors()
end
