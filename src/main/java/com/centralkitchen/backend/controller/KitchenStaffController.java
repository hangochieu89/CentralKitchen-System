package com.centralkitchen.backend.controller;

import com.centralkitchen.backend.service.KitchenStaffService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@Controller
@RequestMapping("/kitchen-staff")
public class KitchenStaffController {

    @Autowired
    private KitchenStaffService kitchenStaffService;

    @GetMapping("/dashboard")
    public String dashboard(Model model) {
        model.addAttribute("orders", kitchenStaffService.getAllOrders());
        model.addAttribute("plans", kitchenStaffService.getAllProductionPlans());
        model.addAttribute("batches", kitchenStaffService.getAllProductBatches());
        model.addAttribute("inventories", kitchenStaffService.getCentralKitchenInventories());
        model.addAttribute("receipts", kitchenStaffService.getAllGoodsReceipts());
        model.addAttribute("receiptDetails", kitchenStaffService.getAllGoodsReceiptDetails());

        return "forward:/kitchen-staff/index.jsp";
    }

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
}
