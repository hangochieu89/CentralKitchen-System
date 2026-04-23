package com.centralkitchen.backend.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "Recipes")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Recipe {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "finished_product_id", nullable = false)
    private Product finishedProduct;

    @ManyToOne
    @JoinColumn(name = "ingredient_product_id", nullable = false)
    private Product ingredientProduct;

    @Column(name = "quantity_required", nullable = false)
    private Double quantityRequired;
}
