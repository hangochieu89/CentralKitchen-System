<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!-- ── PAGE: PRODUCTION ── -->
  <div id="page-production" style="display:none;">
    <!-- Hidden: danh sach order_id da co ke hoach (de filter o nhu cau tong hop) -->
    <div id="planned-order-ids" style="display:none;">
      <c:forEach items="${plans}" var="plan">
        <c:if test="${plan.status != 'CANCELLED'}">
          <c:forEach items="${plan.planOrders}" var="po">
            <span data-order-id="${po.order.id}" data-product-id="${plan.product.id}"></span>
          </c:forEach>
        </c:if>
      </c:forEach>
    </div>

    <div class="page-header">
      <hgroup>
        <h1>Kế hoạch sản xuất</h1>
        <p>Lập và theo dõi kế hoạch sản xuất theo nhu cầu tổng hợp</p>
      </hgroup>
      <div class="actions">
        <button class="btn btn-primary" onclick="openCreatePlanDialog()">+ Tạo kế hoạch mới</button>
      </div>
    </div>

    <!-- Nhu cầu tổng hợp theo sản phẩm -->
    <section class="panel">
      <header class="panel-head">
        <h2>📊 Nhu cầu sản xuất tổng hợp</h2>
        <span class="text-muted" style="font-size:.78rem;">Nhóm theo sản phẩm từ đơn PENDING / CONFIRMED</span>
      </header>
      <div class="table-wrap">
        <table id="consolidated-table">
          <thead>
            <tr><th>Sản phẩm</th><th>Tổng cần SX</th><th>Số đơn</th><th>Chi tiết theo chi nhánh</th><th></th></tr>
          </thead>
          <tbody id="consolidated-tbody">
            <tr><td colspan="5" class="empty-state">Đang tính toán…</td></tr>
          </tbody>
        </table>
      </div>
    </section>

    <!-- Kế hoạch đã tạo -->
    <section class="panel">
      <header class="panel-head">
        <h2>📋 Kế hoạch sản xuất đã tạo</h2>
        <button class="btn btn-secondary btn-sm">⬇ In kế hoạch</button>
      </header>
      <div class="table-wrap">
        <table>
          <thead>
            <tr><th>Sản phẩm</th><th>Số lượng</th><th>Đơn hàng liên kết</th><th>Nhân sự</th><th>Ngày SX</th><th>Trạng thái</th><th>Thao tác</th></tr>
          </thead>
          <tbody>
            <c:choose>
              <c:when test="${empty plans}">
                <tr><td colspan="7" class="empty-state">Chưa có kế hoạch sản xuất nào.</td></tr>
              </c:when>
              <c:otherwise>
                <c:forEach items="${plans}" var="plan">
                <tr>
                  <td><strong>${plan.product.name}</strong></td>
                  <td><span class="mono">${plan.totalQuantity} ${plan.product.unit}</span></td>
                  <td>
                    <c:choose>
                      <c:when test="${not empty plan.planOrders}">
                        <c:forEach items="${plan.planOrders}" var="po" varStatus="st">
                          <span class="lot-tag">#ORD-${po.order.id}</span>
                        </c:forEach>
                      </c:when>
                      <c:otherwise><span class="text-muted">—</span></c:otherwise>
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
                      onclick="openPlanUpdateDialog(
                        ${plan.id},
                        '${plan.product.name}',
                        '${plan.plannedDate}',
                        '<c:out value="${plan.assignedTo != null ? plan.assignedTo.fullName : ''}"/>',
                        '${plan.status}'
                      )">Cập nhật</button>
                  </td>
                </tr>
                </c:forEach>
              </c:otherwise>
            </c:choose>
          </tbody>
        </table>
      </div>
    </section>
  </div><!-- /page-production -->

<script>
// Goi sau khi tab production duoc show (tu showPage)
function initProductionPage() {
  buildConsolidatedNeeds();
}
document.addEventListener('DOMContentLoaded', function() {
  // Fallback neu trang load truc tiep
  setTimeout(buildConsolidatedNeeds, 100);
});

function buildConsolidatedNeeds() {
  const ACTIVE = ['PENDING','CONFIRMED'];
  const needs  = {};

  // Thu thap cac order_id da co ke hoach tu bang ke hoach
  const plannedOrderIds = new Set();
  document.querySelectorAll('#planned-order-ids span').forEach(function(s) {
    plannedOrderIds.add(s.dataset.orderId);
  });

  document.querySelectorAll('[id^="order-data-"]').forEach(div => {
    if (!ACTIVE.includes(div.dataset.status)) return;
    const oid       = div.dataset.id;
    const storeName = div.dataset.store;

    div.querySelectorAll('.order-item-entry').forEach(item => {
      const name = item.dataset.name;
      const qty  = parseFloat(item.dataset.qty) || 0;
      const unit = item.dataset.unit;
      if (!name || qty <= 0) return;

      if (!needs[name]) needs[name] = { name, unit, totalQty: 0, orders: [] };
      needs[name].totalQty += qty;
      needs[name].orders.push({ oid, storeName, qty });
    });
  });

  const tbody  = document.getElementById('consolidated-tbody');
  const entries = Object.values(needs);

  if (!entries.length) {
    tbody.innerHTML = '<tr><td colspan="5" class="empty-state">Không có đơn hàng nào đang chờ sản xuất.</td></tr>';
    return;
  }

  tbody.innerHTML = entries.map(n => {
    const detail = n.orders.map(o =>
      '<span style="font-size:.78rem;color:var(--gray-600);">' +
        '<span class="lot-tag">#ORD-' + o.oid + '</span> ' + o.storeName + ': <strong>' + o.qty + ' ' + n.unit + '</strong>' +
      '</span>'
    ).join('<br/>');

    return '<tr>' +
      '<td><strong>' + n.name + '</strong></td>' +
      '<td><span class="mono" style="font-size:1rem;font-weight:700;">' + n.totalQty.toFixed(1) + '</span> <span class="text-muted">' + n.unit + '</span></td>' +
      '<td><span class="badge badge-process">' + n.orders.length + ' đơn</span></td>' +
      '<td>' + detail + '</td>' +
      '<td><button class="btn btn-primary btn-sm" onclick="openCreatePlanDialogForProduct('' + n.name + '')">+ Tạo KH</button></td>' +
    '</tr>';
  }).join('');
}

// Mở dialog tạo kế hoạch và pre-select sản phẩm
function openCreatePlanDialogForProduct(productName) {
  openCreatePlanDialog();
  setTimeout(function() {
    const sel = document.getElementById('plan-product');
    for (let i = 0; i < sel.options.length; i++) {
      if (sel.options[i].text.trim() === productName) {
        sel.value = sel.options[i].value;
        onPlanProductChange();
        break;
      }
    }
  }, 50);
}
</script>
