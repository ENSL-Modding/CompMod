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