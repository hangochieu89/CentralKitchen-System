<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="true" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Central Kitchen Staff</title>
  <link rel="stylesheet" href="/css/kitchen-staff-styles.css">
  <style>
    .status{padding:2px 8px;border-radius:999px;font-size:11px}
    .s-confirmed{background:#cffafe;color:#155e75}.s-progress{background:#ddd6fe;color:#5b21b6}
    .s-ready{background:#dcfce7;color:#166534}.s-delivering{background:#dbeafe;color:#1e40af}
  </style>
</head>
<body>
<header>
  <div class="brand">Central Kitchen Staff</div>
  <div class="user-chip"><span>Nhân viên bếp trung tâm</span></div>
</header>
<main>
  <div class="page-header">
    <h1>Tiếp nhận đơn - Sản xuất - Xuất giao</h1>
    <div class="actions">
      <a class="btn btn-secondary" href="/dashboard/index.jsp">Về Dashboard</a>
    </div>
  </div>

  <section class="panel">
    <header class="panel-head"><h2>Cấu hình phiên</h2></header>
    <div style="padding:16px;display:grid;grid-template-columns:1fr 1fr;gap:12px">
      <label>User ID (KITCHEN_STAFF) <input id="k-user-id" type="number" value="5"></label>
    </div>
  </section>

  <section class="panel">
    <header class="panel-head"><h2>Đơn đã xác nhận (CONFIRMED)</h2></header>
    <div class="table-wrap">
      <table id="tb-confirmed"><thead><tr><th>#</th><th>Cửa hàng</th><th>Ngày giao dự kiến</th><th>Trạng thái</th><th>Thao tác</th></tr></thead><tbody></tbody></table>
    </div>
  </section>

  <section class="panel">
    <header class="panel-head"><h2>Đơn đang sản xuất / sẵn sàng</h2></header>
    <div class="table-wrap">
      <table id="tb-progress"><thead><tr><th>#</th><th>Cửa hàng</th><th>Trạng thái</th><th>Thao tác</th></tr></thead><tbody></tbody></table>
    </div>
  </section>
</main>

<script>
  const API = '/api/kitchen-staff';
  function userId(){ return parseInt(document.getElementById('k-user-id').value, 10); }
  function headers(extra={}){
    const uid = userId();
    if (!uid) throw new Error('Vui lòng nhập User ID hợp lệ');
    return {'X-User-Id': String(uid), 'X-User-Role': 'KITCHEN_STAFF', ...extra};
  }
  function sc(s){ return s === 'CONFIRMED' ? 's-confirmed' : s === 'IN_PRODUCTION' ? 's-progress' : s === 'READY' ? 's-ready' : 's-delivering'; }
  async function json(url, options={}) {
    const res = await fetch(url, options);
    const body = await res.json().catch(() => ({}));
    if (!res.ok) throw new Error(body.message || body.error || ('HTTP ' + res.status));
    if (body && typeof body === 'object' && !Array.isArray(body) && body.success === false) {
      throw new Error(body.message || body.error || 'Yêu cầu thất bại');
    }
    return body;
  }
  async function loadConfirmed() {
    const data = await json(`${API}/orders/confirmed`, {headers: headers()});
    const html = data.map(o => `<tr><td>#${o.id}</td><td>${o.storeName || '-'}</td><td>${o.deliveryDate || '-'}</td><td><span class="status ${sc(o.status)}">${o.status}</span></td><td><button class="btn btn-sm btn-primary" onclick="startProduction(${o.id})">Bắt đầu SX</button></td></tr>`).join('');
    document.querySelector('#tb-confirmed tbody').innerHTML = html || '<tr><td colspan="5">Không có đơn</td></tr>';
  }
  async function loadProgress() {
    const inProd = await json(`${API}/orders/in-production`, {headers: headers()});
    const ready = await json(`${API}/orders/ready`, {headers: headers()});
    const list = [...inProd, ...ready];
    const html = list.map(o => `<tr><td>#${o.id}</td><td>${o.storeName || '-'}</td><td><span class="status ${sc(o.status)}">${o.status}</span></td><td>${action(o)}</td></tr>`).join('');
    document.querySelector('#tb-progress tbody').innerHTML = html || '<tr><td colspan="4">Không có đơn</td></tr>';
  }
  function action(o){
    if (o.status === 'IN_PRODUCTION') return `<button class="btn btn-sm btn-primary" onclick="markReady(${o.id})">Hoàn tất SX (READY)</button>`;
    if (o.status === 'READY') return `<button class="btn btn-sm btn-primary" onclick="dispatch(${o.id})">Xuất giao (DELIVERING)</button>`;
    return '-';
  }
  async function startProduction(orderId){
    await json(`${API}/orders/production-status`, {
      method: 'PUT',
      headers: headers({'Content-Type': 'application/json'}),
      body: JSON.stringify({orderId, status: 'IN_PRODUCTION', note: 'Kitchen started'})
    });
    await Promise.all([loadConfirmed(), loadProgress()]);
  }
  async function markReady(orderId){
    await json(`${API}/orders/production-status`, {
      method: 'PUT',
      headers: headers({'Content-Type': 'application/json'}),
      body: JSON.stringify({orderId, status: 'READY', note: 'Kitchen completed'})
    });
    await Promise.all([loadConfirmed(), loadProgress()]);
  }
  async function dispatch(orderId){
    await json(`${API}/orders/dispatch`, {
      method: 'PUT',
      headers: headers({'Content-Type': 'application/json'}),
      body: JSON.stringify({orderId, note: 'Ready for transport'})
    });
    await Promise.all([loadConfirmed(), loadProgress()]);
  }
  document.getElementById('k-user-id').addEventListener('change', () => Promise.all([loadConfirmed(), loadProgress()]));
  window.onload = () => Promise.all([loadConfirmed(), loadProgress()]).catch(e => alert(e.message));
</script>
</body>
</html>
