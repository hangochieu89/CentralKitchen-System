package com.centralkitchen.backend.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class KitchenDispatchRequestDTO {
    @NotNull
    private Integer orderId;

    private String note;
}
