package com.centralkitchen.backend.repository;

import com.centralkitchen.backend.entity.ProductionPlan;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface ProductionPlanRepository extends JpaRepository<ProductionPlan, Integer> {
    
    // Tìm các production plan theo order id
    List<ProductionPlan> findByOrderId(Integer orderId);
    
    // Tìm các production plan theo status
    List<ProductionPlan> findByStatus(String status);
    
    // Tìm các production plan theo assigned user
    List<ProductionPlan> findByAssignedToId(Integer userId);
    
    // Tìm các production plan theo status và assigned user
    List<ProductionPlan> findByStatusAndAssignedToId(String status, Integer userId);
    
    // Tìm các production plan theo planned date range
    List<ProductionPlan> findByPlannedDateBetween(LocalDateTime startDate, LocalDateTime endDate);
}
