<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!-- ── PAGE: BATCHES ── -->
  <div id="page-batches" style="display:none;">
    <div class="page-header">
      <hgroup>
        <h1>Lô sản xuất</h1>
        <p>Quản lý lô sản xuất, hạn sử dụng và truy xuất nguồn gốc</p>
      </hgroup>
      <div class="actions">
        <button class="btn btn-primary">+ Tạo lô mới</button>
      </div>
    </div>

    <section class="panel">
      <header class="panel-head">
        <h2>Danh sách lô sản xuất</h2>
        <div class="panel-actions">
          <select style="font-size:.8rem;padding:5px 8px;border:1px solid var(--gray-200);border-radius:var(--radius);">
            <option>Tất cả</option><option>Còn hạn</option><option>Sắp hết hạn</option><option>Đã hết hạn</option>
          </select>
        </div>
      </header>
      <div class="filter-bar">
        <input type="search" placeholder="Tìm mã lô, sản phẩm…" />
        <select><option>7 ngày gần nhất</option><option>Tháng này</option></select>
      </div>
      <div class="table-wrap">
        <table>
          <thead><tr><th>Mã lô</th><th>Sản phẩm</th><th>Ngày SX</th><th>HSD</th><th>Số lượng</th><th>Nguyên liệu chính</th><th>Xuất cho</th><th>Trạng thái</th></tr></thead>
          <tbody>
            <c:forEach items="${batches}" var="batch">
            <tr>
              <td><span class="lot-tag">${batch.batchNumber}</span></td>
              <td><strong>${batch.product.name}</strong></td>
              <td><span class="mono">${batch.manufactureDate}</span></td>
              <td><span class="expiry">${batch.expirationDate}</span></td>
              <td><span class="mono">${batch.quantityRemaining} ${batch.product.unit}</span></td>
              <td>Thành phần liên quan (${batch.product.name})</td>
              <td>${batch.store.name}</td>
              <td><span class="badge ${batch.quantityRemaining > 0 ? 'badge-process' : 'badge-done'}">${batch.quantityRemaining > 0 ? 'Sẵn sàng' : 'Hết lô'}</span></td>
            </tr>
            </c:forEach>
          </tbody>
        </table>
      </div>
    </section>
  </div><!-- /page-batches -->