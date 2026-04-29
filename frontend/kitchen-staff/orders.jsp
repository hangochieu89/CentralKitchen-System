<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!-- ── PAGE: ORDERS ── -->
  <div id="page-orders" style="display:none;">
    <div class="page-header">
      <hgroup>
        <h1>Tiếp nhận đơn hàng</h1>
        <p>Quản lý đơn đặt hàng từ các cửa hàng franchise</p>
      </hgroup>
    </div>

    <div class="two-col">
      <!-- Danh sách đơn -->
      <section class="panel">
        <header class="panel-head">
          <h2>Danh sách đơn hàng</h2>
          <div class="panel-actions">
            <select id="orders-filter-status" onchange="filterOrders()" style="font-size:.8rem;padding:5px 8px;border:1px solid var(--gray-200);border-radius:var(--radius);">
              <option value="">Tất cả trạng thái</option>
              <option value="PENDING">Chờ xử lý</option>
              <option value="CONFIRMED">Đã xác nhận</option>
              <option value="IN_PRODUCTION">Đang SX</option>
              <option value="READY">Sẵn sàng</option>
            </select>
          </div>
        </header>
        <div class="filter-bar">
          <input type="search" id="orders-search" placeholder="Tìm mã đơn, cửa hàng…" oninput="filterOrders()" />
        </div>
        <div class="table-wrap">
          <table>
            <thead>
              <tr>
                <th>Mã đơn</th>
                <th>Cửa hàng</th>
                <th>Sản phẩm</th>
                <th>Ngày đặt</th>
                <th>Trạng thái</th>
              </tr>
            </thead>
            <tbody id="orders-tbody">
              <c:forEach items="${orders}" var="order">
              <tr class="order-row"
                  data-oid="${order.id}"
                  data-status="${order.status}"
                  data-store="<c:out value='${order.store.name}'/>"
                  tabindex="0"
                  onclick="selectOrder(${order.id})"
                  onkeydown="if(event.key==='Enter'||event.key===' ')selectOrder(${order.id})">
                <td><span class="mono">#ORD-${order.id}</span></td>
                <td><strong><c:out value="${order.store.name}"/></strong></td>
                <td>
                  <c:forEach items="${order.orderItems}" var="item" varStatus="loop">
                    <c:out value="${item.product.name}"/><c:if test="${!loop.last}">, </c:if>
                  </c:forEach>
                  <c:if test="${empty order.orderItems}"><span class="text-muted">—</span></c:if>
                </td>
                <td><span class="mono">${order.orderDate}</span></td>
                <td>
                  <c:choose>
                    <c:when test="${order.status == 'PENDING'}"><span class="badge badge-pending">Chờ xử lý</span></c:when>
                    <c:when test="${order.status == 'CONFIRMED'}"><span class="badge badge-process">Đã xác nhận</span></c:when>
                    <c:when test="${order.status == 'IN_PRODUCTION'}"><span class="badge badge-process">Đang SX</span></c:when>
                    <c:when test="${order.status == 'READY'}"><span class="badge badge-done">Sẵn sàng</span></c:when>
                    <c:when test="${order.status == 'DELIVERING'}"><span class="badge badge-process">Đang giao</span></c:when>
                    <c:when test="${order.status == 'DELIVERED'}"><span class="badge badge-done">Hoàn thành</span></c:when>
                    <c:otherwise><span class="badge badge-alert">Đã hủy</span></c:otherwise>
                  </c:choose>
                </td>
              </tr>
              <!-- Hidden data node for JS to read -->
              <tr id="order-data-${order.id}" style="display:none;"
                  data-id="${order.id}"
                  data-store="<c:out value='${order.store.name}'/>"
                  data-date="${order.orderDate}"
                  data-delivery="${order.deliveryDate}"
                  data-status="${order.status}"
                  data-note="<c:out value='${order.note}'/>">
                <td>
                  <c:forEach items="${order.orderItems}" var="item">
                    <span class="order-item-entry"
                          data-name="<c:out value='${item.product.name}'/>"
                          data-qty="${item.quantityRequested}"
                          data-unit="${item.product.unit}"></span>
                  </c:forEach>
                </td>
              </tr>
              </c:forEach>
            </tbody>
          </table>
        </div>
      </section>

      <!-- Chi tiết đơn (right panel) -->
      <section class="panel" id="order-detail-panel">
        <header class="panel-head">
          <h2 id="order-detail-title">Chi tiết đơn hàng</h2>
        </header>

        <!-- Placeholder khi chưa chọn -->
        <div id="order-detail-placeholder" style="padding:40px;text-align:center;color:var(--gray-400);">
          <div style="font-size:2.5rem;margin-bottom:10px;opacity:.3;">📋</div>
          <p>Chọn một đơn hàng bên trái để xem chi tiết.</p>
        </div>

        <!-- Nội dung chi tiết -->
        <div id="order-detail-body" style="display:none;">
          <div class="order-detail">
            <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px;">
              <div class="field">
                <span class="field-label">Cửa hàng</span>
                <p class="fw7" id="detail-store"></p>
              </div>
              <div class="field">
                <span class="field-label">Trạng thái</span>
                <p id="detail-status-badge"></p>
              </div>
              <div class="field">
                <span class="field-label">Ngày đặt</span>
                <p class="mono" id="detail-date"></p>
              </div>
              <div class="field">
                <span class="field-label">Thời gian giao mong muốn</span>
                <p class="mono" id="detail-delivery"></p>
              </div>
            </div>

            <hr class="divider" />

            <div class="field">
              <span class="field-label">Danh sách sản phẩm</span>
            </div>
            <div class="item-list" id="detail-items"></div>

            <hr class="divider" />

            <div class="field">
              <span class="field-label">Ghi chú</span>
              <p id="detail-note" class="text-muted" style="font-size:.85rem;"></p>
            </div>
          </div>
          <div class="detail-action-bar" id="detail-actions"></div>
        </div>
      </section>
    </div>
  </div><!-- /page-orders -->

<script>
// ── Lọc đơn hàng theo search/status ─────────────────────
function filterOrders() {
  const search = (document.getElementById('orders-search').value || '').toLowerCase();
  const status = document.getElementById('orders-filter-status').value;
  document.querySelectorAll('#orders-tbody tr.order-row').forEach(row => {
    const matchSearch = !search ||
      row.dataset.oid.includes(search) ||
      row.dataset.store.toLowerCase().includes(search);
    const matchStatus = !status || row.dataset.status === status;
    row.style.display = (matchSearch && matchStatus) ? '' : 'none';
  });
}

// ── Chọn đơn hàng ────────────────────────────────────────
function selectOrder(oid) {
  // Highlight row
  document.querySelectorAll('#orders-tbody tr.order-row').forEach(r => r.classList.remove('row-selected'));
  const selectedRow = document.querySelector('#orders-tbody tr.order-row[data-oid="' + oid + '"]');
  if (selectedRow) selectedRow.classList.add('row-selected');

  // Đọc data
  const dataRow = document.getElementById('order-data-' + oid);
  if (!dataRow) return;

  const store    = dataRow.dataset.store;
  const date     = dataRow.dataset.date;
  const delivery = dataRow.dataset.delivery;
  const status   = dataRow.dataset.status;
  const note     = dataRow.dataset.note;
  const items    = dataRow.querySelectorAll('.order-item-entry');

  // Cập nhật title
  document.getElementById('order-detail-title').textContent = 'Đơn hàng #ORD-' + oid;

  // Điền thông tin
  document.getElementById('detail-store').textContent    = store;
  document.getElementById('detail-date').textContent     = date || '—';
  document.getElementById('detail-delivery').textContent = delivery || 'Chưa xác định';
  document.getElementById('detail-note').textContent     = note || '—';
  document.getElementById('detail-status-badge').innerHTML = getStatusBadge(status);

  // Danh sách sản phẩm
  const itemsEl = document.getElementById('detail-items');
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

  // Nút hành động
  document.getElementById('detail-actions').innerHTML = buildActionButtons(oid, status);

  // Hiện panel
  document.getElementById('order-detail-placeholder').style.display = 'none';
  document.getElementById('order-detail-body').style.display = '';
}

function buildActionButtons(oid, status) {
  const next = { PENDING: 'CONFIRMED', CONFIRMED: 'IN_PRODUCTION', IN_PRODUCTION: 'READY' };
  const labels = {
    PENDING:       '✓ Xác nhận đơn hàng',
    CONFIRMED:     '▶ Bắt đầu sản xuất',
    IN_PRODUCTION: '✅ Đánh dấu sẵn sàng'
  };
  if (!next[status]) return '';
  return '<button class="btn btn-primary" onclick="updateOrderStatus(' + oid + ',\'' + next[status] + '\')">' +
           labels[status] +
         '</button>';
}
</script>
