if Server then
    function RegenerationMixin:AddRegeneration()
        --local max = self:GetMaxHealth() - self:GetHealth()

        --self.regenerationHealth = math.min(self.regenerationHealth + self.regenerationValue, max)

        self.regenerationHealth = self.regenerationHealth + self.regenerationValue

        self.regenerating = true
    end

    function RegenerationMixin:OnProcessMove(input)
        if not self.regenerating then return end

        local deltaTime = input.time

        local amount = deltaTime * self.regenerationValue

        self.regenerationHealth = math.max(self.regenerationHealth - amount, 0)

        --returns false if entity is allready fully healed
        self:Heal(amount)
        if self.regenerationHealth == 0 then-- or not self:Heal(amount) then
            self.regenerating = false
            self.regenerationHealth = 0
        end
    end
end