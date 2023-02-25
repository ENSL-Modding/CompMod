Alien.kOvershieldViewMaterialName = "cinematics/vfx_materials/overshield_view.material"
Alien.kOvershieldThirdPersonMaterialName = "cinematics/vfx_materials/overshield.material"
Shared.PrecacheSurfaceShader("cinematics/vfx_materials/overshield.surface_shader")
Shared.PrecacheSurfaceShader("cinematics/vfx_materials/overshield_view.surface_shader")

local kOvershieldEffectInterval = 1

local oldUpdateMucousEffects = Alien.UpdateMucousEffects
function Alien:UpdateMucousEffects(isLocal)
    oldUpdateMucousEffects(self, isLocal)

    -- Rather than override Alien:UpdateClientEffects, which is fairly large, we can hijack UpdateMucousEffects to also display our Vamp shield effects.
    self:UpdateShieldEffects(isLocal)
end

function Alien:UpdateShieldEffects(isLocal)
    if self.overShieldedClient ~= self.overShielded then
        if isLocal then
            local viewModel
            if self:GetViewModelEntity() then
                viewModel = self:GetViewModelEntity():GetRenderModel()
            end

            if viewModel then
                if self.overShielded then
                    self.overshieldViewMaterial = AddMaterial(viewModel, Alien.kOvershieldViewMaterialName)
                else
                    if RemoveMaterial(viewModel, self.overshieldViewMaterial) then
                        self.overshieldViewMaterial = nil
                    end
                end
            end
        end

        local thirdPersonModel = self:GetRenderModel()
        if thirdPersonModel then
            if self.overShielded then
                self.overshieldMaterial = AddMaterial(thirdPersonModel, Alien.kOvershieldThirdPersonMaterialName)
            else
                if RemoveMaterial(thirdPersonModel, self.overshieldMaterial) then
                    self.overshieldMaterial = nil
                end
            end
        end

        self.overShieldedClient = self.overShielded
    end

    -- update cinematics
    -- is this needed?
    if self.overShielded then
        if not self.lastOvershieldEffect or self.lastOvershieldEffect + kOvershieldEffectInterval < Shared.GetTime() then
            self.lastOvershieldEffect = Shared.GetTime()
        end
    end
end
