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
        <button class="btn btn-primary" onclick="document.getElementById('dlg-plan').showModal()">+ Tạo kế hoạch SX</button>
      </div>
    </div>

    <!-- Stats -->
    <div class="stats-grid">
      <c:set var="pendingOrders" value="0" />
      <c:set var="inProductionPlans" value="0" />
      <c:set var="readyOrders" value="0" />
      <c:set var="lowInventories" value="0" />

      <c:forEach items="${orders}" var="order">
        <c:if test="${order.status == 'PENDING'}">
          <c:set var="pendingOrders" value="${pendingOrders + 1}" />
        </c:if>
        <c:if test="${order.status == 'READY'}">
          <c:set var="readyOrders" value="${readyOrders + 1}" />
        </c:if>
      </c:forEach>

      <c:forEach items="${plans}" var="plan">
        <c:if test="${plan.status == 'IN_PROGRESS'}">
          <c:set var="inProductionPlans" value="${inProductionPlans + 1}" />
        </c:if>
      </c:forEach>

      <c:forEach items="${inventories}" var="inv">
        <c:if test="${inv.quantity < inv.minThreshold}">
          <c:set var="lowInventories" value="${lowInventories + 1}" />
        </c:if>
      </c:forEach>

      <article class="stat-card c-orange">
        <div class="stat-icon">📋</div>
        <div class="stat-label">Đơn chờ xử lý</div>
        <div class="stat-value">${pendingOrders}</div>
        <div class="stat-sub">Vừa cập nhật</div>
      </article>
      <article class="stat-card c-blue">
        <div class="stat-icon">⚙️</div>
        <div class="stat-label">Đang sản xuất</div>
        <div class="stat-value">${inProductionPlans}</div>
        <div class="stat-sub">Đang thực hiện</div>
      </article>
      <article class="stat-card c-green">
        <div class="stat-icon">🚚</div>
        <div class="stat-label">Sẵn sàng giao</div>
        <div class="stat-value">${readyOrders}</div>
        <div class="stat-sub">Chờ xuất kho</div>
      </article>
      <article class="stat-card c-amber">
        <div class="stat-icon">⚠️</div>
        <div class="stat-label">Tồn kho thấp</div>
        <div class="stat-value">${lowInventories}</div>
        <div class="stat-sub">Cần bổ sung</div>
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
                <th>Ngày đặt</th>
                <th>Trạng thái</th>
                <th></th>
              </tr>
            </thead>
            <tbody>
              <c:forEach items="${orders}" var="order" end="4">
              <tr>
                <td><span class="mono">#ORD-${order.id}</span></td>
                <td>${order.store.name}</td>
                <td class="text-muted">${order.orderDate.toLocalDate()} ${order.orderDate.toLocalTime()}</td>
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
                <td><button class="btn btn-ghost btn-sm" onclick="openOrderDialog(${order.id})">Chi tiết</button></td>
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
            <c:choose>
              <c:when test="${empty plans}">
                <div class="empty-state" style="padding:20px 0;">
                  <div class="empty-icon">📋</div>
                  Chưa có kế hoạch sản xuất nào.
                </div>
              </c:when>
              <c:otherwise>
                <c:forEach items="${plans}" var="plan" end="3">
                <div class="progress-wrap">
                  <div class="prog-label">
                    <span>Đơn #ORD-${plan.order.id}</span>
                    <span class="badge ${plan.status == 'COMPLETED' ? 'badge-done' : (plan.status == 'IN_PROGRESS' ? 'badge-process' : 'badge-pending')}" style="font-size:.68rem;">
                      ${plan.status == 'COMPLETED' ? 'Hoàn thành' : (plan.status == 'IN_PROGRESS' ? 'Đang SX' : 'Chờ')}
                    </span>
                  </div>
                  <progress class="${plan.status == 'COMPLETED' ? 'green' : (plan.status == 'IN_PROGRESS' ? 'amber' : '')}"
                            value="${plan.status == 'COMPLETED' ? 100 : (plan.status == 'IN_PROGRESS' ? 50 : 0)}" max="100"></progress>
                  <span class="text-muted" style="font-size:.73rem;">Phân công: ${plan.assignedTo != null ? plan.assignedTo.fullName : 'Chưa phân công'}</span>
                </div>
                </c:forEach>
              </c:otherwise>
            </c:choose>
          </div>
        </section>

        <!-- Cảnh báo tồn kho -->
        <section class="panel">
          <header class="panel-head"><h2>⚠️ Cảnh báo tồn kho</h2></header>
          <div style="padding:12px 16px;display:flex;flex-direction:column;gap:8px;">
            <c:set var="hasLow" value="false" />
            <c:forEach items="${inventories}" var="inv">
              <c:if test="${inv.quantity < inv.minThreshold}">
                <c:set var="hasLow" value="true" />
                <div style="padding:10px 12px;background:var(--red-lt);border-radius:var(--radius);font-size:.83rem;display:flex;justify-content:space-between;align-items:center;">
                  <span>⚠️ ${inv.product.name}</span>
                  <span style="color:var(--red);font-family:var(--font-mono);font-weight:700;">${inv.quantity} ${inv.product.unit} còn lại</span>
                </div>
              </c:if>
            </c:forEach>
            <c:if test="${!hasLow}">
              <div class="empty-state" style="padding:16px 0;">
                <div class="empty-icon">✅</div>
                Tồn kho bình thường, không có cảnh báo.
              </div>
            </c:if>
          </div>
        </section>
      </div>
    </div>
  </div><!-- /page-dashboard -->
