# Central Kitchen & Franchise Store Management System

Hệ thống quản lý Bếp Trung Tâm và Chuỗi Cửa Hàng Franchise.

## Công nghệ sử dụng

- Backend: Java 17, Spring Boot 3.2.5, Spring Data JPA
- Database: Microsoft SQL Server
- Build Tool: Maven
- Frontend: HTML, CSS, JavaScript (thuần)

## Cấu trúc project
```
CentralKitchen-System/
│
├── database/                  # Script tạo database SQL Server
│
├── frontend/
│   ├── kitchen-staff/
│   ├── manager-admin/
│   ├── supply-coordinator/   # Điều phối cung ứng (gọi API /api/supply-coordinator)
│   └── store-staff/
│
└── src/main/java/com/centralkitchen/backend/
├── controller/
├── dto/
├── entity/
├── repository/
└── service/
```
## Hướng dẫn cài đặt

### Yêu cầu

- Java 17 trở lên
- Maven 3.8 trở lên
- SQL Server / SQL Server Express
- IntelliJ IDEA

### Các bước chạy

1. Tạo database
- Mở SQL Server Management Studio (SSMS)
- Chạy file: database/database.sql

2. Cấu hình kết nối

- **Mặc định (H2 in-memory):** không cần SQL Server; `mvn spring-boot:run` hoặc `.\mvnw.cmd spring-boot:run` là chạy được ngay (profile `local`).
- **SQL Server:** chỉnh `spring.datasource.url`, `username`, `password` trong `src/main/resources/application-sqlserver.properties`, rồi chạy với profile `sqlserver`, ví dụ: `.\mvnw.cmd spring-boot:run "-Dspring-boot.run.profiles=sqlserver"`. Tham chiếu thêm `application.properties.example`.

3. Chạy ứng dụng

Với H2: chỉ cần `.\mvnw.cmd spring-boot:run`. Với SQL Server: bật SQL Server, tạo DB (bước 1), rồi chạy với profile `sqlserver` như trên.

IntelliJ: chạy `CentralKitchenSystemApplication.java` (mặc định dùng H2). `mvn test` không yêu cầu SQL Server khi dùng profile mặc định.

4. Truy cập

- API / trang chủ: http://localhost:8080  
- Dashboard (chọn vai trò): http://localhost:8080/dashboard/index.jsp  
- Store Staff: http://localhost:8080/store-staff/index.html  
- Central Kitchen Staff: http://localhost:8080/kitchen-staff/index.jsp  
- **Supply Coordinator:** http://localhost:8080/supply-coordinator/index.html  
- Manager/Admin portal: http://localhost:8080/manager-admin/index.html  

(Giao diện Supply Coordinator gọi API tại `http://localhost:8080`; nếu mở file qua `python -m http.server`, cần backend chạy cổng 8080.)

5. Header xác thực API theo vai trò

- Từ bản này, các endpoint `/api/**` dùng header:
  - `X-User-Id`
  - `X-User-Role`
- Các UI trong `frontend/` đã tự gắn header mặc định theo role demo.
- Khi bảng user còn trống (chưa seed), interceptor cho phép bỏ qua header để tiện thử API nhanh.

## Phân công nhóm

| Thành viên     | Vai trò |
|----------------|--------|
| Hà Ngọc Hiếu   | Admin - Quản trị hệ thống & phân quyền |
| Phan Thành An  | Supply Coordinator - Điều phối cung ứng |
| Trần Bảo       | Manager - Quản lý vận hành |
| Đình Phát      | Central Kitchen Staff - Nhân viên bếp trung tâm |
| Lê Khắc Huy    | Franchise Store Staff - Nhân viên cửa hàng |