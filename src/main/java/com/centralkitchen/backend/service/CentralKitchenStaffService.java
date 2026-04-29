package com.centralkitchen.backend.service;

import com.centralkitchen.backend.dto.KitchenDispatchRequestDTO;
import com.centralkitchen.backend.dto.KitchenProductionUpdateRequestDTO;
import com.centralkitchen.backend.dto.OrderSummaryDTO;
import com.centralkitchen.backend.entity.Order;
import com.centralkitchen.backend.entity.OrderItem;
import com.centralkitchen.backend.entity.ProductionPlan;
import com.centralkitchen.backend.repository.OrderItemRepository;
import com.centralkitchen.backend.repository.OrderRepository;
import com.centralkitchen.backend.repository.ProductionPlanRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional
public class CentralKitchenStaffService {
    private final OrderRepository orderRepository;
    private final OrderItemRepository orderItemRepository;
    private final ProductionPlanRepository productionPlanRepository;
    private final SupplyCoordinatorService supplyCoordinatorService;

    public List<OrderSummaryDTO> getConfirmedOrders() {
        return orderRepository.findByStatus("CONFIRMED")
                .stream()
                .map(supplyCoordinatorService::toOrderSummaryDTO)
                .collect(Collectors.toList());
    }

    public List<OrderSummaryDTO> getInProductionOrders() {
        return orderRepository.findByStatus("IN_PRODUCTION")
                .stream()
                .map(supplyCoordinatorService::toOrderSummaryDTO)
                .collect(Collectors.toList());
    }

    public List<OrderSummaryDTO> getReadyOrders() {
        return orderRepository.findByStatus("READY")
                .stream()
                .map(supplyCoordinatorService::toOrderSummaryDTO)
                .collect(Collectors.toList());
    }

    public OrderSummaryDTO updateProductionStatus(KitchenProductionUpdateRequestDTO request) {
        Order order = orderRepository.findById(request.getOrderId())
                .orElseThrow(() -> new IllegalArgumentException("Đơn hàng không tồn tại"));

        Map<String, List<String>> transitions = Map.of(
                "CONFIRMED", List.of("IN_PRODUCTION"),
                "IN_PRODUCTION", List.of("READY")
        );

        List<String> allowed = transitions.getOrDefault(order.getStatus(), List.of());
        if (!allowed.contains(request.getStatus())) {
            throw new IllegalStateException("Không thể chuyển từ " + order.getStatus() + " sang " + request.getStatus());
        }

        order.setStatus(request.getStatus());
        if (request.getNote() != null && !request.getNote().isBlank()) {
            String note = order.getNote() == null ? "" : order.getNote() + "\n";
            order.setNote(note + "[Kitchen] " + request.getNote());
        }
        Order saved = orderRepository.save(order);

        ProductionPlan plan = productionPlanRepository.findByOrderId(order.getId())
                .stream()
                .findFirst()
                .orElseGet(() -> ProductionPlan.builder()
                        .order(order)
                        .plannedDate(LocalDateTime.now())
                        .status("PENDING")
                        .build());

        if ("IN_PRODUCTION".equals(request.getStatus())) {
            plan.setStatus("IN_PROGRESS");
            plan.setPlannedDate(plan.getPlannedDate() == null ? LocalDateTime.now() : plan.getPlannedDate());
        } else if ("READY".equals(request.getStatus())) {
            plan.setStatus("COMPLETED");
        }
        if (request.getNote() != null && !request.getNote().isBlank()) {
            plan.setNote(request.getNote());
        }
        productionPlanRepository.save(plan);

        return supplyCoordinatorService.toOrderSummaryDTO(saved);
    }

    public OrderSummaryDTO markOrderAsDelivering(KitchenDispatchRequestDTO request) {
        Order order = orderRepository.findById(request.getOrderId())
                .orElseThrow(() -> new IllegalArgumentException("Đơn hàng không tồn tại"));

        if (!"READY".equals(order.getStatus())) {
            throw new IllegalStateException("Chỉ đơn READY mới có thể xuất giao");
        }

        List<OrderItem> items = orderItemRepository.findByOrderId(order.getId());
        for (OrderItem item : items) {
            if (item.getQuantityDelivered() == null || item.getQuantityDelivered() <= 0) {
                item.setQuantityDelivered(item.getQuantityRequested());
            }
        }
        orderItemRepository.saveAll(items);

        order.setStatus("DELIVERING");
        if (request.getNote() != null && !request.getNote().isBlank()) {
            String note = order.getNote() == null ? "" : order.getNote() + "\n";
            order.setNote(note + "[Dispatch] " + request.getNote());
        }
        return supplyCoordinatorService.toOrderSummaryDTO(orderRepository.save(order));
    }
}
