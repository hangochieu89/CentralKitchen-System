package com.centralkitchen.backend.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class DashboardController {

    @GetMapping("/")
    public String home() {
        return "redirect:/dashboard/index.jsp";
    }

    @GetMapping("/dashboard")
    public String dashboard() {
        return "redirect:/dashboard/index.jsp";
    }

    @GetMapping("/store-staff")
    public String storeStaff() {
        return "redirect:/store-staff/index.html";
    }

    @GetMapping("/supply-coordinator")
    public String supplyCoordinator() {
        return "redirect:/supply-coordinator/index.html";
    }

    @GetMapping("/kitchen-staff")
    public String kitchenStaff() {
        return "redirect:/kitchen-staff/index.jsp";
    }

    @GetMapping("/manager")
    public String manager() {
        return "redirect:/manager-admin/index.html";
    }

    @GetMapping("/admin")
    public String admin() {
        return "redirect:/manager-admin/index.html";
    }

}
