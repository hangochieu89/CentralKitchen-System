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
        <button class="btn btn-primary" onclick="document.getElementById('dlg-input-inv').showModal()">+ Nhập kho</button>
      </div>
    </div>

    <div class="filter-bar" style="border:1px solid var(--gray-100);border-radius:var(--radius);background:var(--white);margin-bottom:0;">
      <input type="search" id="inv-search" placeholder="Tìm tên sản phẩm…" style="width:240px;" oninput="filterInventory()" />
      <select id="inv-level-filter" onchange="filterInventory()">
        <option value="">Tất cả mức tồn</option>
        <option value="low">Thấp (&lt; min)</option>
        <option value="ok">Bình thường</option>
      </select>
    </div>

    <div class="inv-grid" id="inv-grid-container">
      <c:choose>
        <c:when test="${empty inventories}">
          <div class="empty-state" style="grid-column:1/-1;">
            <div class="empty-icon">📦</div>
            Chưa có dữ liệu tồn kho.
          </div>
        </c:when>
        <c:otherwise>
          <c:forEach items="${inventories}" var="inv">
          <article class="inv-card ${inv.quantity < inv.minThreshold ? 'low' : 'ok'}"
                   data-inv-name="${inv.product.name}"
                   data-inv-level="${inv.quantity < inv.minThreshold ? 'low' : 'ok'}">
            <div class="flex-between">
              <div class="inv-name"><c:out value="${inv.product.name}"/></div>
              <span class="badge ${inv.quantity < inv.minThreshold ? 'badge-alert' : 'badge-done'}" style="font-size:.68rem;">
                ${inv.quantity < inv.minThreshold ? 'Thấp' : 'OK'}
              </span>
            </div>
            <div class="inv-sku">Kho: <c:out value="${inv.store.name}"/></div>
            <div>
              <span class="inv-qty" ${inv.quantity < inv.minThreshold ? 'style="color:var(--red);"' : ''}>${inv.quantity}</span>
              <span class="inv-unit">${inv.product.unit}</span>
            </div>
            <div class="inv-meta">
              <span>Tối thiểu: ${inv.minThreshold} ${inv.product.unit}</span>
              <span class="expiry ok">Cập nhật: <c:out value="${inv.updatedAt}" /></span>
            </div>
            <div style="display:flex;gap:6px;margin-top:4px;">
              <button class="btn btn-ghost btn-sm" style="flex:1;"
                onclick="openInvDetail(
                  ${inv.id},
                  '<c:out value="${inv.product.name}"/>',
                  '<c:out value="${inv.store.name}"/>',
                  ${inv.quantity},
                  ${inv.minThreshold},
                  '<c:out value="${inv.updatedAt}"/>'
                )">Chi tiết</button>
            </div>
          </article>
          </c:forEach>
        </c:otherwise>
      </c:choose>
    </div>
  </div><!-- /page-inventory -->

<script>
function filterInventory() {
  const search = (document.getElementById('inv-search').value||'').toLowerCase();
  const level  = document.getElementById('inv-level-filter').value;
  document.querySelectorAll('#inv-grid-container .inv-card').forEach(card => {
    const ms  = !search || card.dataset.invName.toLowerCase().includes(search);
    const ml  = !level  || card.dataset.invLevel === level;
    card.style.display = (ms && ml) ? '' : 'none';
  });
}
</script>
