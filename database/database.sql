-- ============================================================
-- HỆ THỐNG QUẢN LÝ BẾP TRUNG TÂM & FRANCHISE
-- Database: SQL Server
-- Có thể Execute (F5) nhiều lần: bảng đã có thì bỏ qua CREATE; dữ liệu mẫu chỉ thêm khi bảng trống.
-- Cần xóa hết DB: chạy database/00-drop-database.sql rồi chạy lại file này.
-- ============================================================

IF DB_ID(N'CentralKitchenDB') IS NULL
BEGIN
    CREATE DATABASE CentralKitchenDB;
END
GO
USE CentralKitchenDB;
GO

-- ============================================================
-- 1. STORES
-- ============================================================
IF OBJECT_ID(N'dbo.Stores', N'U') IS NULL
CREATE TABLE Stores (
                        id          INT IDENTITY(1,1) PRIMARY KEY,
                        name        NVARCHAR(100)   NOT NULL,
                        address     NVARCHAR(255),
                        phone       VARCHAR(20),
                        type        VARCHAR(30)     NOT NULL CHECK (type IN ('CENTRAL_KITCHEN','FRANCHISE_STORE')),
                        is_active   BIT             DEFAULT 1,
                        created_at  DATETIME        DEFAULT GETDATE()
);
GO

-- ============================================================
-- 2. USERS
-- ============================================================
IF OBJECT_ID(N'dbo.Users', N'U') IS NULL
CREATE TABLE Users (
                       id            INT IDENTITY(1,1) PRIMARY KEY,
                       username      VARCHAR(50)    NOT NULL UNIQUE,
                       password_hash VARCHAR(255)   NOT NULL,
                       full_name     NVARCHAR(100)  NOT NULL,
                       email         VARCHAR(100)   UNIQUE,
                       role          VARCHAR(30)    NOT NULL CHECK (role IN (
                                                                             'ADMIN','MANAGER','SUPPLY_COORDINATOR',
                                                                             'KITCHEN_STAFF','STORE_STAFF')),
                       store_id      INT            REFERENCES Stores(id),
                       is_active     BIT            DEFAULT 1,
                       created_at    DATETIME       DEFAULT GETDATE()
);
GO

-- ============================================================
-- 3. PRODUCTS
-- ============================================================
IF OBJECT_ID(N'dbo.Products', N'U') IS NULL
CREATE TABLE Products (
                          id                 INT IDENTITY(1,1) PRIMARY KEY,
                          name               NVARCHAR(150)  NOT NULL,
                          category           NVARCHAR(100),
                          unit               NVARCHAR(30)   NOT NULL,
                          standard_quantity  FLOAT          DEFAULT 0,
                          description        NVARCHAR(500),
                          is_active          BIT            DEFAULT 1,
                          created_at         DATETIME       DEFAULT GETDATE()
);
GO

-- ============================================================
-- 4. INVENTORY
-- ============================================================
IF OBJECT_ID(N'dbo.Inventory', N'U') IS NULL
CREATE TABLE Inventory (
                           id            INT IDENTITY(1,1) PRIMARY KEY,
                           store_id      INT     NOT NULL REFERENCES Stores(id),
                           product_id    INT     NOT NULL REFERENCES Products(id),
                           quantity      FLOAT   DEFAULT 0,
                           min_threshold FLOAT   DEFAULT 0,
                           updated_at    DATETIME DEFAULT GETDATE(),
                           UNIQUE (store_id, product_id)
);
GO

-- ============================================================
-- 5. ORDERS
-- ============================================================
IF OBJECT_ID(N'dbo.Orders', N'U') IS NULL
CREATE TABLE Orders (
                        id            INT IDENTITY(1,1) PRIMARY KEY,
                        store_id      INT          NOT NULL REFERENCES Stores(id),
                        created_by    INT          NOT NULL REFERENCES Users(id),
                        order_date    DATETIME     DEFAULT GETDATE(),
                        delivery_date DATETIME,
                        status        VARCHAR(20)  DEFAULT 'PENDING' CHECK (status IN (
                                                                                       'PENDING','CONFIRMED','IN_PRODUCTION',
                                                                                       'READY','DELIVERING','DELIVERED','CANCELLED')),
                        note          NVARCHAR(500),
                        created_at    DATETIME     DEFAULT GETDATE()
);
GO

-- ============================================================
-- 6. ORDER_ITEMS
-- ============================================================
IF OBJECT_ID(N'dbo.OrderItems', N'U') IS NULL
CREATE TABLE OrderItems (
                            id                  INT IDENTITY(1,1) PRIMARY KEY,
                            order_id            INT     NOT NULL REFERENCES Orders(id),
                            product_id          INT     NOT NULL REFERENCES Products(id),
                            quantity_requested  FLOAT   NOT NULL,
                            quantity_delivered  FLOAT   DEFAULT 0,
                            note                NVARCHAR(300)
);
GO

-- ============================================================
-- 7. PRODUCTION_PLANS
-- ============================================================
IF OBJECT_ID(N'dbo.ProductionPlans', N'U') IS NULL
CREATE TABLE ProductionPlans (
                                 id           INT IDENTITY(1,1) PRIMARY KEY,
                                 order_id     INT          NOT NULL REFERENCES Orders(id),
                                 assigned_to  INT          REFERENCES Users(id),
                                 planned_date DATETIME,
                                 status       VARCHAR(20)  DEFAULT 'PENDING' CHECK (status IN (
                                                                                               'PENDING','IN_PROGRESS','COMPLETED','CANCELLED')),
                                 note         NVARCHAR(500),
                                 created_at   DATETIME     DEFAULT GETDATE()
);
GO

-- ============================================================
-- 8. DELIVERIES
-- ============================================================
IF OBJECT_ID(N'dbo.Deliveries', N'U') IS NULL
CREATE TABLE Deliveries (
                            id             INT IDENTITY(1,1) PRIMARY KEY,
                            order_id       INT          NOT NULL REFERENCES Orders(id),
                            coordinator_id INT          REFERENCES Users(id),
                            scheduled_at   DATETIME,
                            actual_at      DATETIME,
                            status         VARCHAR(20)  DEFAULT 'SCHEDULED' CHECK (status IN (
                                                                                              'SCHEDULED','IN_TRANSIT','DELIVERED','FAILED')),
                            note           NVARCHAR(500),
                            created_at     DATETIME     DEFAULT GETDATE()
);
GO

-- ============================================================
-- 9. QUALITY_FEEDBACKS
-- ============================================================
IF OBJECT_ID(N'dbo.QualityFeedbacks', N'U') IS NULL
CREATE TABLE QualityFeedbacks (
                                  id           INT IDENTITY(1,1) PRIMARY KEY,
                                  delivery_id  INT   NOT NULL REFERENCES Deliveries(id),
                                  submitted_by INT   NOT NULL REFERENCES Users(id),
                                  rating       INT   CHECK (rating BETWEEN 1 AND 5),
                                  comment      NVARCHAR(1000),
                                  submitted_at DATETIME DEFAULT GETDATE()
);
GO

-- ============================================================
-- DỮ LIỆU MẪU (chỉ khi bảng còn trống — tránh lỗi khi chạy lại script)
-- ============================================================

IF NOT EXISTS (SELECT 1 FROM dbo.Stores WHERE name = N'Bếp Trung Tâm HQ')
    INSERT INTO Stores (name, address, phone, type) VALUES
        (N'Bếp Trung Tâm HQ', N'123 Nguyễn Huệ, Q1, TP.HCM', '0281234567', 'CENTRAL_KITCHEN');
IF NOT EXISTS (SELECT 1 FROM dbo.Stores WHERE name = N'Chi nhánh Quận 2')
    INSERT INTO Stores (name, address, phone, type) VALUES
        (N'Chi nhánh Quận 2',  N'45 Thảo Điền, Q2, TP.HCM',  '0281234568', 'FRANCHISE_STORE');
IF NOT EXISTS (SELECT 1 FROM dbo.Stores WHERE name = N'Chi nhánh Bình Thạnh')
    INSERT INTO Stores (name, address, phone, type) VALUES
        (N'Chi nhánh Bình Thạnh', N'78 Xô Viết Nghệ Tĩnh, BT', '0281234569', 'FRANCHISE_STORE');
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'admin')
    INSERT INTO Users (username, password_hash, full_name, email, role, store_id)
    VALUES ('admin', '$2a$10$examplehash1', N'Nguyễn Admin', 'admin@ck.vn', 'ADMIN', NULL);
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'manager1')
    INSERT INTO Users (username, password_hash, full_name, email, role, store_id)
    VALUES ('manager1', '$2a$10$examplehash2', N'Trần Manager', 'manager@ck.vn', 'MANAGER', NULL);
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'coord1')
    INSERT INTO Users (username, password_hash, full_name, email, role, store_id)
    VALUES ('coord1', '$2a$10$examplehash3', N'Lê Điều Phối 1', 'coord1@ck.vn', 'SUPPLY_COORDINATOR',
            (SELECT TOP 1 id FROM Stores WHERE type='CENTRAL_KITCHEN' ORDER BY id));
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'coord2')
    INSERT INTO Users (username, password_hash, full_name, email, role, store_id)
    VALUES ('coord2', '$2a$10$examplehash6', N'Hoàng Điều Phối 2', 'coord2@ck.vn', 'SUPPLY_COORDINATOR',
            (SELECT TOP 1 id FROM Stores WHERE type='CENTRAL_KITCHEN' ORDER BY id));
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'kitchen1')
    INSERT INTO Users (username, password_hash, full_name, email, role, store_id)
    VALUES ('kitchen1', '$2a$10$examplehash4', N'Phạm Bếp', 'kitchen@ck.vn', 'KITCHEN_STAFF',
            (SELECT TOP 1 id FROM Stores WHERE type='CENTRAL_KITCHEN' ORDER BY id));
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'kitchen2')
    INSERT INTO Users (username, password_hash, full_name, email, role, store_id)
    VALUES ('kitchen2', '$2a$10$examplehash7', N'Tạ Bếp Trợ', 'kitchen2@ck.vn', 'KITCHEN_STAFF',
            (SELECT TOP 1 id FROM Stores WHERE type='CENTRAL_KITCHEN' ORDER BY id));
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'store_q2')
    INSERT INTO Users (username, password_hash, full_name, email, role, store_id)
    VALUES ('store_q2', '$2a$10$examplehash5', N'Hoàng Cửa Hàng', 'storeq2@ck.vn', 'STORE_STAFF',
            (SELECT TOP 1 id FROM Stores WHERE name = N'Chi nhánh Quận 2' ORDER BY id));
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE username = 'store_bt')
    INSERT INTO Users (username, password_hash, full_name, email, role, store_id)
    VALUES ('store_bt', '$2a$10$examplehash8', N'Vũ Cửa Hàng BT', 'storebt@ck.vn', 'STORE_STAFF',
            (SELECT TOP 1 id FROM Stores WHERE name = N'Chi nhánh Bình Thạnh' ORDER BY id));
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE name = N'Thịt heo xay')
    INSERT INTO Products (name, category, unit, standard_quantity) VALUES (N'Thịt heo xay', N'Thịt', N'kg', 10);
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE name = N'Rau cải xanh')
    INSERT INTO Products (name, category, unit, standard_quantity) VALUES (N'Rau cải xanh', N'Rau củ', N'kg', 5);
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE name = N'Nước tương')
    INSERT INTO Products (name, category, unit, standard_quantity) VALUES (N'Nước tương', N'Gia vị', N'lít', 2);
IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE name = N'Cơm chiên dương châu')
    INSERT INTO Products (name, category, unit, standard_quantity) VALUES (N'Cơm chiên dương châu', N'Thành phẩm', N'phần', 50);
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Inventory)
BEGIN
    INSERT INTO Inventory (store_id, product_id, quantity, min_threshold) VALUES
        (1, 1, 100, 20), (1, 2, 50, 10), (1, 3, 30, 5), (1, 4, 0, 0),
        (2, 1, 5,   10), (2, 2, 3,  5),  (2, 4, 20, 10),
        (3, 1, 8,   10), (3, 4, 15, 10);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Orders)
BEGIN
    INSERT INTO Orders (store_id, created_by, order_date, delivery_date, status, note) VALUES
        (2, 7, GETDATE()-2, GETDATE()+1, 'PENDING', N'Đơn khẩn, cần giao sáng'),
        (2, 7, GETDATE()-1, GETDATE()+2, 'PENDING', N'Đặt hàng định kỳ thứ 2'),
        (3, 8, GETDATE()-3, GETDATE(), 'CONFIRMED', N'Đã xác nhận'),
        (2, 7, GETDATE()-5, DATEADD(day, -1, GETDATE()), 'IN_PRODUCTION', N'Đang sản xuất'),
        (3, 8, GETDATE()-4, DATEADD(day, -2, GETDATE()), 'READY', N'Đã sẵn sàng giao');
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.OrderItems)
BEGIN
    INSERT INTO OrderItems (order_id, product_id, quantity_requested, quantity_delivered) VALUES
        (1, 1, 25, 0),
        (1, 2, 10, 0),
        (1, 4, 100, 0),
        (2, 1, 15, 0),
        (2, 3, 5, 0),
        (2, 4, 50, 0),
        (3, 1, 30, 0),
        (3, 2, 20, 0),
        (3, 4, 150, 0),
        (4, 1, 20, 20),
        (4, 2, 15, 15),
        (5, 1, 25, 25),
        (5, 4, 80, 80);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ProductionPlans)
BEGIN
    INSERT INTO ProductionPlans (order_id, assigned_to, planned_date, status, note) VALUES
        (1, 5, DATEADD(hour, 8, GETDATE()), 'PENDING', N'Chưa bắt đầu'),
        (2, 5, DATEADD(hour, 12, GETDATE()), 'PENDING', N'Chờ xác nhận'),
        (3, 5, DATEADD(hour, 4, GETDATE()), 'COMPLETED', N'Hoàn thành sản xuất'),
        (4, 5, DATEADD(day, -1, GETDATE()), 'COMPLETED', N'Đã hoàn thành'),
        (5, 6, DATEADD(day, -2, GETDATE()), 'COMPLETED', N'Sản xuất xong');
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Deliveries)
BEGIN
    INSERT INTO Deliveries (order_id, coordinator_id, scheduled_at, actual_at, status, note) VALUES
        (3, 3, GETDATE(), NULL, 'SCHEDULED', N'Chờ giao'),
        (4, 3, DATEADD(day, -1, GETDATE()), DATEADD(day, -1, GETDATE()), 'DELIVERED', N'Đã giao thành công'),
        (5, 3, DATEADD(day, -2, GETDATE()), DATEADD(day, -2, GETDATE()), 'DELIVERED', N'Giao thành công');
END
GO
