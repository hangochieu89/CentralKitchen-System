package com.centralkitchen.backend.repository;

import com.centralkitchen.backend.entity.OrderItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface OrderItemRepository extends JpaRepository<OrderItem, Integer> {

    // Dung nativeQuery = true de bypass Hibernate naming strategy
    // query thang vao bang OrderItems dung ten trong SQL Server
    @Query(value = "SELECT * FROM OrderItems WHERE order_id = :orderId", nativeQuery = true)
    List<OrderItem> findByOrderId(@Param("orderId") Integer orderId);
}