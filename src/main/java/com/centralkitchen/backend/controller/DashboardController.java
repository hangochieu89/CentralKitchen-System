package com.centralkitchen.backend.controller;

import com.centralkitchen.backend.entity.User;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class DashboardController {

    @GetMapping("/")
    public String home(HttpSession session) {
        if (session.getAttribute("currentUser") == null)
            return "redirect:/login";
        return "redirect:/dashboard";
    }

    @GetMapping("/dashboard")
    public String dashboard(HttpSession session, Model model) {
        User user = (User) session.getAttribute("currentUser");
        if (user == null) return "redirect:/login";
        model.addAttribute("currentUser", user);
        return "forward:/dashboard/index.jsp";
    }

    @GetMapping("/manager-admin")
    public String managerAdmin()      { return "redirect:/manager-admin/index.html"; }

    @GetMapping("/kitchen-staff")
    public String kitchenStaff(HttpSession session) {
        User user = (User) session.getAttribute("currentUser");
        if (user == null) {
            return "redirect:/login";
        }
        if (!"KITCHEN_STAFF".equals(user.getRole())) {
            return "redirect:/dashboard";
        }
        return "redirect:/kitchen-staff/dashboard";
    }

    @GetMapping("/store-staff")
    public String storeStaff(HttpSession session) {
        User user = (User) session.getAttribute("currentUser");
        if (user == null) {
            return "redirect:/login";
        }
        if (!"STORE_STAFF".equals(user.getRole()) || user.getStore() == null) {
            return "redirect:/dashboard";
        }
        return "redirect:/store-staff/index.html";
    }

    @GetMapping("/supply-coordinator")
    public String supplyCoordinator(HttpSession session) {
        User user = (User) session.getAttribute("currentUser");
        if (user == null) {
            return "redirect:/login";
        }
        if (!"SUPPLY_COORDINATOR".equals(user.getRole())) {
            return "redirect:/dashboard";
        }
        return "redirect:/supply-coordinator/index.html";
    }
}