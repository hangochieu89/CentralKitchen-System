package com.centralkitchen.backend.controller;

import com.centralkitchen.backend.entity.Product;
import com.centralkitchen.backend.entity.Store;
import com.centralkitchen.backend.entity.User;
import com.centralkitchen.backend.repository.ProductRepository;
import com.centralkitchen.backend.repository.StoreRepository;
import com.centralkitchen.backend.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/admin")
@CrossOrigin(origins = "*")
public class AdminController {

    @Autowired private UserRepository userRepository;
    @Autowired private StoreRepository storeRepository;
    @Autowired private ProductRepository productRepository;

    // ==================== THỐNG KÊ ====================
    @GetMapping("/stats")
    public ResponseEntity<?> getStats() {
        return ResponseEntity.ok(Map.of(
                "totalUsers",    userRepository.count(),
                "totalStores",   storeRepository.count(),
                "totalProducts", productRepository.count(),
                "activeUsers",   userRepository.countByIsActive(true)
        ));
    }

    // ==================== USERS ====================
    @GetMapping("/users")
    public List<User> getAllUsers() {
        return userRepository.findAll();
    }

    @PostMapping("/users")
    public ResponseEntity<?> createUser(@RequestBody User user) {
        if (userRepository.existsByUsername(user.getUsername())) {
            return ResponseEntity.badRequest().body(Map.of("error", "Username đã tồn tại"));
        }
        user.setIsActive(true);
        return ResponseEntity.ok(userRepository.save(user));
    }

    @PutMapping("/users/{id}")
    public ResponseEntity<?> updateUser(@PathVariable Integer id, @RequestBody User updated) {
        return userRepository.findById(id).map(user -> {
            user.setFullName(updated.getFullName());
            user.setEmail(updated.getEmail());
            user.setRole(updated.getRole());
            user.setStore(updated.getStore());
            user.setIsActive(updated.getIsActive());
            return ResponseEntity.ok(userRepository.save(user));
        }).orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/users/{id}")
    public ResponseEntity<?> deleteUser(@PathVariable Integer id) {
        return userRepository.findById(id).map(user -> {
            user.setIsActive(false); // soft delete
            userRepository.save(user);
            return ResponseEntity.ok(Map.of("message", "Đã vô hiệu hóa user"));
        }).orElse(ResponseEntity.notFound().build());
    }

    // ==================== STORES ====================
    @GetMapping("/stores")
    public List<Store> getAllStores() {
        return storeRepository.findAll();
    }

    @PostMapping("/stores")
    public ResponseEntity<?> createStore(@RequestBody Store store) {
        store.setIsActive(true);
        return ResponseEntity.ok(storeRepository.save(store));
    }

    @PutMapping("/stores/{id}")
    public ResponseEntity<?> updateStore(@PathVariable Integer id, @RequestBody Store updated) {
        return storeRepository.findById(id).map(store -> {
            store.setName(updated.getName());
            store.setAddress(updated.getAddress());
            store.setPhone(updated.getPhone());
            store.setType(updated.getType());
            store.setIsActive(updated.getIsActive());
            return ResponseEntity.ok(storeRepository.save(store));
        }).orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/stores/{id}")
    public ResponseEntity<?> deleteStore(@PathVariable Integer id) {
        return storeRepository.findById(id).map(store -> {
            store.setIsActive(false);
            storeRepository.save(store);
            return ResponseEntity.ok(Map.of("message", "Đã vô hiệu hóa cửa hàng"));
        }).orElse(ResponseEntity.notFound().build());
    }

    // ==================== PRODUCTS ====================
    @GetMapping("/products")
    public List<Product> getAllProducts() {
        return productRepository.findAll();
    }

    @PostMapping("/products")
    public ResponseEntity<?> createProduct(@RequestBody Product product) {
        product.setIsActive(true);
        return ResponseEntity.ok(productRepository.save(product));
    }

    @PutMapping("/products/{id}")
    public ResponseEntity<?> updateProduct(@PathVariable Integer id, @RequestBody Product updated) {
        return productRepository.findById(id).map(product -> {
            product.setName(updated.getName());
            product.setCategory(updated.getCategory());
            product.setUnit(updated.getUnit());
            product.setStandardQuantity(updated.getStandardQuantity());
            product.setDescription(updated.getDescription());
            product.setIsActive(updated.getIsActive());
            return ResponseEntity.ok(productRepository.save(product));
        }).orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/products/{id}")
    public ResponseEntity<?> deleteProduct(@PathVariable Integer id) {
        return productRepository.findById(id).map(product -> {
            product.setIsActive(false);
            productRepository.save(product);
            return ResponseEntity.ok(Map.of("message", "Đã vô hiệu hóa sản phẩm"));
        }).orElse(ResponseEntity.notFound().build());
    }
}