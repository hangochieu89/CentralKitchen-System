package com.centralkitchen.backend.dto;

import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class OrderItemDTO {
    
    private Integer id;
    private Integer productId;
    private String productName;
    private String productUnit;
    private Double quantity;

    /** SL thực giao (nếu điều phối/bếp cập nhật); null coi như chưa khai báo */
    private Double quantityDelivered;
}
