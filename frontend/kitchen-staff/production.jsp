<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!-- ── PAGE: PRODUCTION ── -->
  <div id="page-production" style="display:none;">
    <div class="page-header">
      <hgroup>
        <h1>Kế hoạch sản xuất</h1>
        <p>Lập và theo dõi kế hoạch sản xuất theo nhu cầu tổng hợp</p>
      </hgroup>
      <div class="actions">
        <button class="btn btn-primary" onclick="document.getElementById('dlg-plan').showModal()">+ Tạo kế hoạch mới</button>
      </div>
    </div>

    <!-- ── Nhu cầu tổng hợp ── -->
    <section class="panel">
      <header class="panel-head">
        <h2>📊 Nhu cầu sản xuất tổng hợp</h2>
        <div class="panel-actions">
          <span class="text-muted" style="font-size:.78rem;">Nhóm theo sản phẩm từ đơn đang xử lý</span>
        </div>
      </header>
      <div class="table-wrap">
        <table id="consolidated-table">
          <thead>
            <tr>
              <th>Sản phẩm</th>
              <th>Tổng số lượng cần SX</th>
              <th>Số đơn liên kết</th>
              <th>Mã đơn</th>
            </tr>
          </thead>
          <tbody id="consolidated-tbody">
            <tr><td colspan="4" class="empty-state">Đang tính toán…</td></tr>
          </tbody>
        </table>
      </div>
    </section>

    <!-- ── Kế hoạch hiện tại ── -->
    <section class="panel">
      <header class="panel-head">
        <h2>📋 Kế hoạch sản xuất đã tạo</h2>
        <div class="panel-actions">
          <button class="btn btn-secondary btn-sm">⬇ In kế hoạch</button>
        </div>
      </header>
      <div class="table-wrap">
        <table>
          <thead>
            <tr>
              <th>Đơn hàng</th>
              <th>Sản phẩm</th>
              <th>Nhân sự</th>
              <th>Ngày lên kế hoạch</th>
              <th>Trạng thái</th>
              <th>Thao tác</th>
            </tr>
          </thead>
          <tbody>
            <c:choose>
              <c:when test="${empty plans}">
                <tr><td colspan="6" class="empty-state">Chưa có kế hoạch sản xuất nào.</td></tr>
              </c:when>
              <c:otherwise>
                <c:forEach items="${plans}" var="plan">
                <tr>
                  <td><span class="mono">#ORD-${plan.order.id}</span></td>
                  <td>
                    <c:choose>
                      <c:when test="${plan.order != null && !empty plan.order.orderItems}">
                        <c:forEach items="${plan.order.orderItems}" var="item" varStatus="st">
                          <c:out value="${item.product.name}"/><c:if test="${!st.last}">, </c:if>
                        </c:forEach>
                      </c:when>
                      <c:otherwise><span class="text-muted">N/A</span></c:otherwise>
                    </c:choose>
                  </td>
                  <td>
                    <c:choose>
                      <c:when test="${plan.assignedTo != null}">${plan.assignedTo.fullName}</c:when>
                      <c:otherwise><span class="badge badge-alert">Chưa phân công</span></c:otherwise>
                    </c:choose>
                  </td>
                  <td><span class="mono">${plan.plannedDate}</span></td>
                  <td>
                    <c:choose>
                      <c:when test="${plan.status == 'PENDING'}"><span class="badge badge-pending">Chờ xử lý</span></c:when>
                      <c:when test="${plan.status == 'IN_PROGRESS'}"><span class="badge badge-process">Đang SX</span></c:when>
                      <c:when test="${plan.status == 'COMPLETED'}"><span class="badge badge-done">Hoàn thành</span></c:when>
                      <c:otherwise><span class="badge badge-alert">Đã hủy</span></c:otherwise>
                    </c:choose>
                  </td>
                  <td>
                    <button class="btn btn-secondary btn-sm"
                            onclick="openPlanUpdateForm(${plan.id}, '${plan.status}')">Cập nhật</button>
                  </td>
                </tr>
                </c:forEach>
              </c:otherwise>
            </c:choose>
          </tbody>
        </table>
      </div>
    </section>

    <!-- ── Cập nhật trạng thái nhanh ── -->
    <section class="panel" id="plan-update-section" style="display:none;">
      <header class="panel-head">
        <h2>✎ Cập nhật trạng thái kế hoạch</h2>
        <button class="btn btn-ghost btn-sm" onclick="document.getElementById('plan-update-section').style.display='none'">✕ Đóng</button>
      </header>
      <div style="padding:20px;">
        <form onsubmit="return false;" style="display:flex;flex-direction:column;gap:16px;">
          <input type="hidden" id="prod-plan-id" value="" />
          <div class="form-grid">
            <div class="form-group">
              <label for="prod-status">Trạng thái mới</label>
              <select id="prod-status">
                <option value="IN_PROGRESS">Đang sản xuất</option>
                <option value="COMPLETED">Hoàn thành</option>
                <option value="CANCELLED">Hủy</option>
              </select>
            </div>
            <div class="form-group">
              <label for="prod-qty">Số lượng thực tế</label>
              <input id="prod-qty" type="number" placeholder="Nhập số lượng…" />
            </div>
            <div class="form-group full">
              <label for="prod-note">Ghi chú / vấn đề phát sinh</label>
              <textarea id="prod-note" rows="2" placeholder="Nhập ghi chú nếu có…"></textarea>
            </div>
          </div>
          <div style="display:flex;gap:8px;">
            <button class="btn btn-primary" onclick="savePlanUpdate()">💾 Lưu cập nhật</button>
            <button class="btn btn-secondary" onclick="document.getElementById('plan-update-section').style.display='none'">Hủy</button>
          </div>
        </form>
      </div>
    </section>
  </div><!-- /page-production -->

<script>
// ── Tính nhu cầu tổng hợp từ các đơn đang xử lý ────────
document.addEventListener('DOMContentLoaded', function() {
  buildConsolidatedNeeds();
});

function buildConsolidatedNeeds() {
  const ACTIVE_STATUSES = ['PENDING', 'CONFIRMED', 'IN_PRODUCTION'];
  const needs = {};

  document.querySelectorAll('[id^="order-data-"]').forEach(function(div) {
    var status = div.dataset.status;
    if (!ACTIVE_STATUSES.includes(status)) return;

    var oid = div.dataset.id;
    div.querySelectorAll('.order-item-entry').forEach(function(item) {
      var name = item.dataset.name;
      var qty  = parseFloat(item.dataset.qty) || 0;
      var unit = item.dataset.unit;
      if (!needs[name]) {
        needs[name] = { name: name, unit: unit, qty: 0, orders: [] };
      }
      needs[name].qty += qty;
      if (!needs[name].orders.includes(oid)) needs[name].orders.push(oid);
    });
  });

  var tbody = document.getElementById('consolidated-tbody');
  var entries = Object.values(needs);
  if (entries.length === 0) {
    tbody.innerHTML = '<tr><td colspan="4" class="empty-state">Không có đơn hàng nào đang hoạt động.</td></tr>';
    return;
  }

  tbody.innerHTML = entries.map(function(n) {
    var orderLinks = n.orders.map(function(oid) {
      return '<span class="lot-tag">#ORD-' + oid + '</span>';
    }).join(' ');
    return '<tr>' +
      '<td><strong>' + n.name + '</strong></td>' +
      '<td><span class="mono" style="font-size:1rem;font-weight:700;">' + n.qty.toFixed(1) + '</span> <span class="text-muted">' + n.unit + '</span></td>' +
      '<td><span class="badge badge-process">' + n.orders.length + ' đơn</span></td>' +
      '<td>' + orderLinks + '</td>' +
    '</tr>';
  }).join('');
}

// ── Mở form cập nhật kế hoạch ──────────────────────────
function openPlanUpdateForm(planId, currentStatus) {
  document.getElementById('prod-plan-id').value = planId;
  document.getElementById('prod-status').value =
    currentStatus === 'PENDING' ? 'IN_PROGRESS' : 'COMPLETED';
  document.getElementById('prod-note').value = '';
  document.getElementById('prod-qty').value = '';
  var section = document.getElementById('plan-update-section');
  section.style.display = '';
  section.scrollIntoView({ behavior: 'smooth', block: 'start' });
}

function savePlanUpdate() {
  // Placeholder – kết nối backend khi có endpoint
  showToast('Đã cập nhật kế hoạch sản xuất!');
  document.getElementById('plan-update-section').style.display = 'none';
}
</script>
