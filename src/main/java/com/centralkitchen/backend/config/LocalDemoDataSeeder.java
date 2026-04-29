package com.centralkitchen.backend.config;

import com.centralkitchen.backend.entity.*;
import com.centralkitchen.backend.repository.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

/**
 * H2 / profile local: nạp dữ liệu mẫu khi DB trống (khớp database/database.sql và ID mặc định trên UI).
 */
@Component
@Profile("local")
@RequiredArgsConstructor
@Slf4j
public class LocalDemoDataSeeder implements ApplicationRunner {

    private static final String DEMO_HASH = "$2a$10$demoLocalHashPlaceholderNotForProd";

    private final StoreRepository storeRepository;
    private final UserRepository userRepository;
    private final ProductRepository productRepository;
    private final InventoryRepository inventoryRepository;
    private final OrderRepository orderRepository;
    private final OrderItemRepository orderItemRepository;
    private final ProductionPlanRepository productionPlanRepository;
    private final DeliveryRepository deliveryRepository;

    @Override
    @Transactional
    public void run(ApplicationArguments args) {
        if (storeRepository.count() > 0) {
            return;
        }
        log.info("Local profile: seeding demo stores, users, products, orders…");

        Store hq = storeRepository.save(store("Bếp Trung Tâm HQ", "123 Nguyễn Huệ, Q1, TP.HCM", "0281234567", "CENTRAL_KITCHEN"));
        Store q2 = storeRepository.save(store("Chi nhánh Quận 2", "45 Thảo Điền, Q2, TP.HCM", "0281234568", "FRANCHISE_STORE"));
        Store bt = storeRepository.save(store("Chi nhánh Bình Thạnh", "78 Xô Viết Nghệ Tĩnh, BT", "0281234569", "FRANCHISE_STORE"));

        User admin = userRepository.save(user("admin", "Nguyễn Admin", "admin@ck.vn", "ADMIN", null));
        userRepository.save(user("manager1", "Trần Manager", "manager@ck.vn", "MANAGER", null));
        User coord1 = userRepository.save(user("coord1", "Lê Điều Phối 1", "coord1@ck.vn", "SUPPLY_COORDINATOR", hq));
        userRepository.save(user("coord2", "Hoàng Điều Phối 2", "coord2@ck.vn", "SUPPLY_COORDINATOR", hq));
        User kitchen1 = userRepository.save(user("kitchen1", "Phạm Bếp", "kitchen@ck.vn", "KITCHEN_STAFF", hq));
        User kitchen2 = userRepository.save(user("kitchen2", "Tạ Bếp Trợ", "kitchen2@ck.vn", "KITCHEN_STAFF", hq));
        User storeQ2 = userRepository.save(user("store_q2", "Hoàng Cửa Hàng", "storeq2@ck.vn", "STORE_STAFF", q2));
        User storeBt = userRepository.save(user("store_bt", "Vũ Cửa Hàng BT", "storebt@ck.vn", "STORE_STAFF", bt));

        Product p1 = productRepository.save(product("Thịt heo xay", "Thịt", "kg", 10.0));
        Product p2 = productRepository.save(product("Rau cải xanh", "Rau củ", "kg", 5.0));
        Product p3 = productRepository.save(product("Nước tương", "Gia vị", "lít", 2.0));
        Product p4 = productRepository.save(product("Cơm chiên dương châu", "Thành phẩm", "phần", 50.0));

        inv(hq, p1, 100, 20);
        inv(hq, p2, 50, 10);
        inv(hq, p3, 30, 5);
        inv(hq, p4, 0, 0);
        inv(q2, p1, 5, 10);
        inv(q2, p2, 3, 5);
        inv(q2, p4, 20, 10);
        inv(bt, p1, 8, 10);
        inv(bt, p4, 15, 10);

        LocalDateTime now = LocalDateTime.now();
        Order o1 = orderRepository.save(makeOrder(q2, storeQ2, now.minusDays(2), now.plusDays(1), "PENDING", "Đơn khẩn, cần giao sáng"));
        Order o2 = orderRepository.save(makeOrder(q2, storeQ2, now.minusDays(1), now.plusDays(2), "PENDING", "Đặt hàng định kỳ thứ 2"));
        Order o3 = orderRepository.save(makeOrder(bt, storeBt, now.minusDays(3), now, "CONFIRMED", "Đã xác nhận"));
        Order o4 = orderRepository.save(makeOrder(q2, storeQ2, now.minusDays(5), now.minusDays(1), "IN_PRODUCTION", "Đang sản xuất"));
        Order o5 = orderRepository.save(makeOrder(bt, storeBt, now.minusDays(4), now.minusDays(2), "READY", "Đã sẵn sàng giao"));

        line(o1, p1, 25, 0);
        line(o1, p2, 10, 0);
        line(o1, p4, 100, 0);
        line(o2, p1, 15, 0);
        line(o2, p3, 5, 0);
        line(o2, p4, 50, 0);
        line(o3, p1, 30, 0);
        line(o3, p2, 20, 0);
        line(o3, p4, 150, 0);
        line(o4, p1, 20, 20);
        line(o4, p2, 15, 15);
        line(o5, p1, 25, 25);
        line(o5, p4, 80, 80);

        productionPlanRepository.save(ProductionPlan.builder().order(o1).assignedTo(kitchen1).plannedDate(now.plusHours(8)).status("PENDING").note("Chưa bắt đầu").build());
        productionPlanRepository.save(ProductionPlan.builder().order(o2).assignedTo(kitchen1).plannedDate(now.plusHours(12)).status("PENDING").note("Chờ xác nhận").build());
        productionPlanRepository.save(ProductionPlan.builder().order(o3).assignedTo(kitchen1).plannedDate(now.plusHours(4)).status("COMPLETED").note("Hoàn thành sản xuất").build());
        productionPlanRepository.save(ProductionPlan.builder().order(o4).assignedTo(kitchen1).plannedDate(now.minusDays(1)).status("COMPLETED").note("Đã hoàn thành").build());
        productionPlanRepository.save(ProductionPlan.builder().order(o5).assignedTo(kitchen2).plannedDate(now.minusDays(2)).status("COMPLETED").note("Sản xuất xong").build());

        deliveryRepository.save(Delivery.builder().order(o3).coordinator(coord1).scheduledAt(now).status("SCHEDULED").note("Chờ giao").build());
        deliveryRepository.save(Delivery.builder().order(o4).coordinator(coord1).scheduledAt(now.minusDays(1)).actualAt(now.minusDays(1)).status("DELIVERED").note("Đã giao thành công").build());
        deliveryRepository.save(Delivery.builder().order(o5).coordinator(coord1).scheduledAt(now.minusDays(2)).actualAt(now.minusDays(2)).status("DELIVERED").note("Giao thành công").build());

        log.info("Demo seed done. Gợi ý: Admin id={}, Store staff Q2 id={}, Coordinator id={}, Kitchen id={}",
                admin.getId(), storeQ2.getId(), coord1.getId(), kitchen1.getId());
    }

    private Store store(String name, String address, String phone, String type) {
        Store s = new Store();
        s.setName(name);
        s.setAddress(address);
        s.setPhone(phone);
        s.setType(type);
        s.setIsActive(true);
        return s;
    }

    private User user(String username, String fullName, String email, String role, Store store) {
        User u = new User();
        u.setUsername(username);
        u.setPasswordHash(DEMO_HASH);
        u.setFullName(fullName);
        u.setEmail(email);
        u.setRole(role);
        u.setStore(store);
        u.setIsActive(true);
        return u;
    }

    private Product product(String name, String category, String unit, double std) {
        Product p = new Product();
        p.setName(name);
        p.setCategory(category);
        p.setUnit(unit);
        p.setStandardQuantity(std);
        p.setDescription(null);
        p.setIsActive(true);
        return p;
    }

    private void inv(Store store, Product product, double qty, double min) {
        inventoryRepository.save(Inventory.builder()
                .store(store)
                .product(product)
                .quantity(qty)
                .minThreshold(min)
                .build());
    }

    private Order makeOrder(Store store, User createdBy, LocalDateTime orderDate, LocalDateTime deliveryDate, String status, String note) {
        Order o = new Order();
        o.setStore(store);
        o.setCreatedBy(createdBy);
        o.setOrderDate(orderDate);
        o.setDeliveryDate(deliveryDate);
        o.setStatus(status);
        o.setNote(note);
        return o;
    }

    private void line(Order order, Product product, double req, double delivered) {
        OrderItem it = new OrderItem();
        it.setOrder(order);
        it.setProduct(product);
        it.setQuantityRequested(req);
        it.setQuantityDelivered(delivered);
        orderItemRepository.save(it);
    }
}
