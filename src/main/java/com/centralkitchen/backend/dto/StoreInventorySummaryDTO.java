package com.centralkitchen.backend.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class StoreInventorySummaryDTO {

    private int trackedSkuCount;
    private int lowStockCount;
    private double totalQuantity;
    /** Tối đa vài dòng cảnh báo để hiển thị trên dashboard */
    private List<LowStockLine> lowStockLines;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class LowStockLine {
        private Integer productId;
        private String productName;
        private Double quantity;
        private Double minThreshold;
    }
}
