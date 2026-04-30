package com.centralkitchen.backend.repository;

import com.centralkitchen.backend.entity.ProductionPlanOrder;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ProductionPlanOrderRepository extends JpaRepository<ProductionPlanOrder, Integer> {

    @Query(value = "SELECT * FROM production_plan_orders WHERE plan_id = :planId", nativeQuery = true)
    List<ProductionPlanOrder> findByPlanId(@Param("planId") Integer planId);

    @Query(value = "SELECT * FROM production_plan_orders WHERE order_id = :orderId", nativeQuery = true)
    List<ProductionPlanOrder> findByOrderId(@Param("orderId") Integer orderId);
}