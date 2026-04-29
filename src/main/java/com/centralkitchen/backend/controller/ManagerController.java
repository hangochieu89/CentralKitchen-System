package com.centralkitchen.backend.controller;

import com.centralkitchen.backend.entity.Inventory;
import com.centralkitchen.backend.entity.OrderItem;
import com.centralkitchen.backend.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/manager")
@CrossOrigin(origins = "*")
@RequiredArgsConstructor
public class ManagerController {
    private final OrderRepository orderRepository;
    private final DeliveryRepository deliveryRepository;
    private final InventoryRepository inventoryRepository;
    private final ProductRepository productRepository;
    private final QualityFeedbackRepository qualityFeedbackRepository;
    private final OrderItemRepository orderItemRepository;

    @GetMapping("/overview")
    public ResponseEntity<Map<String, Object>> overview() {
        List<OrderItem> orderItems = orderItemRepository.findAll();
        double requested = orderItems.stream().mapToDouble(i -> i.getQuantityRequested() == null ? 0.0 : i.getQuantityRequested()).sum();
        double delivered = orderItems.stream().mapToDouble(i -> i.getQuantityDelivered() == null ? 0.0 : i.getQuantityDelivered()).sum();
        double fulfillmentRate = requested == 0 ? 0.0 : (delivered / requested) * 100.0;

        return ResponseEntity.ok(Map.of(
                "totalOrders", orderRepository.count(),
                "activeOrders", orderRepository.countActiveOrders(),
                "deliveredOrders", orderRepository.countByStatus("DELIVERED"),
                "failedDeliveries", deliveryRepository.findByStatus("FAILED").size(),
                "overdueDeliveries", deliveryRepository.findByStatusNotInAndScheduledAtBefore(
                        List.of("DELIVERED", "FAILED"),
                        java.time.LocalDateTime.now()
                ).size(),
                "lowStockItems", inventoryRepository.findLowStockItems().size(),
                "totalProducts", productRepository.count(),
                "feedbackCount", qualityFeedbackRepository.count(),
                "fulfillmentRate", Math.round(fulfillmentRate * 100.0) / 100.0
        ));
    }

    @GetMapping("/low-stock")
    public ResponseEntity<List<Inventory>> lowStock() {
        return ResponseEntity.ok(inventoryRepository.findLowStockItems());
    }
}
