package com.centralkitchen.backend.controller;

import com.centralkitchen.backend.dto.KitchenDispatchRequestDTO;
import com.centralkitchen.backend.dto.KitchenProductionUpdateRequestDTO;
import com.centralkitchen.backend.dto.OrderSummaryDTO;
import com.centralkitchen.backend.service.CentralKitchenStaffService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/kitchen-staff")
@CrossOrigin(origins = "*")
@RequiredArgsConstructor
public class CentralKitchenStaffController {
    private final CentralKitchenStaffService centralKitchenStaffService;

    @GetMapping("/orders/confirmed")
    public ResponseEntity<List<OrderSummaryDTO>> getConfirmedOrders() {
        return ResponseEntity.ok(centralKitchenStaffService.getConfirmedOrders());
    }

    @GetMapping("/orders/in-production")
    public ResponseEntity<List<OrderSummaryDTO>> getInProductionOrders() {
        return ResponseEntity.ok(centralKitchenStaffService.getInProductionOrders());
    }

    @GetMapping("/orders/ready")
    public ResponseEntity<List<OrderSummaryDTO>> getReadyOrders() {
        return ResponseEntity.ok(centralKitchenStaffService.getReadyOrders());
    }

    @PutMapping("/orders/production-status")
    public ResponseEntity<OrderSummaryDTO> updateProductionStatus(@Valid @RequestBody KitchenProductionUpdateRequestDTO request) {
        return ResponseEntity.ok(centralKitchenStaffService.updateProductionStatus(request));
    }

    @PutMapping("/orders/dispatch")
    public ResponseEntity<OrderSummaryDTO> dispatchOrder(@Valid @RequestBody KitchenDispatchRequestDTO request) {
        return ResponseEntity.ok(centralKitchenStaffService.markOrderAsDelivering(request));
    }

    @ExceptionHandler({IllegalArgumentException.class, IllegalStateException.class})
    public ResponseEntity<Map<String, Object>> handleBusinessErrors(RuntimeException ex) {
        return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "message", ex.getMessage()
        ));
    }
}
