local kSpreadDistance = kShotgunSpreadDistance

Shotgun.kSpreadVectors =
{
    -- GetNormalizedVector(Vector(-0.01, 0.01, kSpreadDistance)),

    GetNormalizedVector(Vector(-0.45, 0.45, kSpreadDistance)),
    GetNormalizedVector(Vector(0.45, 0.45, kSpreadDistance)),
    GetNormalizedVector(Vector(0.45, -0.45, kSpreadDistance)),
    GetNormalizedVector(Vector(-0.45, -0.45, kSpreadDistance)),

    GetNormalizedVector(Vector(-1, 0, kSpreadDistance)),
    GetNormalizedVector(Vector(1, 0, kSpreadDistance)),
    GetNormalizedVector(Vector(0, -1, kSpreadDistance)),
    GetNormalizedVector(Vector(0, 1, kSpreadDistance)),

    GetNormalizedVector(Vector(-1.35, 0, kSpreadDistance)),
    GetNormalizedVector(Vector(1.35, 0, kSpreadDistance)),
    GetNormalizedVector(Vector(0, -1.35, kSpreadDistance)),
    GetNormalizedVector(Vector(0, 1.35, kSpreadDistance)),

    GetNormalizedVector(Vector(-0.65, 0, kSpreadDistance)),
    GetNormalizedVector(Vector(0.65, 0, kSpreadDistance)),
    GetNormalizedVector(Vector(0, -0.65, kSpreadDistance)),
    GetNormalizedVector(Vector(0, 0.65, kSpreadDistance)),

    GetNormalizedVector(Vector(-0.35, 0, kSpreadDistance)),
    GetNormalizedVector(Vector(0.35, 0, kSpreadDistance)),
    GetNormalizedVector(Vector(0, -0.35, kSpreadDistance)),
    GetNormalizedVector(Vector(0, 0.35, kSpreadDistance)),

    GetNormalizedVector(Vector(-0.8, -0.8, kSpreadDistance)),
    GetNormalizedVector(Vector(-0.8, 0.8, kSpreadDistance)),
    GetNormalizedVector(Vector(0.8, 0.8, kSpreadDistance)),
    GetNormalizedVector(Vector(0.8, -0.8, kSpreadDistance)),

}
