package com.centralkitchen.backend.repository;

import com.centralkitchen.backend.entity.ProductionPlanOrder;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ProductionPlanOrderRepository extends JpaRepository<ProductionPlanOrder, Integer> {

    List<ProductionPlanOrder> findByPlan_Id(Integer planId);

    List<ProductionPlanOrder> findByOrder_Id(Integer orderId);
}
