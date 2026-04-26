package com.centralkitchen.backend.config;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import org.springframework.stereotype.Component;
import java.io.IOException;
import java.util.List;

@Component
public class SessionFilter implements Filter {

    // Các URL không cần đăng nhập
    private static final List<String> PUBLIC_PATHS = List.of(
            "/login", "/auth/login", "/auth/logout",
            "/css/", "/image/", "/js/"
    );

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest  request  = (HttpServletRequest)  req;
        HttpServletResponse response = (HttpServletResponse) res;

        String path = request.getRequestURI()
                .substring(request.getContextPath().length());

        // Cho qua nếu là public path
        boolean isPublic = PUBLIC_PATHS.stream().anyMatch(path::startsWith);
        if (isPublic) {
            chain.doFilter(req, res);
            return;
        }

        // Kiểm tra session
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        chain.doFilter(req, res);
    }
}