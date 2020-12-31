local oldLoginPlayer = CommandStructure.LoginPlayer
function CommandStructure:LoginPlayer(player, forced)
    if player:isa("Fade") then
        -- If we triggered metabolize using the movement modifier key, reset our active weapon and clear metab cooldown when logging into the hive.
        if player:GetHasMetabolizeAnimationDelay() and player.previousweapon ~= nil then
            if player:GetActiveWeapon():GetMapName() == Metabolize.kMapName then
                player:SetActiveWeapon(player.previousweapon)
            end
            player.previousweapon = nil

            -- Clear metabolize cooldown just in case :}
            player.timeMetabolize = Shared.GetTime() - 1
        end
    end

    return oldLoginPlayer(self, player, forced)
end