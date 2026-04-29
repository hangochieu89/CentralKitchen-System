package com.centralkitchen.backend.config;

import com.centralkitchen.backend.entity.User;
import com.centralkitchen.backend.repository.UserRepository;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

import java.util.List;

@Component
@RequiredArgsConstructor
public class ApiAuthInterceptor implements HandlerInterceptor {
    private final UserRepository userRepository;

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        if (userRepository.count() == 0) {
            // Cho phép khi chưa có user trong DB (chưa seed).
            return true;
        }

        String path = request.getRequestURI();
        String userIdHeader = request.getHeader("X-User-Id");
        String roleHeader = request.getHeader("X-User-Role");

        if (userIdHeader == null || roleHeader == null) {
            writeJsonError(response, HttpServletResponse.SC_UNAUTHORIZED,
                    "Thiếu header xác thực X-User-Id hoặc X-User-Role");
            return false;
        }

        Integer userId;
        try {
            userId = Integer.valueOf(userIdHeader);
        } catch (NumberFormatException ex) {
            writeJsonError(response, HttpServletResponse.SC_UNAUTHORIZED, "X-User-Id không hợp lệ");
            return false;
        }

        User user = userRepository.findById(userId).orElse(null);
        if (user == null || !Boolean.TRUE.equals(user.getIsActive())) {
            writeJsonError(response, HttpServletResponse.SC_UNAUTHORIZED, "Người dùng không tồn tại hoặc đã bị vô hiệu");
            return false;
        }
        if (!user.getRole().equals(roleHeader)) {
            writeJsonError(response, HttpServletResponse.SC_FORBIDDEN, "Vai trò không khớp với user");
            return false;
        }

        if (!isRoleAllowed(path, roleHeader)) {
            writeJsonError(response, HttpServletResponse.SC_FORBIDDEN, "Không có quyền truy cập tài nguyên này");
            return false;
        }

        request.setAttribute("authUser", user);
        return true;
    }

    private boolean isRoleAllowed(String path, String role) {
        if (path.startsWith("/api/admin")) {
            return "ADMIN".equals(role);
        }
        if (path.startsWith("/api/manager")) {
            return List.of("MANAGER", "ADMIN").contains(role);
        }
        if (path.startsWith("/api/store-staff")) {
            return List.of("STORE_STAFF", "MANAGER", "ADMIN").contains(role);
        }
        if (path.startsWith("/api/supply-coordinator")) {
            return List.of("SUPPLY_COORDINATOR", "MANAGER", "ADMIN").contains(role);
        }
        if (path.startsWith("/api/kitchen-staff")) {
            return List.of("KITCHEN_STAFF", "SUPPLY_COORDINATOR", "MANAGER", "ADMIN").contains(role);
        }
        return false;
    }

    private void writeJsonError(HttpServletResponse response, int status, String message) throws Exception {
        response.setStatus(status);
        response.setContentType(MediaType.APPLICATION_JSON_VALUE);
        response.getWriter().write("{\"success\":false,\"message\":\"" + message.replace("\"", "\\\"") + "\"}");
    }
}
