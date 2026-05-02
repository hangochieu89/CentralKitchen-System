package com.centralkitchen.backend.dto;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class StoreOrderListRowDTO {

    private Integer id;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime orderDate;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime deliveryDate;

    /** Trạng thái xử lý đơn tại bếp / điều phối */
    private String status;

    /** Phiếu giao mới nhất (nếu có): SCHEDULED, IN_TRANSIT, DELIVERED, FAILED */
    private String latestDeliveryStatus;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime storeReceiptConfirmedAt;

    private boolean qualityFeedbackSubmitted;
}
