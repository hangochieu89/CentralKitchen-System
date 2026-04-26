package com.centralkitchen.backend.repository;

import com.centralkitchen.backend.entity.Delivery;
import com.centralkitchen.backend.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface DeliveryRepository extends JpaRepository<Delivery, Integer> {
    
    // Tìm các delivery theo coordinator
    List<Delivery> findByCoordinator(User coordinator);
    
    // Tìm các delivery theo status
    List<Delivery> findByStatus(String status);
    
    // Tìm các delivery theo coordinator và status
    List<Delivery> findByCoordinatorAndStatus(User coordinator, String status);
    
    // Tìm các delivery theo khoảng thời gian
    List<Delivery> findByScheduledAtBetween(LocalDateTime startDate, LocalDateTime endDate);
    
    // Tìm các delivery theo order id
    List<Delivery> findByOrderId(Integer orderId);
    
    // Tìm các delivery quá hạn: chưa giao/chưa thất bại và đã qua thời gian dự kiến
    List<Delivery> findByStatusNotInAndScheduledAtBefore(List<String> statuses, LocalDateTime dateTime);
}
