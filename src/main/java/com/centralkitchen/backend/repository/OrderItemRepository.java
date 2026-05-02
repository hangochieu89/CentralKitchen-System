package com.centralkitchen.backend.repository;

import com.centralkitchen.backend.entity.OrderItem;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface OrderItemRepository extends JpaRepository<OrderItem, Integer> {

    @EntityGraph(attributePaths = { "product" })
    List<OrderItem> findByOrder_Id(Integer orderId);
}
