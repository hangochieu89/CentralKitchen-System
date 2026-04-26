<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng nhập – Central Kitchen System</title>
    <link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary: #e05c2a;
            --primary-hover: #c44e20;
            --bg: #f9fafb;
            --text: #1f2937;
            --border: #e5e7eb;
        }
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body {
            font-family: 'DM Sans', sans-serif;
            background: var(--bg);
            color: var(--text);
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
        }
        .card {
            background: white;
            padding: 40px;
            border-radius: 14px;
            box-shadow: 0 4px 24px rgba(0,0,0,0.09);
            width: 100%;
            max-width: 400px;
        }
        .logo {
            text-align: center;
            margin-bottom: 28px;
        }
        .logo h1 { color: var(--primary); font-size: 22px; }
        .logo p  { color: #6b7280; font-size: 13px; margin-top: 4px; }

        .alert {
            padding: 10px 14px;
            border-radius: 8px;
            font-size: 14px;
            margin-bottom: 18px;
        }
        .alert-error   { background: #fef2f2; color: #b91c1c; border: 1px solid #fecaca; }
        .alert-success { background: #f0fdf4; color: #166534; border: 1px solid #bbf7d0; }

        label { display: block; font-size: 14px; font-weight: 500; margin-bottom: 6px; }
        .field { margin-bottom: 18px; }
        input[type=text], input[type=password] {
            width: 100%;
            padding: 10px 14px;
            border: 1px solid var(--border);
            border-radius: 8px;
            font-size: 15px;
            font-family: inherit;
            outline: none;
            transition: border-color .2s;
        }
        input:focus { border-color: var(--primary); }

        button[type=submit] {
            width: 100%;
            padding: 12px;
            background: var(--primary);
            color: white;
            border: none;
            border-radius: 8px;
            font-size: 15px;
            font-weight: 600;
            font-family: inherit;
            cursor: pointer;
            transition: background .2s;
        }
        .pw-wrap {
            position: relative;
        }
        .pw-wrap input {
            padding-right: 42px;
        }
        .pw-toggle {
            position: absolute;
            right: 12px;
            top: 50%;
            transform: translateY(-50%);
            background: none;
            border: none;
            cursor: pointer;
            color: #9ca3af;
            padding: 0;
            display: flex;
            align-items: center;
            transition: color .2s;
        }
        .pw-toggle:hover { color: var(--primary); }
        .pw-toggle svg { width: 18px; height: 18px; }
        button[type=submit]:hover { background: var(--primary-hover); }
    </style>
</head>
<body>
<div class="card">
    <div class="logo">
        <h1>Central Kitchen System</h1>
        <p>Vui lòng đăng nhập để tiếp tục</p>
    </div>

    <%-- Hiển thị thông báo lỗi / thành công --%>
    <% if (request.getAttribute("error") != null) { %>
        <div class="alert alert-error">${error}</div>
    <% } %>
    <% if (request.getAttribute("message") != null) { %>
        <div class="alert alert-success">${message}</div>
    <% } %>

    <form action="${pageContext.request.contextPath}/auth/login" method="post">
        <div class="field">
            <label for="username">Tên đăng nhập</label>
            <input type="text" id="username" name="username"
                   placeholder="Nhập username..." autocomplete="username" required>
        </div>
        <div class="field">
            <label for="password">Mật khẩu</label>
            <div class="pw-wrap">
                <input type="password" id="password" name="password"
                       placeholder="Nhập mật khẩu..." autocomplete="current-password" required>
                <button type="button" class="pw-toggle" onclick="togglePw()" title="Hiện/ẩn mật khẩu">
                    <svg id="eye-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"
                         fill="none" stroke="currentColor" stroke-width="2"
                         stroke-linecap="round" stroke-linejoin="round">
                        <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/>
                        <circle cx="12" cy="12" r="3"/>
                    </svg>
                </button>
            </div>
        </div>
        <button type="submit">Đăng nhập</button>
    </form>
</div>
<script>
function togglePw() {
    const input = document.getElementById('password');
    const icon  = document.getElementById('eye-icon');
    const show  = input.type === 'password';
    input.type  = show ? 'text' : 'password';
    icon.innerHTML = show
        ? `<path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94"/>
           <path d="M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19"/>
           <line x1="1" y1="1" x2="23" y2="23"/>`
        : `<path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/>
           <circle cx="12" cy="12" r="3"/>`;
}
</script>
</body>
</html>