package com.centralkitchen.backend.repository;

import com.centralkitchen.backend.entity.OrderItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface OrderItemRepository extends JpaRepository<OrderItem, Integer> {
    
    // Tìm tất cả các món trong một đơn hàng cụ thể
    List<OrderItem> findByOrderId(Integer orderId);
}
