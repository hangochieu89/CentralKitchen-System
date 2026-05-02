package com.centralkitchen.backend.config;

import com.centralkitchen.backend.entity.Inventory;
import com.centralkitchen.backend.entity.Order;
import com.centralkitchen.backend.entity.OrderItem;
import com.centralkitchen.backend.entity.Product;
import com.centralkitchen.backend.entity.Store;
import com.centralkitchen.backend.entity.User;
import com.centralkitchen.backend.entity.Supplier;
import com.centralkitchen.backend.repository.InventoryRepository;
import com.centralkitchen.backend.repository.OrderItemRepository;
import com.centralkitchen.backend.repository.OrderRepository;
import com.centralkitchen.backend.repository.ProductRepository;
import com.centralkitchen.backend.repository.StoreRepository;
import com.centralkitchen.backend.repository.SupplierRepository;
import com.centralkitchen.backend.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Profile;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

/**
 * H2 local: tạo cửa hàng + tài khoản mẫu lần đầu chạy (mật khẩu mọi user: 123123),
 * và thêm sản phẩm + đơn hàng mẫu để Điều phối / NV bếp có dữ liệu thao tác.
 */
@Component
@Profile("local")
@RequiredArgsConstructor
public class LocalDemoDataSeeder implements CommandLineRunner {

    private final StoreRepository storeRepository;
    private final UserRepository userRepository;
    private final ProductRepository productRepository;
    private final OrderRepository orderRepository;
    private final OrderItemRepository orderItemRepository;
    private final SupplierRepository supplierRepository;
    private final InventoryRepository inventoryRepository;
    private final BCryptPasswordEncoder passwordEncoder;

    @Override
    @Transactional
    public void run(String... args) {
        seedUsersIfAbsent();
        seedDemoCatalogAndOrdersIfAbsent();
    }

    private void seedUsersIfAbsent() {
        if (userRepository.existsByUsername("admin")) {
            return;
        }

        Store central = storeRepository.save(new Store(
                null,
                "Bếp Trung Tâm HQ",
                "123 Nguyễn Huệ, Q1, TP.HCM",
                "0281234567",
                "CENTRAL_KITCHEN",
                true,
                null));
        Store franchise2 = storeRepository.save(new Store(
                null,
                "Chi nhánh Quận 2",
                "45 Thảo Điền, Q2, TP.HCM",
                "0281234568",
                "FRANCHISE_STORE",
                true,
                null));
        Store franchise3 = storeRepository.save(new Store(
                null,
                "Chi nhánh Bình Thạnh",
                "78 Xô Viết Nghệ Tĩnh, BT",
                "0281234569",
                "FRANCHISE_STORE",
                true,
                null));

        String hash = passwordEncoder.encode("123123");

        userRepository.save(user("admin", hash, "Nguyễn Admin", "admin@ck.vn", "ADMIN", null));
        userRepository.save(user("manager1", hash, "Trần Manager", "manager@ck.vn", "MANAGER", null));
        userRepository.save(user("coord1", hash, "Lê Điều Phối 1", "coord1@ck.vn", "SUPPLY_COORDINATOR", central));
        userRepository.save(user("coord2", hash, "Hoàng Điều Phối 2", "coord2@ck.vn", "SUPPLY_COORDINATOR", central));
        userRepository.save(user("kitchen1", hash, "Phạm Bếp", "kitchen@ck.vn", "KITCHEN_STAFF", central));
        userRepository.save(user("kitchen2", hash, "Tạ Bếp Trợ", "kitchen2@ck.vn", "KITCHEN_STAFF", central));
        userRepository.save(user("store_q2", hash, "Hoàng Cửa Hàng", "storeq2@ck.vn", "STORE_STAFF", franchise2));
        userRepository.save(user("store_bt", hash, "Vũ Cửa Hàng BT", "storebt@ck.vn", "STORE_STAFF", franchise3));
    }

    private void seedDemoCatalogAndOrdersIfAbsent() {
        if (productRepository.count() > 0) {
            return;
        }
        User storeUser = userRepository.findByUsername("store_q2").orElse(null);
        if (storeUser == null || storeUser.getStore() == null) {
            return;
        }
        Store store = storeUser.getStore();

        Product p1 = productRepository.save(Product.builder()
                .name("Thịt heo xay")
                .category("Thịt")
                .unit("kg")
                .standardQuantity(10.0)
                .description("Nguyên liệu mẫu")
                .build());
        Product p2 = productRepository.save(Product.builder()
                .name("Rau cải xanh")
                .category("Rau củ")
                .unit("kg")
                .standardQuantity(5.0)
                .build());
        Product p3 = productRepository.save(Product.builder()
                .name("Cơm chiên dương châu")
                .category("Thành phẩm")
                .unit("phần")
                .standardQuantity(50.0)
                .build());
        productRepository.save(Product.builder()
                .name("Nước tương")
                .category("Gia vị")
                .unit("lít")
                .standardQuantity(2.0)
                .build());
        productRepository.save(Product.builder()
                .name("Nem chua (chưa rán)")
                .category("Bán thành phẩm")
                .unit("cái")
                .standardQuantity(120.0)
                .description("BTP từ bếp trung tâm — demo danh mục đặt hàng")
                .build());

        if (supplierRepository.count() == 0) {
            supplierRepository.save(Supplier.builder()
                    .name("NCC Thực phẩm ABC")
                    .address("KCN Tân Bình")
                    .phone("0283999888")
                    .email("contact@abc-food.vn")
                    .build());
        }

        Order o1 = orderRepository.save(Order.builder()
                .store(store)
                .createdBy(storeUser)
                .orderDate(LocalDateTime.now().minusDays(1))
                .deliveryDate(LocalDateTime.now().plusDays(1))
                .status("PENDING")
                .note("Đơn mẫu — cần xác nhận (Q2)")
                .build());
        orderItemRepository.save(OrderItem.builder()
                .order(o1)
                .product(p1)
                .quantityRequested(25.0)
                .quantityDelivered(0.0)
                .build());
        orderItemRepository.save(OrderItem.builder()
                .order(o1)
                .product(p3)
                .quantityRequested(40.0)
                .quantityDelivered(0.0)
                .build());

        Order o2 = orderRepository.save(Order.builder()
                .store(store)
                .createdBy(storeUser)
                .orderDate(LocalDateTime.now().minusHours(5))
                .deliveryDate(LocalDateTime.now().plusDays(2))
                .status("CONFIRMED")
                .note("Đơn mẫu — đã xác nhận")
                .build());
        orderItemRepository.save(OrderItem.builder()
                .order(o2)
                .product(p2)
                .quantityRequested(10.0)
                .quantityDelivered(0.0)
                .build());

        // Tồn kho & đơn riêng cho từng cửa hàng franchise (Q2 vs Bình Thạnh)
        Store stQ2 = store;
        if (inventoryRepository.findByStoreId(stQ2.getId()).isEmpty()) {
            inventoryRepository.save(Inventory.builder().store(stQ2).product(p1).quantity(18.0).minThreshold(20.0).build());
            inventoryRepository.save(Inventory.builder().store(stQ2).product(p2).quantity(6.0).minThreshold(8.0).build());
            inventoryRepository.save(Inventory.builder().store(stQ2).product(p3).quantity(30.0).minThreshold(25.0).build());
        }

        User btUser = userRepository.findByUsername("store_bt").orElse(null);
        if (btUser != null && btUser.getStore() != null) {
            Store stBt = storeRepository.findById(btUser.getStore().getId()).orElse(btUser.getStore());
            if (inventoryRepository.findByStoreId(stBt.getId()).isEmpty()) {
                inventoryRepository.save(Inventory.builder().store(stBt).product(p1).quantity(4.0).minThreshold(12.0).build());
                inventoryRepository.save(Inventory.builder().store(stBt).product(p2).quantity(14.0).minThreshold(6.0).build());
                inventoryRepository.save(Inventory.builder().store(stBt).product(p3).quantity(8.0).minThreshold(20.0).build());
            }
            if (orderRepository.findByStoreId(stBt.getId()).isEmpty()) {
                Order oBt = orderRepository.save(Order.builder()
                        .store(stBt)
                        .createdBy(btUser)
                        .orderDate(LocalDateTime.now().minusHours(2))
                        .deliveryDate(LocalDateTime.now().plusDays(3))
                        .status("PENDING")
                        .note("Đơn mẫu — chỉ cửa hàng Bình Thạnh (store_bt)")
                        .build());
                orderItemRepository.save(OrderItem.builder()
                        .order(oBt)
                        .product(p3)
                        .quantityRequested(24.0)
                        .quantityDelivered(0.0)
                        .build());
            }
        }
    }

    private static User user(String username, String passwordHash, String fullName, String email,
                             String role, Store store) {
        User u = new User();
        u.setUsername(username);
        u.setPasswordHash(passwordHash);
        u.setFullName(fullName);
        u.setEmail(email);
        u.setRole(role);
        u.setStore(store);
        u.setIsActive(true);
        return u;
    }
}
