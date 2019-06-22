function SpawnPlayerAtPoint(player, origin, angles)

    player:SetOrigin(origin)

    if angles then
        -- For some reason only the "pitch" adjusts the in game angle,
        -- so take the yaw (the rotation of the entity) and convert it
        -- to "roll". Also SetViewAngles does not work here.

        --From McG: no clue what above note is about. SetViewAngles works without issue
        --Best guess, at some point this it was broken due to another issue, so this was
        --never actually broken.

        -- simba says this might work :@@
        player:SetBaseViewAngles(Angles(0,0,0))

        player:SetViewAngles(angles)
    end

end
