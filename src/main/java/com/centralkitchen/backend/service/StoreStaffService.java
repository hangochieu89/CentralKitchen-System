package com.centralkitchen.backend.service;

import com.centralkitchen.backend.dto.OrderItemDTO;
import com.centralkitchen.backend.dto.OrderRequest;
import com.centralkitchen.backend.dto.StoreDeliverySnapshotDTO;
import com.centralkitchen.backend.dto.StoreInventoryDeltaRequest;
import com.centralkitchen.backend.dto.StoreInventorySummaryDTO;
import com.centralkitchen.backend.dto.StoreOrderDetailDTO;
import com.centralkitchen.backend.dto.StoreOrderListRowDTO;
import com.centralkitchen.backend.dto.StoreProductCatalogDTO;
import com.centralkitchen.backend.dto.StoreStaffFeedbackRequest;
import com.centralkitchen.backend.dto.StoreStocktakeRequest;
import com.centralkitchen.backend.entity.*;
import com.centralkitchen.backend.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class StoreStaffService {

    private static final Set<String> CATEGORY_NGUYEN_LIEU = Set.of("Thịt", "Rau củ", "Gia vị");

    private final InventoryRepository inventoryRepository;
    private final OrderRepository orderRepository;
    private final OrderItemRepository orderItemRepository;
    private final ProductRepository productRepository;
    private final QualityFeedbackRepository feedbackRepository;
    private final StoreRepository storeRepository;
    private final UserRepository userRepository;
    private final DeliveryRepository deliveryRepository;

    private void assertStoreStaff(User staff) {
        if (staff == null || !"STORE_STAFF".equals(staff.getRole()) || staff.getStore() == null) {
            throw new IllegalArgumentException("Chỉ nhân viên cửa hàng franchise (có chi nhánh gán) mới được thực hiện thao tác này.");
        }
    }

    private void assertOwnStore(User staff, Integer storeId) {
        assertStoreStaff(staff);
        if (!staff.getStore().getId().equals(storeId)) {
            throw new IllegalArgumentException("Bạn không được truy cập dữ liệu của cửa hàng khác.");
        }
    }

    public List<Inventory> getMyStoreInventory(Integer storeId, User staff) {
        assertOwnStore(staff, storeId);
        return inventoryRepository.findByStoreId(storeId);
    }

    public StoreInventorySummaryDTO getInventorySummary(Integer storeId, User staff) {
        assertOwnStore(staff, storeId);
        List<Inventory> rows = inventoryRepository.findByStoreId(storeId);
        int low = (int) rows.stream().filter(this::isBelowThreshold).count();
        double sum = rows.stream().mapToDouble(i -> i.getQuantity() != null ? i.getQuantity() : 0.0).sum();
        List<StoreInventorySummaryDTO.LowStockLine> preview = rows.stream()
                .filter(this::isBelowThreshold)
                .limit(8)
                .map(i -> StoreInventorySummaryDTO.LowStockLine.builder()
                        .productId(i.getProduct().getId())
                        .productName(i.getProduct().getName())
                        .quantity(i.getQuantity())
                        .minThreshold(i.getMinThreshold())
                        .build())
                .collect(Collectors.toList());
        return StoreInventorySummaryDTO.builder()
                .trackedSkuCount(rows.size())
                .lowStockCount(low)
                .totalQuantity(sum)
                .lowStockLines(preview)
                .build();
    }

    private boolean isBelowThreshold(Inventory i) {
        double q = i.getQuantity() != null ? i.getQuantity() : 0.0;
        double th = i.getMinThreshold() != null ? i.getMinThreshold() : 0.0;
        return q < th;
    }

    @Transactional
    public List<Inventory> applyStocktake(Integer storeId, StoreStocktakeRequest body, User staff) {
        assertOwnStore(staff, storeId);
        Store store = storeRepository.findById(storeId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy cửa hàng."));
        List<Inventory> saved = new ArrayList<>();
        for (StoreStocktakeRequest.StoreStocktakeLineRequest line : body.getLines()) {
            Product product = productRepository.findById(line.getProductId())
                    .orElseThrow(() -> new IllegalArgumentException("Sản phẩm không tồn tại: #" + line.getProductId()));
            if (Boolean.FALSE.equals(product.getIsActive())) {
                throw new IllegalArgumentException("Sản phẩm \"" + product.getName() + "\" không còn hoạt động.");
            }
            if (line.getMinThreshold() != null && line.getMinThreshold() < 0) {
                throw new IllegalArgumentException("Ngưỡng tối thiểu không được âm.");
            }
            Inventory inv = inventoryRepository.findByStoreIdAndProductId(storeId, line.getProductId())
                    .orElse(Inventory.builder()
                            .store(store)
                            .product(product)
                            .quantity(0.0)
                            .minThreshold(0.0)
                            .build());
            inv.setQuantity(line.getCountedQuantity());
            if (line.getMinThreshold() != null) {
                inv.setMinThreshold(line.getMinThreshold());
            }
            inv.setUpdatedAt(LocalDateTime.now());
            saved.add(inventoryRepository.save(inv));
        }
        return saved;
    }

    @Transactional
    public Inventory applyInventoryDelta(Integer storeId, StoreInventoryDeltaRequest body, User staff) {
        assertOwnStore(staff, storeId);
        Store store = storeRepository.findById(storeId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy cửa hàng."));
        Product product = productRepository.findById(body.getProductId())
                .orElseThrow(() -> new IllegalArgumentException("Sản phẩm không tồn tại."));
        if (Boolean.FALSE.equals(product.getIsActive())) {
            throw new IllegalArgumentException("Sản phẩm không còn hoạt động.");
        }
        Inventory inv = inventoryRepository.findByStoreIdAndProductId(storeId, body.getProductId())
                .orElse(null);
        if (inv == null) {
            if (body.getDelta() == null || body.getDelta() <= 0) {
                throw new IllegalArgumentException("Chưa theo dõi sản phẩm này — chỉ có thể nhập delta dương để khởi tạo tồn.");
            }
            inv = Inventory.builder()
                    .store(store)
                    .product(product)
                    .quantity(body.getDelta())
                    .minThreshold(0.0)
                    .build();
        } else {
            double q = (inv.getQuantity() != null ? inv.getQuantity() : 0.0) + body.getDelta();
            if (q < 0) {
                throw new IllegalArgumentException("Tồn sau điều chỉnh không được âm (hiện tại: "
                        + inv.getQuantity() + ", delta: " + body.getDelta() + ").");
            }
            inv.setQuantity(q);
        }
        inv.setUpdatedAt(LocalDateTime.now());
        return inventoryRepository.save(inv);
    }

    @Transactional
    public Order createOrder(OrderRequest request, User staff) {
        assertStoreStaff(staff);
        if (request.getItems() == null || request.getItems().isEmpty()) {
            throw new IllegalArgumentException("Đơn phải có ít nhất một dòng hàng (nguyên liệu / bán thành phẩm / thành phẩm).");
        }
        if (request.getStoreId() != null && !request.getStoreId().equals(staff.getStore().getId())) {
            throw new IllegalArgumentException("Không được tạo đơn cho cửa hàng khác.");
        }
        if (request.getUserId() != null && !request.getUserId().equals(staff.getId())) {
            throw new IllegalArgumentException("Không được giả mạo người tạo đơn.");
        }

        Store store = storeRepository.findById(staff.getStore().getId())
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy cửa hàng."));
        User creator = userRepository.findById(staff.getId())
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy người dùng."));

        Order order = Order.builder()
                .store(store)
                .createdBy(creator)
                .deliveryDate(request.getDeliveryDate())
                .note(request.getNote())
                .status("PENDING")
                .build();

        Order savedOrder = orderRepository.save(order);

        for (OrderRequest.OrderItemRequest itemDto : request.getItems()) {
            if (itemDto.getProductId() == null || itemDto.getQuantity() == null || itemDto.getQuantity() <= 0) {
                throw new IllegalArgumentException("Mỗi dòng hàng cần productId và số lượng > 0.");
            }
            Product product = productRepository.findById(itemDto.getProductId())
                    .orElseThrow(() -> new IllegalArgumentException("Sản phẩm không tồn tại: #" + itemDto.getProductId()));
            if (Boolean.FALSE.equals(product.getIsActive())) {
                throw new IllegalArgumentException("Sản phẩm \"" + product.getName() + "\" không còn hoạt động.");
            }
            OrderItem item = OrderItem.builder()
                    .order(savedOrder)
                    .product(product)
                    .quantityRequested(itemDto.getQuantity())
                    .note(itemDto.getNote())
                    .build();
            orderItemRepository.save(item);
        }

        return savedOrder;
    }

    public List<StoreOrderListRowDTO> listStoreOrders(Integer storeId, User staff) {
        assertOwnStore(staff, storeId);
        List<Order> orders = orderRepository.findByStoreId(storeId);
        orders.sort(Comparator.comparing(Order::getOrderDate, Comparator.nullsLast(Comparator.naturalOrder())).reversed());
        return orders.stream().map(this::toOrderListRow).collect(Collectors.toList());
    }

    private StoreOrderListRowDTO toOrderListRow(Order o) {
        List<Delivery> dlv = deliveryRepository.findByOrder_Id(o.getId());
        String latest = null;
        if (!dlv.isEmpty()) {
            latest = dlv.stream().max(Comparator.comparing(Delivery::getId)).map(Delivery::getStatus).orElse(null);
        }
        boolean fb = false;
        for (Delivery d : dlv) {
            if (feedbackRepository.existsByDelivery_Id(d.getId())) {
                fb = true;
                break;
            }
        }
        return StoreOrderListRowDTO.builder()
                .id(o.getId())
                .orderDate(o.getOrderDate())
                .deliveryDate(o.getDeliveryDate())
                .status(o.getStatus())
                .latestDeliveryStatus(latest)
                .storeReceiptConfirmedAt(o.getStoreReceiptConfirmedAt())
                .qualityFeedbackSubmitted(fb)
                .build();
    }

    public StoreOrderDetailDTO getOrderDetails(Integer orderId, User staff) {
        assertStoreStaff(staff);
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy đơn hàng"));
        if (!order.getStore().getId().equals(staff.getStore().getId())) {
            throw new IllegalArgumentException("Đơn không thuộc cửa hàng của bạn.");
        }

        List<OrderItem> items = orderItemRepository.findByOrder_Id(orderId);
        List<OrderItemDTO> itemDTOs = items.stream()
                .map(item -> OrderItemDTO.builder()
                        .id(item.getId())
                        .productId(item.getProduct().getId())
                        .productName(item.getProduct().getName())
                        .productUnit(item.getProduct().getUnit())
                        .quantity(item.getQuantityRequested())
                        .quantityDelivered(item.getQuantityDelivered())
                        .build())
                .collect(Collectors.toList());

        List<Delivery> deliveries = deliveryRepository.findByOrder_Id(orderId);
        deliveries.sort(Comparator.comparing(Delivery::getId));
        List<StoreDeliverySnapshotDTO> dSnaps = deliveries.stream()
                .map(d -> StoreDeliverySnapshotDTO.builder()
                        .id(d.getId())
                        .status(d.getStatus())
                        .scheduledAt(d.getScheduledAt())
                        .actualAt(d.getActualAt())
                        .note(d.getNote())
                        .build())
                .collect(Collectors.toList());

        boolean fbSubmitted = false;
        Integer rating = null;
        Optional<Delivery> deliveredForFb = deliveries.stream()
                .filter(d -> "DELIVERED".equals(d.getStatus()))
                .max(Comparator.comparing(Delivery::getId));
        if (deliveredForFb.isPresent()) {
            List<QualityFeedback> fbs = feedbackRepository.findByDeliveryId(deliveredForFb.get().getId());
            if (!fbs.isEmpty()) {
                fbSubmitted = true;
                rating = fbs.get(fbs.size() - 1).getRating();
            }
        }

        return StoreOrderDetailDTO.builder()
                .id(order.getId())
                .storeId(order.getStore().getId())
                .storeName(order.getStore().getName())
                .createdByName(order.getCreatedBy() != null ? order.getCreatedBy().getFullName() : null)
                .orderDate(order.getOrderDate())
                .deliveryDate(order.getDeliveryDate())
                .status(order.getStatus())
                .note(order.getNote())
                .items(itemDTOs)
                .createdAt(order.getCreatedAt())
                .deliveries(dSnaps)
                .storeReceiptConfirmedAt(order.getStoreReceiptConfirmedAt())
                .qualityFeedbackSubmitted(fbSubmitted)
                .qualityFeedbackRating(rating)
                .build();
    }

    /**
     * Cửa hàng xác nhận đã nhận đủ hàng sau khi đơn &amp; phiếu giao ở trạng thái giao xong.
     * Cộng tồn kho cửa hàng theo SL giao (hoặc SL đặt nếu chưa ghi nhận giao).
     */
    @Transactional
    public Order confirmReceipt(Integer orderId, User staff) {
        assertStoreStaff(staff);
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy đơn hàng."));
        if (!order.getStore().getId().equals(staff.getStore().getId())) {
            throw new IllegalArgumentException("Đơn không thuộc cửa hàng của bạn.");
        }
        if (!"DELIVERED".equals(order.getStatus())) {
            throw new IllegalArgumentException("Chỉ xác nhận nhận khi đơn đã ở trạng thái DELIVERED (bếp/điều phối đã hoàn tất giao).");
        }
        Optional<Delivery> delivered = deliveryRepository.findByOrder_Id(orderId).stream()
                .filter(d -> "DELIVERED".equals(d.getStatus()))
                .max(Comparator.comparing(Delivery::getId));
        if (delivered.isEmpty()) {
            throw new IllegalArgumentException("Chưa có phiếu giao ở trạng thái DELIVERED — không thể xác nhận nhận hàng.");
        }
        if (order.getStoreReceiptConfirmedAt() != null) {
            return order;
        }

        int storeId = order.getStore().getId();
        Store store = order.getStore();
        List<OrderItem> lines = orderItemRepository.findByOrder_Id(orderId);
        for (OrderItem line : lines) {
            double qty = line.getQuantityDelivered() != null && line.getQuantityDelivered() > 0
                    ? line.getQuantityDelivered()
                    : (line.getQuantityRequested() != null ? line.getQuantityRequested() : 0.0);
            if (qty <= 0) {
                continue;
            }
            Product product = line.getProduct();
            Inventory inv = inventoryRepository.findByStoreIdAndProductId(storeId, product.getId())
                    .orElse(Inventory.builder()
                            .store(store)
                            .product(product)
                            .quantity(0.0)
                            .minThreshold(0.0)
                            .build());
            double q = (inv.getQuantity() != null ? inv.getQuantity() : 0.0) + qty;
            inv.setQuantity(q);
            inv.setUpdatedAt(LocalDateTime.now());
            inventoryRepository.save(inv);
        }

        order.setStoreReceiptConfirmedAt(LocalDateTime.now());
        return orderRepository.save(order);
    }

    @Transactional
    public QualityFeedback submitFeedback(StoreStaffFeedbackRequest body, User staff) {
        assertStoreStaff(staff);
        Order order = orderRepository.findById(body.getOrderId())
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy đơn hàng."));
        if (!order.getStore().getId().equals(staff.getStore().getId())) {
            throw new IllegalArgumentException("Đơn không thuộc cửa hàng của bạn.");
        }
        if (order.getStoreReceiptConfirmedAt() == null) {
            throw new IllegalArgumentException("Vui lòng xác nhận đã nhận hàng trước khi gửi đánh giá chất lượng.");
        }
        if (!"DELIVERED".equals(order.getStatus())) {
            throw new IllegalArgumentException("Chỉ đánh giá được khi đơn đã giao (DELIVERED).");
        }
        Delivery delivery = deliveryRepository.findByOrder_Id(order.getId()).stream()
                .filter(d -> "DELIVERED".equals(d.getStatus()))
                .max(Comparator.comparing(Delivery::getId))
                .orElseThrow(() -> new IllegalArgumentException("Chưa có phiếu giao DELIVERED — không thể gửi đánh giá."));
        if (feedbackRepository.existsByDelivery_Id(delivery.getId())) {
            throw new IllegalArgumentException("Bạn đã gửi đánh giá cho đợt giao này.");
        }
        User submitter = userRepository.findById(staff.getId()).orElseThrow();

        QualityFeedback fb = QualityFeedback.builder()
                .delivery(delivery)
                .submittedBy(submitter)
                .rating(body.getRating())
                .comment(body.getComment())
                .build();
        return feedbackRepository.save(fb);
    }

    public List<Product> getAllProducts() {
        return productRepository.findByIsActive(true);
    }

    public StoreProductCatalogDTO getProductCatalog() {
        List<Product> all = productRepository.findByIsActive(true);
        List<Product> nl = new ArrayList<>();
        List<Product> btp = new ArrayList<>();
        List<Product> tp = new ArrayList<>();
        List<Product> khac = new ArrayList<>();
        for (Product p : all) {
            String c = p.getCategory() != null ? p.getCategory().trim() : "";
            if (CATEGORY_NGUYEN_LIEU.contains(c)) {
                nl.add(p);
            } else if ("Bán thành phẩm".equalsIgnoreCase(c)) {
                btp.add(p);
            } else if ("Thành phẩm".equalsIgnoreCase(c)) {
                tp.add(p);
            } else {
                khac.add(p);
            }
        }
        return StoreProductCatalogDTO.builder()
                .nguyenLieu(nl)
                .banThanhPham(btp)
                .thanhPham(tp)
                .khac(khac)
                .build();
    }
}
