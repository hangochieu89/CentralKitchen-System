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
        <button class="btn btn-primary" onclick="document.getElementById('dlg-batch').showModal()">+ Tạo lô mới</button>
      </div>
    </div>

    <section class="panel">
      <header class="panel-head">
        <h2>Danh sách lô sản xuất</h2>
        <div class="panel-actions">
          <select id="batch-status-filter" onchange="filterBatches()"
                  style="font-size:.8rem;padding:5px 8px;border:1px solid var(--gray-200);border-radius:var(--radius);">
            <option value="">Tất cả</option>
            <option value="ok">Còn hạn</option>
            <option value="empty">Hết lô</option>
          </select>
        </div>
      </header>
      <div class="filter-bar">
        <input type="search" id="batch-search" placeholder="Tìm mã lô, sản phẩm…" oninput="filterBatches()" />
        <select><option>7 ngày gần nhất</option><option>Tháng này</option><option>Tất cả</option></select>
      </div>
      <div class="table-wrap">
        <table>
          <thead>
            <tr><th>Mã lô</th><th>Sản phẩm</th><th>Ngày SX</th><th>HSD</th><th>Số lượng ban đầu</th><th>Còn lại</th><th>Kho</th><th>Trạng thái</th><th>Thao tác</th></tr>
          </thead>
          <tbody id="batches-tbody">
            <c:choose>
              <c:when test="${empty batches}">
                <tr><td colspan="9" class="empty-state">Chưa có lô sản xuất nào.</td></tr>
              </c:when>
              <c:otherwise>
                <c:forEach items="${batches}" var="batch">
                <tr data-batch-status="${batch.quantityRemaining > 0 ? 'ok' : 'empty'}"
                    data-batch-name="${batch.product.name}"
                    data-batch-number="${batch.batchNumber}">
                  <td><span class="lot-tag">${batch.batchNumber}</span></td>
                  <td><strong>${batch.product.name}</strong></td>
                  <td><span class="mono">${batch.manufactureDate}</span></td>
                  <td><span class="expiry">${batch.expirationDate}</span></td>
                  <td><span class="mono">${batch.quantityInitial} ${batch.product.unit}</span></td>
                  <td><span class="mono">${batch.quantityRemaining} ${batch.product.unit}</span></td>
                  <td>${batch.store.name}</td>
                  <td>
                    <span class="badge ${batch.quantityRemaining > 0 ? 'badge-process' : 'badge-done'}">
                      ${batch.quantityRemaining > 0 ? 'Sẵn sàng' : 'Hết lô'}
                    </span>
                  </td>
                  <td>
                    <button class="btn btn-secondary btn-sm"
                      onclick="openBatchUpdateDialog(
                        ${batch.id},
                        '${batch.batchNumber}',
                        '<c:out value="${batch.product.name}"/>',
                        ${batch.quantityRemaining},
                        '${batch.expirationDate}'
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
  </div><!-- /page-batches -->

<script>
function filterBatches() {
  const search = (document.getElementById('batch-search').value||'').toLowerCase();
  const status = document.getElementById('batch-status-filter').value;
  document.querySelectorAll('#batches-tbody tr[data-batch-name]').forEach(row => {
    const ms = !search || row.dataset.batchName.toLowerCase().includes(search) || row.dataset.batchNumber.toLowerCase().includes(search);
    const mst= !status || row.dataset.batchStatus === status;
    row.style.display = (ms && mst) ? '' : 'none';
  });
}
</script>
