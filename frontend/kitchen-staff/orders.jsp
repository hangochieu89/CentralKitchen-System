<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!-- ── PAGE: ORDERS ── -->
  <div id="page-orders" style="display:none;">
    <div class="page-header">
      <hgroup>
        <h1>Tiếp nhận đơn hàng</h1>
        <p>Đơn ở trạng thái <strong>Chờ xử lý</strong> do <strong>Điều phối cung ứng</strong> xác nhận trước; bếp xử lý từ <strong>Đã xác nhận</strong> (sản xuất → sẵn sàng → xuất kho / giao).</p>
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
                  <c:choose>
                    <c:when test="${not empty order.orderItems}">
                      <span style="font-size:.8rem;">
                        <c:out value="${order.orderItems[0].product.name}"/>
                        <c:if test="${fn:length(order.orderItems) > 1}">
                          <span class="badge badge-process" style="font-size:.68rem;margin-left:4px;">+${fn:length(order.orderItems) - 1}</span>
                        </c:if>
                      </span>
                    </c:when>
                    <c:otherwise><span class="text-muted">—</span></c:otherwise>
                  </c:choose>
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
              <!-- Hidden data node for JS -->
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
                          data-name="${item.product.name}"
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

      <!-- Chi tiết đơn -->
      <section class="panel" id="order-detail-panel">
        <header class="panel-head">
          <h2 id="order-detail-title">Chi tiết đơn hàng</h2>
        </header>

        <div id="order-detail-placeholder" style="padding:40px;text-align:center;color:var(--gray-400);">
          <div style="font-size:2.5rem;margin-bottom:10px;opacity:.3;">📋</div>
          <p>Chọn một đơn hàng bên trái để xem chi tiết.</p>
        </div>

        <div id="order-detail-body" style="display:none;">
          <div class="order-detail">
            <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px;">
              <div class="field"><span class="field-label">Cửa hàng</span><p class="fw7" id="detail-store"></p></div>
              <div class="field"><span class="field-label">Trạng thái</span><p id="detail-status-badge"></p></div>
              <div class="field"><span class="field-label">Ngày đặt</span><p class="mono" id="detail-date"></p></div>
              <div class="field"><span class="field-label">Thời gian giao mong muốn</span><p class="mono" id="detail-delivery"></p></div>
            </div>
            <hr class="divider" />
            <div class="field"><span class="field-label">Danh sách sản phẩm</span></div>
            <div class="item-list" id="detail-items"></div>
            <hr class="divider" />
            <div class="field"><span class="field-label">Ghi chú</span><p id="detail-note" class="text-muted" style="font-size:.85rem;"></p></div>
          </div>
          <div class="detail-action-bar" id="detail-actions"></div>
        </div>
      </section>
    </div>
  </div><!-- /page-orders -->

<script>
function filterOrders() {
  const search = (document.getElementById('orders-search').value||'').toLowerCase();
  const status = document.getElementById('orders-filter-status').value;
  document.querySelectorAll('#orders-tbody tr.order-row').forEach(row => {
    const ms = !search || row.dataset.oid.includes(search) || row.dataset.store.toLowerCase().includes(search);
    const mst= !status || row.dataset.status === status;
    row.style.display = (ms && mst) ? '' : 'none';
  });
}

function selectOrder(oid) {
  document.querySelectorAll('#orders-tbody tr.order-row').forEach(r => r.classList.remove('row-selected'));
  const sel = document.querySelector('#orders-tbody tr.order-row[data-oid="'+oid+'"]');
  if (sel) sel.classList.add('row-selected');

  const dataRow = document.getElementById('order-data-'+oid);
  if (!dataRow) return;

  const items = dataRow.querySelectorAll('.order-item-entry');
  document.getElementById('order-detail-title').textContent = 'Đơn hàng #ORD-'+oid;
  document.getElementById('detail-store').textContent    = dataRow.dataset.store;
  document.getElementById('detail-date').textContent     = dataRow.dataset.date || '—';
  document.getElementById('detail-delivery').textContent = dataRow.dataset.delivery || 'Chưa xác định';
  document.getElementById('detail-note').textContent     = dataRow.dataset.note || '—';
  document.getElementById('detail-status-badge').innerHTML = getStatusBadge(dataRow.dataset.status);

  const itemsEl = document.getElementById('detail-items');
  if (!items.length) {
    itemsEl.innerHTML = '<div class="item-row"><span class="text-muted">Không có sản phẩm.</span></div>';
  } else {
    itemsEl.innerHTML = '';
    items.forEach(item => {
      itemsEl.innerHTML += '<div class="item-row"><span class="item-name">'+item.dataset.name+'</span><span class="item-qty">'+item.dataset.qty+' '+item.dataset.unit+'</span></div>';
    });
  }

  document.getElementById('detail-actions').innerHTML = buildActionButtons(oid, dataRow.dataset.status);
  document.getElementById('order-detail-placeholder').style.display = 'none';
  document.getElementById('order-detail-body').style.display = '';
}

function buildActionButtons(oid, status) {
  if (status === 'PENDING') {
    return '<p class="text-muted" style="font-size:.82rem;padding:8px 0;">Đơn đang chờ Điều phối cung ứng xác nhận — không thao tác tại bếp.</p>';
  }
  const next   = {CONFIRMED:'IN_PRODUCTION', IN_PRODUCTION:'READY', READY:'DELIVERING', DELIVERING:'DELIVERED'};
  const labels = {CONFIRMED:'▶ Bắt đầu sản xuất', IN_PRODUCTION:'✅ Đánh dấu sẵn sàng', READY:'🚚 Xuất kho / Đang giao', DELIVERING:'✓ Hoàn tất giao hàng'};
  if (!next[status]) return '';
  return '<button class="btn btn-primary" onclick="updateOrderStatus('+oid+',\''+next[status]+'\')">'+labels[status]+'</button>';
}
</script>
