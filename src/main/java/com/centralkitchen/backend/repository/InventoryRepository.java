package com.centralkitchen.backend.repository;

import com.centralkitchen.backend.entity.Inventory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

@Repository
public interface InventoryRepository extends JpaRepository<Inventory, Integer> {

    // Xem tồn kho của 1 cửa hàng
    List<Inventory> findByStoreId(Integer storeId);

    // Tìm 1 dòng tồn kho cụ thể (store + product)
    Optional<Inventory> findByStoreIdAndProductId(Integer storeId, Integer productId);

    // Cảnh báo tồn kho dưới ngưỡng tối thiểu
    @Query("SELECT i FROM Inventory i WHERE i.quantity < i.minThreshold")
    List<Inventory> findLowStockItems();

    // Cảnh báo tồn kho thấp của 1 cửa hàng cụ thể
    @Query("SELECT i FROM Inventory i WHERE i.store.id = :storeId AND i.quantity < i.minThreshold")
    List<Inventory> findLowStockByStore(Integer storeId);

    // Tồn kho theo loại cửa hàng (VD: CENTRAL_KITCHEN)
    List<Inventory> findByStoreType(String type);
}