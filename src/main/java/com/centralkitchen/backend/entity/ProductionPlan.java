package com.centralkitchen.backend.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;
import java.util.List;

@Entity
@Table(name = "\"ProductionPlans\"", schema = "dbo")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ProductionPlan {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "product_id", nullable = false)
    private Product product;

    @Column(name = "total_quantity", nullable = false)
    private Double totalQuantity;

    @ManyToOne
    @JoinColumn(name = "assigned_to")
    private User assignedTo;

    @Column(name = "planned_date")
    private LocalDateTime plannedDate;

    @Column(length = 20)
    @Builder.Default
    private String status = "PENDING";

    @Column(length = 500)
    private String note;

    @Column(name = "created_at")
    @Builder.Default
    private LocalDateTime createdAt = LocalDateTime.now();

    @Transient
    private List<ProductionPlanOrder> planOrders;
}