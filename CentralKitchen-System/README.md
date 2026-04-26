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

Mở file:  
src/main/resources/application.properties

Cập nhật:

spring.datasource.username=your_username  
spring.datasource.password=your_password  
spring.datasource.url=jdbc:sqlserver://localhost:1433;databaseName=CentralKitchenDB

3. Chạy ứng dụng

Cách 1: IntelliJ
- Chạy file CentralKitchenSystemApplication.java

Cách 2: Terminal  
mvn spring-boot:run

4. Truy cập API

http://localhost:8080

## Phân công nhóm

| Thành viên     | Vai trò |
|----------------|--------|
| Hà Ngọc Hiếu   | Admin - Quản trị hệ thống & phân quyền |
| Phan Thành An  | Supply Coordinator - Điều phối cung ứng |
| Trần Bảo       | Manager - Quản lý vận hành |
| Đình Phát      | Central Kitchen Staff - Nhân viên bếp trung tâm |
| Lê Khắc Huy    | Franchise Store Staff - Nhân viên cửa hàng |