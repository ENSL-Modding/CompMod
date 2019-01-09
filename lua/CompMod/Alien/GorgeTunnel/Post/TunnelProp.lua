local kPropModels =
{
    [kTunnelPropType.Ceiling] = {
        PrecacheAsset("models/alien/tunnel/tunnel_attch_topTent.model"),
        -- PrecacheAsset("models/alien/tunnel/tunnel_attch_growth.model"),
        -- PrecacheAsset("models/alien/tunnel/tunnel_attch_botTents.model"),
        -- PrecacheAsset("models/alien/tunnel/tunnel_attch_polyps.model"),
    },
    
    [kTunnelPropType.Floor] = {
        PrecacheAsset("models/alien/tunnel/tunnel_attch_botTents.model"),
        PrecacheAsset("models/alien/tunnel/tunnel_attch_growth.model"),
        -- PrecacheAsset("models/alien/tunnel/tunnel_attch_topTent.model"),
        PrecacheAsset("models/alien/tunnel/tunnel_attch_polyps.model"),
        PrecacheAsset("models/alien/tunnel/tunnel_attch_bulb.model"),
    }
}

local kPropAnimGraphs = {}
kPropAnimGraphs["models/alien/tunnel/tunnel_attch_topTent.model"] = PrecacheAsset("models/alien/tunnel/tunnel_attch_topTent.animation_graph")
kPropAnimGraphs["models/alien/tunnel/tunnel_attch_botTents.model"] = PrecacheAsset("models/alien/tunnel/tunnel_attch_botTents.animation_graph")
kPropAnimGraphs["models/alien/tunnel/tunnel_attch_bulb.model"] = PrecacheAsset("models/alien/tunnel/tunnel_attch_bulb.animation_graph")
kPropAnimGraphs["models/alien/tunnel/tunnel_attch_growth.model"] = PrecacheAsset("models/alien/tunnel/tunnel_attch_growth.animation_graph")
kPropAnimGraphs["models/alien/tunnel/tunnel_attch_polyps.model"] = PrecacheAsset("models/alien/tunnel/tunnel_attch_polyps.animation_graph")


local function GetRandomPropModel(propType)

    local propModels = kPropModels[propType]
    local numModels = #propModels
    local randomIndex = math.random(1, numModels)
    
    return propModels[randomIndex]

end

function TunnelProp:SetTunnelPropType(propType, attachPointNum)

    if Server then

        local randomModel = GetRandomPropModel(propType)
        self:SetModel(randomModel, kPropAnimGraphs[randomModel])
        
        self.attachPointNum = attachPointNum
        
    end

end