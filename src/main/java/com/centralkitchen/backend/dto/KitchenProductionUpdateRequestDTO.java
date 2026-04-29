package com.centralkitchen.backend.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class KitchenProductionUpdateRequestDTO {
    @NotNull
    private Integer orderId;

    @NotBlank
    private String status; // IN_PRODUCTION | READY

    private String note;
}
