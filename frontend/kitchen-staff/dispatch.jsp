<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!-- ── PAGE: DISPATCH ── -->
  <div id="page-dispatch" style="display:none;">
    <div class="page-header">
      <hgroup>
        <h1>Xuất kho &amp; Giao hàng</h1>
        <p>Xác nhận xuất kho và theo dõi trạng thái vận chuyển đến cửa hàng</p>
      </hgroup>
    </div>

    <!-- Stats -->
    <div class="stats-grid" style="grid-template-columns:repeat(3,1fr);">
      <c:set var="cntReady"      value="0" />
      <c:set var="cntDelivering" value="0" />
      <c:set var="cntDelivered"  value="0" />
      <c:forEach items="${orders}" var="o">
        <c:if test="${o.status == 'READY'}">      <c:set var="cntReady"      value="${cntReady + 1}" /></c:if>
        <c:if test="${o.status == 'DELIVERING'}"> <c:set var="cntDelivering" value="${cntDelivering + 1}" /></c:if>
        <c:if test="${o.status == 'DELIVERED'}">  <c:set var="cntDelivered"  value="${cntDelivered + 1}" /></c:if>
      </c:forEach>
      <article class="stat-card c-amber">
        <div class="stat-icon">📦</div><div class="stat-label">Chờ xuất kho</div><div class="stat-value">${cntReady}</div>
      </article>
      <article class="stat-card c-blue">
        <div class="stat-icon">🚚</div><div class="stat-label">Đang giao</div><div class="stat-value">${cntDelivering}</div>
      </article>
      <article class="stat-card c-green">
        <div class="stat-icon">✅</div><div class="stat-label">Đã giao hôm nay</div><div class="stat-value">${cntDelivered}</div>
      </article>
    </div>

    <section class="panel">
      <header class="panel-head">
        <h2>Danh sách xuất kho</h2>
        <div class="panel-actions">
          <select id="dispatch-filter" onchange="filterDispatch()"
                  style="font-size:.8rem;padding:5px 8px;border:1px solid var(--gray-200);border-radius:var(--radius);">
            <option value="">Tất cả</option>
            <option value="READY">Chờ xuất kho</option>
            <option value="DELIVERING">Đang giao</option>
            <option value="DELIVERED">Đã giao</option>
          </select>
        </div>
      </header>
      <div class="table-wrap">
        <c:set var="hasDispatch" value="false" />
        <c:forEach items="${orders}" var="o">
          <c:if test="${o.status == 'READY' || o.status == 'DELIVERING' || o.status == 'DELIVERED'}">
            <c:set var="hasDispatch" value="true" />
          </c:if>
        </c:forEach>

        <c:choose>
          <c:when test="${!hasDispatch}">
            <div class="empty-state">
              <div class="empty-icon">🚚</div>
              Chưa có đơn hàng nào sẵn sàng xuất kho.
            </div>
          </c:when>
          <c:otherwise>
            <table>
              <thead>
                <tr><th>Đơn hàng</th><th>Cửa hàng</th><th>Sản phẩm</th><th>Giờ giao</th><th>Trạng thái</th><th>Thao tác</th></tr>
              </thead>
              <tbody id="dispatch-tbody">
                <c:forEach items="${orders}" var="order">
                  <c:if test="${order.status == 'READY' || order.status == 'DELIVERING' || order.status == 'DELIVERED'}">
                    <tr data-status="${order.status}">
                      <td><span class="mono">#ORD-${order.id}</span></td>
                      <td><strong><c:out value="${order.store.name}"/></strong></td>
                      <td>
                        <c:choose>
                          <c:when test="${not empty order.orderItems}">
                            <c:forEach items="${order.orderItems}" var="item" varStatus="st">
                              <c:out value="${item.product.name}"/> (${item.quantityRequested} ${item.product.unit})<c:if test="${!st.last}"><br/></c:if>
                            </c:forEach>
                          </c:when>
                          <c:otherwise><span class="text-muted">—</span></c:otherwise>
                        </c:choose>
                      </td>
                      <td><span class="mono"><c:out value="${order.deliveryDate}"/></span></td>
                      <td>
                        <c:choose>
                          <c:when test="${order.status == 'READY'}"><span class="badge badge-pending">Chờ xuất kho</span></c:when>
                          <c:when test="${order.status == 'DELIVERING'}"><span class="badge badge-process">Đang giao</span></c:when>
                          <c:otherwise><span class="badge badge-done">Đã giao</span></c:otherwise>
                        </c:choose>
                      </td>
                      <td>
                        <c:if test="${order.status == 'READY'}">
                          <button class="btn btn-primary btn-sm" onclick="confirmDispatch(${order.id})">Xác nhận xuất</button>
                        </c:if>
                        <c:if test="${order.status == 'DELIVERING'}">
                          <button class="btn btn-secondary btn-sm" onclick="confirmDelivered(${order.id})">Đã giao xong</button>
                        </c:if>
                        <c:if test="${order.status == 'DELIVERED'}">
                          <span class="text-muted" style="font-size:.78rem;">Hoàn tất</span>
                        </c:if>
                      </td>
                    </tr>
                  </c:if>
                </c:forEach>
              </tbody>
            </table>
          </c:otherwise>
        </c:choose>
      </div>
    </section>
  </div><!-- /page-dispatch -->

<script>
function filterDispatch() {
  const status = document.getElementById('dispatch-filter').value;
  document.querySelectorAll('#dispatch-tbody tr').forEach(row => {
    row.style.display = (!status || row.dataset.status === status) ? '' : 'none';
  });
}

async function confirmDispatch(orderId) {
  if (!confirm('Xác nhận xuất kho cho đơn #ORD-'+orderId+'?')) return;
  try {
    const r = await fetch('/kitchen-staff/orders/'+orderId+'/status?status=DELIVERING',{method:'POST',headers:{'X-Requested-With':'XMLHttpRequest'}});
    if (r.ok) { showToast('Đã xác nhận xuất kho đơn #ORD-'+orderId); setTimeout(()=>location.reload(),800); }
    else alert('Lỗi cập nhật trạng thái. Vui lòng thử lại.');
  } catch(e) { alert('Lỗi kết nối: '+e.message); }
}

async function confirmDelivered(orderId) {
  if (!confirm('Xác nhận đã giao xong đơn #ORD-'+orderId+'?')) return;
  try {
    const r = await fetch('/kitchen-staff/orders/'+orderId+'/status?status=DELIVERED',{method:'POST',headers:{'X-Requested-With':'XMLHttpRequest'}});
    if (r.ok) { showToast('Đã xác nhận giao thành công đơn #ORD-'+orderId); setTimeout(()=>location.reload(),800); }
    else alert('Lỗi cập nhật trạng thái. Vui lòng thử lại.');
  } catch(e) { alert('Lỗi kết nối: '+e.message); }
}
</script>
