package com.centralkitchen.backend.dto;

import lombok.Data;
import java.time.LocalDateTime;
import java.util.List;

@Data
public class OrderRequest {
    private Integer storeId;
    private Integer userId;
    private LocalDateTime deliveryDate;
    private String note;
    private List<OrderItemRequest> items;

    @Data
    public static class OrderItemRequest {
        private Integer productId;
        private Double quantity;
        private String note;
    }
}