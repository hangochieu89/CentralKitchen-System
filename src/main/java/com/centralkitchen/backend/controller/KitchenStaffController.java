package com.centralkitchen.backend.controller;

import com.centralkitchen.backend.service.KitchenStaffService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

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
        model.addAttribute("inventories", kitchenStaffService.getAllInventories());
        model.addAttribute("receipts", kitchenStaffService.getAllGoodsReceipts());
        model.addAttribute("receiptDetails", kitchenStaffService.getAllGoodsReceiptDetails());
        
        return "forward:/kitchen-staff/index.jsp";
    }
}
