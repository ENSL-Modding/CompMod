if Server then
    function Mine:GetCanTakeDamage()
        return true
    end

    function Mine:OnKill(attacker, doer, point, direction)
        self:Arm()

        ScriptActor.OnKill(self, attacker, doer, point, direction)
        if not self.active and not self.armed then
            DestroyEntity(self)
        end
    end
end
