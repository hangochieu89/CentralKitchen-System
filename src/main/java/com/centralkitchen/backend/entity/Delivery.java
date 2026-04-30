package com.centralkitchen.backend.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "Deliveries", schema = "dbo")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Delivery {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "order_id", nullable = false)
    private Order order;

    @ManyToOne
    @JoinColumn(name = "coordinator_id")
    private User coordinator;

    @Column(name = "scheduled_at")
    private LocalDateTime scheduledAt;

    @Column(name = "actual_at")
    private LocalDateTime actualAt;

    @Column(length = 20)
    private String status = "SCHEDULED";
    // SCHEDULED → IN_TRANSIT → DELIVERED → FAILED

    @Column(length = 500)
    private String note;

    @Column(name = "created_at")
    private LocalDateTime createdAt = LocalDateTime.now();
}