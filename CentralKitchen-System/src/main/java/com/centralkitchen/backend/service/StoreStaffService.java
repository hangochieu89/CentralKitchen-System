package com.centralkitchen.backend.service;

import com.centralkitchen.backend.dto.OrderItemDTO;
import com.centralkitchen.backend.dto.OrderRequest;
import com.centralkitchen.backend.dto.OrderSummaryDTO;
import com.centralkitchen.backend.entity.*;
import com.centralkitchen.backend.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class StoreStaffService {

    private final InventoryRepository inventoryRepository;
    private final OrderRepository orderRepository;
    private final OrderItemRepository orderItemRepository; 
    private final ProductRepository productRepository;
    private final QualityFeedbackRepository feedbackRepository;

    // 1. Xem tồn kho tại cửa hàng của mình
    public List<Inventory> getMyStoreInventory(Integer storeId) {
        return inventoryRepository.findByStoreId(storeId);
    }

    // 2. Tạo đơn đặt hàng mới gửi lên Bếp Trung Tâm
    @Transactional
    public Order createOrder(OrderRequest request) {
        Order order = Order.builder()
                .store(new Store(request.getStoreId(), null, null, null, null, null, null))
                .createdBy(new User(request.getUserId(), null, null, null, null, null, null, null, null))
                .deliveryDate(request.getDeliveryDate())
                .note(request.getNote())
                .status("PENDING")
                .build();
        
        Order savedOrder = orderRepository.save(order);

        request.getItems().forEach(itemDto -> {
            Product product = productRepository.findById(itemDto.getProductId())
                    .orElseThrow(() -> new RuntimeException("Sản phẩm không tồn tại"));
            
            OrderItem item = OrderItem.builder()
                    .order(savedOrder)
                    .product(product)
                    .quantityRequested(itemDto.getQuantity())
                    .note(itemDto.getNote())
                    .build();
            orderItemRepository.save(item);
        });

        return savedOrder;
    }

    // 3. Theo dõi danh sách đơn hàng của cửa hàng
    public List<Order> getStoreOrders(Integer storeId) {
        return orderRepository.findByStoreId(storeId);
    }

    // 4. Gửi phản hồi chất lượng sau khi nhận hàng
    public QualityFeedback submitFeedback(QualityFeedback feedback) {
        return feedbackRepository.save(feedback);
    }

    // Lấy danh sách tất cả sản phẩm để hiển thị trong form đặt hàng
    public List<Product> getAllProducts() {
        return productRepository.findByIsActive(true);
    }

    // Lấy thông tin chi tiết một đơn hàng (bao gồm các món đã đặt)
    public OrderSummaryDTO getOrderDetails(Integer orderId) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy đơn hàng"));
        
        List<OrderItem> items = orderItemRepository.findByOrderId(orderId);
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
                .storeName(order.getStore().getName())
                .orderDate(order.getOrderDate())
                .status(order.getStatus())
                .items(itemDTOs)
                .build();
    }

    
}