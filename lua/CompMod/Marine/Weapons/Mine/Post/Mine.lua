if Server then
    function Mine:GetCanTakeDamage()
        return true
    end

    function Mine:GetDestroyOnKill()
        if not self.active and not self.armed then
            return true
        end
        return false
    end

    -- TODO: Figure out when death messages should be displayed
    --function Mine:GetSendDeathMessageOverride()
    --    if not self.active and not self.armed then
    --        return false
    --    end
    --    return true
    --end
end
