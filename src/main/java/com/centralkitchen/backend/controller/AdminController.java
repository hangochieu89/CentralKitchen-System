package com.centralkitchen.backend.controller;

import com.centralkitchen.backend.entity.Order;
import com.centralkitchen.backend.entity.Product;
import com.centralkitchen.backend.entity.Store;
import com.centralkitchen.backend.entity.User;
import com.centralkitchen.backend.repository.InventoryRepository;
import com.centralkitchen.backend.repository.OrderRepository;
import com.centralkitchen.backend.repository.ProductRepository;
import com.centralkitchen.backend.repository.StoreRepository;
import com.centralkitchen.backend.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/admin")
@CrossOrigin(origins = "*")
public class AdminController {

    @Autowired private UserRepository userRepository;
    @Autowired private StoreRepository storeRepository;
    @Autowired private ProductRepository productRepository;
    @Autowired private OrderRepository orderRepository;
    @Autowired private InventoryRepository inventoryRepository;

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

    // ==================== DASHBOARD CHARTS ====================

    @GetMapping("/dashboard/orders-by-day")
    public ResponseEntity<?> getOrdersByDay() {
        LocalDateTime sevenDaysAgo = LocalDateTime.now().minusDays(6);
        List<Order> orders = orderRepository.findByOrderDateBetween(sevenDaysAgo, LocalDateTime.now());

        Map<String, Long> result = new java.util.LinkedHashMap<>();
        for (int i = 6; i >= 0; i--) {
            String date = LocalDateTime.now().minusDays(i)
                    .format(java.time.format.DateTimeFormatter.ofPattern("dd/MM"));
            result.put(date, 0L);
        }
        orders.forEach(o -> {
            // ← Thêm null check
            if (o.getOrderDate() != null) {
                String date = o.getOrderDate()
                        .format(java.time.format.DateTimeFormatter.ofPattern("dd/MM"));
                result.merge(date, 1L, Long::sum);
            }
        });
        return ResponseEntity.ok(result);
    }

    @GetMapping("/dashboard/orders-by-status")
    public ResponseEntity<?> getOrdersByStatus() {
        List<Order> all = orderRepository.findAll();

        // Dịch sang tiếng Việt luôn
        Map<String, Long> result = new java.util.LinkedHashMap<>();
        result.put("Chờ duyệt",       0L);
        result.put("Đã xác nhận",     0L);
        result.put("Đang sản xuất",   0L);
        result.put("Sẵn sàng",        0L);
        result.put("Đang giao",       0L);
        result.put("Đã giao",         0L);
        result.put("Đã hủy",          0L);

        Map<String, String> translate = Map.of(
                "PENDING",       "Chờ duyệt",
                "CONFIRMED",     "Đã xác nhận",
                "IN_PRODUCTION", "Đang sản xuất",
                "READY",         "Sẵn sàng",
                "DELIVERING",    "Đang giao",
                "DELIVERED",     "Đã giao",
                "CANCELLED",     "Đã hủy"
        );

        all.forEach(o -> {
            if (o.getStatus() != null) {
                String label = translate.getOrDefault(o.getStatus(), o.getStatus());
                result.merge(label, 1L, Long::sum);
            }
        });
        return ResponseEntity.ok(result);
    }

    @GetMapping("/dashboard/top-stores")
    public ResponseEntity<?> getTopStores() {
        List<Order> all = orderRepository.findAll();
        Map<String, Long> result = new java.util.LinkedHashMap<>();
        all.forEach(o -> {
            // ← Thêm null check ở đây
            if (o.getStore() != null && o.getStore().getName() != null) {
                result.merge(o.getStore().getName(), 1L, Long::sum);
            }
        });
        return ResponseEntity.ok(
                result.entrySet().stream()
                        .sorted(Map.Entry.<String,Long>comparingByValue().reversed())
                        .limit(5)
                        .collect(java.util.stream.Collectors.toMap(
                                Map.Entry::getKey, Map.Entry::getValue,
                                (e1,e2)->e1, java.util.LinkedHashMap::new))
        );
    }

    // ==================== PERMANENT DELETE ====================

    @DeleteMapping("/users/{id}/permanent")
    public ResponseEntity<?> permanentDeleteUser(@PathVariable Integer id) {
        return userRepository.findById(id).map(user -> {
            try {
                userRepository.delete(user);
                userRepository.flush(); // ← force commit ngay, bắt được exception
                return ResponseEntity.ok(Map.of("message", "Đã xóa người dùng"));
            } catch (Exception e) {
                return ResponseEntity.badRequest()
                        .body(Map.of("error", "Không thể xóa: tài khoản đang được liên kết với dữ liệu khác"));
            }
        }).orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/stores/{id}/permanent")
    public ResponseEntity<?> permanentDeleteStore(@PathVariable Integer id) {
        return storeRepository.findById(id).map(store -> {
            try {
                storeRepository.delete(store);
                storeRepository.flush();
                return ResponseEntity.ok(Map.of("message", "Đã xóa cửa hàng"));
            } catch (Exception e) {
                return ResponseEntity.badRequest()
                        .body(Map.of("error", "Không thể xóa: cửa hàng đang có dữ liệu liên quan"));
            }
        }).orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/products/{id}/permanent")
    public ResponseEntity<?> permanentDeleteProduct(@PathVariable Integer id) {
        return productRepository.findById(id).map(product -> {
            try {
                productRepository.delete(product);
                productRepository.flush();
                return ResponseEntity.ok(Map.of("message", "Đã xóa sản phẩm"));
            } catch (Exception e) {
                return ResponseEntity.badRequest()
                        .body(Map.of("error", "Không thể xóa: sản phẩm đang được sử dụng trong đơn hàng"));
            }
        }).orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/dashboard/low-stock")
    public ResponseEntity<?> getLowStock() {
        return ResponseEntity.ok(inventoryRepository.findLowStockItems());
    }
}