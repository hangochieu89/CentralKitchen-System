package com.centralkitchen.backend.controller;

import com.centralkitchen.backend.dto.OrderRequest;
import com.centralkitchen.backend.dto.OrderSummaryDTO;
import com.centralkitchen.backend.entity.*;
import com.centralkitchen.backend.service.StoreStaffService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/store-staff")
@RequiredArgsConstructor
@CrossOrigin(origins = "*") // Hỗ trợ gọi từ frontend thuần
public class StoreStaffController {

    private final StoreStaffService storeStaffService;

    // Xem tồn kho tại chi nhánh
    @GetMapping("/inventory/{storeId}")
    public ResponseEntity<List<Inventory>> getInventory(@PathVariable Integer storeId) {
        return ResponseEntity.ok(storeStaffService.getMyStoreInventory(storeId));
    }

    // Đặt hàng
    @PostMapping("/orders")
    public ResponseEntity<Order> createOrder(@RequestBody OrderRequest request) {
        return ResponseEntity.ok(storeStaffService.createOrder(request));
    }

    // Danh sách đơn hàng của chi nhánh
    @GetMapping("/orders/{storeId}")
    public ResponseEntity<List<Order>> getOrders(@PathVariable Integer storeId) {
        return ResponseEntity.ok(storeStaffService.getStoreOrders(storeId));
    }

    @GetMapping("/products")
    public ResponseEntity<List<Product>> getProducts() {
        return ResponseEntity.ok(storeStaffService.getAllProducts());
    }

    @GetMapping("/orders/detail/{orderId}")
    public ResponseEntity<OrderSummaryDTO> getOrderDetail(@PathVariable Integer orderId) {
        return ResponseEntity.ok(storeStaffService.getOrderDetails(orderId));
    }

    // Đánh giá chất lượng đơn hàng
    @PostMapping("/feedback")
    public ResponseEntity<QualityFeedback> postFeedback(@RequestBody QualityFeedback feedback) {
        return ResponseEntity.ok(storeStaffService.submitFeedback(feedback));
    }

    @GetMapping("/deliveries/delivered/{storeId}")
    public ResponseEntity<List<Delivery>> getDeliveredByStore(@PathVariable Integer storeId) {
        return ResponseEntity.ok(storeStaffService.getDeliveredDeliveriesByStore(storeId));
    }

    @ExceptionHandler({IllegalArgumentException.class, RuntimeException.class})
    public ResponseEntity<?> handleErrors(RuntimeException ex) {
        return ResponseEntity.badRequest().body(java.util.Map.of(
                "success", false,
                "message", ex.getMessage()
        ));
    }
}