package com.centralkitchen.backend.controller;

import com.centralkitchen.backend.dto.LoginRequest;
import com.centralkitchen.backend.entity.User;
import com.centralkitchen.backend.repository.UserRepository;
import jakarta.servlet.http.HttpSession;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.LinkedHashMap;
import java.util.Map;

@Controller
@RequiredArgsConstructor
public class AuthController {

    private final UserRepository userRepository;
    private final BCryptPasswordEncoder passwordEncoder;

    /** Thông tin user đang đăng nhập (cho SPA supply-coordinator, v.v.) */
    @GetMapping("/api/session/me")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> currentUser(HttpSession session) {
        User raw = (User) session.getAttribute("currentUser");
        if (raw == null) {
            return ResponseEntity.status(401).build();
        }
        User u = userRepository.findByIdWithStore(raw.getId()).orElse(raw);
        session.setAttribute("currentUser", u);
        Map<String, Object> body = new LinkedHashMap<>();
        body.put("id", u.getId());
        body.put("username", u.getUsername());
        body.put("fullName", u.getFullName());
        body.put("role", u.getRole());
        body.put("storeId", u.getStore() != null ? u.getStore().getId() : null);
        body.put("storeName", u.getStore() != null ? u.getStore().getName() : null);
        return ResponseEntity.ok(body);
    }

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

        // Nạp lại user + cửa hàng (JOIN FETCH) để session luôn có store cho STORE_STAFF — tránh 403 API cửa hàng
        User sessionUser = userRepository.findByIdWithStore(user.getId()).orElse(user);

        // Lưu user vào session (30 phút timeout)
        session.setAttribute("currentUser", sessionUser);
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