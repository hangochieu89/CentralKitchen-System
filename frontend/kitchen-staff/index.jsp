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
    Hệ thống Quản lý Bếp Trung Tâm
  </div>
  <nav class="top-nav" aria-label="Top navigation">
    <button>🔔 Thông báo <span style="background:var(--accent);color:#fff;padding:1px 6px;border-radius:10px;font-size:.68rem;margin-left:2px">4</span></button>
    <button>Hỗ trợ</button>
  </nav>
  <div class="user-chip">
    <div class="avatar">NK</div>
    <span>Đình Phát &mdash; <span style="color:var(--accent);font-weight:600;">Bếp Trung Tâm</span></span>
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
    <span class="badge" id="badge-pending">
      <c:set var="pc" value="0"/>
      <c:forEach items="${orders}" var="o">
        <c:if test="${o.status == 'PENDING'}"><c:set var="pc" value="${pc+1}"/></c:if>
      </c:forEach>
      ${pc}
    </span>
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

</main>

<!-- ════════════════════════════════════════════════════════
     DIALOGS / MODALS
════════════════════════════════════════════════════════ -->

<!-- Modal: Chi tiết & xử lý đơn hàng -->
<dialog id="dlg-order">
  <header>
    <h3 id="dlg-order-title">Chi tiết đơn hàng</h3>
    <button class="btn btn-ghost btn-sm" onclick="document.getElementById('dlg-order').close()">✕</button>
  </header>
  <div class="dialog-body">
    <div class="form-grid">
      <div class="form-group">
        <label for="dlg-store">Cửa hàng</label>
        <input id="dlg-store" type="text" readonly style="background:var(--gray-50);" />
      </div>
      <div class="form-group">
        <label for="dlg-status">Trạng thái hiện tại</label>
        <input id="dlg-status" type="text" readonly style="background:var(--gray-50);" />
      </div>
      <div class="form-group">
        <label for="dlg-date">Ngày đặt</label>
        <input id="dlg-date" type="text" readonly style="background:var(--gray-50);" />
      </div>
      <div class="form-group">
        <label for="dlg-delivery">Thời gian giao</label>
        <input id="dlg-delivery" type="text" readonly style="background:var(--gray-50);" />
      </div>
    </div>
    <div>
      <p style="font-size:.78rem;font-weight:600;color:var(--gray-600);margin-bottom:8px;">Danh sách sản phẩm</p>
      <div id="dlg-items" class="item-list"></div>
    </div>
    <div class="form-group">
      <label for="dlg-note">Ghi chú</label>
      <textarea id="dlg-note" rows="2" readonly style="background:var(--gray-50);resize:none;"></textarea>
    </div>
  </div>
  <footer>
    <button class="btn btn-secondary" onclick="document.getElementById('dlg-order').close()">Đóng</button>
    <button class="btn btn-primary" id="dlg-confirm-btn" onclick="confirmOrderFromDialog()" style="display:none;">✓ Xác nhận</button>
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
        <input id="plan-date" type="date" />
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

<!-- Toast notification -->
<div id="status-toast"></div>

<!-- ════════════════════════════════════════════════════════
     JS – Shared utilities & Page Navigation
════════════════════════════════════════════════════════ -->
<script>
  // ── Page map ─────────────────────────────────────────────
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
    Object.values(pages).forEach(p => {
      const node = document.getElementById(p);
      if (node) node.style.display = 'none';
    });
    const target = document.getElementById(pages[id]);
    if (target) { target.style.display = 'flex'; target.style.flexDirection = 'column'; target.style.gap = '24px'; }
    document.querySelectorAll('nav.sidebar a').forEach(a => a.classList.remove('active'));
    if (el) el.classList.add('active');
    if (el && el.preventDefault) el.preventDefault();
    return false;
  }

  document.addEventListener('DOMContentLoaded', () => {
    showPage('dashboard', document.querySelector('nav.sidebar a.active'));
  });

  // ── Status helpers ────────────────────────────────────────
  function getStatusLabel(status) {
    const map = {
      PENDING:       'Chờ xử lý',
      CONFIRMED:     'Đã xác nhận',
      IN_PRODUCTION: 'Đang sản xuất',
      READY:         'Sẵn sàng giao',
      DELIVERING:    'Đang giao',
      DELIVERED:     'Đã giao',
      CANCELLED:     'Đã hủy'
    };
    return map[status] || status;
  }

  function getStatusBadge(status) {
    const cls = {
      PENDING: 'badge-pending', CONFIRMED: 'badge-process',
      IN_PRODUCTION: 'badge-process', READY: 'badge-done',
      DELIVERING: 'badge-process', DELIVERED: 'badge-done',
      CANCELLED: 'badge-alert'
    };
    return '<span class="badge ' + (cls[status] || 'badge-default') + '">' + getStatusLabel(status) + '</span>';
  }

  // ── Toast notification ────────────────────────────────────
  function showToast(msg, isError) {
    const t = document.getElementById('status-toast');
    t.textContent = msg;
    t.style.background = isError ? 'var(--red)' : 'var(--green)';
    t.classList.add('show');
    setTimeout(() => t.classList.remove('show'), 2800);
  }

  // ── Update order status via AJAX ──────────────────────────
  async function updateOrderStatus(orderId, newStatus) {
    try {
      const resp = await fetch('/kitchen-staff/orders/' + orderId + '/status?status=' + newStatus, {
        method: 'POST',
        headers: { 'X-Requested-With': 'XMLHttpRequest' }
      });
      if (resp.ok) {
        showToast('Đã cập nhật trạng thái đơn #ORD-' + orderId + ' → ' + getStatusLabel(newStatus));
        setTimeout(() => location.reload(), 900);
      } else {
        showToast('Lỗi cập nhật. Vui lòng thử lại.', true);
      }
    } catch (e) {
      showToast('Lỗi kết nối: ' + e.message, true);
    }
  }

  // ── Open order dialog (from dashboard) ───────────────────
  function openOrderDialog(oid) {
    const dataRow = document.getElementById('order-data-' + oid);
    if (!dataRow) { alert('Không tìm thấy dữ liệu đơn hàng.'); return; }

    const store    = dataRow.dataset.store;
    const date     = dataRow.dataset.date;
    const delivery = dataRow.dataset.delivery;
    const status   = dataRow.dataset.status;
    const note     = dataRow.dataset.note;
    const items    = dataRow.querySelectorAll('.order-item-entry');

    document.getElementById('dlg-order-title').textContent = 'Đơn hàng #ORD-' + oid;
    document.getElementById('dlg-store').value   = store;
    document.getElementById('dlg-date').value    = date || '—';
    document.getElementById('dlg-delivery').value = delivery || 'Chưa xác định';
    document.getElementById('dlg-status').value  = getStatusLabel(status);
    document.getElementById('dlg-note').value    = note || '';

    const itemsEl = document.getElementById('dlg-items');
    if (items.length === 0) {
      itemsEl.innerHTML = '<div class="item-row"><span class="text-muted">Không có sản phẩm.</span></div>';
    } else {
      itemsEl.innerHTML = '';
      items.forEach(item => {
        itemsEl.innerHTML +=
          '<div class="item-row">' +
            '<span class="item-name">' + item.dataset.name + '</span>' +
            '<span class="item-qty">' + item.dataset.qty + ' ' + item.dataset.unit + '</span>' +
          '</div>';
      });
    }

    // Nút xác nhận theo trạng thái
    const nextStatus = { PENDING: 'CONFIRMED', CONFIRMED: 'IN_PRODUCTION', IN_PRODUCTION: 'READY' };
    const btnLabels  = { PENDING: '✓ Xác nhận đơn', CONFIRMED: '▶ Bắt đầu SX', IN_PRODUCTION: '✅ Sẵn sàng' };
    const btn = document.getElementById('dlg-confirm-btn');
    if (nextStatus[status]) {
      btn.style.display = '';
      btn.textContent   = btnLabels[status];
      btn.dataset.oid   = oid;
      btn.dataset.next  = nextStatus[status];
    } else {
      btn.style.display = 'none';
    }

    document.getElementById('dlg-order').showModal();
  }

  async function confirmOrderFromDialog() {
    const btn  = document.getElementById('dlg-confirm-btn');
    const oid  = btn.dataset.oid;
    const next = btn.dataset.next;
    if (!oid || !next) return;
    document.getElementById('dlg-order').close();
    await updateOrderStatus(parseInt(oid), next);
  }
</script>
</body>
</html>
