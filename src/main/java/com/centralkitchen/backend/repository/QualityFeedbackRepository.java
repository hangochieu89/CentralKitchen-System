package com.centralkitchen.backend.repository;

import com.centralkitchen.backend.entity.QualityFeedback;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface QualityFeedbackRepository extends JpaRepository<QualityFeedback, Integer> {
    
    // Tìm các phản hồi theo ID của đợt giao hàng
    List<QualityFeedback> findByDeliveryId(Integer deliveryId);

    // Tìm các phản hồi được gửi bởi một nhân viên cụ thể
    List<QualityFeedback> findBySubmittedById(Integer userId);
}