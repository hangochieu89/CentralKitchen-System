package com.centralkitchen.backend.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "Users")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(nullable = false, unique = true, length = 50)
    private String username;

    @Column(name = "password_hash", nullable = false)
    private String passwordHash;

    @Column(name = "full_name", nullable = false, length = 100)
    private String fullName;

    @Column(unique = true)
    private String email;

    @Column(nullable = false, length = 30)
    private String role; // ADMIN | MANAGER | SUPPLY_COORDINATOR | KITCHEN_STAFF | STORE_STAFF

    // Quan hệ Many-to-One: nhiều user thuộc 1 store
    // @JsonIgnore nếu cần tránh vòng lặp JSON
    @ManyToOne
    @JoinColumn(name = "store_id")
    private Store store;

    @Column(name = "is_active")
    private Boolean isActive = true;

    @Column(name = "created_at")
    private LocalDateTime createdAt = LocalDateTime.now();
}
