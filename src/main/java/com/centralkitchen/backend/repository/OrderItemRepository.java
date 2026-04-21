package com.centralkitchen.backend.repository;

import com.centralkitchen.backend.entity.OrderItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
<<<<<<< HEAD
=======

>>>>>>> 6607cc6 (supply coordination)
import java.util.List;

@Repository
public interface OrderItemRepository extends JpaRepository<OrderItem, Integer> {
    
<<<<<<< HEAD
    // Tìm tất cả các món trong một đơn hàng cụ thể
    List<OrderItem> findByOrderId(Integer orderId);
}
=======
    // Tìm các order items theo order id
    List<OrderItem> findByOrderId(Integer orderId);
}
>>>>>>> 6607cc6 (supply coordination)
