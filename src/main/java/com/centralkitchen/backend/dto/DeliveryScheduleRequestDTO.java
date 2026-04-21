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
public class DeliveryScheduleRequestDTO {
    
    @NotNull(message = "Order ID không được để trống")
    private Integer orderId;
    
    @NotNull(message = "Coordinator ID không được để trống")
    private Integer coordinatorId;
    
    @NotNull(message = "Thời gian giao hàng không được để trống")
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime scheduledAt;
    
    private String note;
}
