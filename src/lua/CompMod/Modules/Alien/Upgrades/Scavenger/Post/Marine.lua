local oldOnInitialized = Marine.OnInitialized
function Marine:OnInitialized()
    oldOnInitialized(self)

    if Server then
        self.damageHistory = {}
    end
end
