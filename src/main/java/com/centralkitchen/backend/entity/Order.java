package com.centralkitchen.backend.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "Orders", schema = "dbo")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Order {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "store_id", nullable = false)
    private Store store;

    @ManyToOne
    @JoinColumn(name = "created_by", nullable = false)
    private User createdBy;

    @Column(name = "order_date")
    private LocalDateTime orderDate = LocalDateTime.now();

    @Column(name = "delivery_date")
    private LocalDateTime deliveryDate;

    @Column(length = 20)
    private String status = "PENDING";
    // PENDING → CONFIRMED → IN_PRODUCTION → READY → DELIVERING → DELIVERED → CANCELLED

    @Column(length = 500)
    private String note;

    /** Cửa hàng xác nhận đã nhận đủ hàng (sau khi phiếu giao DELIVERED) — mở khóa đánh giá & cộng tồn kho. */
    @Column(name = "store_receipt_confirmed_at")
    private LocalDateTime storeReceiptConfirmedAt;

    @Column(name = "created_at")
    private LocalDateTime createdAt = LocalDateTime.now();

    @OneToMany(mappedBy = "order", fetch = FetchType.LAZY)
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private java.util.List<OrderItem> orderItems;
}