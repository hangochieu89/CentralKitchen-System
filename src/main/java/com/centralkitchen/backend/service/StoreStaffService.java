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
    private final DeliveryRepository deliveryRepository;
    private final UserRepository userRepository;
    private final StoreRepository storeRepository;

    // 1. Xem tồn kho tại cửa hàng của mình
    public List<Inventory> getMyStoreInventory(Integer storeId) {
        return inventoryRepository.findByStoreId(storeId);
    }

    // 2. Tạo đơn đặt hàng mới gửi lên Bếp Trung Tâm
    @Transactional
    public Order createOrder(OrderRequest request) {
        if (request.getItems() == null || request.getItems().isEmpty()) {
            throw new IllegalArgumentException("Đơn hàng phải có ít nhất 1 sản phẩm");
        }

        Store store = storeRepository.findById(request.getStoreId())
                .orElseThrow(() -> new IllegalArgumentException("Cửa hàng không tồn tại"));
        User createdBy = userRepository.findById(request.getUserId())
                .orElseThrow(() -> new IllegalArgumentException("Người tạo đơn không tồn tại"));
        if (!Boolean.TRUE.equals(store.getIsActive())) {
            throw new IllegalArgumentException("Cửa hàng đang bị vô hiệu");
        }
        if (!Boolean.TRUE.equals(createdBy.getIsActive())) {
            throw new IllegalArgumentException("Người dùng đang bị vô hiệu");
        }
        if (createdBy.getStore() == null || !store.getId().equals(createdBy.getStore().getId())) {
            throw new IllegalArgumentException("Người dùng không thuộc cửa hàng này");
        }

        Order order = Order.builder()
                .store(store)
                .createdBy(createdBy)
                .deliveryDate(request.getDeliveryDate())
                .note(request.getNote())
                .status("PENDING")
                .build();
        
        Order savedOrder = orderRepository.save(order);

        request.getItems().forEach(itemDto -> {
            Product product = productRepository.findById(itemDto.getProductId())
                    .orElseThrow(() -> new RuntimeException("Sản phẩm không tồn tại"));
            if (!Boolean.TRUE.equals(product.getIsActive())) {
                throw new IllegalArgumentException("Sản phẩm '" + product.getName() + "' đang bị vô hiệu");
            }
            if (itemDto.getQuantity() == null || itemDto.getQuantity() <= 0) {
                throw new IllegalArgumentException("Số lượng đặt phải lớn hơn 0");
            }
            
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

    public List<Delivery> getDeliveredDeliveriesByStore(Integer storeId) {
        return deliveryRepository.findByOrderStoreIdAndStatus(storeId, "DELIVERED");
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