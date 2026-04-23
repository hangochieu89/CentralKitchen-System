package com.centralkitchen.backend.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDate;

@Entity
@Table(name = "GoodsReceiptDetails")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class GoodsReceiptDetail {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "receipt_id", nullable = false)
    private GoodsReceipt goodsReceipt;

    @ManyToOne
    @JoinColumn(name = "product_id", nullable = false)
    private Product product;

    @Column(name = "batch_number", length = 50)
    private String batchNumber;

    @Column(name = "expiration_date", nullable = false)
    private LocalDate expirationDate;

    @Column(nullable = false)
    private Double quantity;

    @Column(name = "unit_price")
    private Double unitPrice;
}
