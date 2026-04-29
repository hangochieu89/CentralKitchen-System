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
          <h2>Danh sách nguyên liệu</h2>
        </header>
        <div class="filter-bar">
          <input type="search" placeholder="Tìm nguyên liệu, nhà cung cấp…" />
          <select><option>Tất cả</option><option>Thịt / Hải sản</option><option>Rau củ</option><option>Gia vị</option><option>Gạo / Bột</option></select>
        </div>
        <div class="table-wrap">
          <table>
            <thead><tr><th>Mã NL</th><th>Tên</th><th>Nhà CC</th><th>Ngày nhập</th><th>HSD</th><th>Tồn kho</th><th>Trạng thái</th></tr></thead>
            <tbody>
              <c:forEach items="${receiptDetails}" var="detail">
              <tr>
                <td><span class="mono">${detail.product.id}</span></td>
                <td><strong>${detail.product.name}</strong></td>
                <td>N/A</td>
                <td><span class="mono">${detail.goodsReceipt != null ? detail.goodsReceipt.receiptDate : ''}</span></td>
                <td><span class="expiry ok">${detail.expirationDate}</span></td>
                <td><span class="mono">${detail.quantity} ${detail.product.unit}</span></td>
                <td><span class="badge badge-done">OK</span></td>
              </tr>
              </c:forEach>
            </tbody>
          </table>
        </div>
      </section>

      <!-- Lịch sử nhập kho -->
      <section class="panel">
        <header class="panel-head"><h2>Lịch sử hoạt động hôm nay</h2></header>
        <ol class="timeline">
          <li>
            <div class="dot done">✓</div>
            <div class="t-body">
              <div class="t-title">Nhập thịt heo xay — Vissan</div>
              <div class="t-time">08:30 — 12 kg</div>
              <div class="t-desc">Phiếu nhập #PN-0412, QC đạt</div>
            </div>
          </li>
          <li>
            <div class="dot done">✓</div>
            <div class="t-body">
              <div class="t-title">Xuất kho nước dùng — CH Bình Thạnh</div>
              <div class="t-time">09:00 — 30L</div>
              <div class="t-desc">Đơn #ORD-2340 được xuất</div>
            </div>
          </li>
          <li>
            <div class="dot active">→</div>
            <div class="t-body">
              <div class="t-title">Đang SX: Phở bò Lô #L241</div>
              <div class="t-time">09:15 — Tiến độ 70%</div>
              <div class="t-desc">Dự kiến hoàn thành 10:30</div>
            </div>
          </li>
          <li>
            <div class="dot">○</div>
            <div class="t-body">
              <div class="t-title">Cần bổ sung: Thịt bò, Sả tươi</div>
              <div class="t-time">Chờ phê duyệt</div>
              <div class="t-desc">Yêu cầu #YC-088 đã gửi điều phối</div>
            </div>
          </li>
        </ol>
      </section>
    </div>
  </div><!-- /page-inputs -->