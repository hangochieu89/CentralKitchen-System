package com.centralkitchen.backend.dto;

import com.centralkitchen.backend.entity.Product;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

/** Danh mục đặt hàng từ bếp: nguyên liệu / bán thành phẩm / thành phẩm (theo category). */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class StoreProductCatalogDTO {

    private List<Product> nguyenLieu;
    private List<Product> banThanhPham;
    private List<Product> thanhPham;
    private List<Product> khac;
}
