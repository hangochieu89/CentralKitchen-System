package com.centralkitchen.backend.service;

import com.centralkitchen.backend.dto.*;
import com.centralkitchen.backend.entity.*;
import com.centralkitchen.backend.repository.*;
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
public class SupplyCoordinatorService {

    private final OrderRepository orderRepository;
    private final OrderItemRepository orderItemRepository;
    private final DeliveryRepository deliveryRepository;
    private final ProductionPlanRepository productionPlanRepository;
    private final UserRepository userRepository;
    private final ProductRepository productRepository;
    private final InventoryRepository inventoryRepository;
    private final StoreRepository storeRepository;
    
    /**
     * Tổng hợp tất cả đơn hàng đang chờ xử lý
     * (Aggregate all pending orders from franchise stores)
     */
    public List<OrderSummaryDTO> getAllPendingOrders() {
        List<Order> pendingOrders = orderRepository.findByStatus("PENDING");
        return pendingOrders.stream()
                .map(this::convertOrderToDTO)
                .collect(Collectors.toList());
    }
    
    /**
     * Tổng hợp đơn hàng theo khoảng thời gian
     * (Get orders by date range)
     */
    public List<OrderSummaryDTO> getOrdersByDateRange(LocalDateTime startDate, LocalDateTime endDate) {
        List<Order> orders = orderRepository.findByOrderDateBetween(startDate, endDate);
        return orders.stream()
                .map(this::convertOrderToDTO)
                .collect(Collectors.toList());
    }
    
    /**
     * Tổng hợp đơn hàng theo trạng thái
     * (Get orders by status)
     */
    public List<OrderSummaryDTO> getOrdersByStatus(String status) {
        List<Order> orders = orderRepository.findByStatus(status);
        return orders.stream()
                .map(this::convertOrderToDTO)
                .collect(Collectors.toList());
    }
    
    /**
     * Phân loại đơn hàng theo cửa hàng
     * (Classify orders by store)
     */
    public List<OrderSummaryDTO> getOrdersByStore(Integer storeId) {
        List<Order> orders = orderRepository.findByStoreId(storeId);
        return orders.stream()
                .map(this::convertOrderToDTO)
                .collect(Collectors.toList());
    }
    
    /**
     * Xác nhận đơn hàng và chuyển sang trạng thái CONFIRMED
     * (Confirm orders)
     */
    public OrderSummaryDTO confirmOrder(Integer orderId) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new IllegalArgumentException("Đơn hàng không tồn tại"));
        
        if (!order.getStatus().equals("PENDING")) {
            throw new IllegalStateException("Chỉ các đơn ở trạng thái PENDING mới có thể được xác nhận");
        }
        
        order.setStatus("CONFIRMED");
        Order savedOrder = orderRepository.save(order);

        boolean hasPlan = !productionPlanRepository.findByOrderId(savedOrder.getId()).isEmpty();
        if (!hasPlan) {
            productionPlanRepository.save(ProductionPlan.builder()
                    .order(savedOrder)
                    .status("PENDING")
                    .plannedDate(savedOrder.getDeliveryDate() != null ? savedOrder.getDeliveryDate() : LocalDateTime.now())
                    .note("Auto tạo khi xác nhận đơn")
                    .build());
        }
        return convertOrderToDTO(savedOrder);
    }
    
    /**
     * Lập lịch giao hàng
     * (Schedule delivery)
     */
    public DeliveryDTO scheduleDelivery(DeliveryScheduleRequestDTO request) {
        Order order = orderRepository.findById(request.getOrderId())
                .orElseThrow(() -> new IllegalArgumentException("Đơn hàng không tồn tại"));

        if (!List.of("READY", "DELIVERING").contains(order.getStatus())) {
            throw new IllegalStateException("Chỉ đơn READY hoặc DELIVERING mới có thể lập lịch giao");
        }
        
        User coordinator = userRepository.findById(request.getCoordinatorId())
                .orElseThrow(() -> new IllegalArgumentException("Điều phối viên không tồn tại"));
        
        if (!coordinator.getRole().equals("SUPPLY_COORDINATOR")) {
            throw new IllegalArgumentException("Người dùng phải có vai trò SUPPLY_COORDINATOR");
        }
        
        Delivery delivery = Delivery.builder()
                .order(order)
                .coordinator(coordinator)
                .scheduledAt(request.getScheduledAt())
                .status("SCHEDULED")
                .note(request.getNote())
                .build();
        
        Delivery savedDelivery = deliveryRepository.save(delivery);
        return convertDeliveryToDTO(savedDelivery);
    }
    
    /**
     * Cập nhật trạng thái giao hàng
     * (Update delivery status)
     */
    public DeliveryDTO updateDeliveryStatus(DeliveryUpdateStatusRequestDTO request) {
        Delivery delivery = deliveryRepository.findById(request.getDeliveryId())
                .orElseThrow(() -> new IllegalArgumentException("Phiếu giao hàng không tồn tại"));
        
        List<String> validStatuses = List.of("SCHEDULED", "IN_TRANSIT", "DELIVERED", "FAILED");
        if (!validStatuses.contains(request.getStatus())) {
            throw new IllegalArgumentException("Trạng thái không hợp lệ. Các giá trị hợp lệ: " + validStatuses);
        }
        
        validateDeliveryStatusTransition(delivery.getStatus(), request.getStatus());
        
        delivery.setStatus(request.getStatus());
        if (request.getActualAt() != null) {
            delivery.setActualAt(request.getActualAt());
        }
        if (request.getNote() != null) {
            delivery.setNote(request.getNote());
        }
        
        Delivery savedDelivery = deliveryRepository.save(delivery);
        
        // Đồng bộ trạng thái order theo luồng giao nhận
        if ("IN_TRANSIT".equals(request.getStatus())) {
            Order order = delivery.getOrder();
            order.setStatus("DELIVERING");
            orderRepository.save(order);
        }

        // Nếu giao hàng thành công, cập nhật trạng thái order + tồn kho
        if ("DELIVERED".equals(request.getStatus())) {
            Order order = delivery.getOrder();
            order.setStatus("DELIVERED");
            orderRepository.save(order);
            syncInventoryOnDelivered(order);
        }
        
        return convertDeliveryToDTO(savedDelivery);
    }
    
    /**
     * Lấy danh sách giao hàng của một điều phối viên
     * (Get deliveries for a coordinator)
     */
    public List<DeliveryDTO> getCoordinatorDeliveries(Integer coordinatorId) {
        User coordinator = userRepository.findById(coordinatorId)
                .orElseThrow(() -> new IllegalArgumentException("Điều phối viên không tồn tại"));
        
        List<Delivery> deliveries = deliveryRepository.findByCoordinator(coordinator);
        return deliveries.stream()
                .map(this::convertDeliveryToDTO)
                .collect(Collectors.toList());
    }
    
    /**
     * Lấy danh sách giao hàng theo trạng thái
     * (Get deliveries by status)
     */
    public List<DeliveryDTO> getDeliveriesByStatus(String status) {
        List<Delivery> deliveries = deliveryRepository.findByStatus(status);
        return deliveries.stream()
                .map(this::convertDeliveryToDTO)
                .collect(Collectors.toList());
    }
    
    /**
     * Lấy danh sách giao hàng quá hạn (chưa giao nhưng đã vượt quá thời gian scheduled)
     * (Get overdue deliveries)
     */
    public List<DeliveryDTO> getOverdueDeliveries() {
        LocalDateTime now = LocalDateTime.now();
        List<Delivery> overdueDeliveries = deliveryRepository
                .findByStatusNotInAndScheduledAtBefore(List.of("DELIVERED", "FAILED"), now);
        return overdueDeliveries.stream()
                .map(this::convertDeliveryToDTO)
                .collect(Collectors.toList());
    }
    
    /**
     * Xử lý vấn đề: Hủy đơn hàng
     * (Handle issue: Cancel order)
     */
    public OrderSummaryDTO cancelOrder(Integer orderId, String reason) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new IllegalArgumentException("Đơn hàng không tồn tại"));
        
        if (List.of("DELIVERED", "DELIVERING").contains(order.getStatus())) {
            throw new IllegalStateException("Không thể hủy đơn hàng đã giao hoặc đang vận chuyển");
        }
        
        order.setStatus("CANCELLED");
        if (reason != null && !reason.isEmpty()) {
            order.setNote((order.getNote() != null ? order.getNote() + "\n" : "") + "Lý do hủy: " + reason);
        }
        
        Order savedOrder = orderRepository.save(order);
        
        List<Delivery> deliveries = deliveryRepository.findByOrderId(orderId);
        for (Delivery delivery : deliveries) {
            if (!delivery.getStatus().equals("DELIVERED")) {
                delivery.setStatus("FAILED");
                delivery.setNote((delivery.getNote() != null ? delivery.getNote() + "\n" : "") 
                        + "Đơn hàng bị hủy: " + (reason != null ? reason : "Không rõ lý do"));
                deliveryRepository.save(delivery);
            }
        }
        
        return convertOrderToDTO(savedOrder);
    }
    
    /**
     * Xử lý vấn đề: Đánh dấu giao hàng thất bại
     * (Handle issue: Mark delivery as failed)
     */
    public DeliveryDTO markDeliveryAsFailed(Integer deliveryId, String reason) {
        Delivery delivery = deliveryRepository.findById(deliveryId)
                .orElseThrow(() -> new IllegalArgumentException("Phiếu giao hàng không tồn tại"));
        
        delivery.setStatus("FAILED");
        if (reason != null && !reason.isEmpty()) {
            delivery.setNote((delivery.getNote() != null ? delivery.getNote() + "\n" : "") + "Lý do thất bại: " + reason);
        }
        
        Delivery savedDelivery = deliveryRepository.save(delivery);
        return convertDeliveryToDTO(savedDelivery);
    }
    
    /**
     * Lấy thống kê sản xuất
     * (Get production statistics)
     */
    public List<ProductionPlanDTO> getProductionStats(LocalDateTime startDate, LocalDateTime endDate) {
        List<ProductionPlan> plans = productionPlanRepository.findByPlannedDateBetween(startDate, endDate);
        return plans.stream()
                .map(this::convertProductionPlanToDTO)
                .collect(Collectors.toList());
    }
    
    /**
     * Validate delivery status transition:
     * SCHEDULED → IN_TRANSIT → DELIVERED
     * SCHEDULED/IN_TRANSIT → FAILED
     */
    private void validateDeliveryStatusTransition(String currentStatus, String newStatus) {
        Map<String, List<String>> allowedTransitions = Map.of(
                "SCHEDULED", List.of("IN_TRANSIT", "FAILED"),
                "IN_TRANSIT", List.of("DELIVERED", "FAILED")
        );

        List<String> allowed = allowedTransitions.getOrDefault(currentStatus, List.of());
        if (!allowed.contains(newStatus)) {
            throw new IllegalStateException(
                    "Không thể chuyển trạng thái từ '" + currentStatus + "' sang '" + newStatus 
                    + "'. Các trạng thái hợp lệ: " + allowed);
        }
    }

    /**
     * Helper: Convert Order to OrderSummaryDTO
     */
    public OrderSummaryDTO toOrderSummaryDTO(Order order) {
        List<OrderItem> items = orderItemRepository.findByOrderId(order.getId());
        List<OrderItemDTO> itemDTOs = items.stream()
                .map(item -> OrderItemDTO.builder()
                        .id(item.getId())
                        .productId(item.getProduct().getId())
                        .productName(item.getProduct().getName())
                        .productUnit(item.getProduct().getUnit())
                        .quantity(item.getQuantityRequested())
                        .build())
                .collect(Collectors.toList());
        
        return OrderSummaryDTO.builder()
                .id(order.getId())
                .storeId(order.getStore().getId())
                .storeName(order.getStore().getName())
                .createdByName(order.getCreatedBy().getFullName())
                .orderDate(order.getOrderDate())
                .deliveryDate(order.getDeliveryDate())
                .status(order.getStatus())
                .note(order.getNote())
                .items(itemDTOs)
                .createdAt(order.getCreatedAt())
                .build();
    }

    private OrderSummaryDTO convertOrderToDTO(Order order) {
        return toOrderSummaryDTO(order);
    }

    private void syncInventoryOnDelivered(Order order) {
        Store centralKitchen = storeRepository.findFirstByTypeAndIsActive("CENTRAL_KITCHEN", true)
                .orElseThrow(() -> new IllegalStateException("Không tìm thấy bếp trung tâm đang hoạt động"));

        List<OrderItem> items = orderItemRepository.findByOrderId(order.getId());
        for (OrderItem item : items) {
            double deliveredQty = item.getQuantityDelivered() != null && item.getQuantityDelivered() > 0
                    ? item.getQuantityDelivered()
                    : item.getQuantityRequested();

            Inventory centralInventory = inventoryRepository
                    .findByStoreIdAndProductId(centralKitchen.getId(), item.getProduct().getId())
                    .orElseGet(() -> Inventory.builder()
                            .store(centralKitchen)
                            .product(item.getProduct())
                            .quantity(0.0)
                            .minThreshold(0.0)
                            .updatedAt(LocalDateTime.now())
                            .build());

            centralInventory.setQuantity(Math.max(0.0, centralInventory.getQuantity() - deliveredQty));
            centralInventory.setUpdatedAt(LocalDateTime.now());
            inventoryRepository.save(centralInventory);

            Inventory storeInventory = inventoryRepository
                    .findByStoreIdAndProductId(order.getStore().getId(), item.getProduct().getId())
                    .orElseGet(() -> Inventory.builder()
                            .store(order.getStore())
                            .product(item.getProduct())
                            .quantity(0.0)
                            .minThreshold(0.0)
                            .updatedAt(LocalDateTime.now())
                            .build());

            storeInventory.setQuantity(storeInventory.getQuantity() + deliveredQty);
            storeInventory.setUpdatedAt(LocalDateTime.now());
            inventoryRepository.save(storeInventory);

            item.setQuantityDelivered(deliveredQty);
        }
        orderItemRepository.saveAll(items);
    }
    
    /**
     * Helper: Convert Delivery to DeliveryDTO
     */
    private DeliveryDTO convertDeliveryToDTO(Delivery delivery) {
        return DeliveryDTO.builder()
                .id(delivery.getId())
                .orderId(delivery.getOrder().getId())
                .coordinatorId(delivery.getCoordinator() != null ? delivery.getCoordinator().getId() : null)
                .coordinatorName(delivery.getCoordinator() != null ? delivery.getCoordinator().getFullName() : null)
                .scheduledAt(delivery.getScheduledAt())
                .actualAt(delivery.getActualAt())
                .status(delivery.getStatus())
                .note(delivery.getNote())
                .createdAt(delivery.getCreatedAt())
                .build();
    }

    /**
     * Helper: Convert ProductionPlan to ProductionPlanDTO
     */
    private ProductionPlanDTO convertProductionPlanToDTO(ProductionPlan plan) {
        return ProductionPlanDTO.builder()
                .id(plan.getId())
                .orderId(plan.getOrder().getId())
                .assignedToId(plan.getAssignedTo() != null ? plan.getAssignedTo().getId() : null)
                .assignedToName(plan.getAssignedTo() != null ? plan.getAssignedTo().getFullName() : null)
                .plannedDate(plan.getPlannedDate())
                .status(plan.getStatus())
                .note(plan.getNote())
                .createdAt(plan.getCreatedAt())
                .build();
    }
}
