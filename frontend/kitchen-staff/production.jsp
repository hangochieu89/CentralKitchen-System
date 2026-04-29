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

    <div class="page-tabs">
      <button class="active">Hôm nay (18/3)</button>
      <button>Ngày mai (19/3)</button>
      <button>Tuần này</button>
    </div>

    <section class="panel">
      <header class="panel-head">
        <h2>Kế hoạch ngày 18/03/2026</h2>
        <div class="panel-actions">
          <button class="btn btn-secondary btn-sm">⬇ In kế hoạch</button>
          <button class="btn btn-primary btn-sm">+ Thêm mục</button>
        </div>
      </header>
      <div class="table-wrap">
        <table>
          <thead><tr><th>Sản phẩm</th><th>Số lượng SX</th><th>Ca</th><th>Nhân sự</th><th>Nguyên liệu</th><th>Lô</th><th>Trạng thái</th><th>Thao tác</th></tr></thead>
          <tbody>
            <c:forEach items="${plans}" var="plan">
            <tr>
              <td>
                <strong>Đơn hàng liên kết: #ORD-${plan.order.id}</strong>
              </td>
              <td><span class="mono">Theo đơn hàng</span></td>
              <td>Ca sản xuất</td>
              <td>${plan.assignedTo != null ? plan.assignedTo.fullName : 'Chưa phân công'}</td>
              <td>(Thành phần nguyên liệu)</td>
              <td><span class="lot-tag">N/A</span></td>
              <td>
                  <c:choose>
                    <c:when test="${plan.status == 'PENDING'}"><span class="badge badge-pending">Chờ xử lý</span></c:when>
                    <c:when test="${plan.status == 'IN_PROGRESS'}"><span class="badge badge-process">Đang SX</span></c:when>
                    <c:when test="${plan.status == 'COMPLETED'}"><span class="badge badge-done">Hoàn thành</span></c:when>
                    <c:otherwise><span class="badge badge-alert">Đã hủy</span></c:otherwise>
                  </c:choose>
              </td>
              <td>
                <button class="btn btn-secondary btn-sm">Cập nhật</button>
              </td>
            </tr>
            </c:forEach>
          </tbody>
        </table>
      </div>
    </section>

    <!-- Cập nhật trạng thái nhanh -->
    <section class="panel">
      <header class="panel-head"><h2>✎ Cập nhật trạng thái sản xuất — Lô #L241</h2></header>
      <div style="padding:20px;">
        <form onsubmit="return false;" style="display:flex;flex-direction:column;gap:16px;">
          <div class="form-grid">
            <div class="form-group">
              <label for="prod-lot">Mã lô</label>
              <input id="prod-lot" type="text" value="#L241" readonly style="background:var(--gray-50);" />
            </div>
            <div class="form-group">
              <label for="prod-status">Trạng thái</label>
              <select id="prod-status">
                <option>Đang sản xuất</option>
                <option>Tạm dừng</option>
                <option selected>Hoàn thành</option>
                <option>Hủy</option>
              </select>
            </div>
            <div class="form-group">
              <label for="prod-qty">Số lượng thực tế (kg)</label>
              <input id="prod-qty" type="number" value="24.5" step="0.1" />
            </div>
            <div class="form-group">
              <label for="prod-time">Thời gian hoàn thành</label>
              <input id="prod-time" type="datetime-local" value="2026-03-18T10:20" />
            </div>
            <div class="form-group full">
              <label for="prod-note">Ghi chú / vấn đề phát sinh</label>
              <textarea id="prod-note" rows="2" placeholder="Nhập ghi chú nếu có…"></textarea>
            </div>
          </div>
          <div style="display:flex;gap:8px;">
            <button class="btn btn-primary">💾 Lưu cập nhật</button>
            <button class="btn btn-secondary">Hủy</button>
          </div>
        </form>
      </div>
    </section>
  </div><!-- /page-production -->