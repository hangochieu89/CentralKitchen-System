package com.centralkitchen.backend.repository;

import com.centralkitchen.backend.entity.Recipe;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface RecipeRepository extends JpaRepository<Recipe, Integer> {

    // Lay cong thuc cua 1 thanh pham
    @Query(value = "SELECT * FROM Recipes WHERE finished_product_id = :productId", nativeQuery = true)
    List<Recipe> findByFinishedProductId(@Param("productId") Integer productId);
}