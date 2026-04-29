<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!-- ── PAGE: INVENTORY ── -->
  <div id="page-inventory" style="display:none;">
    <div class="page-header">
      <hgroup>
        <h1>Tồn kho bếp trung tâm</h1>
        <p>Theo dõi số lượng thành phẩm / bán thành phẩm sẵn sàng xuất</p>
      </hgroup>
      <div class="actions">
        <button class="btn btn-secondary">⬇ Xuất Excel</button>
        <button class="btn btn-primary">+ Nhập kho</button>
      </div>
    </div>

    <div class="filter-bar" style="border:1px solid var(--gray-100);border-radius:var(--radius);background:var(--white);margin-bottom:0;">
      <input type="search" placeholder="Tìm tên sản phẩm, SKU…" style="width:240px;" />
      <select><option>Tất cả danh mục</option><option>Súp / Nước dùng</option><option>Thịt sơ chế</option><option>Bánh / Bột</option><option>Gia vị</option></select>
      <select><option>Tất cả mức tồn</option><option>Bình thường</option><option>Thấp (&lt; min)</option><option>Hết hàng</option></select>
    </div>

    <div class="inv-grid">
      <c:forEach items="${inventories}" var="inv">
      <article class="inv-card ${inv.quantity < inv.minThreshold ? 'low' : 'ok'}">
        <div class="flex-between">
          <div class="inv-name">${inv.product.name}</div>
          <span class="badge ${inv.quantity < inv.minThreshold ? 'badge-alert' : 'badge-done'}" style="font-size:.68rem;">${inv.quantity < inv.minThreshold ? 'Thấp' : 'OK'}</span>
        </div>
        <div class="inv-sku">Thuộc: ${inv.store.name}</div>
        <div><span class="inv-qty" ${inv.quantity < inv.minThreshold ? 'style="color:var(--red);"' : ''}>${inv.quantity}</span> <span class="inv-unit">${inv.product.unit}</span></div>
        <div class="inv-meta">
          <span>Tối thiểu: ${inv.minThreshold} ${inv.product.unit}</span>
          <span>Lô: N/A</span>
          <span class="expiry ok">Cập nhật: <c:out value="${inv.updatedAt}" /></span>
        </div>
        <div style="display:flex;gap:6px;margin-top:4px;">
          <button class="btn btn-secondary btn-sm" style="flex:1;">Xuất kho</button>
          <button class="btn btn-ghost btn-sm">Chi tiết</button>
        </div>
      </article>
      </c:forEach>
    </div>
  </div><!-- /page-inventory -->