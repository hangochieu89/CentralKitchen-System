package com.centralkitchen.backend.repository;

import com.centralkitchen.backend.entity.Store;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

@Repository
public interface StoreRepository extends JpaRepository<Store, Integer> {

    // Tìm theo loại: CENTRAL_KITCHEN hoặc FRANCHISE_STORE
    List<Store> findByType(String type);

    // Chỉ lấy cửa hàng đang hoạt động
    List<Store> findByIsActive(Boolean isActive);

    Optional<Store> findFirstByTypeAndIsActive(String type, Boolean isActive);
}