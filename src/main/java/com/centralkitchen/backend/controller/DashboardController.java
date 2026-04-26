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
    public String kitchenStaff()      { return "redirect:/kitchen-staff/index.jsp"; }

    @GetMapping("/store-staff")
    public String storeStaff()        { return "redirect:/store-staff/index.html"; }

    @GetMapping("/supply-coordinator")
    public String supplyCoordinator() { return "redirect:/supply-coordinator/index.html"; }
}