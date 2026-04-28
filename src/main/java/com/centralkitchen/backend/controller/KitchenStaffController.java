package com.centralkitchen.backend.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/kitchen-staff")
public class KitchenStaffController {

    @GetMapping("/dashboard")
    public String dashboard() {
        return "forward:/kitchen-staff/index.jsp";
    }
}
