if Client then
    function Hive:OnUpdate(deltaTime)
        if self.isTeleporting ~= self.lastisTeleporting then
            if not self.isTeleporting and self.lastisTeleporting then
                self:DestroyInfestation()
            end
            self.lastisTeleporting = self.isTeleporting
        end
    end
end
