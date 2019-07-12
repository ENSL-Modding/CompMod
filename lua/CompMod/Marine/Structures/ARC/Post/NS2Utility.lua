-- prioritise engagement point over model origin rather than the other way around
function GetTargetOrigin(target)

    if target.GetEngagementPoint then
        return target:GetEngagementPoint()
    end

    if target.GetModelOrigin then
        return target:GetModelOrigin()
    end

    return target:GetOrigin()

end
