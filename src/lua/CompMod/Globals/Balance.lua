kCystBuildTime = 6
kCystDetectRange = 10

kDrifterDetectRange = 5

kEnzymeCloudAbilityCooldown = 1

kAdvancedSwipeDamageScalar = 1.08
kAdvancedSwipeResearchTime = 60
kAdvancedSwipeCost = 25

kBabblerHealth = 11 -- 12

kWebHealthPerCharge = 5

kWebMaxCharges = 0 --3

kWebbedDuration = 2.5 --5

kHealingClampReductionScalar = 0.20

kSpikeDamage = 6
kSpikeSpread = Math.Radians(3.8)

kUmbraResearchTime = 105 -- 45

kMucousMembraneAbilityCooldown = 1

kSkulkMucousShieldPercent = 0.2
kGorgeMucousShieldPercent = 0.13
kLerkMucousShieldPercent = 0.14
kFadeMucousShieldPercent = 0.16
kOnosMucousShieldPercent = 0.09
kMucousShieldMaxAmount = 85

kEchoVeilCost = 2
kEchoSpurCost = 2
kEchoShellCost = 2
kEchoEggCost = 1

kLeapEnergyCost = 55

kAdrenalineAbilityMaxEnergy = kAbilityMaxEnergy

kSkulkNeurotoxinDamage = 7
kGorgeNeurotoxinDamage = 6
kLerkNeurotoxinDamage = 5
kFadeNeurotoxinDamage = 9
kOnosNeurotoxinDamage = 7

kAlienRegenerationPercentage = 0.06
kAlienMinRegeneration = 5

kBiteLeapVampirismScalar = 0.0377 -- 0.0466 (4.66%)

kAdvancedArmoryHealth = 2000 --3000
kAdvancedArmoryArmor = 500 -- this has no effect due to a bug
kAdvancedArmoryPointValue = 10

-- Demolitions includes flamethrower and grenade launcher
kDemolitionsTechResearchCost = 15
kDemolitionsTechResearchTime = 30

kARCHealth = 1800
kARCArmor = 500
kARCPointValue = 5
kARCDeployedHealth = 1800

kAdvancedArmoryUpgradeCost = 15
kAdvancedArmoryResearchTime = 45

kHeavyMachineGunDamage = 7
kHeavyMachineGunSpread = Math.Radians(3.2)

kMACCost = 4 --5

kMedpackHeal = 50 -- 25
kMedpackPickupDelay = 0.6 -- 0.45
kMarineRegenerationHeal = 0 -- 25

-- Lower player nanoshield duration to 2 from 3
kNanoShieldPlayerDuration = 2

kObservatoryBuildTime = 10

kPrototypeLabCost = 25 -- 35

kRoboticsFactoryCost = 5 --10
kUpgradeRoboticsFactoryCost = 10 --5

kSentryCost = 6 -- 5

kConfusedSentryBaseROF = 4.0 --2.0

kSentryBatteryCost = 12 -- 10

-- Increase damage per upgrade to ~13.33 from ~10

local kShotgunDamagePerUpgradeScalar = 0.078
kShotgunWeapons1DamageScalar = 1 + kShotgunDamagePerUpgradeScalar
kShotgunWeapons2DamageScalar = 1 + kShotgunDamagePerUpgradeScalar * 2
kShotgunWeapons3DamageScalar = 1 + kShotgunDamagePerUpgradeScalar * 3

kMACSupply = 15 --5
kSentrySupply = 15 -- 10
kObservatorySupply = 30 -- 25
kSentryBatterySupply = 25 -- 15
kRoboticsFactorySupply = 15 --5

kWeaponStayTime = 18

kStartBlinkEnergyCost = 12 -- 14

kPhaseGateHealth = 1500
kPhaseGateArmor = 800
kPhaseGateHealth = 1300
kPhaseGateArmor = 900

kSwipeDamageType = kDamageType.StructuresOnlyLight
kSwipeDamage = 75

kAlienStructureOutOfCombatMoveScalar = 1.10

kAdrenalineRushRangeScalar = 0.25
kAdrenalineRushIntervalScalar = 0.1

kLerkHealth = 170 -- 180

kWeapons1ResearchTime = 80 --75
kWeapons2ResearchTime = 95 --90
kArmor1ResearchTime = 80 -- 75
kArmor2ResearchTime = 95 -- 90

kMinBuildTimePerHealSpray = 0.91
kJetpackDropCost = 20

kMACOutOfCombatSpeedScalar = 1.15 -- 15%

kGorgeHealth = 190 -- 160
kBoneShieldHitpoints = 500 -- 1000
