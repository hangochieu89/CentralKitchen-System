package com.centralkitchen.backend.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "GoodsReceipts")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class GoodsReceipt {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "kitchen_id", nullable = false)
    private Store kitchen;

    @ManyToOne
    @JoinColumn(name = "supplier_id", nullable = false)
    private Supplier supplier;

    @Column(name = "receipt_date")
    @Builder.Default
    private LocalDateTime receiptDate = LocalDateTime.now();

    @Column(length = 20)
    @Builder.Default
    private String status = "PENDING"; // PENDING, COMPLETED, CANCELLED

    private String note;
}
