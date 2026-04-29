<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!-- ── PAGE: DISPATCH ── -->
  <div id="page-dispatch" style="display:none;">
    <div class="page-header">
      <hgroup>
        <h1>Xuất kho &amp; Giao hàng</h1>
        <p>Cập nhật trạng thái xuất kho và theo dõi vận chuyển</p>
      </hgroup>
    </div>

    <section class="panel">
      <header class="panel-head">
        <h2>Danh sách xuất kho hôm nay</h2>
        <div class="panel-actions">
          <button class="btn btn-primary btn-sm">+ Tạo phiếu xuất</button>
        </div>
      </header>
      <div class="table-wrap">
        <table>
          <thead><tr><th>Phiếu xuất</th><th>Đơn hàng</th><th>Cửa hàng</th><th>Sản phẩm</th><th>Số lượng</th><th>Lô</th><th>Giờ giao</th><th>Trạng thái</th><th>Thao tác</th></tr></thead>
          <tbody>
            <c:forEach items="${orders}" var="order">
              <c:if test="${order.status == 'COMPLETED' || order.status == 'DELIVERING' || order.status == 'DELIVERED'}">
                <c:forEach items="${order.orderItems}" var="item">
                  <tr>
                    <td><span class="mono">#PX-${order.id}</span></td>
                    <td><span class="mono">#ORD-${order.id}</span></td>
                    <td>${order.store.name}</td>
                    <td>${item.product.name}</td>
                    <td><span class="mono">${item.quantity} ${item.product.unit}</span></td>
                    <td><span class="lot-tag">N/A</span></td>
                    <td><span class="mono"><c:out value="${order.deliveryDate}" /></span></td>
                    <td><span class="badge ${order.status == 'COMPLETED' ? 'badge-process' : 'badge-done'}">${order.status}</span></td>
                    <td>
                      <c:if test="${order.status == 'COMPLETED'}">
                        <button class="btn btn-primary btn-sm">Xác nhận xuất</button>
                      </c:if>
                      <button class="btn btn-ghost btn-sm">In phiếu</button>
                    </td>
                  </tr>
                </c:forEach>
              </c:if>
            </c:forEach>
          </tbody>
        </table>
      </div>
    </section>
  </div><!-- /page-dispatch -->