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
}
