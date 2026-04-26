package com.centralkitchen.backend.controller;

import com.centralkitchen.backend.dto.LoginRequest;
import com.centralkitchen.backend.entity.User;
import com.centralkitchen.backend.repository.UserRepository;
import jakarta.servlet.http.HttpSession;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

@Controller
@RequiredArgsConstructor
public class AuthController {

    private final UserRepository userRepository;
    private final BCryptPasswordEncoder passwordEncoder;

    // ── Hiển thị trang login ──────────────────────────────────────
    @GetMapping("/login")
    public String loginPage(@RequestParam(required = false) String error,
                            @RequestParam(required = false) String logout,
                            HttpSession session,
                            Model model) {
        // Nếu đã đăng nhập rồi thì redirect thẳng
        if (session.getAttribute("currentUser") != null) {
            return redirectByRole((User) session.getAttribute("currentUser"));
        }
        if (error != null)  model.addAttribute("error", "Tên đăng nhập hoặc mật khẩu không đúng.");
        if (logout != null) model.addAttribute("message", "Đăng xuất thành công.");
        return "forward:/login/index.jsp";
    }

    // ── Xử lý POST login ─────────────────────────────────────────
    @PostMapping("/auth/login")
    public String doLogin(@Valid @ModelAttribute LoginRequest req,
                          HttpSession session,
                          Model model) {

        User user = userRepository.findByUsername(req.getUsername()).orElse(null);

        if (user == null || !Boolean.TRUE.equals(user.getIsActive())
                || !passwordEncoder.matches(req.getPassword(), user.getPasswordHash())) {
            model.addAttribute("error", "Tên đăng nhập hoặc mật khẩu không đúng.");
            return "forward:/login/index.jsp";
        }

        // Lưu user vào session (30 phút timeout)
        session.setAttribute("currentUser", user);
        session.setMaxInactiveInterval(30 * 60);

        return redirectByRole(user);
    }

    // ── Đăng xuất ────────────────────────────────────────────────
    @GetMapping("/auth/logout")
    public String logout(HttpSession session) {
        session.invalidate();
        return "redirect:/login?logout";
    }

    // ── Helper: redirect theo role ────────────────────────────────
    private String redirectByRole(User user) {
        return switch (user.getRole()) {
            case "ADMIN", "MANAGER"          -> "redirect:/manager-admin";
            case "KITCHEN_STAFF"             -> "redirect:/kitchen-staff";
            case "STORE_STAFF"               -> "redirect:/store-staff";
            case "SUPPLY_COORDINATOR"        -> "redirect:/supply-coordinator";
            default                          -> "redirect:/login?error";
        };
    }
}