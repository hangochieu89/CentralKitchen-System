package com.centralkitchen.backend.controller;

import com.centralkitchen.backend.dto.*;
import com.centralkitchen.backend.service.SupplyCoordinatorService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/supply-coordinator")
@RequiredArgsConstructor
public class SupplyCoordinatorController {

    private final SupplyCoordinatorService supplyCoordinatorService;
    
    // ==================== Tổng hợp đơn hàng - Order Aggregation ====================
    
    /**
     * Lấy tất cả đơn hàng đang chờ xử lý
     * GET /api/supply-coordinator/orders/pending
     */
    @GetMapping("/orders/pending")
    public ResponseEntity<Map<String, Object>> getPendingOrders() {
        try {
            List<OrderSummaryDTO> orders = supplyCoordinatorService.getAllPendingOrders();
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Lấy danh sách đơn hàng chờ xử lý thành công");
            response.put("count", orders.size());
            response.put("data", orders);
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return buildErrorResponse("Lỗi khi lấy danh sách đơn hàng chờ xử lý: " + e.getMessage());
        }
    }
    
    /**
     * Lấy đơn hàng theo trạng thái
     * GET /api/supply-coordinator/orders/status/{status}
     */
    @GetMapping("/orders/status/{status}")
    public ResponseEntity<Map<String, Object>> getOrdersByStatus(@PathVariable String status) {
        try {
            List<OrderSummaryDTO> orders = supplyCoordinatorService.getOrdersByStatus(status);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Lấy danh sách đơn hàng theo trạng thái '" + status + "' thành công");
            response.put("count", orders.size());
            response.put("data", orders);
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return buildErrorResponse("Lỗi khi lấy danh sách đơn hàng: " + e.getMessage());
        }
    }
    
    /**
     * Lấy đơn hàng theo khoảng thời gian
     * GET /api/supply-coordinator/orders/date-range?startDate=2024-01-01T00:00:00&endDate=2024-12-31T23:59:59
     */
    @GetMapping("/orders/date-range")
    public ResponseEntity<Map<String, Object>> getOrdersByDateRange(
            @RequestParam String startDate,
            @RequestParam String endDate) {
        try {
            LocalDateTime start = LocalDateTime.parse(startDate);
            LocalDateTime end = LocalDateTime.parse(endDate);
            
            List<OrderSummaryDTO> orders = supplyCoordinatorService.getOrdersByDateRange(start, end);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Lấy danh sách đơn hàng trong khoảng thời gian thành công");
            response.put("count", orders.size());
            response.put("data", orders);
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return buildErrorResponse("Lỗi khi lấy danh sách đơn hàng: " + e.getMessage());
        }
    }
    
    /**
     * Phân loại đơn hàng theo cửa hàng
     * GET /api/supply-coordinator/orders/store/{storeId}
     */
    @GetMapping("/orders/store/{storeId}")
    public ResponseEntity<Map<String, Object>> getOrdersByStore(@PathVariable Integer storeId) {
        try {
            List<OrderSummaryDTO> orders = supplyCoordinatorService.getOrdersByStore(storeId);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Lấy danh sách đơn hàng của cửa hàng thành công");
            response.put("count", orders.size());
            response.put("data", orders);
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return buildErrorResponse("Lỗi khi lấy danh sách đơn hàng: " + e.getMessage());
        }
    }
    
    /**
     * Xác nhận đơn hàng
     * POST /api/supply-coordinator/orders/{orderId}/confirm
     */
    @PostMapping("/orders/{orderId}/confirm")
    public ResponseEntity<Map<String, Object>> confirmOrder(@PathVariable Integer orderId) {
        try {
            OrderSummaryDTO order = supplyCoordinatorService.confirmOrder(orderId);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Xác nhận đơn hàng thành công");
            response.put("data", order);
            
            return ResponseEntity.ok(response);
        } catch (IllegalArgumentException e) {
            return buildErrorResponse(e.getMessage(), HttpStatus.NOT_FOUND);
        } catch (IllegalStateException e) {
            return buildErrorResponse(e.getMessage(), HttpStatus.BAD_REQUEST);
        } catch (Exception e) {
            return buildErrorResponse("Lỗi khi xác nhận đơn hàng: " + e.getMessage());
        }
    }
    
    // ==================== Lập lịch và điều phối giao hàng - Delivery Scheduling ====================
    
    /**
     * Lập lịch giao hàng
     * POST /api/supply-coordinator/deliveries/schedule
     */
    @PostMapping("/deliveries/schedule")
    public ResponseEntity<Map<String, Object>> scheduleDelivery(
            @Valid @RequestBody DeliveryScheduleRequestDTO request) {
        try {
            DeliveryDTO delivery = supplyCoordinatorService.scheduleDelivery(request);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Lập lịch giao hàng thành công");
            response.put("data", delivery);
            
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        } catch (IllegalArgumentException e) {
            return buildErrorResponse(e.getMessage(), HttpStatus.NOT_FOUND);
        } catch (Exception e) {
            return buildErrorResponse("Lỗi khi lập lịch giao hàng: " + e.getMessage());
        }
    }
    
    /**
     * Cập nhật trạng thái giao hàng
     * PUT /api/supply-coordinator/deliveries/update-status
     */
    @PutMapping("/deliveries/update-status")
    public ResponseEntity<Map<String, Object>> updateDeliveryStatus(
            @Valid @RequestBody DeliveryUpdateStatusRequestDTO request) {
        try {
            DeliveryDTO delivery = supplyCoordinatorService.updateDeliveryStatus(request);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Cập nhật trạng thái giao hàng thành công");
            response.put("data", delivery);
            
            return ResponseEntity.ok(response);
        } catch (IllegalArgumentException e) {
            return buildErrorResponse(e.getMessage(), HttpStatus.NOT_FOUND);
        } catch (IllegalStateException e) {
            return buildErrorResponse(e.getMessage(), HttpStatus.BAD_REQUEST);
        } catch (Exception e) {
            return buildErrorResponse("Lỗi khi cập nhật trạng thái giao hàng: " + e.getMessage());
        }
    }
    
    /**
     * Lấy danh sách giao hàng của một điều phối viên
     * GET /api/supply-coordinator/deliveries/coordinator/{coordinatorId}
     */
    @GetMapping("/deliveries/coordinator/{coordinatorId}")
    public ResponseEntity<Map<String, Object>> getCoordinatorDeliveries(@PathVariable Integer coordinatorId) {
        try {
            List<DeliveryDTO> deliveries = supplyCoordinatorService.getCoordinatorDeliveries(coordinatorId);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Lấy danh sách giao hàng của điều phối viên thành công");
            response.put("count", deliveries.size());
            response.put("data", deliveries);
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return buildErrorResponse("Lỗi khi lấy danh sách giao hàng: " + e.getMessage());
        }
    }
    
    /**
     * Lấy danh sách giao hàng theo trạng thái
     * GET /api/supply-coordinator/deliveries/status/{status}
     */
    @GetMapping("/deliveries/status/{status}")
    public ResponseEntity<Map<String, Object>> getDeliveriesByStatus(@PathVariable String status) {
        try {
            List<DeliveryDTO> deliveries = supplyCoordinatorService.getDeliveriesByStatus(status);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Lấy danh sách giao hàng theo trạng thái '" + status + "' thành công");
            response.put("count", deliveries.size());
            response.put("data", deliveries);
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return buildErrorResponse("Lỗi khi lấy danh sách giao hàng: " + e.getMessage());
        }
    }
    
    /**
     * Lấy danh sách giao hàng quá hạn
     * GET /api/supply-coordinator/deliveries/overdue
     */
    @GetMapping("/deliveries/overdue")
    public ResponseEntity<Map<String, Object>> getOverdueDeliveries() {
        try {
            List<DeliveryDTO> deliveries = supplyCoordinatorService.getOverdueDeliveries();
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Lấy danh sách giao hàng quá hạn thành công");
            response.put("count", deliveries.size());
            response.put("data", deliveries);
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return buildErrorResponse("Lỗi khi lấy danh sách giao hàng quá hạn: " + e.getMessage());
        }
    }
    
    // ==================== Xử lý vấn đề phát sinh - Issue Handling ====================
    
    /**
     * Hủy đơn hàng
     * POST /api/supply-coordinator/orders/{orderId}/cancel
     */
    @PostMapping("/orders/{orderId}/cancel")
    public ResponseEntity<Map<String, Object>> cancelOrder(
            @PathVariable Integer orderId,
            @RequestParam(required = false) String reason) {
        try {
            OrderSummaryDTO order = supplyCoordinatorService.cancelOrder(orderId, reason);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Hủy đơn hàng thành công");
            response.put("data", order);
            
            return ResponseEntity.ok(response);
        } catch (IllegalArgumentException e) {
            return buildErrorResponse(e.getMessage(), HttpStatus.NOT_FOUND);
        } catch (IllegalStateException e) {
            return buildErrorResponse(e.getMessage(), HttpStatus.BAD_REQUEST);
        } catch (Exception e) {
            return buildErrorResponse("Lỗi khi hủy đơn hàng: " + e.getMessage());
        }
    }
    
    /**
     * Đánh dấu giao hàng thất bại
     * POST /api/supply-coordinator/deliveries/{deliveryId}/failed
     */
    @PostMapping("/deliveries/{deliveryId}/failed")
    public ResponseEntity<Map<String, Object>> markDeliveryAsFailed(
            @PathVariable Integer deliveryId,
            @RequestParam(required = false) String reason) {
        try {
            DeliveryDTO delivery = supplyCoordinatorService.markDeliveryAsFailed(deliveryId, reason);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Đánh dấu giao hàng thất bại thành công");
            response.put("data", delivery);
            
            return ResponseEntity.ok(response);
        } catch (IllegalArgumentException e) {
            return buildErrorResponse(e.getMessage(), HttpStatus.NOT_FOUND);
        } catch (Exception e) {
            return buildErrorResponse("Lỗi khi đánh dấu giao hàng thất bại: " + e.getMessage());
        }
    }
    
    // ==================== Thống kê và báo cáo - Statistics & Reports ====================
    
    /**
     * Lấy thống kê sản xuất trong khoảng thời gian
     * GET /api/supply-coordinator/production-stats?startDate=2024-01-01T00:00:00&endDate=2024-12-31T23:59:59
     */
    @GetMapping("/production-stats")
    public ResponseEntity<Map<String, Object>> getProductionStats(
            @RequestParam String startDate,
            @RequestParam String endDate) {
        try {
            LocalDateTime start = LocalDateTime.parse(startDate);
            LocalDateTime end = LocalDateTime.parse(endDate);
            
            List<ProductionPlanDTO> stats = supplyCoordinatorService.getProductionStats(start, end);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Lấy thống kê sản xuất thành công");
            response.put("count", stats.size());
            response.put("data", stats);
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return buildErrorResponse("Lỗi khi lấy thống kê sản xuất: " + e.getMessage());
        }
    }
    
    // ==================== Helper Methods ====================
    
    private ResponseEntity<Map<String, Object>> buildErrorResponse(String message) {
        return buildErrorResponse(message, HttpStatus.INTERNAL_SERVER_ERROR);
    }
    
    private ResponseEntity<Map<String, Object>> buildErrorResponse(String message, HttpStatus status) {
        Map<String, Object> response = new HashMap<>();
        response.put("success", false);
        response.put("message", message);
        return ResponseEntity.status(status).body(response);
    }
}
