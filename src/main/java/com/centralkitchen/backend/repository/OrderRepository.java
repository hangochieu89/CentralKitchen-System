package com.centralkitchen.backend.repository;

import com.centralkitchen.backend.entity.Order;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface OrderRepository extends JpaRepository<Order, Integer> {

    // Tất cả đơn của 1 cửa hàng
    List<Order> findByStoreId(Integer storeId);

    // Đơn theo trạng thái
    List<Order> findByStatus(String status);
    List<Order> findByStatusIn(List<String> statuses);

    // Đơn của 1 cửa hàng theo trạng thái
    List<Order> findByStoreIdAndStatus(Integer storeId, String status);

    // Đơn theo khoảng thời gian
    List<Order> findByOrderDateBetween(LocalDateTime startDate, LocalDateTime endDate);

    // Đếm đơn đang xử lý toàn chuỗi (dùng cho dashboard Manager)
    @Query("SELECT COUNT(o) FROM Order o WHERE o.status NOT IN ('DELIVERED','CANCELLED')")
    Long countActiveOrders();

    long countByStatus(String status);
}