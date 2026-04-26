package com.centralkitchen.backend.repository;

import com.centralkitchen.backend.entity.Product;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface ProductRepository extends JpaRepository<Product, Integer> {

    // Tìm theo danh mục: Thịt, Rau củ, Thành phẩm...
    List<Product> findByCategory(String category);

    // Chỉ lấy sản phẩm đang active
    List<Product> findByIsActive(Boolean isActive);

    // Tìm theo tên (không phân biệt hoa thường)
    List<Product> findByNameContainingIgnoreCase(String name);
}