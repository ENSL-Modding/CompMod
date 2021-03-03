if Client then
    local blipRotation = Vector(0,0,0)
    function MapBlip:UpdateMinimapItemHook(minimap, item)
        PROFILE("MapBlip:UpdateMinimapItemHook")

        local rotation = self:GetRotation()
        if rotation ~= item.prevRotation then
            item.prevRotation = rotation
            blipRotation.z = rotation
            item:SetRotation(blipRotation)
        end

        local blipTeam = self:GetMapBlipTeam(minimap)
        local blipColor = item.blipColor
        
        -- if self.OnSameMinimapBlipTeam(minimap.playerTeam, blipTeam) or minimap.spectating then
            self:UpdateHook(minimap, item)
            
            if self.isHallucination then
                blipColor = kHallucinationColor
            elseif self.isInCombat then
                if self.MinimapBlipTeamIsActive(blipTeam) then

                    if self.highlighted then
                        local percentage = (math.cos(Shared.GetTime() * 10) + 1) * 0.5
                        blipColor = LerpColor(kRed, MapBlip.kHighlightSameBuildingsColor, percentage)
                    else
                        blipColor = self.PulseRed(1.0)
                    end

                else
                    blipColor = self.PulseDarkRed(blipColor)
                end
            end  
        -- end
        self.currentMapBlipColor = blipColor

    end
end

class 'TunnelMapBlip' (MapBlip)

TunnelMapBlip.kMapName = "TunnelMapBlip"

if Client then
    -- If left to default then labels are delayed when opening the minimap
    function TunnelMapBlip:UpdateMinimapActivity()
        return kMinimapActivity.High
    end

    -- Show a label for tunnels on the minimap
    function TunnelMapBlip:UpdateHook(minimap, item)
        local owner = self.ownerEntityId and Shared.GetEntity(self.ownerEntityId)
        if owner then
            minimap:DrawMinimapNameTunnel(item, self:GetMapBlipTeam(minimap), owner)
        end
    end
end
Shared.LinkClassToMap("TunnelMapBlip", TunnelMapBlip.kMapName, {})
