package entity

type Plan struct {
    ID           int
    Code         string
    Name         string
    PricePaise   int
    DurationDays int
    IsTrial      bool
    IsActive     bool
}
