package entity

// FeatureLimit: -1 = unlimited, 0 = not allowed, N = numeric cap.
type SubscriptionFeature struct {
    PlanID       int
    FeatureKey   string
    FeatureLimit int
}