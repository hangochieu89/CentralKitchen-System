package com.centralkitchen.backend.service;

import com.centralkitchen.backend.entity.*;
import com.centralkitchen.backend.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Set;

@Service
public class KitchenStaffService {

    @Autowired private OrderRepository orderRepository;
    @Autowired private OrderItemRepository orderItemRepository;
    @Autowired private ProductionPlanRepository productionPlanRepository;
    @Autowired private ProductBatchRepository productBatchRepository;
    @Autowired private InventoryRepository inventoryRepository;
    @Autowired private GoodsReceiptRepository goodsReceiptRepository;
    @Autowired private GoodsReceiptDetailRepository goodsReceiptDetailRepository;
    @Autowired private ProductRepository productRepository;
    @Autowired private UserRepository userRepository;
    @Autowired private StoreRepository storeRepository;
    @Autowired private SupplierRepository supplierRepository;
    @Autowired private ProductionPlanOrderRepository productionPlanOrderRepository;
    @Autowired private RecipeRepository recipeRepository;

    private static final org.slf4j.Logger log = org.slf4j.LoggerFactory.getLogger(KitchenStaffService.class);

    // ── Orders ───────────────────────────────────────────────
    public List<Order> getAllOrders() {
        List<Order> orders = orderRepository.findAll();
        orders.forEach(order -> {
            List<OrderItem> items = orderItemRepository.findByOrder_Id(order.getId());
            log.info("  [Service] Order #{} -> findByOrder_Id returned {} items", order.getId(), items.size());
            if (!items.isEmpty()) {
                log.info("    first item product: {}", items.get(0).getProduct() != null ? items.get(0).getProduct().getName() : "NULL product");
            }
            order.setOrderItems(items);
        });
        return orders;
    }

    /**
     * Bếp trung tâm chỉ xử lý đơn đã được Điều phối cung ứng xác nhận (CONFIRMED trở đi).
     * PENDING → CONFIRMED do Supply Coordinator đảm nhiệm.
     */
    public void updateOrderStatus(Integer id, String newStatus) {
        Order order = orderRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy đơn hàng: " + id));
        String current = order.getStatus();
        if ("PENDING".equals(current)) {
            throw new RuntimeException(
                    "Đơn đang chờ Điều phối cung ứng xác nhận. Vui lòng không thao tác tại bếp cho đến khi đơn chuyển sang \"Đã xác nhận\".");
        }
        Map<String, Set<String>> allowed = Map.of(
                "CONFIRMED", Set.of("IN_PRODUCTION"),
                "IN_PRODUCTION", Set.of("READY"),
                "READY", Set.of("DELIVERING"),
                "DELIVERING", Set.of("DELIVERED")
        );
        if (!allowed.getOrDefault(current, Set.of()).contains(newStatus)) {
            throw new RuntimeException("Không thể chuyển trạng thái từ \"" + current + "\" sang \"" + newStatus + "\" tại bếp.");
        }
        order.setStatus(newStatus);
        orderRepository.save(order);
    }

    // ── Production Plans ─────────────────────────────────────
    public List<ProductionPlan> getAllProductionPlans() {
        List<ProductionPlan> plans = productionPlanRepository.findAll();
        // Manually load planOrders de tranh Hibernate naming strategy issue
        plans.forEach(plan -> {
            List<ProductionPlanOrder> orders = productionPlanOrderRepository.findByPlan_Id(plan.getId());
            plan.setPlanOrders(orders);
        });
        return plans;
    }

    /**
     * Tạo kế hoạch sản xuất mới.
     * Body gồm:
     *   productId      : ID sản phẩm cần nấu
     *   totalQuantity  : tổng số lượng kế hoạch này nấu
     *   assignedToId   : ID đầu bếp phụ trách (nullable)
     *   plannedDate    : ngày giờ nấu (ISO string)
     *   note           : ghi chú
     *   orderItems     : List<{orderId, quantity}> - các đơn được gộp vào kế hoạch này
     */
    @Transactional
    public ProductionPlan createProductionPlan(Map<String, Object> body) {
        Integer productId    = (Integer) body.get("productId");
        Integer assignedToId = body.get("assignedToId") != null ? (Integer) body.get("assignedToId") : null;
        String  plannedDate  = (String)  body.get("plannedDate");
        String  note         = (String)  body.get("note");
        Object  qtyRaw       = body.get("totalQuantity");
        Double  totalQty     = qtyRaw instanceof Integer ? ((Integer) qtyRaw).doubleValue() : (Double) qtyRaw;

        Product product = productRepository.findById(productId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy sản phẩm: " + productId));

        ProductionPlan plan = ProductionPlan.builder()
                .product(product)
                .totalQuantity(totalQty)
                .plannedDate(plannedDate != null ? LocalDateTime.parse(plannedDate) : LocalDateTime.now())
                .status("PENDING")
                .note(note)
                .build();

        if (assignedToId != null) {
            userRepository.findById(assignedToId).ifPresent(plan::setAssignedTo);
        }

        ProductionPlan savedPlan = productionPlanRepository.save(plan);

        // Lưu các đơn hàng được gộp vào kế hoạch
        List<?> orderItemsRaw = (List<?>) body.get("orderItems");
        if (orderItemsRaw != null) {
            for (Object itemRaw : orderItemsRaw) {
                Map<?, ?> item    = (Map<?, ?>) itemRaw;
                Integer   orderId = (Integer) item.get("orderId");
                Object    oqRaw   = item.get("quantity");
                Double    oqty    = oqRaw instanceof Integer ? ((Integer) oqRaw).doubleValue() : (Double) oqRaw;

                Order order = orderRepository.findById(orderId)
                        .orElseThrow(() -> new RuntimeException("Không tìm thấy đơn: " + orderId));

                ProductionPlanOrder ppo = ProductionPlanOrder.builder()
                        .plan(savedPlan)
                        .order(order)
                        .quantity(oqty)
                        .build();
                productionPlanOrderRepository.save(ppo);
            }
        }

        return savedPlan;
    }

    @Transactional
    public ProductionPlan updateProductionPlan(Integer planId, Map<String, Object> body) {
        ProductionPlan plan = productionPlanRepository.findById(planId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy kế hoạch: " + planId));

        String newStatus = body.containsKey("status") ? (String) body.get("status") : plan.getStatus();

        if (body.containsKey("status"))  plan.setStatus(newStatus);
        if (body.containsKey("note"))    plan.setNote((String) body.get("note"));
        if (body.containsKey("plannedDate") && body.get("plannedDate") != null) {
            plan.setPlannedDate(LocalDateTime.parse((String) body.get("plannedDate")));
        }
        if (body.containsKey("assignedToId") && body.get("assignedToId") != null) {
            userRepository.findById((Integer) body.get("assignedToId")).ifPresent(plan::setAssignedTo);
        }

        ProductionPlan savedPlan = productionPlanRepository.save(plan);

        // Khi kế hoạch hoàn thành: trừ nguyên liệu và kiểm tra cập nhật đơn hàng
        if ("COMPLETED".equals(newStatus)) {
            deductInventoryForPlan(savedPlan);
            checkAndUpdateOrdersStatus(savedPlan);
        }

        return savedPlan;
    }

    /**
     * Trừ nguyên liệu theo công thức: quantity_required × totalQuantity
     * Trừ từ kho CENTRAL_KITCHEN
     */
    private void deductInventoryForPlan(ProductionPlan plan) {
        List<com.centralkitchen.backend.entity.Recipe> recipes =
                recipeRepository.findByFinishedProduct_Id(plan.getProduct().getId());

        // Lấy store CENTRAL_KITCHEN đầu tiên
        List<Store> kitchens = storeRepository.findByType("CENTRAL_KITCHEN");
        if (kitchens.isEmpty()) return;
        Store kitchen = kitchens.get(0);

        for (com.centralkitchen.backend.entity.Recipe recipe : recipes) {
            Double deductQty = recipe.getQuantityRequired() * plan.getTotalQuantity();
            inventoryRepository.findByStoreIdAndProductId(kitchen.getId(), recipe.getIngredientProduct().getId())
                    .ifPresent(inv -> {
                        inv.setQuantity(Math.max(0.0, inv.getQuantity() - deductQty));
                        inv.setUpdatedAt(LocalDateTime.now());
                        inventoryRepository.save(inv);
                    });
        }
    }

    /**
     * Kiểm tra: nếu tất cả kế hoạch liên quan đến 1 đơn hàng đều COMPLETED
     * thì cập nhật đơn đó sang READY
     */
    private void checkAndUpdateOrdersStatus(ProductionPlan completedPlan) {
        // Lấy danh sách đơn hàng liên kết với kế hoạch vừa hoàn thành
        List<ProductionPlanOrder> planOrders =
                productionPlanOrderRepository.findByPlan_Id(completedPlan.getId());

        for (ProductionPlanOrder ppo : planOrders) {
            Order order = ppo.getOrder();
            // Lấy tất cả kế hoạch liên quan đến đơn này
            List<ProductionPlanOrder> allPlanOrders =
                    productionPlanOrderRepository.findByOrder_Id(order.getId());

            boolean allCompleted = allPlanOrders.stream().allMatch(p -> {
                ProductionPlan relatedPlan = productionPlanRepository.findById(p.getPlan().getId())
                        .orElse(null);
                return relatedPlan != null && "COMPLETED".equals(relatedPlan.getStatus());
            });

            if (allCompleted && !"READY".equals(order.getStatus())
                    && !"DELIVERING".equals(order.getStatus())
                    && !"DELIVERED".equals(order.getStatus())) {
                order.setStatus("READY");
                orderRepository.save(order);
            }
        }
    }

    // ── Product Batches ──────────────────────────────────────
    public List<ProductBatch> getAllProductBatches() {
        return productBatchRepository.findAll();
    }

    @Transactional
    public ProductBatch createProductBatch(Map<String, Object> body) {
        Integer productId = (Integer) body.get("productId");
        Integer storeId   = (Integer) body.get("storeId");

        Product product = productRepository.findById(productId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy sản phẩm: " + productId));
        Store store = storeRepository.findById(storeId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy kho: " + storeId));

        Double qty = body.get("quantity") instanceof Integer
                ? ((Integer) body.get("quantity")).doubleValue()
                : (Double) body.get("quantity");

        ProductBatch batch = ProductBatch.builder()
                .product(product)
                .store(store)
                .batchNumber((String) body.get("batchNumber"))
                .manufactureDate(LocalDate.parse((String) body.get("manufactureDate")))
                .expirationDate(LocalDate.parse((String) body.get("expirationDate")))
                .quantityInitial(qty)
                .quantityRemaining(qty)
                .build();

        return productBatchRepository.save(batch);
    }

    @Transactional
    public ProductBatch updateProductBatch(Integer batchId, Map<String, Object> body) {
        ProductBatch batch = productBatchRepository.findById(batchId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy lô: " + batchId));

        if (body.containsKey("expirationDate") && body.get("expirationDate") != null)
            batch.setExpirationDate(LocalDate.parse((String) body.get("expirationDate")));
        if (body.containsKey("quantityRemaining") && body.get("quantityRemaining") != null) {
            Object qr = body.get("quantityRemaining");
            batch.setQuantityRemaining(qr instanceof Integer ? ((Integer) qr).doubleValue() : (Double) qr);
        }

        return productBatchRepository.save(batch);
    }

    // ── Inventory ────────────────────────────────────────────
    public List<Inventory> getAllInventories() {
        return inventoryRepository.findAll();
    }

    public List<Inventory> getCentralKitchenInventories() {
        return inventoryRepository.findByStoreType("CENTRAL_KITCHEN");
    }

    @Transactional
    public Inventory createOrUpdateInventory(Map<String, Object> body) {
        Integer storeId   = (Integer) body.get("storeId");
        Integer productId = (Integer) body.get("productId");
        Object  qtyRaw    = body.get("quantity");
        Double  qty       = qtyRaw instanceof Integer ? ((Integer) qtyRaw).doubleValue() : (Double) qtyRaw;
        Object  minRaw    = body.get("minThreshold");
        Double  minThreshold = minRaw instanceof Integer ? ((Integer) minRaw).doubleValue() : (minRaw != null ? (Double) minRaw : 0.0);

        Inventory inv = inventoryRepository.findByStoreIdAndProductId(storeId, productId)
                .orElseGet(() -> {
                    Inventory newInv = new Inventory();
                    storeRepository.findById(storeId).ifPresent(newInv::setStore);
                    productRepository.findById(productId).ifPresent(newInv::setProduct);
                    newInv.setQuantity(0.0);
                    newInv.setMinThreshold(0.0);
                    return newInv;
                });

        inv.setQuantity(inv.getQuantity() + qty);
        inv.setMinThreshold(minThreshold);
        inv.setUpdatedAt(LocalDateTime.now());
        return inventoryRepository.save(inv);
    }

    @Transactional
    public Inventory updateInventory(Integer invId, Map<String, Object> body) {
        Inventory inv = inventoryRepository.findById(invId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy tồn kho: " + invId));

        if (body.containsKey("quantity") && body.get("quantity") != null) {
            Object q = body.get("quantity");
            inv.setQuantity(q instanceof Integer ? ((Integer) q).doubleValue() : (Double) q);
        }
        if (body.containsKey("minThreshold") && body.get("minThreshold") != null) {
            Object m = body.get("minThreshold");
            inv.setMinThreshold(m instanceof Integer ? ((Integer) m).doubleValue() : (Double) m);
        }
        inv.setUpdatedAt(LocalDateTime.now());
        return inventoryRepository.save(inv);
    }

    // ── Goods Receipts (Nguyên liệu đầu vào) ─────────────────
    public List<GoodsReceipt> getAllGoodsReceipts() {
        return goodsReceiptRepository.findAll();
    }

    public List<GoodsReceiptDetail> getAllGoodsReceiptDetails() {
        return goodsReceiptDetailRepository.findAll();
    }

    @Transactional
    public GoodsReceiptDetail createGoodsReceiptDetail(Map<String, Object> body) {
        Integer kitchenId  = (Integer) body.get("kitchenId");
        Integer supplierId = (Integer) body.get("supplierId");
        Integer productId  = (Integer) body.get("productId");
        String  batchNo    = (String)  body.get("batchNumber");
        String  expDate    = (String)  body.get("expirationDate");
        Object  qtyRaw     = body.get("quantity");
        Double  qty        = qtyRaw instanceof Integer ? ((Integer) qtyRaw).doubleValue() : (Double) qtyRaw;

        Store    kitchen  = storeRepository.findById(kitchenId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy kho: " + kitchenId));
        Supplier supplier = supplierRepository.findById(supplierId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy nhà cung cấp: " + supplierId));
        Product  product  = productRepository.findById(productId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy sản phẩm: " + productId));

        GoodsReceipt receipt = GoodsReceipt.builder()
                .kitchen(kitchen)
                .supplier(supplier)
                .status("COMPLETED")
                .build();
        receipt = goodsReceiptRepository.save(receipt);

        GoodsReceiptDetail detail = GoodsReceiptDetail.builder()
                .goodsReceipt(receipt)
                .product(product)
                .batchNumber(batchNo)
                .expirationDate(LocalDate.parse(expDate))
                .quantity(qty)
                .build();

        return goodsReceiptDetailRepository.save(detail);
    }

    // ── Utility ──────────────────────────────────────────────
    public List<Product> getAllProducts()          { return productRepository.findByIsActive(true); }
    public List<Product> getFinishedProducts()     { return productRepository.findByCategoryAndIsActive("Thanh pham", true); }
    public List<User>     getAllKitchenUsers() { return userRepository.findByRole("KITCHEN_STAFF"); }
    public List<Store>    getAllStores()     { return storeRepository.findAll(); }
    public List<Supplier> getAllSuppliers()  { return supplierRepository.findAll(); }
}