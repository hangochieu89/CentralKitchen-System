<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Central Kitchen System - Dashboard Home</title>
    <link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;700&display=swap" rel="stylesheet">
    <script src="https://unpkg.com/lucide@latest/dist/umd/lucide.js"></script>
    <style>
        :root {
            --primary: #e05c2a;
            --primary-hover: #c44e20;
            --bg: #f9fafb;
            --text: #1f2937;
            --border: #e5e7eb;
        }
        
        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        body {
            font-family: 'DM Sans', sans-serif;
            background-color: var(--bg);
            color: var(--text);
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            padding: 20px;
        }

        .container {
            background: white;
            padding: 40px;
            border-radius: 12px;
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
            width: 100%;
            max-width: 600px;
        }

        h1 {
            text-align: center;
            margin-bottom: 8px;
            color: var(--primary);
            font-size: 24px;
        }

        p.subtitle {
            text-align: center;
            color: #6b7280;
            margin-bottom: 30px;
            font-size: 15px;
        }

        .role-list {
            display: flex;
            flex-direction: column;
            gap: 12px;
        }

        .role-card {
            display: flex;
            align-items: center;
            padding: 16px 20px;
            background: #fdf2f0;
            border: 1px solid #ffd9cc;
            border-radius: 8px;
            text-decoration: none;
            color: var(--text);
            transition: all 0.2s ease;
            font-weight: 500;
        }

        .role-card:hover {
            background: var(--primary);
            color: white;
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(224, 92, 42, 0.2);
        }

        .role-card .icon {
            font-size: 24px;
            margin-right: 16px;
        }

        .role-card .info {
            flex: 1;
        }

        .role-card .info span {
            display: block;
            font-size: 16px;
        }

        .role-card .info small {
            display: block;
            font-size: 13px;
            opacity: 0.8;
            margin-top: 4px;
            font-weight: 400;
        }
        
        .role-card:hover .info small {
            color: rgba(255, 255, 255, 0.9);
        }

        .not-ready {
            opacity: 0.6;
            cursor: not-allowed;
        }
        
        .not-ready:hover {
            background: #fdf2f0;
            color: var(--text);
            transform: none;
            box-shadow: none;
        }

        .icon-wrap {
            width: 36px; height: 36px;
            display: flex; align-items: center; justify-content: center;
            background: rgba(0,0,0,0.04);
            border-radius: 8px;
            margin-right: 14px;
            flex-shrink: 0;
        }
        .icon-wrap svg { width: 18px; height: 18px; }
        .icon-trail { width: 16px; height: 16px; opacity: 0.4; }
    </style>
</head>
<body>
        <div class="container">

            <%-- Header: hiển thị tên user --%>
            <h1>Central Kitchen System</h1>
            <p class="subtitle">
                Xin chào, <strong>${currentUser.fullName}</strong> · Chọn phân hệ để truy cập
            </p>

            <div class="role-list">

                <%-- Chỉ ADMIN và MANAGER thấy --%>
                <c:if test="${currentUser.role == 'ADMIN' || currentUser.role == 'MANAGER'}">
                    <a href="${pageContext.request.contextPath}/manager-admin" class="role-card">
                        <div class="icon-wrap"><i data-lucide="settings-2"></i></div>
                        <div class="info">
                            <span>Admin / Manager</span>
                            <small>Quản trị hệ thống</small>
                        </div>
                        <i data-lucide="chevron-right" class="icon-trail"></i>
                    </a>
                </c:if>

                <%-- Chỉ KITCHEN_STAFF thấy --%>
                <c:if test="${currentUser.role == 'KITCHEN_STAFF'}">
                    <a href="${pageContext.request.contextPath}/kitchen-staff" class="role-card">
                        <div class="icon-wrap"><i data-lucide="utensils"></i></div>
                        <div class="info">
                            <span>Central Kitchen Staff</span>
                            <small>Nhân viên bếp trung tâm</small>
                        </div>
                        <i data-lucide="chevron-right" class="icon-trail"></i>
                    </a>
                </c:if>

                <%-- Chỉ STORE_STAFF thấy --%>
                <c:if test="${currentUser.role == 'STORE_STAFF'}">
                    <a href="${pageContext.request.contextPath}/store-staff" class="role-card">
                        <div class="icon-wrap"><i data-lucide="store"></i></div>
                        <div class="info">
                            <span>Franchise Store Staff</span>
                            <small>Nhân viên cửa hàng</small>
                        </div>
                        <i data-lucide="chevron-right" class="icon-trail"></i>
                    </a>
                </c:if>

                <%-- Chỉ SUPPLY_COORDINATOR thấy --%>
                <c:if test="${currentUser.role == 'SUPPLY_COORDINATOR'}">
                    <a href="${pageContext.request.contextPath}/supply-coordinator" class="role-card">
                        <div class="icon-wrap"><i data-lucide="truck"></i></div>
                        <div class="info">
                            <span>Supply Coordinator</span>
                            <small>Tổng hợp đơn franchise · xác nhận · lập lịch giao · xử lý sự cố</small>
                        </div>
                        <i data-lucide="chevron-right" class="icon-trail"></i>
                    </a>
                </c:if>

                <%-- Nút đăng xuất --%>
                <a href="${pageContext.request.contextPath}/auth/logout"
                   class="role-card"
                   style="border-color:#ffd9cc;color:#e05c2a;margin-top:8px;">
                    <div class="icon-wrap"><i data-lucide="log-out"></i></div>
                    <div class="info">
                        <span>Đăng xuất</span>
                        <small>Thoát khỏi hệ thống</small>
                    </div>
                </a>

            </div>
        </div>
      <script>lucide.createIcons();</script>
</body>
</html>