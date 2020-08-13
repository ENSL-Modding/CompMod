local oldGetCanAttachBabbler = BabblerClingMixin.GetCanAttachBabbler

function BabblerClingMixin:GetCanAttachBabbler()
    if self.isHallucination then
        return false
    end

    return oldGetCanAttachBabbler(self)
end
