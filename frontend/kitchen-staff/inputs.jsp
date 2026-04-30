<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!-- ── PAGE: INPUTS ── -->
  <div id="page-inputs" style="display:none;">
    <div class="page-header">
      <hgroup>
        <h1>Nguyên liệu đầu vào</h1>
        <p>Quản lý nhập hàng, hạn sử dụng và truy xuất nguồn gốc</p>
      </hgroup>
      <div class="actions">
        <button class="btn btn-primary" onclick="document.getElementById('dlg-input').showModal()">+ Nhập nguyên liệu</button>
      </div>
    </div>

    <div class="two-col">
      <section class="panel">
        <header class="panel-head">
          <h2>Danh sách nguyên liệu đã nhập</h2>
        </header>
        <div class="filter-bar">
          <input type="search" id="inputs-search" placeholder="Tìm nguyên liệu…" oninput="filterInputs()" />
        </div>
        <div class="table-wrap">
          <table>
            <thead>
              <tr><th>Mã NL</th><th>Tên</th><th>Nhà cung cấp</th><th>Ngày nhập</th><th>HSD</th><th>Số lượng</th><th>Trạng thái</th></tr>
            </thead>
            <tbody id="inputs-tbody">
              <c:choose>
                <c:when test="${empty receiptDetails}">
                  <tr><td colspan="7" class="empty-state">Chưa có nguyên liệu nào được nhập.</td></tr>
                </c:when>
                <c:otherwise>
                  <c:forEach items="${receiptDetails}" var="detail">
                  <tr data-input-name="${detail.product.name}">
                    <td><span class="mono">${detail.product.id}</span></td>
                    <td><strong>${detail.product.name}</strong></td>
                    <td>
                      <c:choose>
                        <c:when test="${detail.goodsReceipt != null && detail.goodsReceipt.supplier != null}">
                          <c:out value="${detail.goodsReceipt.supplier.name}"/>
                        </c:when>
                        <c:otherwise><span class="text-muted">—</span></c:otherwise>
                      </c:choose>
                    </td>
                    <td><span class="mono">${detail.goodsReceipt != null ? detail.goodsReceipt.receiptDate : '—'}</span></td>
                    <td><span class="expiry ok">${detail.expirationDate}</span></td>
                    <td><span class="mono">${detail.quantity} ${detail.product.unit}</span></td>
                    <td><span class="badge badge-done">OK</span></td>
                  </tr>
                  </c:forEach>
                </c:otherwise>
              </c:choose>
            </tbody>
          </table>
        </div>
      </section>

      <!-- Lịch sử nhập kho -->
      <section class="panel">
        <header class="panel-head"><h2>📋 Phiếu nhập kho gần đây</h2></header>
        <div class="table-wrap">
          <table>
            <thead>
              <tr><th>Mã phiếu</th><th>Nhà cung cấp</th><th>Ngày nhập</th><th>Trạng thái</th></tr>
            </thead>
            <tbody>
              <c:choose>
                <c:when test="${empty receipts}">
                  <tr><td colspan="4" class="empty-state">Chưa có phiếu nhập nào.</td></tr>
                </c:when>
                <c:otherwise>
                  <c:forEach items="${receipts}" var="receipt" end="9">
                  <tr>
                    <td><span class="mono">#RCP-${receipt.id}</span></td>
                    <td><c:out value="${receipt.supplier.name}"/></td>
                    <td><span class="mono">${receipt.receiptDate}</span></td>
                    <td>
                      <c:choose>
                        <c:when test="${receipt.status == 'COMPLETED'}"><span class="badge badge-done">Hoàn thành</span></c:when>
                        <c:when test="${receipt.status == 'PENDING'}"><span class="badge badge-pending">Chờ xử lý</span></c:when>
                        <c:otherwise><span class="badge badge-alert">Đã hủy</span></c:otherwise>
                      </c:choose>
                    </td>
                  </tr>
                  </c:forEach>
                </c:otherwise>
              </c:choose>
            </tbody>
          </table>
        </div>
      </section>
    </div>
  </div><!-- /page-inputs -->

<script>
function filterInputs() {
  const search = (document.getElementById('inputs-search').value||'').toLowerCase();
  document.querySelectorAll('#inputs-tbody tr[data-input-name]').forEach(row => {
    row.style.display = (!search || row.dataset.inputName.toLowerCase().includes(search)) ? '' : 'none';
  });
}
</script>
