function TargetSelector:SetRange(range)
    if range ~= self.range then
        self.range = range
        self:AttackerMoved()
    end
end
