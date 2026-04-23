<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/kitchen-staff-styles.css">
  <title>Central Kitchen Staff</title>
  <link href="https://fonts.googleapis.com/css2?family=DM+Mono:wght@400;500&family=DM+Sans:ital,opsz,wght@0,9..40,300;0,9..40,500;0,9..40,700;1,9..40,300&display=swap" rel="stylesheet" />
</head>
<body>

<!-- ════════════════════════════════════════════════════════
     HEADER
════════════════════════════════════════════════════════ -->
<header>
  <div class="brand">
    <div class="logo-mark">🍳</div>
    Hệ thống Quản lý Bếp Trung Tâm và Cửa hàng
  </div>
  <nav class="top-nav" aria-label="Top navigation">
    <button>Thông báo <span style="background:#e05c2a;color:#fff;padding:1px 6px;border-radius:10px;font-size:.68rem;margin-left:2px">4</span></button>
    <button>Hỗ trợ</button>
  </nav>
  <div class="user-chip">
    <div class="avatar">NK</div>
    <span>Đình Phát  &mdash; <span style="color:#e05c2a">Bếp Trung Tâm</span></span>
  </div>
</header>

<!-- ════════════════════════════════════════════════════════
     SIDEBAR
════════════════════════════════════════════════════════ -->
<nav class="sidebar" aria-label="Sidebar navigation">
  <span class="nav-section-label">Tổng quan</span>
  <a href="#dashboard" class="active" onclick="showPage('dashboard',this)">
    <span class="icon">📊</span> Dashboard
  </a>

  <span class="nav-section-label">Đơn hàng</span>
  <a href="#orders" onclick="showPage('orders',this)">
    <span class="icon">📋</span> Tiếp nhận đơn
    <span class="badge">7</span>
  </a>
  <a href="#dispatch" onclick="showPage('dispatch',this)">
    <span class="icon">🚚</span> Xuất kho &amp; Giao hàng
  </a>

  <span class="nav-section-label">Sản xuất</span>
  <a href="#production" onclick="showPage('production',this)">
    <span class="icon">⚙️</span> Kế hoạch SX
  </a>
  <a href="#batches" onclick="showPage('batches',this)">
    <span class="icon">🏷️</span> Lô sản xuất
  </a>

  <span class="nav-section-label">Kho &amp; Nguyên liệu</span>
  <a href="#inventory" onclick="showPage('inventory',this)">
    <span class="icon">📦</span> Tồn kho
  </a>
  <a href="#inputs" onclick="showPage('inputs',this)">
    <span class="icon">🥩</span> Nguyên liệu đầu vào
  </a>
</nav>

<!-- ════════════════════════════════════════════════════════
     MAIN
════════════════════════════════════════════════════════ -->
<main>

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
            <tbody>
              <tr>
                <td><span class="mono">#ORD-2341</span></td>
                <td>CH Quận 1</td>
                <td>Phở bò (5kg), Cháo (3kg)</td>
                <td class="text-muted">08:15</td>
                <td><span class="badge badge-pending">Chờ xử lý</span></td>
                <td><button class="btn btn-primary btn-sm">Xử lý</button></td>
              </tr>
              <tr>
                <td><span class="mono">#ORD-2340</span></td>
                <td>CH Bình Thạnh</td>
                <td>Bún bò (8kg)</td>
                <td class="text-muted">07:50</td>
                <td><span class="badge badge-process">Đang SX</span></td>
                <td><button class="btn btn-ghost btn-sm">Chi tiết</button></td>
              </tr>
              <tr>
                <td><span class="mono">#ORD-2339</span></td>
                <td>CH Tân Bình</td>
                <td>Cơm tấm (10 suất), Chả</td>
                <td class="text-muted">07:20</td>
                <td><span class="badge badge-done">Hoàn thành</span></td>
                <td><button class="btn btn-ghost btn-sm">Chi tiết</button></td>
              </tr>
              <tr>
                <td><span class="mono">#ORD-2338</span></td>
                <td>CH Gò Vấp</td>
                <td>Nước dùng (20L), Xương</td>
                <td class="text-muted">06:40</td>
                <td><span class="badge badge-process">Đang SX</span></td>
                <td><button class="btn btn-ghost btn-sm">Chi tiết</button></td>
              </tr>
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
            <div class="progress-wrap">
              <div class="prog-label"><span>Phở bò — Lô #L241</span><span>70%</span></div>
              <progress value="70" max="100"></progress>
              <span class="text-muted" style="font-size:.73rem;">ETA: 10:30</span>
            </div>
            <div class="progress-wrap">
              <div class="prog-label"><span>Bún bò — Lô #L242</span><span>40%</span></div>
              <progress class="amber" value="40" max="100"></progress>
              <span class="text-muted" style="font-size:.73rem;">ETA: 12:00</span>
            </div>
            <div class="progress-wrap">
              <div class="prog-label"><span>Nước dùng gà — Lô #L243</span><span>90%</span></div>
              <progress class="green" value="90" max="100"></progress>
              <span class="text-muted" style="font-size:.73rem;">ETA: 09:45</span>
            </div>
            <div class="progress-wrap">
              <div class="prog-label"><span>Chả lụa — Lô #L244</span><span>15%</span></div>
              <progress value="15" max="100"></progress>
              <span class="text-muted" style="font-size:.73rem;">ETA: 15:00</span>
            </div>
          </div>
        </section>

        <!-- Cảnh báo -->
        <section class="panel">
          <header class="panel-head"><h2>⚠️ Cảnh báo tồn kho</h2></header>
          <div style="padding:12px 16px;display:flex;flex-direction:column;gap:8px;">
            <div class="item-row" style="padding:10px 12px;background:var(--red-lt);border-radius:var(--radius);font-size:.83rem;display:flex;justify-content:space-between;align-items:center;">
              <span>🥩 Thịt bò tươi</span>
              <span style="color:var(--red);font-family:var(--font-mono);font-weight:700;">2.5 kg còn lại</span>
            </div>
            <div class="item-row" style="padding:10px 12px;background:var(--amber-lt);border-radius:var(--radius);font-size:.83rem;display:flex;justify-content:space-between;align-items:center;">
              <span>🌿 Sả tươi</span>
              <span style="color:var(--amber);font-family:var(--font-mono);font-weight:700;">0.8 kg còn lại</span>
            </div>
            <div class="item-row" style="padding:10px 12px;background:var(--amber-lt);border-radius:var(--radius);font-size:.83rem;display:flex;justify-content:space-between;align-items:center;">
              <span>🦴 Xương heo</span>
              <span style="color:var(--amber);font-family:var(--font-mono);font-weight:700;">5 kg còn lại</span>
            </div>
          </div>
        </section>
      </div>
    </div>
  </div><!-- /page-dashboard -->

  <!-- ── PAGE: ORDERS ── -->
  <div id="page-orders" style="display:none;">
    <div class="page-header">
      <hgroup>
        <h1>Tiếp nhận đơn hàng</h1>
        <p>Quản lý đơn đặt hàng từ các cửa hàng franchise</p>
      </hgroup>
    </div>

    <div class="two-col">
      <!-- Danh sách đơn -->
      <section class="panel">
        <header class="panel-head">
          <h2>Danh sách đơn hàng</h2>
          <div class="panel-actions">
            <select style="font-size:.8rem;padding:5px 8px;border:1px solid var(--gray-200);border-radius:var(--radius);">
              <option>Tất cả trạng thái</option>
              <option>Chờ xử lý</option>
              <option>Đang SX</option>
              <option>Hoàn thành</option>
            </select>
          </div>
        </header>
        <div class="filter-bar">
          <input type="search" placeholder="Tìm mã đơn, cửa hàng…" />
          <select><option>Hôm nay</option><option>7 ngày</option><option>Tháng này</option></select>
          <select><option>Tất cả cửa hàng</option><option>CH Quận 1</option><option>CH Bình Thạnh</option><option>CH Tân Bình</option><option>CH Gò Vấp</option></select>
        </div>
        <div class="table-wrap">
          <table>
            <thead><tr><th>Mã đơn</th><th>Cửa hàng</th><th>Sản phẩm</th><th>Ngày đặt</th><th>Ưu tiên</th><th>Trạng thái</th><th>Thao tác</th></tr></thead>
            <tbody>
              <tr>
                <td><span class="mono">#ORD-2341</span></td>
                <td><strong>CH Quận 1</strong></td>
                <td>Phở bò 5kg, Cháo 3kg</td>
                <td><span class="mono">18/03 08:15</span></td>
                <td><span class="badge badge-alert">Cao</span></td>
                <td><span class="badge badge-pending">Chờ xử lý</span></td>
                <td>
                  <button class="btn btn-primary btn-sm" onclick="document.getElementById('dlg-order').showModal()">Xử lý</button>
                </td>
              </tr>
              <tr>
                <td><span class="mono">#ORD-2340</span></td>
                <td><strong>CH Bình Thạnh</strong></td>
                <td>Bún bò 8kg</td>
                <td><span class="mono">18/03 07:50</span></td>
                <td><span class="badge badge-default">Thường</span></td>
                <td><span class="badge badge-process">Đang SX</span></td>
                <td><button class="btn btn-secondary btn-sm">Chi tiết</button></td>
              </tr>
              <tr>
                <td><span class="mono">#ORD-2339</span></td>
                <td><strong>CH Tân Bình</strong></td>
                <td>Cơm tấm 10 suất, Chả lụa 2kg</td>
                <td><span class="mono">18/03 07:20</span></td>
                <td><span class="badge badge-default">Thường</span></td>
                <td><span class="badge badge-done">Hoàn thành</span></td>
                <td><button class="btn btn-ghost btn-sm">Chi tiết</button></td>
              </tr>
              <tr>
                <td><span class="mono">#ORD-2338</span></td>
                <td><strong>CH Gò Vấp</strong></td>
                <td>Nước dùng 20L, Xương heo 5kg</td>
                <td><span class="mono">18/03 06:40</span></td>
                <td><span class="badge badge-process">Trung bình</span></td>
                <td><span class="badge badge-process">Đang SX</span></td>
                <td><button class="btn btn-ghost btn-sm">Chi tiết</button></td>
              </tr>
              <tr>
                <td><span class="mono">#ORD-2337</span></td>
                <td><strong>CH Quận 7</strong></td>
                <td>Bánh mì thịt (50 phần)</td>
                <td><span class="mono">18/03 06:00</span></td>
                <td><span class="badge badge-alert">Cao</span></td>
                <td><span class="badge badge-pending">Chờ xử lý</span></td>
                <td><button class="btn btn-primary btn-sm">Xử lý</button></td>
              </tr>
            </tbody>
          </table>
        </div>
      </section>

      <!-- Chi tiết đơn -->
      <section class="panel">
        <header class="panel-head"><h2>Chi tiết đơn #ORD-2341</h2></header>
        <div class="order-detail">
          <div class="field">
            <label>Cửa hàng</label>
            <p class="fw7">Chi nhánh Quận 1 — 123 Lê Lợi, Q.1</p>
          </div>
          <div class="field">
            <label>Thời gian đặt</label>
            <p class="mono">18/03/2026 08:15</p>
          </div>
          <div class="field">
            <label>Mong muốn nhận</label>
            <p class="mono">18/03/2026 13:00</p>
          </div>
          <hr class="divider" />
          <div class="field">
            <label>Danh sách sản phẩm</label>
          </div>
          <div class="item-list">
            <div class="item-row">
              <div>
                <div class="item-name">Phở bò sơ chế</div>
                <div class="secondary">SKU: PB-001</div>
              </div>
              <div class="item-qty">5.0 kg</div>
            </div>
            <div class="item-row">
              <div>
                <div class="item-name">Cháo trắng</div>
                <div class="secondary">SKU: CT-002</div>
              </div>
              <div class="item-qty">3.0 kg</div>
            </div>
            <div class="item-row">
              <div>
                <div class="item-name">Nước dùng phở</div>
                <div class="secondary">SKU: ND-010</div>
              </div>
              <div class="item-qty">10.0 L</div>
            </div>
          </div>
          <hr class="divider" />
          <div class="field">
            <label>Ghi chú từ cửa hàng</label>
            <p>Nước dùng đặc hơn bình thường. Phở bò cần làm sạch kỹ.</p>
          </div>
          <div style="display:flex;gap:8px;flex-wrap:wrap;">
            <button class="btn btn-primary" onclick="document.getElementById('dlg-order').showModal()">✓ Xác nhận xử lý</button>
            <button class="btn btn-secondary">✎ Cập nhật trạng thái</button>
            <button class="btn btn-ghost" style="color:var(--red);">✕ Từ chối</button>
          </div>
        </div>
      </section>
    </div>
  </div><!-- /page-orders -->

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
            <tr>
              <td>
                <strong>Phở bò sơ chế</strong>
                <div class="secondary">SKU: PB-001</div>
              </td>
              <td><span class="mono">25.0 kg</span></td>
              <td>Ca sáng</td>
              <td>Trần Văn A, Lê Thị B</td>
              <td>Thịt bò 15kg, Gia vị 2kg…</td>
              <td><span class="lot-tag">#L241</span></td>
              <td><span class="badge badge-process">Đang SX — 70%</span></td>
              <td>
                <button class="btn btn-secondary btn-sm">Cập nhật</button>
              </td>
            </tr>
            <tr>
              <td>
                <strong>Bún bò Huế</strong>
                <div class="secondary">SKU: BB-003</div>
              </td>
              <td><span class="mono">18.0 kg</span></td>
              <td>Ca sáng</td>
              <td>Nguyễn Văn C</td>
              <td>Thịt heo 10kg, Mắm ruốc…</td>
              <td><span class="lot-tag">#L242</span></td>
              <td><span class="badge badge-process">Đang SX — 40%</span></td>
              <td><button class="btn btn-secondary btn-sm">Cập nhật</button></td>
            </tr>
            <tr>
              <td>
                <strong>Nước dùng gà</strong>
                <div class="secondary">SKU: ND-012</div>
              </td>
              <td><span class="mono">50.0 L</span></td>
              <td>Ca sáng</td>
              <td>Phạm Thị D, Hoàng E</td>
              <td>Gà nguyên con 20kg…</td>
              <td><span class="lot-tag">#L243</span></td>
              <td><span class="badge badge-done">Hoàn thành — 90%</span></td>
              <td><button class="btn btn-primary btn-sm">Hoàn tất</button></td>
            </tr>
            <tr>
              <td>
                <strong>Chả lụa</strong>
                <div class="secondary">SKU: CL-007</div>
              </td>
              <td><span class="mono">8.0 kg</span></td>
              <td>Ca chiều</td>
              <td>Lê Văn F</td>
              <td>Thịt heo xay 7kg…</td>
              <td><span class="lot-tag">#L244</span></td>
              <td><span class="badge badge-pending">Chưa bắt đầu</span></td>
              <td><button class="btn btn-secondary btn-sm">Bắt đầu</button></td>
            </tr>
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
            <tr>
              <td><span class="lot-tag">#L241</span></td>
              <td><strong>Phở bò sơ chế</strong></td>
              <td><span class="mono">18/03</span></td>
              <td><span class="expiry warn">20/03 (+2 ngày)</span></td>
              <td><span class="mono">25 kg</span></td>
              <td>Thịt bò Nam Phong, Mã NL-B012</td>
              <td>CH Quận 1, CH Q.7</td>
              <td><span class="badge badge-process">Đang SX</span></td>
            </tr>
            <tr>
              <td><span class="lot-tag">#L238</span></td>
              <td><strong>Nước dùng bò</strong></td>
              <td><span class="mono">17/03</span></td>
              <td><span class="expiry ok">22/03 (+4 ngày)</span></td>
              <td><span class="mono">40 L</span></td>
              <td>Xương bò, Hành, Gừng</td>
              <td>CH Bình Thạnh</td>
              <td><span class="badge badge-done">Xuất kho</span></td>
            </tr>
            <tr>
              <td><span class="lot-tag">#L235</span></td>
              <td><strong>Chả lụa</strong></td>
              <td><span class="mono">16/03</span></td>
              <td><span class="expiry crit">18/03 (Hôm nay!)</span></td>
              <td><span class="mono">4 kg</span></td>
              <td>Thịt heo Vissan, Mã NL-H008</td>
              <td>—</td>
              <td><span class="badge badge-alert">Sắp hết hạn</span></td>
            </tr>
            <tr>
              <td><span class="lot-tag">#L229</span></td>
              <td><strong>Cháo trắng</strong></td>
              <td><span class="mono">15/03</span></td>
              <td><span class="expiry ok">21/03 (+3 ngày)</span></td>
              <td><span class="mono">15 kg</span></td>
              <td>Gạo tám thơm</td>
              <td>CH Tân Bình, CH Gò Vấp</td>
              <td><span class="badge badge-done">Đã xuất</span></td>
            </tr>
          </tbody>
        </table>
      </div>
    </section>
  </div><!-- /page-batches -->

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
      <article class="inv-card ok">
        <div class="flex-between">
          <div class="inv-name">Nước dùng bò</div>
          <span class="badge badge-done" style="font-size:.68rem;">OK</span>
        </div>
        <div class="inv-sku">SKU: ND-010</div>
        <div><span class="inv-qty">120</span> <span class="inv-unit">Lít</span></div>
        <div class="inv-meta">
          <span>Tối thiểu: 30L</span>
          <span>Lô: <span class="lot-tag">#L238</span></span>
          <span class="expiry ok">HSD: 22/03</span>
        </div>
        <div style="display:flex;gap:6px;margin-top:4px;">
          <button class="btn btn-secondary btn-sm" style="flex:1;">Xuất kho</button>
          <button class="btn btn-ghost btn-sm">Chi tiết</button>
        </div>
      </article>

      <article class="inv-card low">
        <div class="flex-between">
          <div class="inv-name">Thịt bò tươi</div>
          <span class="badge badge-alert" style="font-size:.68rem;">Thấp</span>
        </div>
        <div class="inv-sku">SKU: NL-B012</div>
        <div><span class="inv-qty" style="color:var(--red);">2.5</span> <span class="inv-unit">kg</span></div>
        <div class="inv-meta">
          <span>Tối thiểu: 10kg</span>
          <span>Lô: <span class="lot-tag">#L241</span></span>
          <span class="expiry warn">HSD: 19/03</span>
        </div>
        <div style="display:flex;gap:6px;margin-top:4px;">
          <button class="btn btn-primary btn-sm" style="flex:1;">Yêu cầu bổ sung</button>
          <button class="btn btn-ghost btn-sm">Chi tiết</button>
        </div>
      </article>

      <article class="inv-card ok">
        <div class="flex-between">
          <div class="inv-name">Cháo trắng</div>
          <span class="badge badge-done" style="font-size:.68rem;">OK</span>
        </div>
        <div class="inv-sku">SKU: CT-002</div>
        <div><span class="inv-qty">45</span> <span class="inv-unit">kg</span></div>
        <div class="inv-meta">
          <span>Tối thiểu: 10kg</span>
          <span>Lô: <span class="lot-tag">#L229</span></span>
          <span class="expiry ok">HSD: 21/03</span>
        </div>
        <div style="display:flex;gap:6px;margin-top:4px;">
          <button class="btn btn-secondary btn-sm" style="flex:1;">Xuất kho</button>
          <button class="btn btn-ghost btn-sm">Chi tiết</button>
        </div>
      </article>

      <article class="inv-card warn">
        <div class="flex-between">
          <div class="inv-name">Chả lụa</div>
          <span class="badge badge-alert" style="font-size:.68rem;">Sắp hết hạn</span>
        </div>
        <div class="inv-sku">SKU: CL-007</div>
        <div><span class="inv-qty" style="color:var(--amber);">4</span> <span class="inv-unit">kg</span></div>
        <div class="inv-meta">
          <span>Tối thiểu: 2kg</span>
          <span>Lô: <span class="lot-tag">#L235</span></span>
          <span class="expiry crit">HSD: 18/03 — Hôm nay!</span>
        </div>
        <div style="display:flex;gap:6px;margin-top:4px;">
          <button class="btn btn-primary btn-sm" style="flex:1;background:var(--amber);border-color:var(--amber);">Xuất ngay</button>
          <button class="btn btn-ghost btn-sm">Chi tiết</button>
        </div>
      </article>

      <article class="inv-card ok">
        <div class="flex-between">
          <div class="inv-name">Nước dùng gà</div>
          <span class="badge badge-done" style="font-size:.68rem;">OK</span>
        </div>
        <div class="inv-sku">SKU: ND-012</div>
        <div><span class="inv-qty">85</span> <span class="inv-unit">Lít</span></div>
        <div class="inv-meta">
          <span>Tối thiểu: 20L</span>
          <span>Lô: <span class="lot-tag">#L243</span></span>
          <span class="expiry ok">HSD: 20/03</span>
        </div>
        <div style="display:flex;gap:6px;margin-top:4px;">
          <button class="btn btn-secondary btn-sm" style="flex:1;">Xuất kho</button>
          <button class="btn btn-ghost btn-sm">Chi tiết</button>
        </div>
      </article>

      <article class="inv-card low">
        <div class="flex-between">
          <div class="inv-name">Sả tươi</div>
          <span class="badge badge-alert" style="font-size:.68rem;">Thấp</span>
        </div>
        <div class="inv-sku">SKU: NL-S005</div>
        <div><span class="inv-qty" style="color:var(--red);">0.8</span> <span class="inv-unit">kg</span></div>
        <div class="inv-meta">
          <span>Tối thiểu: 3kg</span>
          <span>Lô: —</span>
          <span class="expiry warn">HSD: 19/03</span>
        </div>
        <div style="display:flex;gap:6px;margin-top:4px;">
          <button class="btn btn-primary btn-sm" style="flex:1;">Yêu cầu bổ sung</button>
          <button class="btn btn-ghost btn-sm">Chi tiết</button>
        </div>
      </article>
    </div>
  </div><!-- /page-inventory -->

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
              <tr>
                <td><span class="mono">NL-B012</span></td>
                <td><strong>Thịt bò tươi</strong></td>
                <td>Nam Phong Foods</td>
                <td><span class="mono">17/03</span></td>
                <td><span class="expiry warn">19/03</span></td>
                <td><span class="mono">2.5 kg</span></td>
                <td><span class="badge badge-alert">Thấp</span></td>
              </tr>
              <tr>
                <td><span class="mono">NL-H008</span></td>
                <td><strong>Thịt heo xay</strong></td>
                <td>Vissan</td>
                <td><span class="mono">18/03</span></td>
                <td><span class="expiry ok">21/03</span></td>
                <td><span class="mono">12 kg</span></td>
                <td><span class="badge badge-done">OK</span></td>
              </tr>
              <tr>
                <td><span class="mono">NL-G003</span></td>
                <td><strong>Gạo tám thơm</strong></td>
                <td>Nàng Hương ST</td>
                <td><span class="mono">15/03</span></td>
                <td><span class="expiry ok">15/06</span></td>
                <td><span class="mono">50 kg</span></td>
                <td><span class="badge badge-done">OK</span></td>
              </tr>
              <tr>
                <td><span class="mono">NL-S005</span></td>
                <td><strong>Sả tươi</strong></td>
                <td>Vườn Xanh</td>
                <td><span class="mono">16/03</span></td>
                <td><span class="expiry warn">19/03</span></td>
                <td><span class="mono">0.8 kg</span></td>
                <td><span class="badge badge-alert">Thấp</span></td>
              </tr>
              <tr>
                <td><span class="mono">NL-X009</span></td>
                <td><strong>Xương heo</strong></td>
                <td>Chợ đầu mối</td>
                <td><span class="mono">18/03</span></td>
                <td><span class="expiry ok">20/03</span></td>
                <td><span class="mono">5 kg</span></td>
                <td><span class="badge badge-pending">Trung bình</span></td>
              </tr>
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
            <tr>
              <td><span class="mono">#PX-0201</span></td>
              <td><span class="mono">#ORD-2339</span></td>
              <td>CH Tân Bình</td>
              <td>Cơm tấm 10 suất, Chả 2kg</td>
              <td><span class="mono">12 đơn vị</span></td>
              <td><span class="lot-tag">#L229</span></td>
              <td><span class="mono">13:00</span></td>
              <td><span class="badge badge-done">Đã xuất</span></td>
              <td><button class="btn btn-ghost btn-sm">In phiếu</button></td>
            </tr>
            <tr>
              <td><span class="mono">#PX-0202</span></td>
              <td><span class="mono">#ORD-2340</span></td>
              <td>CH Bình Thạnh</td>
              <td>Bún bò 8kg</td>
              <td><span class="mono">8 kg</span></td>
              <td><span class="lot-tag">#L242</span></td>
              <td><span class="mono">14:00</span></td>
              <td><span class="badge badge-process">Đang chuẩn bị</span></td>
              <td>
                <button class="btn btn-primary btn-sm">Xác nhận xuất</button>
              </td>
            </tr>
            <tr>
              <td><span class="mono">#PX-0203</span></td>
              <td><span class="mono">#ORD-2341</span></td>
              <td>CH Quận 1</td>
              <td>Phở bò 5kg, Nước dùng 10L</td>
              <td><span class="mono">15 kg+L</span></td>
              <td><span class="lot-tag">#L241</span></td>
              <td><span class="mono">14:00</span></td>
              <td><span class="badge badge-pending">Chờ SX xong</span></td>
              <td><button class="btn btn-ghost btn-sm">Chi tiết</button></td>
            </tr>
          </tbody>
        </table>
      </div>
    </section>
  </div><!-- /page-dispatch -->

</main><!-- /main -->


<!-- ════════════════════════════════════════════════════════
     DIALOGS / MODALS
════════════════════════════════════════════════════════ -->

<!-- Modal: Xử lý đơn hàng -->
<dialog id="dlg-order">
  <header>
    <h3>Xử lý đơn hàng #ORD-2341</h3>
    <button class="btn btn-ghost btn-sm" onclick="document.getElementById('dlg-order').close()">✕</button>
  </header>
  <div class="dialog-body">
    <fieldset>
      <legend>Thông tin đơn</legend>
      <div class="form-grid">
        <div class="form-group">
          <label>Cửa hàng</label>
          <input type="text" value="CH Quận 1" readonly style="background:var(--gray-50);" />
        </div>
        <div class="form-group">
          <label>Thời gian cần nhận</label>
          <input type="text" value="18/03 13:00" readonly style="background:var(--gray-50);" />
        </div>
      </div>
    </fieldset>
    <fieldset>
      <legend>Phân công sản xuất</legend>
      <div class="form-grid">
        <div class="form-group">
          <label for="assign-staff">Nhân sự phụ trách</label>
          <select id="assign-staff">
            <option>Trần Văn A</option>
            <option>Lê Thị B</option>
            <option>Nguyễn Văn C</option>
          </select>
        </div>
        <div class="form-group">
          <label for="assign-eta">Thời gian dự kiến xong</label>
          <input id="assign-eta" type="datetime-local" value="2026-03-18T12:00" />
        </div>
        <div class="form-group full">
          <label for="assign-note">Ghi chú</label>
          <textarea id="assign-note" rows="2" placeholder="Lưu ý khi sản xuất…"></textarea>
        </div>
      </div>
    </fieldset>
  </div>
  <footer>
    <button class="btn btn-secondary" onclick="document.getElementById('dlg-order').close()">Hủy</button>
    <button class="btn btn-primary" onclick="document.getElementById('dlg-order').close()">✓ Xác nhận xử lý</button>
  </footer>
</dialog>

<!-- Modal: Tạo kế hoạch SX -->
<dialog id="dlg-plan">
  <header>
    <h3>Tạo kế hoạch sản xuất</h3>
    <button class="btn btn-ghost btn-sm" onclick="document.getElementById('dlg-plan').close()">✕</button>
  </header>
  <div class="dialog-body">
    <div class="form-grid">
      <div class="form-group">
        <label for="plan-prod">Sản phẩm</label>
        <select id="plan-prod">
          <option>Phở bò sơ chế</option>
          <option>Bún bò Huế</option>
          <option>Nước dùng gà</option>
          <option>Chả lụa</option>
          <option>Cháo trắng</option>
        </select>
      </div>
      <div class="form-group">
        <label for="plan-qty">Số lượng (kg / L)</label>
        <input id="plan-qty" type="number" placeholder="0.0" step="0.5" />
      </div>
      <div class="form-group">
        <label for="plan-shift">Ca sản xuất</label>
        <select id="plan-shift">
          <option>Ca sáng (06:00–14:00)</option>
          <option>Ca chiều (14:00–22:00)</option>
          <option>Ca đêm (22:00–06:00)</option>
        </select>
      </div>
      <div class="form-group">
        <label for="plan-date">Ngày sản xuất</label>
        <input id="plan-date" type="date" value="2026-03-18" />
      </div>
      <div class="form-group full">
        <label for="plan-remark">Ghi chú</label>
        <textarea id="plan-remark" rows="2" placeholder="Yêu cầu đặc biệt…"></textarea>
      </div>
    </div>
  </div>
  <footer>
    <button class="btn btn-secondary" onclick="document.getElementById('dlg-plan').close()">Hủy</button>
    <button class="btn btn-primary" onclick="document.getElementById('dlg-plan').close()">💾 Tạo kế hoạch</button>
  </footer>
</dialog>

<!-- Modal: Nhập nguyên liệu -->
<dialog id="dlg-input">
  <header>
    <h3>Nhập nguyên liệu đầu vào</h3>
    <button class="btn btn-ghost btn-sm" onclick="document.getElementById('dlg-input').close()">✕</button>
  </header>
  <div class="dialog-body">
    <div class="form-grid">
      <div class="form-group">
        <label for="inp-name">Tên nguyên liệu</label>
        <input id="inp-name" type="text" placeholder="VD: Thịt bò tươi" />
      </div>
      <div class="form-group">
        <label for="inp-supplier">Nhà cung cấp</label>
        <input id="inp-supplier" type="text" placeholder="VD: Nam Phong Foods" />
      </div>
      <div class="form-group">
        <label for="inp-qty">Số lượng</label>
        <input id="inp-qty" type="number" placeholder="0.0" step="0.1" />
      </div>
      <div class="form-group">
        <label for="inp-unit">Đơn vị</label>
        <select id="inp-unit">
          <option>kg</option><option>g</option><option>L</option><option>ml</option><option>cái</option><option>hộp</option>
        </select>
      </div>
      <div class="form-group">
        <label for="inp-mfg">Ngày sản xuất</label>
        <input id="inp-mfg" type="date" />
      </div>
      <div class="form-group">
        <label for="inp-exp">Hạn sử dụng</label>
        <input id="inp-exp" type="date" />
      </div>
      <div class="form-group full">
        <label for="inp-note">Ghi chú / Kiểm tra chất lượng</label>
        <textarea id="inp-note" rows="2" placeholder="KQ kiểm tra đầu vào, nhiệt độ khi nhận…"></textarea>
      </div>
    </div>
  </div>
  <footer>
    <button class="btn btn-secondary" onclick="document.getElementById('dlg-input').close()">Hủy</button>
    <button class="btn btn-primary" onclick="document.getElementById('dlg-input').close()">💾 Lưu nhập kho</button>
  </footer>
</dialog>

<!-- ════════════════════════════════════════════════════════
     JS – Page Navigation
════════════════════════════════════════════════════════ -->
<script>
  const pages = {
    dashboard:  'page-dashboard',
    orders:     'page-orders',
    production: 'page-production',
    batches:    'page-batches',
    inventory:  'page-inventory',
    inputs:     'page-inputs',
    dispatch:   'page-dispatch',
  };

  function showPage(id, el) {
    // Hide all pages
    Object.values(pages).forEach(p => {
      const el = document.getElementById(p);
      if (el) el.style.display = 'none';
    });
    // Show target
    const target = document.getElementById(pages[id]);
    if (target) target.style.display = 'flex', target.style.flexDirection = 'column', target.style.gap = '24px';

    // Update active nav
    document.querySelectorAll('nav.sidebar a').forEach(a => a.classList.remove('active'));
    if (el) el.classList.add('active');

    if (el) { el.preventDefault && el.preventDefault(); }
    return false;
  }

  // Init
  document.addEventListener('DOMContentLoaded', () => {
    showPage('dashboard', document.querySelector('nav.sidebar a.active'));
  });
</script>
</body>
</html>