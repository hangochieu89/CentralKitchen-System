-- ============================================================
-- MIGRATION: Redesign ProductionPlans
-- Bỏ order_id (1-1), thêm product_id + total_quantity
-- Tạo bảng trung gian ProductionPlanOrders
-- ============================================================

-- 1. Xóa bảng cũ (backup trước nếu cần)
-- SELECT * INTO ProductionPlans_backup FROM ProductionPlans;
DROP TABLE IF EXISTS ProductionPlans;

-- 2. Tạo bảng ProductionPlans mới
CREATE TABLE ProductionPlans (
    id              INT IDENTITY(1,1) PRIMARY KEY,
    product_id      INT NOT NULL,
    total_quantity  FLOAT NOT NULL,
    assigned_to     INT NULL,
    planned_date    DATETIME NULL,
    status          NVARCHAR(20) NOT NULL DEFAULT 'PENDING',
    note            NVARCHAR(500) NULL,
    created_at      DATETIME NOT NULL DEFAULT GETDATE(),

    CONSTRAINT FK_ProductionPlans_Product  FOREIGN KEY (product_id)  REFERENCES Products(id),
    CONSTRAINT FK_ProductionPlans_AssignTo FOREIGN KEY (assigned_to) REFERENCES Users(id)
);

-- 3. Tạo bảng trung gian ProductionPlanOrders
CREATE TABLE ProductionPlanOrders (
    id          INT IDENTITY(1,1) PRIMARY KEY,
    plan_id     INT NOT NULL,
    order_id    INT NOT NULL,
    quantity    FLOAT NOT NULL,

    CONSTRAINT FK_PPO_Plan  FOREIGN KEY (plan_id)  REFERENCES ProductionPlans(id),
    CONSTRAINT FK_PPO_Order FOREIGN KEY (order_id) REFERENCES Orders(id)
);
