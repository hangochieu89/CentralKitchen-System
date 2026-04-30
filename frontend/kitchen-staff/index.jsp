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

<!-- ════════════════ HEADER ════════════════ -->
<header>
  <div class="brand">
    <div class="logo-mark">🍳</div>
    Hệ thống Quản lý Bếp Trung Tâm
  </div>
  <nav class="top-nav" aria-label="Top navigation"></nav>
  <div class="user-chip">
    <div class="avatar">NK</div>
    <span>Đình Phát &mdash; <span style="color:var(--accent);font-weight:600;">Bếp Trung Tâm</span></span>
    <a href="/auth/logout" class="btn btn-ghost btn-sm" style="margin-left:8px;">🚪 Đăng xuất</a>
  </div>
</header>

<!-- ════════════════ SIDEBAR ════════════════ -->
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
  <span class="nav-section-label">Kho &amp; Nguyên liệu</span>
  <a href="#inventory" onclick="showPage('inventory',this)">
    <span class="icon">📦</span> Tồn kho
  </a>
  <a href="#inputs" onclick="showPage('inputs',this)">
    <span class="icon">🥩</span> Nguyên liệu đầu vào
  </a>
</nav>

<!-- ════════════════ MAIN ════════════════ -->
<main>
  <jsp:include page="dashboard.jsp" />
  <jsp:include page="orders.jsp" />
  <jsp:include page="production.jsp" />
  <jsp:include page="inventory.jsp" />
  <jsp:include page="inputs.jsp" />
  <jsp:include page="dispatch.jsp" />
</main>

<!-- ════════════════ DIALOGS ════════════════ -->

<!-- Modal: Chi tiết đơn hàng (từ dashboard) -->
<dialog id="dlg-order">
  <header>
    <h3 id="dlg-order-title">Chi tiết đơn hàng</h3>
    <button class="btn btn-ghost btn-sm" onclick="document.getElementById('dlg-order').close()">✕</button>
  </header>
  <div class="dialog-body">
    <div class="form-grid">
      <div class="form-group">
        <label>Cửa hàng</label>
        <input id="dlg-store" type="text" readonly style="background:var(--gray-50);" />
      </div>
      <div class="form-group">
        <label>Trạng thái hiện tại</label>
        <input id="dlg-status" type="text" readonly style="background:var(--gray-50);" />
      </div>
      <div class="form-group">
        <label>Ngày đặt</label>
        <input id="dlg-date" type="text" readonly style="background:var(--gray-50);" />
      </div>
      <div class="form-group">
        <label>Thời gian giao</label>
        <input id="dlg-delivery" type="text" readonly style="background:var(--gray-50);" />
      </div>
    </div>
    <div class="form-group">
      <p style="font-size:.78rem;font-weight:600;color:var(--gray-600);margin-bottom:8px;">Danh sách sản phẩm</p>
      <div id="dlg-items" class="item-list"></div>
    </div>
    <div class="form-group">
      <label>Ghi chú</label>
      <textarea id="dlg-note" rows="2" readonly style="background:var(--gray-50);resize:none;"></textarea>
    </div>
  </div>
  <footer>
    <button class="btn btn-secondary" onclick="document.getElementById('dlg-order').close()">Đóng</button>
    <button class="btn btn-primary" id="dlg-confirm-btn" onclick="confirmOrderFromDialog()" style="display:none;">✓ Xác nhận</button>
  </footer>
</dialog>

<!-- Modal: Tạo kế hoạch SX -->
<dialog id="dlg-plan" style="width:680px;max-width:95vw;">
  <header>
    <h3>Tạo kế hoạch sản xuất</h3>
    <button class="btn btn-ghost btn-sm" onclick="document.getElementById('dlg-plan').close()">✕</button>
  </header>
  <div class="dialog-body">

    <!-- Bước 1: Chọn sản phẩm -->
    <div style="margin-bottom:16px;">
      <p style="font-size:.78rem;font-weight:700;color:var(--gray-500);text-transform:uppercase;letter-spacing:.05em;margin-bottom:8px;">Bước 1 — Chọn sản phẩm cần sản xuất</p>
      <div class="form-grid">
        <div class="form-group full">
          <label for="plan-product">Thành phẩm cần sản xuất</label>
          <select id="plan-product" onchange="onPlanProductChange()">
            <option value="">-- Chọn thành phẩm --</option>
            <c:forEach items="${finishedProducts}" var="p">
              <option value="${p.id}" data-unit="${p.unit}">${p.name}</option>
            </c:forEach>
          </select>
        </div>
      </div>
    </div>

    <!-- Bước 2: Chọn đơn hàng gộp vào -->
    <div id="plan-orders-section" style="margin-bottom:16px;display:none;">
      <p style="font-size:.78rem;font-weight:700;color:var(--gray-500);text-transform:uppercase;letter-spacing:.05em;margin-bottom:8px;">Bước 2 — Chọn đơn hàng gộp vào kế hoạch này</p>
      <div id="plan-orders-list" style="display:flex;flex-direction:column;gap:8px;max-height:220px;overflow-y:auto;"></div>
      <div style="margin-top:8px;padding:10px 14px;background:var(--gray-50);border-radius:var(--radius);font-size:.85rem;display:flex;align-items:center;gap:8px;">
        <span>Tổng số lượng sẽ nấu:</span>
        <strong id="plan-selected-total" style="font-size:1.1rem;color:var(--accent);">0</strong>
        <span id="plan-unit" style="color:var(--gray-500);"></span>
        <input type="hidden" id="plan-total-qty" />
      </div>
    </div>

    <!-- Bước 3: Thông tin kế hoạch -->
    <div>
      <p style="font-size:.78rem;font-weight:700;color:var(--gray-500);text-transform:uppercase;letter-spacing:.05em;margin-bottom:8px;">Bước 3 — Thông tin kế hoạch</p>
      <div class="form-grid">
        <div class="form-group">
          <label for="plan-assigned">Phân công cho</label>
          <select id="plan-assigned">
            <option value="">-- Chưa phân công --</option>
            <c:forEach items="${kitchenUsers}" var="u">
              <option value="${u.id}">${u.fullName}</option>
            </c:forEach>
          </select>
        </div>
        <div class="form-group">
          <label for="plan-date">Ngày sản xuất</label>
          <input id="plan-date" type="datetime-local" />
        </div>
        <div class="form-group full">
          <label for="plan-remark">Ghi chú</label>
          <textarea id="plan-remark" rows="2" placeholder="Yêu cầu đặc biệt…"></textarea>
        </div>
      </div>
    </div>
  </div>
  <footer>
    <button class="btn btn-secondary" onclick="document.getElementById('dlg-plan').close()">Hủy</button>
    <button class="btn btn-primary" onclick="savePlan()">💾 Tạo kế hoạch</button>
  </footer>
</dialog>

<!-- Modal: Cập nhật kế hoạch SX -->
<dialog id="dlg-plan-update">
  <header>
    <h3>Cập nhật kế hoạch sản xuất</h3>
    <button class="btn btn-ghost btn-sm" onclick="document.getElementById('dlg-plan-update').close()">✕</button>
  </header>
  <div class="dialog-body">
    <div style="background:var(--gray-50);border-radius:var(--radius);padding:12px 16px;margin-bottom:16px;font-size:.82rem;">
      <p><strong>Sản phẩm:</strong> <span id="upd-plan-order"></span></p>
      <p style="margin-top:4px;"><strong>Ngày lên kế hoạch:</strong> <span id="upd-plan-date"></span></p>
      <p style="margin-top:4px;"><strong>Phân công:</strong> <span id="upd-plan-assigned"></span></p>
    </div>
    <input type="hidden" id="upd-plan-id" />
    <div class="form-grid">
      <div class="form-group">
        <label for="upd-plan-status">Trạng thái mới</label>
        <select id="upd-plan-status">
          <option value="PENDING">Chờ xử lý</option>
          <option value="IN_PROGRESS">Đang sản xuất</option>
          <option value="COMPLETED">Hoàn thành</option>
          <option value="CANCELLED">Hủy</option>
        </select>
      </div>
      <div class="form-group">
        <label for="upd-plan-assignee">Phân công lại</label>
        <select id="upd-plan-assignee">
          <option value="">-- Giữ nguyên --</option>
          <c:forEach items="${kitchenUsers}" var="u">
            <option value="${u.id}">${u.fullName}</option>
          </c:forEach>
        </select>
      </div>
      <div class="form-group full">
        <label for="upd-plan-note">Ghi chú / vấn đề phát sinh</label>
        <textarea id="upd-plan-note" rows="2" placeholder="Nhập ghi chú nếu có…"></textarea>
      </div>
    </div>
  </div>
  <footer>
    <button class="btn btn-secondary" onclick="document.getElementById('dlg-plan-update').close()">Hủy</button>
    <button class="btn btn-primary" onclick="submitPlanUpdate()">💾 Lưu cập nhật</button>
  </footer>
</dialog>

<!-- Modal: Tạo lô sản xuất -->
<dialog id="dlg-batch">
  <header>
    <h3>Tạo lô sản xuất mới</h3>
    <button class="btn btn-ghost btn-sm" onclick="document.getElementById('dlg-batch').close()">✕</button>
  </header>
  <div class="dialog-body">
    <div class="form-grid">
      <div class="form-group">
        <label for="batch-product">Sản phẩm</label>
        <select id="batch-product">
          <option value="">-- Chọn sản phẩm --</option>
          <c:forEach items="${products}" var="p">
            <option value="${p.id}" data-unit="${p.unit}">${p.name}</option>
          </c:forEach>
        </select>
      </div>
      <div class="form-group">
        <label for="batch-store">Kho</label>
        <select id="batch-store">
          <c:forEach items="${stores}" var="s">
            <option value="${s.id}">${s.name}</option>
          </c:forEach>
        </select>
      </div>
      <div class="form-group">
        <label for="batch-number">Mã lô</label>
        <input id="batch-number" type="text" placeholder="VD: BATCH-2026-001" />
      </div>
      <div class="form-group">
        <label for="batch-qty">Số lượng</label>
        <input id="batch-qty" type="number" step="0.1" placeholder="0.0" />
      </div>
      <div class="form-group">
        <label for="batch-mfg">Ngày sản xuất</label>
        <input id="batch-mfg" type="date" />
      </div>
      <div class="form-group">
        <label for="batch-exp">Hạn sử dụng</label>
        <input id="batch-exp" type="date" />
      </div>
    </div>
  </div>
  <footer>
    <button class="btn btn-secondary" onclick="document.getElementById('dlg-batch').close()">Hủy</button>
    <button class="btn btn-primary" onclick="saveBatch()">💾 Tạo lô</button>
  </footer>
</dialog>

<!-- Modal: Cập nhật lô sản xuất -->
<dialog id="dlg-batch-update">
  <header>
    <h3>Cập nhật lô sản xuất</h3>
    <button class="btn btn-ghost btn-sm" onclick="document.getElementById('dlg-batch-update').close()">✕</button>
  </header>
  <div class="dialog-body">
    <div style="background:var(--gray-50);border-radius:var(--radius);padding:12px 16px;margin-bottom:16px;font-size:.82rem;">
      <p><strong>Mã lô:</strong> <span id="upd-batch-number"></span></p>
      <p style="margin-top:4px;"><strong>Sản phẩm:</strong> <span id="upd-batch-product"></span></p>
    </div>
    <input type="hidden" id="upd-batch-id" />
    <div class="form-grid">
      <div class="form-group">
        <label for="upd-batch-qty">Số lượng còn lại</label>
        <input id="upd-batch-qty" type="number" step="0.1" />
      </div>
      <div class="form-group">
        <label for="upd-batch-exp">Hạn sử dụng</label>
        <input id="upd-batch-exp" type="date" />
      </div>
    </div>
  </div>
  <footer>
    <button class="btn btn-secondary" onclick="document.getElementById('dlg-batch-update').close()">Hủy</button>
    <button class="btn btn-primary" onclick="submitBatchUpdate()">💾 Lưu</button>
  </footer>
</dialog>

<!-- Modal: Nhập kho (tồn kho) -->
<dialog id="dlg-input-inv">
  <header>
    <h3>Nhập kho</h3>
    <button class="btn btn-ghost btn-sm" onclick="document.getElementById('dlg-input-inv').close()">✕</button>
  </header>
  <div class="dialog-body">
    <div class="form-grid">
      <div class="form-group">
        <label for="inv-product">Sản phẩm</label>
        <select id="inv-product">
          <option value="">-- Chọn sản phẩm --</option>
          <c:forEach items="${products}" var="p">
            <option value="${p.id}">${p.name} (${p.unit})</option>
          </c:forEach>
        </select>
      </div>
      <div class="form-group">
        <label for="inv-store">Kho</label>
        <select id="inv-store">
          <c:forEach items="${stores}" var="s">
            <c:if test="${s.type == 'CENTRAL_KITCHEN'}">
              <option value="${s.id}">${s.name}</option>
            </c:if>
          </c:forEach>
        </select>
      </div>
      <div class="form-group">
        <label for="inv-qty">Số lượng nhập</label>
        <input id="inv-qty" type="number" step="0.1" placeholder="0.0" />
      </div>
      <div class="form-group">
        <label for="inv-min">Mức tồn tối thiểu</label>
        <input id="inv-min" type="number" step="0.1" placeholder="0.0" />
      </div>
    </div>
  </div>
  <footer>
    <button class="btn btn-secondary" onclick="document.getElementById('dlg-input-inv').close()">Hủy</button>
    <button class="btn btn-primary" onclick="saveInventoryInput()">💾 Lưu nhập kho</button>
  </footer>
</dialog>

<!-- Modal: Xem / chỉnh sửa chi tiết tồn kho -->
<dialog id="dlg-inv-detail">
  <header>
    <h3>Chi tiết tồn kho</h3>
    <button class="btn btn-ghost btn-sm" onclick="document.getElementById('dlg-inv-detail').close()">✕</button>
  </header>
  <div class="dialog-body">
    <input type="hidden" id="inv-detail-id" />
    <div class="form-grid">
      <div class="form-group">
        <label>Sản phẩm</label>
        <input id="inv-detail-product" type="text" readonly style="background:var(--gray-50);" />
      </div>
      <div class="form-group">
        <label>Kho</label>
        <input id="inv-detail-store" type="text" readonly style="background:var(--gray-50);" />
      </div>
      <div class="form-group">
        <label for="inv-detail-qty">Số lượng hiện tại</label>
        <input id="inv-detail-qty" type="number" step="0.1" />
      </div>
      <div class="form-group">
        <label for="inv-detail-min">Mức tồn tối thiểu</label>
        <input id="inv-detail-min" type="number" step="0.1" />
      </div>
      <div class="form-group full">
        <label>Cập nhật lần cuối</label>
        <input id="inv-detail-updated" type="text" readonly style="background:var(--gray-50);" />
      </div>
    </div>
  </div>
  <footer>
    <button class="btn btn-secondary" onclick="document.getElementById('dlg-inv-detail').close()">Đóng</button>
    <button class="btn btn-primary" onclick="submitInvUpdate()">💾 Lưu thay đổi</button>
  </footer>
</dialog>

<!-- Modal: Nhập nguyên liệu đầu vào -->
<dialog id="dlg-input">
  <header>
    <h3>Nhập nguyên liệu đầu vào</h3>
    <button class="btn btn-ghost btn-sm" onclick="document.getElementById('dlg-input').close()">✕</button>
  </header>
  <div class="dialog-body">
    <div class="form-grid">
      <div class="form-group">
        <label for="inp-product">Nguyên liệu</label>
        <select id="inp-product">
          <option value="">-- Chọn nguyên liệu --</option>
          <c:forEach items="${products}" var="p">
            <option value="${p.id}">${p.name} (${p.unit})</option>
          </c:forEach>
        </select>
      </div>
      <div class="form-group">
        <label for="inp-supplier">Nhà cung cấp</label>
        <select id="inp-supplier">
          <option value="">-- Chọn nhà CC --</option>
          <c:forEach items="${suppliers}" var="s">
            <option value="${s.id}">${s.name}</option>
          </c:forEach>
        </select>
      </div>
      <div class="form-group">
        <label for="inp-kitchen">Kho nhận</label>
        <select id="inp-kitchen">
          <c:forEach items="${stores}" var="s">
            <c:if test="${s.type == 'CENTRAL_KITCHEN'}">
              <option value="${s.id}">${s.name}</option>
            </c:if>
          </c:forEach>
        </select>
      </div>
      <div class="form-group">
        <label for="inp-batch">Số lô</label>
        <input id="inp-batch" type="text" placeholder="VD: LOT-2026-001" />
      </div>
      <div class="form-group">
        <label for="inp-qty">Số lượng</label>
        <input id="inp-qty" type="number" step="0.1" placeholder="0.0" />
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
    <button class="btn btn-primary" onclick="saveInput()">💾 Lưu nhập kho</button>
  </footer>
</dialog>

<!-- Toast -->
<div id="status-toast"></div>

<!-- ════════════════ JS ════════════════ -->
<script>
// ── Page navigation ───────────────────────────────────────
const pages = {
  dashboard:'page-dashboard', orders:'page-orders',
  production:'page-production',
  inventory:'page-inventory', inputs:'page-inputs', dispatch:'page-dispatch'
};

function showPage(id, el) {
  Object.values(pages).forEach(p => {
    const n = document.getElementById(p);
    if (n) n.style.display = 'none';
  });
  const t = document.getElementById(pages[id]);
  if (t) { t.style.display = 'flex'; t.style.flexDirection = 'column'; t.style.gap = '24px'; if (id === 'production') setTimeout(function(){ if(typeof buildConsolidatedNeeds==='function') buildConsolidatedNeeds(); }, 150); }
  document.querySelectorAll('nav.sidebar a').forEach(a => a.classList.remove('active'));
  if (el) el.classList.add('active');
  // Init page-specific logic
  if (id === 'production' && typeof initProductionPage === 'function') initProductionPage();
  return false;
}

document.addEventListener('DOMContentLoaded', () => {
  showPage('dashboard', document.querySelector('nav.sidebar a.active'));
});

// ── Status helpers ────────────────────────────────────────
function getStatusLabel(s) {
  return {PENDING:'Chờ xử lý',CONFIRMED:'Đã xác nhận',IN_PRODUCTION:'Đang sản xuất',
          READY:'Sẵn sàng giao',DELIVERING:'Đang giao',DELIVERED:'Đã giao',CANCELLED:'Đã hủy'}[s] || s;
}
function getStatusBadge(s) {
  const cls = {PENDING:'badge-pending',CONFIRMED:'badge-process',IN_PRODUCTION:'badge-process',
               READY:'badge-done',DELIVERING:'badge-process',DELIVERED:'badge-done',CANCELLED:'badge-alert'};
  return '<span class="badge '+(cls[s]||'badge-default')+'">'+getStatusLabel(s)+'</span>';
}

// ── Toast ─────────────────────────────────────────────────
function showToast(msg, isError) {
  const t = document.getElementById('status-toast');
  t.textContent = msg;
  t.style.background = isError ? 'var(--red)' : 'var(--green)';
  t.classList.add('show');
  setTimeout(() => t.classList.remove('show'), 2800);
}

// ── Update order status ───────────────────────────────────
async function updateOrderStatus(orderId, newStatus) {
  try {
    const r = await fetch('/kitchen-staff/orders/'+orderId+'/status?status='+newStatus, {
      method:'POST', headers:{'X-Requested-With':'XMLHttpRequest'}
    });
    if (r.ok) { showToast('Đã cập nhật đơn #ORD-'+orderId+' → '+getStatusLabel(newStatus)); setTimeout(()=>location.reload(),900); }
    else showToast('Lỗi cập nhật. Vui lòng thử lại.',true);
  } catch(e) { showToast('Lỗi kết nối: '+e.message,true); }
}

// ── Open order dialog (from dashboard) ───────────────────
function openOrderDialog(oid) {
  const dataRow = document.getElementById('order-data-'+oid);
  if (!dataRow) { alert('Không tìm thấy dữ liệu.'); return; }
  const items = dataRow.querySelectorAll('.order-item-entry');
  document.getElementById('dlg-order-title').textContent = 'Đơn hàng #ORD-'+oid;
  document.getElementById('dlg-store').value    = dataRow.dataset.store;
  document.getElementById('dlg-date').value     = dataRow.dataset.date || '—';
  document.getElementById('dlg-delivery').value = dataRow.dataset.delivery || 'Chưa xác định';
  document.getElementById('dlg-status').value   = getStatusLabel(dataRow.dataset.status);
  document.getElementById('dlg-note').value     = dataRow.dataset.note || '';
  const itemsEl = document.getElementById('dlg-items');
  if (!items.length) {
    itemsEl.innerHTML = '<div class="item-row"><span class="text-muted">Không có sản phẩm.</span></div>';
  } else {
    itemsEl.innerHTML = '';
    items.forEach(item => {
      itemsEl.innerHTML += '<div class="item-row"><span class="item-name">'+item.dataset.name+'</span><span class="item-qty">'+item.dataset.qty+' '+item.dataset.unit+'</span></div>';
    });
  }
  const next={PENDING:'CONFIRMED',CONFIRMED:'IN_PRODUCTION',IN_PRODUCTION:'READY'};
  const lab={PENDING:'✓ Xác nhận đơn',CONFIRMED:'▶ Bắt đầu SX',IN_PRODUCTION:'✅ Sẵn sàng'};
  const btn=document.getElementById('dlg-confirm-btn');
  const st=dataRow.dataset.status;
  if(next[st]){btn.style.display='';btn.textContent=lab[st];btn.dataset.oid=oid;btn.dataset.next=next[st];}
  else btn.style.display='none';
  document.getElementById('dlg-order').showModal();
}

async function confirmOrderFromDialog() {
  const btn=document.getElementById('dlg-confirm-btn');
  document.getElementById('dlg-order').close();
  await updateOrderStatus(parseInt(btn.dataset.oid),btn.dataset.next);
}

// ── Production Plan ───────────────────────────────────────

function getActiveOrdersWithItems() {
  const orders = [];
  document.querySelectorAll('[id^="order-data-"]').forEach(div => {
    if (!['PENDING','CONFIRMED'].includes(div.dataset.status)) return;
    const items = [];
    div.querySelectorAll('.order-item-entry').forEach(item => {
      items.push({ productName: item.dataset.name, qty: parseFloat(item.dataset.qty)||0, unit: item.dataset.unit });
    });
    orders.push({ orderId: parseInt(div.dataset.id), storeName: div.dataset.store, items });
  });
  return orders;
}

function openCreatePlanDialog() {
  document.getElementById('plan-product').value = '';
  document.getElementById('plan-total-qty').value = '0';
  document.getElementById('plan-assigned').value = '';
  document.getElementById('plan-date').value = '';
  document.getElementById('plan-remark').value = '';
  document.getElementById('plan-orders-section').style.display = 'none';
  document.getElementById('plan-orders-list').innerHTML = '';
  document.getElementById('plan-selected-total').textContent = '0';
  document.getElementById('dlg-plan').showModal();
}

function onPlanProductChange() {
  const sel    = document.getElementById('plan-product');
  const unit   = sel.options[sel.selectedIndex] ? sel.options[sel.selectedIndex].dataset.unit : '';
  const selName= sel.options[sel.selectedIndex] ? sel.options[sel.selectedIndex].text.trim() : '';
  document.getElementById('plan-unit').textContent = unit;

  if (!sel.value) {
    document.getElementById('plan-orders-section').style.display = 'none';
    return;
  }

  const activeOrders = getActiveOrdersWithItems();

  // Thu thap cac (orderId+productId) da duoc gop vao ke hoach
  const plannedKey = new Set();
  document.querySelectorAll('#planned-order-ids span').forEach(function(s) {
    plannedKey.add(s.dataset.orderId + '_' + s.dataset.productId);
  });
  const selectedProductId = String(sel.value);

  const matched = [];
  activeOrders.forEach(o => {
    // Bo qua don da co ke hoach cho san pham nay
    if (plannedKey.has(String(o.orderId) + '_' + selectedProductId)) return;
    o.items.forEach(item => {
      if (item.productName === selName && item.qty > 0) {
        matched.push({ orderId: o.orderId, storeName: o.storeName, qty: item.qty, unit: item.unit });
      }
    });
  });

  const list = document.getElementById('plan-orders-list');
  if (!matched.length) {
    list.innerHTML = '<div style="color:var(--gray-400);font-size:.82rem;padding:8px;">Không có đơn hàng nào đang cần sản phẩm này.</div>';
  } else {
    list.innerHTML = matched.map(r =>
      '<label style="display:flex;align-items:center;gap:10px;padding:10px 12px;border:1px solid var(--gray-200);border-radius:var(--radius);cursor:pointer;font-size:.83rem;">' +
        '<input type="checkbox" class="plan-order-check" data-order-id="' + r.orderId + '" data-qty="' + r.qty + '" onchange="updatePlanSelectedTotal()" />' +
        '<span style="flex:1;"><strong>#ORD-' + r.orderId + '</strong> — ' + r.storeName + '</span>' +
        '<span style="font-family:var(--font-mono);color:var(--accent);font-weight:700;">' + r.qty + ' ' + r.unit + '</span>' +
      '</label>'
    ).join('');
    const totalAll = matched.reduce(function(s,r){return s+r.qty;}, 0);
    document.getElementById('plan-total-qty').value = totalAll.toFixed(1);
  }
  document.getElementById('plan-orders-section').style.display = '';
  updatePlanSelectedTotal();
}

function updatePlanSelectedTotal() {
  var total = 0;
  document.querySelectorAll('.plan-order-check:checked').forEach(function(cb) {
    total += parseFloat(cb.dataset.qty) || 0;
  });
  document.getElementById('plan-selected-total').textContent = total.toFixed(1);
  document.getElementById('plan-total-qty').value = total.toFixed(1);
}

async function savePlan() {
  const productId   = document.getElementById('plan-product').value;
  const totalQty    = document.getElementById('plan-total-qty').value;
  const assignedTo  = document.getElementById('plan-assigned').value;
  const plannedDate = document.getElementById('plan-date').value;
  const note        = document.getElementById('plan-remark').value;
  if (!productId) { showToast('Vui lòng chọn sản phẩm.',true); return; }
  if (!totalQty || parseFloat(totalQty) <= 0) { showToast('Vui lòng chọn ít nhất 1 đơn hàng.',true); return; }
  const orderItems = [];
  document.querySelectorAll('.plan-order-check:checked').forEach(function(cb) {
    orderItems.push({ orderId: parseInt(cb.dataset.orderId), quantity: parseFloat(cb.dataset.qty) });
  });
  try {
    const r = await fetch('/kitchen-staff/plans', {
      method:'POST', headers:{'Content-Type':'application/json'},
      body: JSON.stringify({
        productId: parseInt(productId),
        totalQuantity: parseFloat(totalQty),
        assignedToId: assignedTo ? parseInt(assignedTo) : null,
        plannedDate: plannedDate ? plannedDate+':00' : null,
        note, orderItems
      })
    });
    const data = await r.json();
    if (data.success) { showToast('Đã tạo kế hoạch sản xuất!'); document.getElementById('dlg-plan').close(); setTimeout(()=>location.reload(),900); }
    else showToast(data.error||'Lỗi tạo kế hoạch.',true);
  } catch(e) { showToast('Lỗi kết nối: '+e.message,true); }
}

// ── Batches ───────────────────────────────────────────────
async function saveBatch() {
  const productId = document.getElementById('batch-product').value;
  const storeId   = document.getElementById('batch-store').value;
  const batchNum  = document.getElementById('batch-number').value;
  const qty       = document.getElementById('batch-qty').value;
  const mfg       = document.getElementById('batch-mfg').value;
  const exp       = document.getElementById('batch-exp').value;
  if (!productId||!storeId||!batchNum||!qty||!mfg||!exp) { showToast('Vui lòng điền đầy đủ thông tin.',true); return; }
  try {
    const r = await fetch('/kitchen-staff/batches', {
      method:'POST', headers:{'Content-Type':'application/json'},
      body: JSON.stringify({productId:parseInt(productId),storeId:parseInt(storeId),batchNumber:batchNum,quantity:parseFloat(qty),manufactureDate:mfg,expirationDate:exp})
    });
    const data = await r.json();
    if (data.success) { showToast('Đã tạo lô sản xuất!'); document.getElementById('dlg-batch').close(); setTimeout(()=>location.reload(),900); }
    else showToast(data.error||'Lỗi tạo lô.',true);
  } catch(e) { showToast('Lỗi kết nối: '+e.message,true); }
}

function openBatchUpdateDialog(batchId, batchNumber, productName, qtyRemaining, expDate) {
  document.getElementById('upd-batch-id').value            = batchId;
  document.getElementById('upd-batch-number').textContent  = batchNumber;
  document.getElementById('upd-batch-product').textContent = productName;
  document.getElementById('upd-batch-qty').value           = qtyRemaining;
  document.getElementById('upd-batch-exp').value           = expDate;
  document.getElementById('dlg-batch-update').showModal();
}

async function submitBatchUpdate() {
  const id  = document.getElementById('upd-batch-id').value;
  const qty = document.getElementById('upd-batch-qty').value;
  const exp = document.getElementById('upd-batch-exp').value;
  try {
    const r = await fetch('/kitchen-staff/batches/'+id, {
      method:'PUT', headers:{'Content-Type':'application/json'},
      body: JSON.stringify({quantityRemaining:parseFloat(qty), expirationDate:exp})
    });
    const data = await r.json();
    if (data.success) { showToast('Đã cập nhật lô!'); document.getElementById('dlg-batch-update').close(); setTimeout(()=>location.reload(),900); }
    else showToast(data.error||'Lỗi cập nhật.',true);
  } catch(e) { showToast('Lỗi kết nối: '+e.message,true); }
}

// ── Inventory ─────────────────────────────────────────────
async function saveInventoryInput() {
  const productId = document.getElementById('inv-product').value;
  const storeId   = document.getElementById('inv-store').value;
  const qty       = document.getElementById('inv-qty').value;
  const min       = document.getElementById('inv-min').value;
  if (!productId||!storeId||!qty) { showToast('Vui lòng điền đầy đủ thông tin.',true); return; }
  try {
    const r = await fetch('/kitchen-staff/inventory', {
      method:'POST', headers:{'Content-Type':'application/json'},
      body: JSON.stringify({productId:parseInt(productId),storeId:parseInt(storeId),quantity:parseFloat(qty),minThreshold:min?parseFloat(min):0})
    });
    const data = await r.json();
    if (data.success) { showToast('Đã nhập kho!'); document.getElementById('dlg-input-inv').close(); setTimeout(()=>location.reload(),900); }
    else showToast(data.error||'Lỗi nhập kho.',true);
  } catch(e) { showToast('Lỗi kết nối: '+e.message,true); }
}

function openInvDetail(id, product, store, qty, minThreshold, updatedAt) {
  document.getElementById('inv-detail-id').value      = id;
  document.getElementById('inv-detail-product').value = product;
  document.getElementById('inv-detail-store').value   = store;
  document.getElementById('inv-detail-qty').value     = qty;
  document.getElementById('inv-detail-min').value     = minThreshold;
  document.getElementById('inv-detail-updated').value = updatedAt;
  document.getElementById('dlg-inv-detail').showModal();
}

async function submitInvUpdate() {
  const id  = document.getElementById('inv-detail-id').value;
  const qty = document.getElementById('inv-detail-qty').value;
  const min = document.getElementById('inv-detail-min').value;
  try {
    const r = await fetch('/kitchen-staff/inventory/'+id, {
      method:'PUT', headers:{'Content-Type':'application/json'},
      body: JSON.stringify({quantity:parseFloat(qty),minThreshold:parseFloat(min)})
    });
    const data = await r.json();
    if (data.success) { showToast('Đã cập nhật tồn kho!'); document.getElementById('dlg-inv-detail').close(); setTimeout(()=>location.reload(),900); }
    else showToast(data.error||'Lỗi cập nhật.',true);
  } catch(e) { showToast('Lỗi kết nối: '+e.message,true); }
}

// ── Plan Update Dialog ───────────────────────────────────
function openPlanUpdateDialog(planId, productName, plannedDate, assignedTo, currentStatus) {
  document.getElementById('upd-plan-id').value          = planId;
  document.getElementById('upd-plan-order').textContent = productName;
  document.getElementById('upd-plan-date').textContent  = plannedDate || '—';
  document.getElementById('upd-plan-assigned').textContent = assignedTo || 'Chưa phân công';
  document.getElementById('upd-plan-status').value      = currentStatus;
  document.getElementById('upd-plan-note').value        = '';
  document.getElementById('upd-plan-assignee').value    = '';
  document.getElementById('dlg-plan-update').showModal();
}

async function submitPlanUpdate() {
  const id     = document.getElementById('upd-plan-id').value;
  const status = document.getElementById('upd-plan-status').value;
  const note   = document.getElementById('upd-plan-note').value;
  const asgn   = document.getElementById('upd-plan-assignee').value;
  try {
    const r = await fetch('/kitchen-staff/plans/'+id, {
      method:'PUT', headers:{'Content-Type':'application/json'},
      body: JSON.stringify({status, note, assignedToId: asgn ? parseInt(asgn) : null})
    });
    const data = await r.json();
    if (data.success) {
      showToast('Đã cập nhật kế hoạch!');
      document.getElementById('dlg-plan-update').close();
      setTimeout(()=>location.reload(),900);
    } else showToast(data.error||'Lỗi cập nhật.',true);
  } catch(e) { showToast('Lỗi kết nối: '+e.message,true); }
}

// ── Inputs (Nguyên liệu) ──────────────────────────────────
async function saveInput() {
  const productId  = document.getElementById('inp-product').value;
  const supplierId = document.getElementById('inp-supplier').value;
  const kitchenId  = document.getElementById('inp-kitchen').value;
  const batchNum   = document.getElementById('inp-batch').value;
  const qty        = document.getElementById('inp-qty').value;
  const exp        = document.getElementById('inp-exp').value;
  if (!productId||!supplierId||!kitchenId||!qty||!exp) { showToast('Vui lòng điền đầy đủ thông tin.',true); return; }
  try {
    const r = await fetch('/kitchen-staff/inputs', {
      method:'POST', headers:{'Content-Type':'application/json'},
      body: JSON.stringify({productId:parseInt(productId),supplierId:parseInt(supplierId),kitchenId:parseInt(kitchenId),batchNumber:batchNum,quantity:parseFloat(qty),expirationDate:exp})
    });
    const data = await r.json();
    if (data.success) { showToast('Đã nhập nguyên liệu!'); document.getElementById('dlg-input').close(); setTimeout(()=>location.reload(),900); }
    else showToast(data.error||'Lỗi nhập nguyên liệu.',true);
  } catch(e) { showToast('Lỗi kết nối: '+e.message,true); }
}
</script>
</body>
</html>
