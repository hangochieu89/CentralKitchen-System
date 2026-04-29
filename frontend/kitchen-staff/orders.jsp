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
            <select style="font-size:.8rem;padding:5px 8px;border:1px solid var(--gray-200);border-radius:var(--radius);">
              <option>Tất cả trạng thái</option>
              <option>Chờ xử lý</option>
              <option>Đang SX</option>
              <option>Hoàn thành</option>
            </select>
          </div>
        </header>
        <div class="filter-bar">
          <input type="search" placeholder="Tìm mã đơn, cửa hàng…" />
          <select><option>Hôm nay</option><option>7 ngày</option><option>Tháng này</option></select>
          <select><option>Tất cả cửa hàng</option><option>CH Quận 1</option><option>CH Bình Thạnh</option><option>CH Tân Bình</option><option>CH Gò Vấp</option></select>
        </div>
        <div class="table-wrap">
          <table>
            <thead><tr><th>Mã đơn</th><th>Cửa hàng</th><th>Sản phẩm</th><th>Ngày đặt</th><th>Ưu tiên</th><th>Trạng thái</th><th>Thao tác</th></tr></thead>
            <tbody>
              <c:forEach items="${orders}" var="order">
              <tr>
                <td><span class="mono">#ORD-${order.id}</span></td>
                <td><strong>${order.store.name}</strong></td>
                <td>N/A</td>
                <td><span class="mono">${order.orderDate}</span></td>
                <td><span class="badge ${order.status == 'PENDING' ? 'badge-alert' : 'badge-default'}">Thường</span></td>
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
                <td>
                  <button class="btn btn-${order.status == 'PENDING' ? 'primary' : 'ghost'} btn-sm" onclick="document.getElementById('dlg-order').showModal()">Chi tiết</button>
                </td>
              </tr>
              </c:forEach>
            </tbody>
          </table>
        </div>
      </section>

      <!-- Chi tiết đơn -->
      <section class="panel">
        <header class="panel-head"><h2>Chi tiết đơn #ORD-2341</h2></header>
        <div class="order-detail">
          <div class="field">
            <label>Cửa hàng</label>
            <p class="fw7">Chi nhánh Quận 1 — 123 Lê Lợi, Q.1</p>
          </div>
          <div class="field">
            <label>Thời gian đặt</label>
            <p class="mono">18/03/2026 08:15</p>
          </div>
          <div class="field">
            <label>Mong muốn nhận</label>
            <p class="mono">18/03/2026 13:00</p>
          </div>
          <hr class="divider" />
          <div class="field">
            <label>Danh sách sản phẩm</label>
          </div>
          <div class="item-list">
            <div class="item-row">
              <div>
                <div class="item-name">Phở bò sơ chế</div>
                <div class="secondary">SKU: PB-001</div>
              </div>
              <div class="item-qty">5.0 kg</div>
            </div>
            <div class="item-row">
              <div>
                <div class="item-name">Cháo trắng</div>
                <div class="secondary">SKU: CT-002</div>
              </div>
              <div class="item-qty">3.0 kg</div>
            </div>
            <div class="item-row">
              <div>
                <div class="item-name">Nước dùng phở</div>
                <div class="secondary">SKU: ND-010</div>
              </div>
              <div class="item-qty">10.0 L</div>
            </div>
          </div>
          <hr class="divider" />
          <div class="field">
            <label>Ghi chú từ cửa hàng</label>
            <p>Nước dùng đặc hơn bình thường. Phở bò cần làm sạch kỹ.</p>
          </div>
          <div style="display:flex;gap:8px;flex-wrap:wrap;">
            <button class="btn btn-primary" onclick="document.getElementById('dlg-order').showModal()">✓ Xác nhận xử lý</button>
            <button class="btn btn-secondary">✎ Cập nhật trạng thái</button>
            <button class="btn btn-ghost" style="color:var(--red);">✕ Từ chối</button>
          </div>
        </div>
      </section>
    </div>
  </div><!-- /page-orders -->