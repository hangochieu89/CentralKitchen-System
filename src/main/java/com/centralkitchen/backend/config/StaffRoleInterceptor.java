package com.centralkitchen.backend.config;

import com.centralkitchen.backend.entity.User;
import com.centralkitchen.backend.repository.UserRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

import java.util.Map;

/**
 * Giới hạn API/trang theo vai trò: điều phối cung ứng vs nhân viên bếp.
 */
@Component
@RequiredArgsConstructor
public class StaffRoleInterceptor implements HandlerInterceptor {

    private final ObjectMapper objectMapper;
    private final UserRepository userRepository;

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler)
            throws Exception {
        String path = request.getRequestURI().substring(request.getContextPath().length());

        if (!path.startsWith("/api/supply-coordinator")
                && !path.startsWith("/kitchen-staff")
                && !path.startsWith("/api/store-staff")) {
            return true;
        }

        HttpSession session = request.getSession(false);
        User user = session == null ? null : (User) session.getAttribute("currentUser");
        if (user != null && "STORE_STAFF".equals(user.getRole()) && user.getStore() == null) {
            userRepository.findByIdWithStore(user.getId()).ifPresent(fresh -> {
                if (fresh.getStore() != null) {
                    session.setAttribute("currentUser", fresh);
                }
            });
            user = (User) session.getAttribute("currentUser");
        }
        if (user == null) {
            if (path.startsWith("/api/store-staff")) {
                writeJson(response, HttpServletResponse.SC_UNAUTHORIZED, "Cần đăng nhập để gọi API cửa hàng.");
                return false;
            }
            return true;
        }

        if (path.startsWith("/api/supply-coordinator")) {
            if (!"SUPPLY_COORDINATOR".equals(user.getRole())) {
                writeJson(response, HttpServletResponse.SC_FORBIDDEN,
                        "Chỉ tài khoản Điều phối cung ứng mới được gọi API này.");
                return false;
            }
        }

        if (path.startsWith("/kitchen-staff")) {
            if (!"KITCHEN_STAFF".equals(user.getRole())) {
                if ("GET".equalsIgnoreCase(request.getMethod())) {
                    response.sendRedirect(request.getContextPath() + "/dashboard");
                } else {
                    writeJson(response, HttpServletResponse.SC_FORBIDDEN,
                            "Chỉ tài khoản Nhân viên bếp mới được thực hiện thao tác này.");
                }
                return false;
            }
        }

        if (path.startsWith("/api/store-staff")) {
            if (!"STORE_STAFF".equals(user.getRole()) || user.getStore() == null) {
                writeJson(response, HttpServletResponse.SC_FORBIDDEN,
                        "Chỉ nhân viên cửa hàng franchise (được gán chi nhánh) mới được gọi API này.");
                return false;
            }
        }

        return true;
    }

    private void writeJson(HttpServletResponse response, int status, String message) throws Exception {
        response.setStatus(status);
        response.setContentType(MediaType.APPLICATION_JSON_VALUE);
        response.setCharacterEncoding("UTF-8");
        response.getWriter().write(objectMapper.writeValueAsString(
                Map.of("success", false, "message", message)));
    }
}
