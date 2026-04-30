package com.centralkitchen.backend.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "\"ProductionPlanOrders\"", schema = "dbo")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ProductionPlanOrder {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "plan_id", nullable = false)
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private ProductionPlan plan;

    @ManyToOne
    @JoinColumn(name = "order_id", nullable = false)
    private Order order;

    @Column(nullable = false)
    private Double quantity;
}