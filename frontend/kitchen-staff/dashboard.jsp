<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!-- ── PAGE: DASHBOARD ── -->
  <div id="page-dashboard">
    <div class="page-header">
      <hgroup>
        <h1>Dashboard</h1>
        <p>Thứ Tư, 18 tháng 3 năm 2026 &mdash; Ca sáng</p>
      </hgroup>
      <div class="actions">
        <button class="btn btn-secondary">⬇ Xuất báo cáo</button>
        <button class="btn btn-primary" onclick="document.getElementById('dlg-plan').showModal()">+ Tạo kế hoạch SX</button>
      </div>
    </div>

    <!-- Stats -->
    <div class="stats-grid">
      <article class="stat-card c-orange">
        <div class="stat-icon">📋</div>
        <div class="stat-label">Đơn chờ xử lý</div>
        <div class="stat-value">7</div>
        <div class="stat-sub">3 ưu tiên cao</div>
      </article>
      <article class="stat-card c-blue">
        <div class="stat-icon">⚙️</div>
        <div class="stat-label">Đang sản xuất</div>
        <div class="stat-value">4</div>
        <div class="stat-sub">2 lô hoàn thành hôm nay</div>
      </article>
      <article class="stat-card c-green">
        <div class="stat-icon">🚚</div>
        <div class="stat-label">Sẵn sàng giao</div>
        <div class="stat-value">12</div>
        <div class="stat-sub">Đợt giao 14:00</div>
      </article>
      <article class="stat-card c-amber">
        <div class="stat-icon">⚠️</div>
        <div class="stat-label">Nguyên liệu sắp hết</div>
        <div class="stat-value">3</div>
        <div class="stat-sub">Cần bổ sung hôm nay</div>
      </article>
    </div>

    <!-- Two-col layout -->
    <div class="two-col">
      <!-- Đơn mới nhất -->
      <section class="panel">
        <header class="panel-head">
          <h2>📋 Đơn hàng mới nhất</h2>
          <div class="panel-actions">
            <button class="btn btn-secondary btn-sm" onclick="showPage('orders', document.querySelector('[href=\'#orders\']'))">Xem tất cả</button>
          </div>
        </header>
        <div class="table-wrap">
          <table>
            <thead>
              <tr>
                <th>Mã đơn</th>
                <th>Cửa hàng</th>
                <th>Sản phẩm</th>
                <th>Thời gian</th>
                <th>Trạng thái</th>
                <th></th>
              </tr>
            </thead>
            <tbody id="dashboard-orders">
              <c:forEach items="${orders}" var="order" end="4">
              <tr>
                <td><span class="mono">#ORD-${order.id}</span></td>
                <td>${order.store.name}</td>
                <td>Đơn hàng</td>
                <td class="text-muted">${order.orderDate}</td>
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
                <td><button class="btn btn-ghost btn-sm" onclick="document.getElementById('dlg-order').showModal()">Chi tiết</button></td>
              </tr>
              </c:forEach>
            </tbody>
          </table>
        </div>
      </section>

      <!-- Right column -->
      <div class="full-col">
        <!-- Tiến độ sản xuất -->
        <section class="panel">
          <header class="panel-head"><h2>⚙️ Tiến độ hôm nay</h2></header>
          <div style="padding:16px 20px;display:flex;flex-direction:column;gap:14px;">
            <c:forEach items="${plans}" var="plan" end="3">
            <div class="progress-wrap">
              <div class="prog-label"><span>Kế hoạch SX cho đơn #ORD-${plan.order.id}</span><span>${plan.status}</span></div>
              <progress class="${plan.status == 'COMPLETED' ? 'green' : (plan.status == 'IN_PROGRESS' ? 'amber' : '')}" value="${plan.status == 'COMPLETED' ? 100 : (plan.status == 'IN_PROGRESS' ? 50 : 0)}" max="100"></progress>
              <span class="text-muted" style="font-size:.73rem;">Phân công: ${plan.assignedTo != null ? plan.assignedTo.fullName : 'Chưa CC'}</span>
            </div>
            </c:forEach>
          </div>
        </section>

        <!-- Cảnh báo -->
        <section class="panel">
          <header class="panel-head"><h2>⚠️ Cảnh báo tồn kho</h2></header>
          <div style="padding:12px 16px;display:flex;flex-direction:column;gap:8px;">
            <c:forEach items="${inventories}" var="inv">
              <c:if test="${inv.quantity < inv.minThreshold}">
              <div class="item-row" style="padding:10px 12px;background:var(--red-lt);border-radius:var(--radius);font-size:.83rem;display:flex;justify-content:space-between;align-items:center;">
                <span>⚠️ ${inv.product.name}</span>
                <span style="color:var(--red);font-family:var(--font-mono);font-weight:700;">${inv.quantity} ${inv.product.unit} còn lại</span>
              </div>
              </c:if>
            </c:forEach>
          </div>
        </section>
      </div>
    </div>
  </div><!-- /page-dashboard -->