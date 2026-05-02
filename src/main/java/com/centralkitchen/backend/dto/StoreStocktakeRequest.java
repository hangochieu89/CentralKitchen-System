package com.centralkitchen.backend.dto;

import jakarta.validation.Valid;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.util.List;

@Data
public class StoreStocktakeRequest {

    @NotEmpty
    private List<@Valid StoreStocktakeLineRequest> lines;

    /** Ghi chú kiểm kê (tuỳ chọn) */
    private String note;

    @Data
    public static class StoreStocktakeLineRequest {

        @NotNull
        private Integer productId;

        /** Số lượng thực tế sau kiểm kê (ghi đè tồn hiện tại) */
        @NotNull
        @DecimalMin(value = "0.0", inclusive = true)
        private Double countedQuantity;

        /** Nếu null: giữ nguyên ngưỡng cảnh báo hiện tại */
        private Double minThreshold;
    }
}
