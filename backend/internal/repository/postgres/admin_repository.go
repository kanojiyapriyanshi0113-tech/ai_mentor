package postgres

import (
    "context"
    "errors"
    "fmt"

    "github.com/google/uuid"
    "github.com/jackc/pgx/v5"
    "github.com/jackc/pgx/v5/pgxpool"

    "ai-mentor-backend/internal/domain/apperror"
    "ai-mentor-backend/internal/domain/entity"
)

type adminRepository struct {
    db *pgxpool.Pool
}

func NewAdminRepository(db *pgxpool.Pool) *adminRepository {
    return &adminRepository{db: db}
}

// ---------- Dashboard ----------

func (r *adminRepository) GetDashboardStats(ctx context.Context) (*entity.AdminDashboardStats, error) {
    var stats entity.AdminDashboardStats
    const q = `
        SELECT
            (SELECT COUNT(*) FROM users WHERE role = 'student') AS total_students,
            (SELECT COUNT(*) FROM users WHERE role = 'teacher') AS total_teachers,
            (SELECT COALESCE(SUM(amount_paise), 0) FROM payments WHERE status = 'success') AS total_revenue,
            (SELECT COUNT(*) FROM subscriptions WHERE status = 'active' AND expires_at > now()) AS active_subs,
            (SELECT COUNT(*) FROM batches WHERE is_active = true) AS active_batches,
            (SELECT COUNT(*) FROM live_classes WHERE is_active = true AND scheduled_at >= now()) AS upcoming_live,
            (SELECT COALESCE(SUM(used_count), 0) FROM user_usage WHERE usage_date = CURRENT_DATE AND feature_key = 'ai_chat_daily_limit') AS ai_usage_today
    `
    err := r.db.QueryRow(ctx, q).Scan(
        &stats.TotalStudents, &stats.TotalTeachers, &stats.TotalRevenuePaise,
        &stats.ActiveSubscriptions, &stats.ActiveBatches, &stats.UpcomingLiveClasses, &stats.AIUsageToday,
    )
    if err != nil {
        return nil, fmt.Errorf("get admin dashboard stats: %w", err)
    }
    return &stats, nil
}

// ---------- Teacher ----------

func (r *adminRepository) AddTeacher(ctx context.Context, name, email, passwordHash string) (*entity.TeacherAccount, error) {
    var t entity.TeacherAccount
    const q = `
        INSERT INTO users (name, email, password_hash, role, is_verified, is_approved)
        VALUES ($1, $2, $3, 'teacher', true, false)
        RETURNING id, name, email, is_approved, is_suspended, created_at
    `
    err := r.db.QueryRow(ctx, q, name, email, passwordHash).
        Scan(&t.ID, &t.Name, &t.Email, &t.IsApproved, &t.IsSuspended, &t.CreatedAt)
    if err != nil {
        var pgErr interface{ ConstraintName() string }
        if errors.As(err, &pgErr) {
            return nil, apperror.ErrEmailAlreadyExists
        }
        return nil, fmt.Errorf("add teacher: %w", err)
    }
    return &t, nil
}

func (r *adminRepository) ApproveTeacher(ctx context.Context, id uuid.UUID) error {
    const q = `UPDATE users SET is_approved = true WHERE id = $1 AND role = 'teacher'`
    tag, err := r.db.Exec(ctx, q, id.String())
    if err != nil {
        return fmt.Errorf("approve teacher: %w", err)
    }
    if tag.RowsAffected() == 0 {
        return apperror.ErrTeacherNotFound
    }
    return nil
}

func (r *adminRepository) EditTeacher(ctx context.Context, id uuid.UUID, name, email string) error {
    const q = `UPDATE users SET name = $1, email = $2, updated_at = now() WHERE id = $3 AND role = 'teacher'`
    tag, err := r.db.Exec(ctx, q, name, email, id.String())
    if err != nil {
        return fmt.Errorf("edit teacher: %w", err)
    }
    if tag.RowsAffected() == 0 {
        return apperror.ErrTeacherNotFound
    }
    return nil
}

func (r *adminRepository) SuspendTeacher(ctx context.Context, id uuid.UUID, suspend bool) error {
    const q = `UPDATE users SET is_suspended = $1 WHERE id = $2 AND role = 'teacher'`
    tag, err := r.db.Exec(ctx, q, suspend, id.String())
    if err != nil {
        return fmt.Errorf("suspend teacher: %w", err)
    }
    if tag.RowsAffected() == 0 {
        return apperror.ErrTeacherNotFound
    }
    return nil
}

func (r *adminRepository) DeleteTeacher(ctx context.Context, id uuid.UUID) error {
    const q = `DELETE FROM users WHERE id = $1 AND role = 'teacher'`
    tag, err := r.db.Exec(ctx, q, id.String())
    if err != nil {
        return fmt.Errorf("delete teacher: %w", err)
    }
    if tag.RowsAffected() == 0 {
        return apperror.ErrTeacherNotFound
    }
    return nil
}

func (r *adminRepository) ListTeachers(ctx context.Context) ([]entity.TeacherAccount, error) {
    const q = `
        SELECT id, name, email, is_approved, is_suspended, created_at
        FROM users WHERE role = 'teacher' ORDER BY created_at DESC
    `
    rows, err := r.db.Query(ctx, q)
    if err != nil {
        return nil, fmt.Errorf("list teachers: %w", err)
    }
    defer rows.Close()

    var out []entity.TeacherAccount
    for rows.Next() {
        var t entity.TeacherAccount
        if err := rows.Scan(&t.ID, &t.Name, &t.Email, &t.IsApproved, &t.IsSuspended, &t.CreatedAt); err != nil {
            return nil, fmt.Errorf("scan teacher: %w", err)
        }
        out = append(out, t)
    }
    return out, nil
}

// ---------- Student ----------

func (r *adminRepository) ListStudents(ctx context.Context, search string, limit, offset int) ([]entity.StudentAccount, error) {
    const q = `
        SELECT id, name, email, is_blocked, premium, created_at
        FROM users
        WHERE role = 'student' AND ($1 = '' OR name ILIKE '%' || $1 || '%' OR email ILIKE '%' || $1 || '%')
        ORDER BY created_at DESC
        LIMIT $2 OFFSET $3
    `
    rows, err := r.db.Query(ctx, q, search, limit, offset)
    if err != nil {
        return nil, fmt.Errorf("list students: %w", err)
    }
    defer rows.Close()

    var out []entity.StudentAccount
    for rows.Next() {
        var s entity.StudentAccount
        if err := rows.Scan(&s.ID, &s.Name, &s.Email, &s.IsBlocked, &s.Premium, &s.CreatedAt); err != nil {
            return nil, fmt.Errorf("scan student: %w", err)
        }
        out = append(out, s)
    }
    return out, nil
}

func (r *adminRepository) BlockStudent(ctx context.Context, id uuid.UUID, block bool) error {
    const q = `UPDATE users SET is_blocked = $1 WHERE id = $2 AND role = 'student'`
    tag, err := r.db.Exec(ctx, q, block, id.String())
    if err != nil {
        return fmt.Errorf("block student: %w", err)
    }
    if tag.RowsAffected() == 0 {
        return apperror.ErrStudentNotFound
    }
    return nil
}

func (r *adminRepository) DeleteStudent(ctx context.Context, id uuid.UUID) error {
    const q = `DELETE FROM users WHERE id = $1 AND role = 'student'`
    tag, err := r.db.Exec(ctx, q, id.String())
    if err != nil {
        return fmt.Errorf("delete student: %w", err)
    }
    if tag.RowsAffected() == 0 {
        return apperror.ErrStudentNotFound
    }
    return nil
}

// ---------- Plan ----------

func (r *adminRepository) CreatePlan(ctx context.Context, p *entity.Plan) error {
    const q = `
        INSERT INTO plans (code, name, price_paise, duration_days, is_trial, is_active)
        VALUES ($1, $2, $3, $4, $5, true)
        RETURNING id
    `
    err := r.db.QueryRow(ctx, q, p.Code, p.Name, p.PricePaise, p.DurationDays, p.IsTrial).Scan(&p.ID)
    if err != nil {
        return fmt.Errorf("create plan: %w", err)
    }
    return nil
}

func (r *adminRepository) UpdatePlan(ctx context.Context, p *entity.Plan) error {
    const q = `UPDATE plans SET name = $1, price_paise = $2, duration_days = $3, is_trial = $4 WHERE id = $5`
    tag, err := r.db.Exec(ctx, q, p.Name, p.PricePaise, p.DurationDays, p.IsTrial, p.ID)
    if err != nil {
        return fmt.Errorf("update plan: %w", err)
    }
    if tag.RowsAffected() == 0 {
        return apperror.ErrPlanNotFound
    }
    return nil
}

func (r *adminRepository) SetPlanActive(ctx context.Context, id int, active bool) error {
    const q = `UPDATE plans SET is_active = $1 WHERE id = $2`
    tag, err := r.db.Exec(ctx, q, active, id)
    if err != nil {
        return fmt.Errorf("set plan active: %w", err)
    }
    if tag.RowsAffected() == 0 {
        return apperror.ErrPlanNotFound
    }
    return nil
}

// ---------- Coupon ----------

func (r *adminRepository) CreateCoupon(ctx context.Context, c *entity.Coupon) error {
    if c.ID == "" {
        c.ID = uuid.New().String()
    }
    const q = `
        INSERT INTO coupons (id, code, discount_percent, discount_amount_paise, max_uses, valid_from, valid_until, is_active, created_at, updated_at)
        VALUES ($1, $2, $3, $4, $5, $6, $7, true, now(), now())
        ON CONFLICT (code) DO NOTHING
    `
    tag, err := r.db.Exec(ctx, q, c.ID, c.Code, c.DiscountPercent, c.DiscountAmountPaise, c.MaxUses, c.ValidFrom, c.ValidUntil)
    if err != nil {
        return fmt.Errorf("create coupon: %w", err)
    }
    if tag.RowsAffected() == 0 {
        return apperror.ErrCouponCodeExists
    }
    return nil
}

func (r *adminRepository) UpdateCoupon(ctx context.Context, c *entity.Coupon) error {
    const q = `
        UPDATE coupons
        SET discount_percent = $1, discount_amount_paise = $2, max_uses = $3, valid_from = $4, valid_until = $5, is_active = $6, updated_at = now()
        WHERE id = $7
    `
    tag, err := r.db.Exec(ctx, q, c.DiscountPercent, c.DiscountAmountPaise, c.MaxUses, c.ValidFrom, c.ValidUntil, c.IsActive, c.ID)
    if err != nil {
        return fmt.Errorf("update coupon: %w", err)
    }
    if tag.RowsAffected() == 0 {
        return apperror.ErrCouponNotFound
    }
    return nil
}

func (r *adminRepository) DeleteCoupon(ctx context.Context, id uuid.UUID) error {
    const q = `DELETE FROM coupons WHERE id = $1`
    tag, err := r.db.Exec(ctx, q, id.String())
    if err != nil {
        return fmt.Errorf("delete coupon: %w", err)
    }
    if tag.RowsAffected() == 0 {
        return apperror.ErrCouponNotFound
    }
    return nil
}

func (r *adminRepository) ListCoupons(ctx context.Context) ([]entity.Coupon, error) {
    const q = `
        SELECT id, code, discount_percent, discount_amount_paise, max_uses, used_count, valid_from, valid_until, is_active, created_at, updated_at
        FROM coupons ORDER BY created_at DESC
    `
    rows, err := r.db.Query(ctx, q)
    if err != nil {
        return nil, fmt.Errorf("list coupons: %w", err)
    }
    defer rows.Close()

    var out []entity.Coupon
    for rows.Next() {
        var c entity.Coupon
        if err := rows.Scan(&c.ID, &c.Code, &c.DiscountPercent, &c.DiscountAmountPaise, &c.MaxUses, &c.UsedCount, &c.ValidFrom, &c.ValidUntil, &c.IsActive, &c.CreatedAt, &c.UpdatedAt); err != nil {
            return nil, fmt.Errorf("scan coupon: %w", err)
        }
        out = append(out, c)
    }
    return out, nil
}

// ---------- Payment ----------

func (r *adminRepository) ListPayments(ctx context.Context, limit, offset int) ([]entity.Payment, error) {
    const q = `
        SELECT id, user_id, COALESCE(subscription_id::text, ''), amount_paise, status, payment_method, transaction_ref, created_at, refunded_at
        FROM payments ORDER BY created_at DESC LIMIT $1 OFFSET $2
    `
    rows, err := r.db.Query(ctx, q, limit, offset)
    if err != nil {
        return nil, fmt.Errorf("list payments: %w", err)
    }
    defer rows.Close()

    var out []entity.Payment
    for rows.Next() {
        var p entity.Payment
        if err := rows.Scan(&p.ID, &p.UserID, &p.SubscriptionID, &p.AmountPaise, &p.Status, &p.PaymentMethod, &p.TransactionRef, &p.CreatedAt, &p.RefundedAt); err != nil {
            return nil, fmt.Errorf("scan payment: %w", err)
        }
        out = append(out, p)
    }
    return out, nil
}

func (r *adminRepository) RefundPayment(ctx context.Context, id uuid.UUID) error {
    var status string
    const checkQ = `SELECT status FROM payments WHERE id = $1`
    err := r.db.QueryRow(ctx, checkQ, id.String()).Scan(&status)
    if err != nil {
        if errors.Is(err, pgx.ErrNoRows) {
            return apperror.ErrPaymentNotFound
        }
        return fmt.Errorf("find payment: %w", err)
    }
    if status == "refunded" {
        return apperror.ErrPaymentAlreadyRefunded
    }

    const q = `UPDATE payments SET status = 'refunded', refunded_at = now() WHERE id = $1`
    if _, err := r.db.Exec(ctx, q, id.String()); err != nil {
        return fmt.Errorf("refund payment: %w", err)
    }
    return nil
}

// ---------- Reports ----------

func (r *adminRepository) GetRevenueReport(ctx context.Context) (*entity.RevenueReport, error) {
    var rep entity.RevenueReport
    const q = `
        SELECT
            (SELECT COALESCE(SUM(amount_paise), 0) FROM payments WHERE status = 'success'),
            (SELECT COUNT(*) FROM payments WHERE status = 'success'),
            (SELECT COALESCE(SUM(amount_paise), 0) FROM payments WHERE status = 'refunded')
    `
    err := r.db.QueryRow(ctx, q).Scan(&rep.TotalRevenuePaise, &rep.TotalPayments, &rep.RefundedPaise)
    if err != nil {
        return nil, fmt.Errorf("get revenue report: %w", err)
    }
    return &rep, nil
}

func (r *adminRepository) GetStudentsReport(ctx context.Context) (*entity.StudentsReport, error) {
    var rep entity.StudentsReport
    const q = `
        SELECT
            (SELECT COUNT(*) FROM users WHERE role = 'student'),
            (SELECT COUNT(*) FROM users WHERE role = 'student' AND created_at >= now() - interval '30 days'),
            (SELECT COUNT(*) FROM users WHERE role = 'student' AND trial_end_date > now() AND premium = false),
            (SELECT COUNT(*) FROM users WHERE role = 'student' AND premium = true)
    `
    err := r.db.QueryRow(ctx, q).Scan(&rep.TotalStudents, &rep.NewStudents30d, &rep.ActiveTrials, &rep.PremiumStudents)
    if err != nil {
        return nil, fmt.Errorf("get students report: %w", err)
    }
    return &rep, nil
}

func (r *adminRepository) GetCoursesReport(ctx context.Context) (*entity.CoursesReport, error) {
    var rep entity.CoursesReport
    const q = `
        SELECT
            (SELECT COUNT(*) FROM batches WHERE is_active = true),
            (SELECT COUNT(*) FROM subjects WHERE is_active = true),
            (SELECT COUNT(*) FROM chapters WHERE is_active = true),
            (SELECT COUNT(*) FROM lectures WHERE is_active = true),
            (SELECT COUNT(*) FROM mock_tests WHERE is_active = true)
    `
    err := r.db.QueryRow(ctx, q).Scan(&rep.TotalBatches, &rep.TotalSubjects, &rep.TotalChapters, &rep.TotalLectures, &rep.TotalMockTests)
    if err != nil {
        return nil, fmt.Errorf("get courses report: %w", err)
    }
    return &rep, nil
}

// ---------- Settings ----------

func (r *adminRepository) GetSetting(ctx context.Context, key string) (string, error) {
    const q = `SELECT value FROM app_settings WHERE key = $1`
    var value string
    err := r.db.QueryRow(ctx, q, key).Scan(&value)
    if err != nil {
        if errors.Is(err, pgx.ErrNoRows) {
            return "", nil
        }
        return "", fmt.Errorf("get setting: %w", err)
    }
    return value, nil
}

func (r *adminRepository) SetSetting(ctx context.Context, key, value string) error {
    const q = `
        INSERT INTO app_settings (key, value, updated_at)
        VALUES ($1, $2, now())
        ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value, updated_at = now()
    `
    _, err := r.db.Exec(ctx, q, key, value)
    if err != nil {
        return fmt.Errorf("set setting: %w", err)
    }
    return nil
}

func (r *adminRepository) ListSettings(ctx context.Context) ([]entity.AppSetting, error) {
    const q = `SELECT key, value, updated_at FROM app_settings ORDER BY key ASC`
    rows, err := r.db.Query(ctx, q)
    if err != nil {
        return nil, fmt.Errorf("list settings: %w", err)
    }
    defer rows.Close()

    var out []entity.AppSetting
    for rows.Next() {
        var s entity.AppSetting
        if err := rows.Scan(&s.Key, &s.Value, &s.UpdatedAt); err != nil {
            return nil, fmt.Errorf("scan setting: %w", err)
        }
        out = append(out, s)
    }
    return out, nil
}

// ---------- Banner ----------

func (r *adminRepository) CreateBanner(ctx context.Context, b *entity.Banner) error {
    if b.ID == "" {
        b.ID = uuid.New().String()
    }
    const q = `
        INSERT INTO banners (id, title, image_url, link_url, display_order, is_active, created_at, updated_at)
        VALUES ($1, $2, $3, $4, $5, true, now(), now())
    `
    _, err := r.db.Exec(ctx, q, b.ID, b.Title, b.ImageURL, b.LinkURL, b.DisplayOrder)
    if err != nil {
        return fmt.Errorf("create banner: %w", err)
    }
    return nil
}

func (r *adminRepository) UpdateBanner(ctx context.Context, b *entity.Banner) error {
    const q = `
        UPDATE banners
        SET title = $1, image_url = $2, link_url = $3, display_order = $4, is_active = $5, updated_at = now()
        WHERE id = $6
    `
    tag, err := r.db.Exec(ctx, q, b.Title, b.ImageURL, b.LinkURL, b.DisplayOrder, b.IsActive, b.ID)
    if err != nil {
        return fmt.Errorf("update banner: %w", err)
    }
    if tag.RowsAffected() == 0 {
        return apperror.ErrBannerNotFound
    }
    return nil
}

func (r *adminRepository) DeleteBanner(ctx context.Context, id uuid.UUID) error {
    const q = `DELETE FROM banners WHERE id = $1`
    tag, err := r.db.Exec(ctx, q, id.String())
    if err != nil {
        return fmt.Errorf("delete banner: %w", err)
    }
    if tag.RowsAffected() == 0 {
        return apperror.ErrBannerNotFound
    }
    return nil
}

func (r *adminRepository) ListBanners(ctx context.Context) ([]entity.Banner, error) {
    const q = `
        SELECT id, title, image_url, link_url, display_order, is_active, created_at, updated_at
        FROM banners ORDER BY display_order ASC
    `
    rows, err := r.db.Query(ctx, q)
    if err != nil {
        return nil, fmt.Errorf("list banners: %w", err)
    }
    defer rows.Close()

    var out []entity.Banner
    for rows.Next() {
        var b entity.Banner
        if err := rows.Scan(&b.ID, &b.Title, &b.ImageURL, &b.LinkURL, &b.DisplayOrder, &b.IsActive, &b.CreatedAt, &b.UpdatedAt); err != nil {
            return nil, fmt.Errorf("scan banner: %w", err)
        }
        out = append(out, b)
    }
    return out, nil
}
