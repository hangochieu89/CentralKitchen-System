package com.centralkitchen.backend.repository;

import com.centralkitchen.backend.entity.ProductionPlan;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface ProductionPlanRepository extends JpaRepository<ProductionPlan, Integer> {

    List<ProductionPlan> findByStatus(String status);

    List<ProductionPlan> findByAssignedTo_Id(Integer userId);

    List<ProductionPlan> findByStatusAndAssignedTo_Id(String status, Integer userId);

    List<ProductionPlan> findByPlannedDateBetween(LocalDateTime startDate, LocalDateTime endDate);

    List<ProductionPlan> findByProduct_Id(Integer productId);
}
