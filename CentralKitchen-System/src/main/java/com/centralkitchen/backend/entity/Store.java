package com.centralkitchen.backend.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "Stores")
@Data                    // Lombok: tự tạo getter/setter/toString
@NoArgsConstructor       // Lombok: tạo constructor rỗng
@AllArgsConstructor      // Lombok: tạo constructor đầy đủ
public class Store {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY) // tự tăng id
    private Integer id;

    @Column(nullable = false, length = 100)
    private String name;

    private String address;
    private String phone;

    @Column(nullable = false, length = 30)
    private String type; // "CENTRAL_KITCHEN" hoặc "FRANCHISE_STORE"

    @Column(name = "is_active")
    private Boolean isActive = true;

    @Column(name = "created_at")
    private LocalDateTime createdAt = LocalDateTime.now();
}