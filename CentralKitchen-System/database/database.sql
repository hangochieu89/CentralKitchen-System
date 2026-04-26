-- ============================================================
-- HỆ THỐNG QUẢN LÝ BẾP TRUNG TÂM & FRANCHISE
-- Database: SQL Server
-- ============================================================

CREATE DATABASE CentralKitchenDB;
GO
USE CentralKitchenDB;
GO

-- ============================================================
-- 1. STORES - Danh sách cửa hàng & bếp trung tâm
--    Mỗi "cửa hàng" là 1 chi nhánh franchise hoặc chính bếp
-- ============================================================
CREATE TABLE Stores (
                        id          INT IDENTITY(1,1) PRIMARY KEY,
                        name        NVARCHAR(100)   NOT NULL,
                        address     NVARCHAR(255),
                        phone       VARCHAR(20),
    -- 'CENTRAL_KITCHEN' hoặc 'FRANCHISE_STORE'
                        type        VARCHAR(30)     NOT NULL CHECK (type IN ('CENTRAL_KITCHEN','FRANCHISE_STORE')),
                        is_active   BIT             DEFAULT 1,
                        created_at  DATETIME        DEFAULT GETDATE()
);

-- ============================================================
-- 2. USERS - Người dùng hệ thống (5 vai trò)
-- ============================================================
CREATE TABLE Users (
                       id            INT IDENTITY(1,1) PRIMARY KEY,
                       username      VARCHAR(50)    NOT NULL UNIQUE,
                       password_hash VARCHAR(255)   NOT NULL,          -- lưu BCrypt hash
                       full_name     NVARCHAR(100)  NOT NULL,
                       email         VARCHAR(100)   UNIQUE,
    -- Vai trò: ADMIN | MANAGER | SUPPLY_COORDINATOR | KITCHEN_STAFF | STORE_STAFF
                       role          VARCHAR(30)    NOT NULL CHECK (role IN (
                                                                             'ADMIN','MANAGER','SUPPLY_COORDINATOR',
                                                                             'KITCHEN_STAFF','STORE_STAFF')),
                       store_id      INT            REFERENCES Stores(id),  -- NULL nếu là ADMIN/MANAGER toàn chuỗi
                       is_active     BIT            DEFAULT 1,
                       created_at    DATETIME       DEFAULT GETDATE()
);

-- ============================================================
-- 3. PRODUCTS - Danh mục sản phẩm / nguyên liệu
-- ============================================================
CREATE TABLE Products (
                          id                 INT IDENTITY(1,1) PRIMARY KEY,
                          name               NVARCHAR(150)  NOT NULL,
                          category           NVARCHAR(100),               -- VD: Rau củ, Thịt, Thành phẩm...
                          unit               NVARCHAR(30)   NOT NULL,      -- kg, lít, hộp, phần...
                          standard_quantity  FLOAT          DEFAULT 0,     -- định mức chuẩn mỗi lần đặt
                          description        NVARCHAR(500),
                          is_active          BIT            DEFAULT 1,
                          created_at         DATETIME       DEFAULT GETDATE()
);

-- ============================================================
-- 4. INVENTORY - Tồn kho theo từng cửa hàng / bếp
-- ============================================================
CREATE TABLE Inventory (
                           id            INT IDENTITY(1,1) PRIMARY KEY,
                           store_id      INT     NOT NULL REFERENCES Stores(id),
                           product_id    INT     NOT NULL REFERENCES Products(id),
                           quantity      FLOAT   DEFAULT 0,
                           min_threshold FLOAT   DEFAULT 0,    -- ngưỡng cảnh báo thiếu hàng
                           updated_at    DATETIME DEFAULT GETDATE(),
                           UNIQUE (store_id, product_id)       -- mỗi sản phẩm chỉ có 1 dòng tồn kho / cửa hàng
);

-- ============================================================
-- 5. ORDERS - Đơn đặt hàng từ cửa hàng gửi lên bếp
-- ============================================================
CREATE TABLE Orders (
                        id            INT IDENTITY(1,1) PRIMARY KEY,
                        store_id      INT          NOT NULL REFERENCES Stores(id),
                        created_by    INT          NOT NULL REFERENCES Users(id),
                        order_date    DATETIME     DEFAULT GETDATE(),
                        delivery_date DATETIME,              -- ngày cửa hàng muốn nhận
    -- Trạng thái: PENDING → CONFIRMED → IN_PRODUCTION → READY → DELIVERING → DELIVERED → CANCELLED
                        status        VARCHAR(20)  DEFAULT 'PENDING' CHECK (status IN (
                                                                                       'PENDING','CONFIRMED','IN_PRODUCTION',
                                                                                       'READY','DELIVERING','DELIVERED','CANCELLED')),
                        note          NVARCHAR(500),
                        created_at    DATETIME     DEFAULT GETDATE()
);

-- ============================================================
-- 6. ORDER_ITEMS - Chi tiết từng sản phẩm trong đơn
-- ============================================================
CREATE TABLE OrderItems (
                            id                  INT IDENTITY(1,1) PRIMARY KEY,
                            order_id            INT     NOT NULL REFERENCES Orders(id),
                            product_id          INT     NOT NULL REFERENCES Products(id),
                            quantity_requested  FLOAT   NOT NULL,   -- số lượng cửa hàng đặt
                            quantity_delivered  FLOAT   DEFAULT 0,  -- số lượng thực tế giao (có thể khác)
                            note                NVARCHAR(300)
);

-- ============================================================
-- 7. PRODUCTION_PLANS - Kế hoạch sản xuất của bếp
-- ============================================================
CREATE TABLE ProductionPlans (
                                 id           INT IDENTITY(1,1) PRIMARY KEY,
                                 order_id     INT          NOT NULL REFERENCES Orders(id),
                                 assigned_to  INT          REFERENCES Users(id),    -- nhân viên bếp phụ trách
                                 planned_date DATETIME,
    -- Trạng thái: PENDING → IN_PROGRESS → COMPLETED → CANCELLED
                                 status       VARCHAR(20)  DEFAULT 'PENDING' CHECK (status IN (
                                                                                               'PENDING','IN_PROGRESS','COMPLETED','CANCELLED')),
                                 note         NVARCHAR(500),
                                 created_at   DATETIME     DEFAULT GETDATE()
);

-- ============================================================
-- 8. DELIVERIES - Giao hàng từ bếp đến cửa hàng
-- ============================================================
CREATE TABLE Deliveries (
                            id             INT IDENTITY(1,1) PRIMARY KEY,
                            order_id       INT          NOT NULL REFERENCES Orders(id),
                            coordinator_id INT          REFERENCES Users(id),  -- Supply Coordinator phụ trách
                            scheduled_at   DATETIME,                           -- dự kiến giao
                            actual_at      DATETIME,                           -- thực tế giao
    -- Trạng thái: SCHEDULED → IN_TRANSIT → DELIVERED → FAILED
                            status         VARCHAR(20)  DEFAULT 'SCHEDULED' CHECK (status IN (
                                                                                              'SCHEDULED','IN_TRANSIT','DELIVERED','FAILED')),
                            note           NVARCHAR(500),
                            created_at     DATETIME     DEFAULT GETDATE()
);

-- ============================================================
-- 9. QUALITY_FEEDBACKS - Phản hồi chất lượng sau nhận hàng
-- ============================================================
CREATE TABLE QualityFeedbacks (
                                  id           INT IDENTITY(1,1) PRIMARY KEY,
                                  delivery_id  INT   NOT NULL REFERENCES Deliveries(id),
                                  submitted_by INT   NOT NULL REFERENCES Users(id),  -- nhân viên cửa hàng đánh giá
                                  rating       INT   CHECK (rating BETWEEN 1 AND 5),
                                  comment      NVARCHAR(1000),
                                  submitted_at DATETIME DEFAULT GETDATE()
);

-- ============================================================
-- DỮ LIỆU MẪU (Sample Data) - để test giao diện
-- ============================================================

-- Cửa hàng
INSERT INTO Stores (name, address, phone, type) VALUES
                                                    (N'Bếp Trung Tâm HQ', N'123 Nguyễn Huệ, Q1, TP.HCM', '0281234567', 'CENTRAL_KITCHEN'),
                                                    (N'Chi nhánh Quận 2',  N'45 Thảo Điền, Q2, TP.HCM',  '0281234568', 'FRANCHISE_STORE'),
                                                    (N'Chi nhánh Bình Thạnh', N'78 Xô Viết Nghệ Tĩnh, BT', '0281234569', 'FRANCHISE_STORE');

-- Người dùng (password_hash dưới đây = BCrypt của "password123")
INSERT INTO Users (username, password_hash, full_name, email, role, store_id) VALUES
                                                                                  ('admin',       '$2a$10$examplehash1', N'Nguyễn Admin',    'admin@ck.vn',       'ADMIN',              NULL),
                                                                                  ('manager1',    '$2a$10$examplehash2', N'Trần Manager',    'manager@ck.vn',     'MANAGER',            NULL),
                                                                                  ('coord1',      '$2a$10$examplehash3', N'Lê Điều Phối 1',   'coord1@ck.vn',       'SUPPLY_COORDINATOR', 1),
                                                                                  ('coord2',      '$2a$10$examplehash6', N'Hoàng Điều Phối 2',   'coord2@ck.vn',       'SUPPLY_COORDINATOR', 1),
                                                                                  ('kitchen1',    '$2a$10$examplehash4', N'Phạm Bếp',       'kitchen@ck.vn',     'KITCHEN_STAFF',      1),
                                                                                  ('kitchen2',    '$2a$10$examplehash7', N'Tạ Bếp Trợ',     'kitchen2@ck.vn',    'KITCHEN_STAFF',      1),
                                                                                  ('store_q2',    '$2a$10$examplehash5', N'Hoàng Cửa Hàng', 'storeq2@ck.vn',    'STORE_STAFF',        2),
                                                                                  ('store_bt',    '$2a$10$examplehash8', N'Vũ Cửa Hàng BT',  'storebt@ck.vn',    'STORE_STAFF',        3);

-- Sản phẩm
INSERT INTO Products (name, category, unit, standard_quantity) VALUES
                                                                   (N'Thịt heo xay',     N'Thịt',      N'kg',   10),
                                                                   (N'Rau cải xanh',     N'Rau củ',    N'kg',   5),
                                                                   (N'Nước tương',       N'Gia vị',    N'lít',  2),
                                                                   (N'Cơm chiên dương châu', N'Thành phẩm', N'phần', 50);

-- Tồn kho ban đầu
INSERT INTO Inventory (store_id, product_id, quantity, min_threshold) VALUES
                                                                          (1, 1, 100, 20), (1, 2, 50, 10), (1, 3, 30, 5), (1, 4, 0, 0),
                                                                          (2, 1, 5,   10), (2, 2, 3,  5),  (2, 4, 20, 10),
                                                                          (3, 1, 8,   10), (3, 4, 15, 10);

-- ============================================================
-- DỮ LIỆU MẫU SUPPLY COORDINATOR (Testing Data)
-- ============================================================

-- Đơn hàng từ các cửa hàng franchise
INSERT INTO Orders (store_id, created_by, order_date, delivery_date, status, note) VALUES
                                                                                       (2, 7, GETDATE()-2, GETDATE()+1, 'PENDING', N'Đơn khẩn, cần giao sáng'),
                                                                                       (2, 7, GETDATE()-1, GETDATE()+2, 'PENDING', N'Đặt hàng định kỳ thứ 2'),
                                                                                       (3, 8, GETDATE()-3, GETDATE(), 'CONFIRMED', N'Đã xác nhận'),
                                                                                       (2, 7, GETDATE()-5, DATEADD(day, -1, GETDATE()), 'IN_PRODUCTION', N'Đang sản xuất'),
                                                                                       (3, 8, GETDATE()-4, DATEADD(day, -2, GETDATE()), 'READY', N'Đã sẵn sàng giao');

-- Chi tiết đơn hàng (Order Items)
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

-- Kế hoạch sản xuất
INSERT INTO ProductionPlans (order_id, assigned_to, planned_date, status, note) VALUES
                                                                                    (1, 5, DATEADD(hour, 8, GETDATE()), 'PENDING', N'Chưa bắt đầu'),
                                                                                    (2, 5, DATEADD(hour, 12, GETDATE()), 'PENDING', N'Chờ xác nhận'),
                                                                                    (3, 5, DATEADD(hour, 4, GETDATE()), 'COMPLETED', N'Hoàn thành sản xuất'),
                                                                                    (4, 5, DATEADD(day, -1, GETDATE()), 'COMPLETED', N'Đã hoàn thành'),
                                                                                    (5, 6, DATEADD(day, -2, GETDATE()), 'COMPLETED', N'Sản xuất xong');

-- Giao hàng (Deliveries)
INSERT INTO Deliveries (order_id, coordinator_id, scheduled_at, actual_at, status, note) VALUES
                                                                                             (3, 3, GETDATE(), NULL, 'SCHEDULED', N'Chờ giao'),
                                                                                             (4, 3, DATEADD(day, -1, GETDATE()), DATEADD(day, -1, GETDATE()), 'DELIVERED', N'Đã giao thành công'),
                                                                                             (5, 3, DATEADD(day, -2, GETDATE()), DATEADD(day, -2, GETDATE()), 'DELIVERED', N'Giao thành công');