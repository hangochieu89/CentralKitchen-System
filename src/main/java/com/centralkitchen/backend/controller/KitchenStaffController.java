package com.centralkitchen.backend.controller;

import com.centralkitchen.backend.entity.Order;
import com.centralkitchen.backend.entity.User;
import com.centralkitchen.backend.service.KitchenStaffService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import jakarta.servlet.http.HttpSession;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/kitchen-staff")
public class KitchenStaffController {

    @Autowired
    private KitchenStaffService kitchenStaffService;

    // ── Dashboard / Main page ─────────────────────────────────
    private static final Logger log = LoggerFactory.getLogger(KitchenStaffController.class);

    @GetMapping("/dashboard")
    public String dashboard(HttpSession session, Model model) {
        User current = (User) session.getAttribute("currentUser");
        model.addAttribute("currentUser", current);

        List<Order> orders = kitchenStaffService.getAllOrders();
        log.info("=== ORDERS COUNT: {} ===", orders.size());
        orders.forEach(o -> log.info("  Order #{} -> orderItems size: {}",
            o.getId(),
            o.getOrderItems() == null ? "NULL" : String.valueOf(o.getOrderItems().size())
        ));
        model.addAttribute("orders", orders);
        model.addAttribute("plans",         kitchenStaffService.getAllProductionPlans());
        model.addAttribute("batches",       kitchenStaffService.getAllProductBatches());
        model.addAttribute("inventories",   kitchenStaffService.getCentralKitchenInventories());
        model.addAttribute("receipts",      kitchenStaffService.getAllGoodsReceipts());
        model.addAttribute("receiptDetails",kitchenStaffService.getAllGoodsReceiptDetails());
        model.addAttribute("products",         kitchenStaffService.getAllProducts());
        model.addAttribute("finishedProducts",  kitchenStaffService.getFinishedProducts());
        model.addAttribute("kitchenUsers",  kitchenStaffService.getAllKitchenUsers());
        model.addAttribute("stores",        kitchenStaffService.getAllStores());
        model.addAttribute("suppliers",     kitchenStaffService.getAllSuppliers());
        return "forward:/kitchen-staff/index.jsp";
    }

    // ── Orders ────────────────────────────────────────────────
    @PostMapping("/orders/{id}/status")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> updateOrderStatus(
            @PathVariable Integer id,
            @RequestParam String status) {
        try {
            kitchenStaffService.updateOrderStatus(id, status);
            return ResponseEntity.ok(Map.of("success", true, "newStatus", status));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(Map.of("success", false, "error", e.getMessage()));
        }
    }

    // ── Production Plans ──────────────────────────────────────
    @PostMapping("/plans")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> createPlan(@RequestBody Map<String, Object> body) {
        try {
            var plan = kitchenStaffService.createProductionPlan(body);
            return ResponseEntity.ok(Map.of("success", true, "id", plan.getId()));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(Map.of("success", false, "error", e.getMessage()));
        }
    }

    @PutMapping("/plans/{id}")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> updatePlan(
            @PathVariable Integer id,
            @RequestBody Map<String, Object> body) {
        try {
            var plan = kitchenStaffService.updateProductionPlan(id, body);
            return ResponseEntity.ok(Map.of("success", true, "id", plan.getId(), "status", plan.getStatus()));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(Map.of("success", false, "error", e.getMessage()));
        }
    }

    // ── Product Batches ───────────────────────────────────────
    @PostMapping("/batches")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> createBatch(@RequestBody Map<String, Object> body) {
        try {
            var batch = kitchenStaffService.createProductBatch(body);
            return ResponseEntity.ok(Map.of("success", true, "id", batch.getId()));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(Map.of("success", false, "error", e.getMessage()));
        }
    }

    @PutMapping("/batches/{id}")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> updateBatch(
            @PathVariable Integer id,
            @RequestBody Map<String, Object> body) {
        try {
            var batch = kitchenStaffService.updateProductBatch(id, body);
            return ResponseEntity.ok(Map.of("success", true, "id", batch.getId()));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(Map.of("success", false, "error", e.getMessage()));
        }
    }

    // ── Inventory ─────────────────────────────────────────────
    @PostMapping("/inventory")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> addInventory(@RequestBody Map<String, Object> body) {
        try {
            var inv = kitchenStaffService.createOrUpdateInventory(body);
            return ResponseEntity.ok(Map.of("success", true, "id", inv.getId()));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(Map.of("success", false, "error", e.getMessage()));
        }
    }

    @PutMapping("/inventory/{id}")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> updateInventory(
            @PathVariable Integer id,
            @RequestBody Map<String, Object> body) {
        try {
            var inv = kitchenStaffService.updateInventory(id, body);
            return ResponseEntity.ok(Map.of("success", true, "id", inv.getId()));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(Map.of("success", false, "error", e.getMessage()));
        }
    }

    // ── Goods Receipts (Nguyên liệu đầu vào) ──────────────────
    @PostMapping("/inputs")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> addInput(@RequestBody Map<String, Object> body) {
        try {
            var detail = kitchenStaffService.createGoodsReceiptDetail(body);
            return ResponseEntity.ok(Map.of("success", true, "id", detail.getId()));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(Map.of("success", false, "error", e.getMessage()));
        }
    }
}