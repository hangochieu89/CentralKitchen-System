package com.centralkitchen.backend.dto;

import com.fasterxml.jackson.annotation.JsonFormat;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.NotBlank;
import lombok.*;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DeliveryUpdateStatusRequestDTO {
    
    @NotNull(message = "Delivery ID không được để trống")
    private Integer deliveryId;
    
    @NotBlank(message = "Status không được để trống")
    private String status; // SCHEDULED | IN_TRANSIT | DELIVERED | FAILED
    
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime actualAt;
    
    private String note;
}
