-- Pre-defined physics group masks.
PhysicsMask = enum
{
    -- Don't collide with anything
    None = 0,

    DefaultOnly = CreateMaskIncludingGroups(PhysicsGroup.DefaultGroup),

    -- Don't filter out anything
    All = 0xFFFFFFFF,

    -- Filters anything that should not be collided with for player movement.
    Movement = CreateMaskExcludingGroups(PhysicsGroup.SmallStructuresGroup,
            PhysicsGroup.RagdollGroup,
            PhysicsGroup.PlayerGroup,
            PhysicsGroup.BabblerGroup,
            PhysicsGroup.ProjectileGroup,
            PhysicsGroup.WeaponGroup,
            PhysicsGroup.DroppedWeaponGroup,
            PhysicsGroup.CommanderBuildGroup,
            PhysicsGroup.PathingGroup,
            PhysicsGroup.WebsGroup),

    -- Filters anything that should not collide with onos movement.
    OnosMovement = CreateMaskExcludingGroups(PhysicsGroup.WhipGroup,
            PhysicsGroup.SmallStructuresGroup,
            PhysicsGroup.MediumStructuresGroup,
            PhysicsGroup.RagdollGroup,
            PhysicsGroup.PlayerGroup,
            PhysicsGroup.PlayerControllersGroup,
            PhysicsGroup.BabblerGroup,
            PhysicsGroup.ProjectileGroup,
            PhysicsGroup.WeaponGroup,
            PhysicsGroup.DroppedWeaponGroup,
            PhysicsGroup.CommanderBuildGroup,
            PhysicsGroup.PathingGroup,
            PhysicsGroup.WebsGroup),

    -- Only collide with marines, we don't care about the environment.
    OnosStampede = CreateMaskExcludingGroups(PhysicsGroup.MarinePlayerGroup),

    -- Filters anything that should not collide with onos charging.
    OnosCharge = CreateMaskExcludingGroups(PhysicsGroup.WhipGroup,
            PhysicsGroup.SmallStructuresGroup,
            PhysicsGroup.MediumStructuresGroup,
            PhysicsGroup.RagdollGroup,
            PhysicsGroup.PlayerGroup,
            PhysicsGroup.PlayerControllersGroup,
            PhysicsGroup.BabblerGroup,
            PhysicsGroup.ProjectileGroup,
            PhysicsGroup.WeaponGroup,
            PhysicsGroup.DroppedWeaponGroup,
            PhysicsGroup.CommanderBuildGroup,
            PhysicsGroup.PathingGroup,
            PhysicsGroup.WebsGroup),

    -- For Drifters, MACs
    AIMovement = CreateMaskExcludingGroups(PhysicsGroup.MediumStructuresGroup,
            PhysicsGroup.SmallStructuresGroup,
            PhysicsGroup.RagdollGroup,
            PhysicsGroup.PlayerGroup,
            PhysicsGroup.BigPlayerControllersGroup,
            PhysicsGroup.PlayerControllersGroup,
            PhysicsGroup.MarinePlayerGroup,
            PhysicsGroup.BabblerGroup,
            PhysicsGroup.CommanderBuildGroup,
            PhysicsGroup.PathingGroup,
            PhysicsGroup.WebsGroup),

    -- Use these with trace functions to determine which entities we collide with. Use the filter to then
    -- ignore specific entities.
    AllButPCs = CreateMaskExcludingGroups(PhysicsGroup.PlayerControllersGroup,
            PhysicsGroup.BigPlayerControllersGroup,
            PhysicsGroup.PathingGroup,
            PhysicsGroup.MarinePlayerGroup),

    -- For things the commander can build on top of other things
    CommanderStack = CreateMaskExcludingGroups(PhysicsGroup.PlayerControllersGroup,
            PhysicsGroup.BigPlayerControllersGroup,
            PhysicsGroup.PathingGroup,
            PhysicsGroup.MarinePlayerGroup),

    -- Used for all types of prediction
    AllButPCsAndRagdolls = CreateMaskExcludingGroups(PhysicsGroup.PlayerControllersGroup,
            PhysicsGroup.BigPlayerControllersGroup,
            PhysicsGroup.RagdollGroup,
            PhysicsGroup.PathingGroup,
            PhysicsGroup.MarinePlayerGroup),

    AllButTriggers = CreateMaskExcludingGroups(PhysicsGroup.TriggerGroup,
            PhysicsGroup.PathingGroup),

    -- Shooting
    Bullets = CreateMaskExcludingGroups(PhysicsGroup.PlayerControllersGroup,
            PhysicsGroup.BigPlayerControllersGroup,
            PhysicsGroup.RagdollGroup,
            PhysicsGroup.CollisionGeometryGroup,
            PhysicsGroup.AllowBulletsPropsGroup,
            PhysicsGroup.WeaponGroup,
            PhysicsGroup.CommanderBuildGroup,
            PhysicsGroup.ProjectileGroup,
            PhysicsGroup.PathingGroup,
            PhysicsGroup.WebsGroup,
            PhysicsGroup.MarinePlayerGroup),

    Flame = CreateMaskExcludingGroups(PhysicsGroup.PlayerControllersGroup,
            PhysicsGroup.BigPlayerControllersGroup,
            PhysicsGroup.RagdollGroup,
            PhysicsGroup.CollisionGeometryGroup,
            PhysicsGroup.AllowBulletsPropsGroup,
            PhysicsGroup.WeaponGroup,
            PhysicsGroup.CommanderBuildGroup,
            PhysicsGroup.ProjectileGroup,
            PhysicsGroup.PathingGroup,
            PhysicsGroup.MarinePlayerGroup),

    -- Melee attacks
    Melee = CreateMaskExcludingGroups(PhysicsGroup.PlayerControllersGroup,
            PhysicsGroup.BigPlayerControllersGroup,
            PhysicsGroup.RagdollGroup,
            PhysicsGroup.CollisionGeometryGroup,
            PhysicsGroup.WeaponGroup,
            PhysicsGroup.CommanderBuildGroup,
            PhysicsGroup.ProjectileGroup,
            PhysicsGroup.PathingGroup,
            PhysicsGroup.WebsGroup,
            PhysicsGroup.MarinePlayerGroup),

    PredictedProjectileGroup = CreateMaskExcludingGroups(PhysicsGroup.CollisionGeometryGroup,
            PhysicsGroup.RagdollGroup,
            PhysicsGroup.ProjectileGroup,
            PhysicsGroup.BabblerGroup,
            PhysicsGroup.WeaponGroup,
            PhysicsGroup.DroppedWeaponGroup,
            PhysicsGroup.CommanderBuildGroup,
            PhysicsGroup.PathingGroup,
            PhysicsGroup.WebsGroup,
            PhysicsGroup.MarinePlayerGroup),

    -- Allows us to mark props as non interfering for commander selection (culls out any props with commAlpha < 1)
    CommanderSelect = CreateMaskExcludingGroups(PhysicsGroup.PlayerControllersGroup,
            PhysicsGroup.BigPlayerControllersGroup,
            PhysicsGroup.RagdollGroup,
            PhysicsGroup.CommanderPropsGroup,
            PhysicsGroup.AllowBulletsPropsGroup,
            PhysicsGroup.CollisionGeometryGroup,
            PhysicsGroup.PathingGroup,
            PhysicsGroup.WebsGroup,
            PhysicsGroup.MarinePlayerGroup),

    -- The same as commander select mask, minus player entities and structures
    CommanderBuild = CreateMaskExcludingGroups(PhysicsGroup.PlayerControllersGroup,
            PhysicsGroup.BigPlayerControllersGroup,
            PhysicsGroup.RagdollGroup,
            PhysicsGroup.CommanderPropsGroup,
            PhysicsGroup.AllowBulletsPropsGroup,
            PhysicsGroup.CommanderUnitGroup,
            PhysicsGroup.CollisionGeometryGroup,
            PhysicsGroup.PathingGroup,
            PhysicsGroup.WebsGroup,
            PhysicsGroup.MarinePlayerGroup),

    -- same as command build, minus CommanderPropsGroup (static props which set alpha to 0), otherwise cysts can be created outside of the map
    CystBuild = CreateMaskExcludingGroups(PhysicsGroup.PlayerControllersGroup,
            PhysicsGroup.BigPlayerControllersGroup,
            PhysicsGroup.RagdollGroup,
            PhysicsGroup.CommanderUnitGroup,
            PhysicsGroup.CollisionGeometryGroup,
            PhysicsGroup.PathingGroup,
            PhysicsGroup.MarinePlayerGroup),

    -- Dropped weapons don't collide with the player controller
    DroppedWeaponFilter = CreateMaskIncludingGroups(PhysicsGroup.PlayerControllersGroup,
            PhysicsGroup.BigPlayerControllersGroup,
            PhysicsGroup.RagdollGroup,
            PhysicsGroup.PathingGroup,
            PhysicsGroup.MarinePlayerGroup),

    BabblerMovement = CreateMaskIncludingGroups(PhysicsGroup.BabblerGroup),

    NoBabblers = CreateMaskIncludingGroups(PhysicsGroup.BabblerGroup,
            PhysicsGroup.ProjectileGroup),

    OnlyWhip = CreateMaskIncludingGroups(PhysicsGroup.WhipGroup),

    Evolve = CreateMaskExcludingGroups(PhysicsGroup.PlayerControllersGroup,
            PhysicsGroup.RagdollGroup,
            PhysicsGroup.BabblerGroup,
            PhysicsGroup.WebsGroup),

    AllButPCsAndRagdollsAndBabblers = CreateMaskExcludingGroups(PhysicsGroup.PlayerControllersGroup,
            PhysicsGroup.BigPlayerControllersGroup,
            PhysicsGroup.RagdollGroup,
            PhysicsGroup.PathingGroup,
            PhysicsGroup.BabblerGroup,
            PhysicsGroup.MarinePlayerGroup),
}