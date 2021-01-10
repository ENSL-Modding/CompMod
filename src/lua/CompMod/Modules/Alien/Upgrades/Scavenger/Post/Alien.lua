local oldOnInit = Alien.OnInitialized
function Alien:OnInitialized()
    oldOnInit(self)

    if Server then
        self.scavengerHealData = {}
        self.scavengerNextHealTime = 0
    end
end