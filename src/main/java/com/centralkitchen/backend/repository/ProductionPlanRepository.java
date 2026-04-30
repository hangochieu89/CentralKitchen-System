package com.centralkitchen.backend.repository;

import com.centralkitchen.backend.entity.ProductionPlan;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface ProductionPlanRepository extends JpaRepository<ProductionPlan, Integer> {

    @Query(value = "SELECT * FROM production_plans", nativeQuery = true)
    List<ProductionPlan> findAll();

    @Query(value = "SELECT * FROM production_plans WHERE status = :status", nativeQuery = true)
    List<ProductionPlan> findByStatus(@Param("status") String status);

    @Query(value = "SELECT * FROM production_plans WHERE assigned_to = :userId", nativeQuery = true)
    List<ProductionPlan> findByAssignedToId(@Param("userId") Integer userId);

    @Query(value = "SELECT * FROM production_plans WHERE status = :status AND assigned_to = :userId", nativeQuery = true)
    List<ProductionPlan> findByStatusAndAssignedToId(@Param("status") String status, @Param("userId") Integer userId);

    @Query(value = "SELECT * FROM production_plans WHERE planned_date BETWEEN :startDate AND :endDate", nativeQuery = true)
    List<ProductionPlan> findByPlannedDateBetween(@Param("startDate") LocalDateTime startDate, @Param("endDate") LocalDateTime endDate);

    @Query(value = "SELECT * FROM production_plans WHERE product_id = :productId", nativeQuery = true)
    List<ProductionPlan> findByProductId(@Param("productId") Integer productId);

    @Query(value = "SELECT * FROM production_plans WHERE id = :id", nativeQuery = true)
    Optional<ProductionPlan> findById(@Param("id") Integer id);
}