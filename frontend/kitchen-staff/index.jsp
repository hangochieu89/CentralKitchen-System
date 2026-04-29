<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/kitchen-staff-styles.css">
  <title>Central Kitchen Staff</title>
  <link href="https://fonts.googleapis.com/css2?family=DM+Mono:wght@400;500&family=DM+Sans:ital,opsz,wght@0,9..40,300;0,9..40,500;0,9..40,700;1,9..40,300&display=swap" rel="stylesheet" />
</head>
<body>

<!-- ════════════════════════════════════════════════════════
     HEADER
════════════════════════════════════════════════════════ -->
<header>
  <div class="brand">
    <div class="logo-mark">🍳</div>
    Hệ thống Quản lý Bếp Trung Tâm và Cửa hàng
  </div>
  <nav class="top-nav" aria-label="Top navigation">
    <button>Thông báo <span style="background:#e05c2a;color:#fff;padding:1px 6px;border-radius:10px;font-size:.68rem;margin-left:2px">4</span></button>
    <button>Hỗ trợ</button>
  </nav>
  <div class="user-chip">
    <div class="avatar">NK</div>
    <span>Đình Phát  &mdash; <span style="color:#e05c2a">Bếp Trung Tâm</span></span>
  </div>
</header>

<!-- ════════════════════════════════════════════════════════
     SIDEBAR
════════════════════════════════════════════════════════ -->
<nav class="sidebar" aria-label="Sidebar navigation">
  <span class="nav-section-label">Tổng quan</span>
  <a href="#dashboard" class="active" onclick="showPage('dashboard',this)">
    <span class="icon">📊</span> Dashboard
  </a>

  <span class="nav-section-label">Đơn hàng</span>
  <a href="#orders" onclick="showPage('orders',this)">
    <span class="icon">📋</span> Tiếp nhận đơn
    <span class="badge">7</span>
  </a>
  <a href="#dispatch" onclick="showPage('dispatch',this)">
    <span class="icon">🚚</span> Xuất kho &amp; Giao hàng
  </a>

  <span class="nav-section-label">Sản xuất</span>
  <a href="#production" onclick="showPage('production',this)">
    <span class="icon">⚙️</span> Kế hoạch SX
  </a>
  <a href="#batches" onclick="showPage('batches',this)">
    <span class="icon">🏷️</span> Lô sản xuất
  </a>

  <span class="nav-section-label">Kho &amp; Nguyên liệu</span>
  <a href="#inventory" onclick="showPage('inventory',this)">
    <span class="icon">📦</span> Tồn kho
  </a>
  <a href="#inputs" onclick="showPage('inputs',this)">
    <span class="icon">🥩</span> Nguyên liệu đầu vào
  </a>
</nav>

<!-- ════════════════════════════════════════════════════════
     MAIN
════════════════════════════════════════════════════════ -->
<main>

  <jsp:include page="dashboard.jsp" />

  <jsp:include page="orders.jsp" />

  <jsp:include page="production.jsp" />

  <jsp:include page="batches.jsp" />

  <jsp:include page="inventory.jsp" />

  <jsp:include page="inputs.jsp" />

  <jsp:include page="dispatch.jsp" />

</main><!-- /main -->


<!-- ════════════════════════════════════════════════════════
     DIALOGS / MODALS
════════════════════════════════════════════════════════ -->

<!-- Modal: Xử lý đơn hàng -->
<dialog id="dlg-order">
  <header>
    <h3>Xử lý đơn hàng #ORD-2341</h3>
    <button class="btn btn-ghost btn-sm" onclick="document.getElementById('dlg-order').close()">✕</button>
  </header>
  <div class="dialog-body">
    <fieldset>
      <legend>Thông tin đơn</legend>
      <div class="form-grid">
        <div class="form-group">
          <label>Cửa hàng</label>
          <input type="text" value="CH Quận 1" readonly style="background:var(--gray-50);" />
        </div>
        <div class="form-group">
          <label>Thời gian cần nhận</label>
          <input type="text" value="18/03 13:00" readonly style="background:var(--gray-50);" />
        </div>
      </div>
    </fieldset>
    <fieldset>
      <legend>Phân công sản xuất</legend>
      <div class="form-grid">
        <div class="form-group">
          <label for="assign-staff">Nhân sự phụ trách</label>
          <select id="assign-staff">
            <option>Trần Văn A</option>
            <option>Lê Thị B</option>
            <option>Nguyễn Văn C</option>
          </select>
        </div>
        <div class="form-group">
          <label for="assign-eta">Thời gian dự kiến xong</label>
          <input id="assign-eta" type="datetime-local" value="2026-03-18T12:00" />
        </div>
        <div class="form-group full">
          <label for="assign-note">Ghi chú</label>
          <textarea id="assign-note" rows="2" placeholder="Lưu ý khi sản xuất…"></textarea>
        </div>
      </div>
    </fieldset>
  </div>
  <footer>
    <button class="btn btn-secondary" onclick="document.getElementById('dlg-order').close()">Hủy</button>
    <button class="btn btn-primary" onclick="document.getElementById('dlg-order').close()">✓ Xác nhận xử lý</button>
  </footer>
</dialog>

<!-- Modal: Tạo kế hoạch SX -->
<dialog id="dlg-plan">
  <header>
    <h3>Tạo kế hoạch sản xuất</h3>
    <button class="btn btn-ghost btn-sm" onclick="document.getElementById('dlg-plan').close()">✕</button>
  </header>
  <div class="dialog-body">
    <div class="form-grid">
      <div class="form-group">
        <label for="plan-prod">Sản phẩm</label>
        <select id="plan-prod">
          <option>Phở bò sơ chế</option>
          <option>Bún bò Huế</option>
          <option>Nước dùng gà</option>
          <option>Chả lụa</option>
          <option>Cháo trắng</option>
        </select>
      </div>
      <div class="form-group">
        <label for="plan-qty">Số lượng (kg / L)</label>
        <input id="plan-qty" type="number" placeholder="0.0" step="0.5" />
      </div>
      <div class="form-group">
        <label for="plan-shift">Ca sản xuất</label>
        <select id="plan-shift">
          <option>Ca sáng (06:00–14:00)</option>
          <option>Ca chiều (14:00–22:00)</option>
          <option>Ca đêm (22:00–06:00)</option>
        </select>
      </div>
      <div class="form-group">
        <label for="plan-date">Ngày sản xuất</label>
        <input id="plan-date" type="date" value="2026-03-18" />
      </div>
      <div class="form-group full">
        <label for="plan-remark">Ghi chú</label>
        <textarea id="plan-remark" rows="2" placeholder="Yêu cầu đặc biệt…"></textarea>
      </div>
    </div>
  </div>
  <footer>
    <button class="btn btn-secondary" onclick="document.getElementById('dlg-plan').close()">Hủy</button>
    <button class="btn btn-primary" onclick="document.getElementById('dlg-plan').close()">💾 Tạo kế hoạch</button>
  </footer>
</dialog>

<!-- Modal: Nhập nguyên liệu -->
<dialog id="dlg-input">
  <header>
    <h3>Nhập nguyên liệu đầu vào</h3>
    <button class="btn btn-ghost btn-sm" onclick="document.getElementById('dlg-input').close()">✕</button>
  </header>
  <div class="dialog-body">
    <div class="form-grid">
      <div class="form-group">
        <label for="inp-name">Tên nguyên liệu</label>
        <input id="inp-name" type="text" placeholder="VD: Thịt bò tươi" />
      </div>
      <div class="form-group">
        <label for="inp-supplier">Nhà cung cấp</label>
        <input id="inp-supplier" type="text" placeholder="VD: Nam Phong Foods" />
      </div>
      <div class="form-group">
        <label for="inp-qty">Số lượng</label>
        <input id="inp-qty" type="number" placeholder="0.0" step="0.1" />
      </div>
      <div class="form-group">
        <label for="inp-unit">Đơn vị</label>
        <select id="inp-unit">
          <option>kg</option><option>g</option><option>L</option><option>ml</option><option>cái</option><option>hộp</option>
        </select>
      </div>
      <div class="form-group">
        <label for="inp-mfg">Ngày sản xuất</label>
        <input id="inp-mfg" type="date" />
      </div>
      <div class="form-group">
        <label for="inp-exp">Hạn sử dụng</label>
        <input id="inp-exp" type="date" />
      </div>
      <div class="form-group full">
        <label for="inp-note">Ghi chú / Kiểm tra chất lượng</label>
        <textarea id="inp-note" rows="2" placeholder="KQ kiểm tra đầu vào, nhiệt độ khi nhận…"></textarea>
      </div>
    </div>
  </div>
  <footer>
    <button class="btn btn-secondary" onclick="document.getElementById('dlg-input').close()">Hủy</button>
    <button class="btn btn-primary" onclick="document.getElementById('dlg-input').close()">💾 Lưu nhập kho</button>
  </footer>
</dialog>

<!-- ════════════════════════════════════════════════════════
     JS – Page Navigation
════════════════════════════════════════════════════════ -->
<script>
  const pages = {
    dashboard:  'page-dashboard',
    orders:     'page-orders',
    production: 'page-production',
    batches:    'page-batches',
    inventory:  'page-inventory',
    inputs:     'page-inputs',
    dispatch:   'page-dispatch',
  };

  function showPage(id, el) {
    // Hide all pages
    Object.values(pages).forEach(p => {
      const el = document.getElementById(p);
      if (el) el.style.display = 'none';
    });
    // Show target
    const target = document.getElementById(pages[id]);
    if (target) target.style.display = 'flex', target.style.flexDirection = 'column', target.style.gap = '24px';

    // Update active nav
    document.querySelectorAll('nav.sidebar a').forEach(a => a.classList.remove('active'));
    if (el) el.classList.add('active');

    if (el) { el.preventDefault && el.preventDefault(); }
    return false;
  }

  // Init
  document.addEventListener('DOMContentLoaded', () => {
    showPage('dashboard', document.querySelector('nav.sidebar a.active'));
  });
</script>
</body>
</html>