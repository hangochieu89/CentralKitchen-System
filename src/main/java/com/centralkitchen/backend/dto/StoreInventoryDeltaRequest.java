package com.centralkitchen.backend.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class StoreInventoryDeltaRequest {

    @NotNull
    private Integer productId;

    /** Dương: nhập thêm / điều chỉnh tăng; âm: hao hụt, hủy, xuất nội bộ… */
    @NotNull
    private Double delta;

    private String note;
}
