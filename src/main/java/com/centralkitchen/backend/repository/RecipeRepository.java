package com.centralkitchen.backend.repository;

import com.centralkitchen.backend.entity.Recipe;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface RecipeRepository extends JpaRepository<Recipe, Integer> {

    List<Recipe> findByFinishedProduct_Id(Integer productId);
}
