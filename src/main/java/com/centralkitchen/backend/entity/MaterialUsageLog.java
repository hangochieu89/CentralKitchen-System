package com.centralkitchen.backend.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "MaterialUsageLogs", schema = "dbo")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MaterialUsageLog {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "production_plan_id", nullable = false)
    private ProductionPlan productionPlan;

    @ManyToOne
    @JoinColumn(name = "product_batch_id", nullable = false)
    private ProductBatch productBatch;

    @Column(name = "quantity_used", nullable = false)
    private Double quantityUsed;

    @Column(name = "used_at")
    @Builder.Default
    private LocalDateTime usedAt = LocalDateTime.now();

    @ManyToOne
    @JoinColumn(name = "used_by")
    private User usedBy;
}
