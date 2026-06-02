<%@ Page Title="Productos" Language="C#" MasterPageFile="~/Site1.Master"
         AutoEventWireup="true" CodeBehind="Productos.aspx.cs" Inherits="Monolito4bm.Productos" %>

<asp:Content ID="headContent" ContentPlaceHolderID="head" runat="server">
<link rel="stylesheet"
      href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css"
      crossorigin="anonymous"/>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<style>
:root {
  --card-bg:  rgba(255,255,255,0.72);
  --radius:   18px;
  --accent:   #db2777;
  --accent2:  #9d174d;
  --danger:   #c0392b;
  --success:  #27ae60;
  --warn:     #e67e22;
}

/* ── Encabezado ─────────────────────────────────────────────── */
.page-header {
  display:flex; align-items:center; justify-content:space-between;
  margin-bottom:24px; flex-wrap:wrap; gap:12px;
}
.page-title {
  font-size:1.65rem; font-weight:700; color:var(--accent2);
  display:flex; align-items:center; gap:10px;
}

/* ── Cards ──────────────────────────────────────────────────── */
.card {
  background:var(--card-bg); backdrop-filter:blur(12px);
  border:1px solid rgba(180,150,220,0.4);
  border-radius:var(--radius); padding:22px 28px;
  box-shadow:0 4px 24px rgba(120,80,180,0.10);
  margin-bottom:24px;
}
.card-title {
  font-size:.98rem; font-weight:700; color:var(--accent2);
  margin-bottom:16px; display:flex; align-items:center; gap:8px;
}

/* ── Buscador ───────────────────────────────────────────────── */
.search-bar {
  display:flex; align-items:center; gap:10px;
  background:rgba(255,255,255,0.9); border:1.5px solid rgba(122,74,170,0.3);
  border-radius:40px; padding:9px 18px;
  box-shadow:0 2px 10px rgba(120,80,180,.07); margin-bottom:14px;
  transition:border-color .2s, box-shadow .2s;
}
.search-bar:focus-within {
  border-color:var(--accent); box-shadow:0 0 0 3px rgba(122,74,170,0.12);
}
.search-bar input {
  border:none; background:transparent; font-family:inherit;
  font-size:.95rem; color:var(--accent2); flex:1; outline:none;
}
.search-bar .si { color:var(--accent); font-size:1rem; }

/* ── Filtros ────────────────────────────────────────────────── */
.filtros-toggle {
  background:none; border:none; cursor:pointer; font-family:inherit;
  font-size:.83rem; font-weight:700; color:var(--accent);
  display:flex; align-items:center; gap:6px; padding:4px 0; margin-bottom:10px;
}
.filtros-panel {
  display:flex; gap:14px; flex-wrap:wrap; padding:16px;
  background:rgba(122,74,170,0.04); border-radius:14px;
  border:1px solid rgba(122,74,170,0.14); margin-bottom:14px;
}
.filtros-panel.closed { display:none; }
@keyframes fadeIn { from{opacity:0;transform:translateY(-4px)} to{opacity:1;transform:none} }

.fg { display:flex; flex-direction:column; gap:5px; min-width:150px; flex:1; }
.fg label { font-size:.76rem; font-weight:700; color:var(--accent2); letter-spacing:.3px; }

/* Precio / stock — grupo de rango */
.range-group {
  display:flex; align-items:center; gap:6px; flex:1; min-width:220px;
}
.range-group .fg { min-width:80px; }
.range-sep { font-size:.8rem; color:#aaa; margin-top:20px; }

.form-control {
  padding:9px 13px; border-radius:10px;
  border:1.5px solid rgba(122,74,170,0.28);
  background:rgba(255,255,255,0.88); font-family:inherit;
  font-size:.88rem; color:#2c1a4a; width:100%;
  transition:border-color .2s, box-shadow .2s;
}
.form-control:focus {
  outline:none; border-color:var(--accent);
  box-shadow:0 0 0 3px rgba(122,74,170,0.13);
}

/* ── Botones ────────────────────────────────────────────────── */
.btn {
  padding:9px 20px; border-radius:30px; border:none; cursor:pointer;
  font-family:inherit; font-size:.86rem; font-weight:700;
  display:inline-flex; align-items:center; gap:7px;
  transition:all .2s; white-space:nowrap; text-decoration:none;
}
.btn-primary   { background:var(--accent);  color:#fff; }
.btn-primary:hover   { background:var(--accent2); transform:translateY(-1px); box-shadow:0 4px 14px rgba(90,42,138,.28); }
.btn-secondary { background:rgba(122,74,170,0.11); color:var(--accent2); border:1.5px solid rgba(122,74,170,0.28); }
.btn-secondary:hover { background:rgba(122,74,170,0.2); }
.btn-success   { background:var(--success); color:#fff; }
.btn-success:hover   { background:#1e8449; transform:translateY(-1px); }
.btn-danger    { background:var(--danger);  color:#fff; }
.btn-danger:hover    { background:#a93226;  transform:translateY(-1px); }
.btn-warn      { background:var(--warn);    color:#fff; }
.btn-warn:hover      { background:#d35400; }
.btn-sm  { padding:5px 13px; font-size:.76rem; border-radius:20px; }

/* ── Action Buttons Custom Styling ── */
.action-btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 38px;
  height: 38px;
  border-radius: 50%;
  font-size: 1.2rem;
  cursor: pointer;
  transition: all 0.22s ease-in-out;
  background: #fff;
  border: 1.5px solid transparent;
  text-decoration: none !important;
}
.action-btn-warn {
  color: var(--warn, #e67e22);
  border-color: var(--warn, #e67e22);
}
.action-btn-warn:hover {
  background: var(--warn, #e67e22);
  color: #fff !important;
  box-shadow: 0 4px 10px rgba(230,126,34,0.3);
  transform: translateY(-2px);
}
.action-btn-danger {
  color: var(--danger, #c0392b);
  border-color: var(--danger, #c0392b);
}
.action-btn-danger:hover {
  background: var(--danger, #c0392b);
  color: #fff !important;
  box-shadow: 0 4px 10px rgba(192,57,43,0.3);
  transform: translateY(-2px);
}
.action-btn-success {
  color: var(--success, #27ae60);
  border-color: var(--success, #27ae60);
}
.action-btn-success:hover {
  background: var(--success, #27ae60);
  color: #fff !important;
  box-shadow: 0 4px 10px rgba(39,174,96,0.3);
  transform: translateY(-2px);
}
.action-btn-secondary {
  color: #7a4aaa;
  border-color: #7a4aaa;
}
.action-btn-secondary:hover {
  background: #7a4aaa;
  color: #fff !important;
  box-shadow: 0 4px 10px rgba(122,74,170,0.3);
  transform: translateY(-2px);
}
.action-btn-primary {
  color: var(--accent, #db2777);
  border-color: var(--accent, #db2777);
}
.action-btn-primary:hover {
  background: var(--accent, #db2777);
  color: #fff !important;
  box-shadow: 0 4px 10px rgba(219,39,119,0.3);
  transform: translateY(-2px);
}

/* ── Alertas ────────────────────────────────────────────────── */
.alert {
  padding:11px 16px; border-radius:12px; margin-bottom:14px;
  font-size:.86rem; font-weight:600; display:flex; align-items:center; gap:9px;
  animation:fadeIn .3s ease;
}
.alert-success { background:rgba(39,174,96,.14); color:#1e8449; border:1px solid rgba(39,174,96,.28); }
.alert-danger  { background:rgba(192,57,43,.11); color:#c0392b; border:1px solid rgba(192,57,43,.24); }

/* ── GridView ───────────────────────────────────────────────── */
.grid-wrapper { overflow-x:auto; border-radius:14px; }
.prod-grid { width:100%; border-collapse:collapse; font-size:.87rem; }
.preview-grid { width:100%; border-collapse:collapse; font-size:.85rem; }
.preview-grid thead tr { background:linear-gradient(90deg,#3f1c68,#7a4aaa); color:#fff; }
.preview-grid thead th, .preview-grid tbody td { padding:10px 12px; text-align:left; border-bottom:1px solid rgba(180,150,220,.18); }
.preview-grid tbody tr:nth-child(even) { background:rgba(248,244,255,.72); }
.massive-layout { display:grid; grid-template-columns:1.2fr .8fr; gap:18px; align-items:start; }
.upload-drop {
  border:1.5px dashed rgba(122,74,170,.35); border-radius:18px; padding:20px;
  background:linear-gradient(180deg, rgba(248,244,255,.92), rgba(255,255,255,.96));
}
.upload-drop small { display:block; color:#7b6a94; margin-top:8px; }
.preview-shell { max-height:200px; overflow-y:auto; overflow-x:auto; border:1px solid rgba(180,150,220,.18); border-radius:14px; background:rgba(255,255,255,.92); }
.preview-meta { display:flex; justify-content:space-between; gap:12px; flex-wrap:wrap; margin:12px 0 0; font-size:.8rem; color:#7b6a94; }
.empty-preview {
  padding:28px; text-align:center; color:#9f93b1; border:1px dashed rgba(180,150,220,.25);
  border-radius:14px; background:rgba(248,244,255,.82);
}
.prod-grid thead tr {
  background:linear-gradient(90deg,var(--accent),var(--accent2)); color:#fff;
}
.prod-grid thead th {
  padding:12px 14px; text-align:left;
  font-size:.78rem; font-weight:700; letter-spacing:.5px; white-space:nowrap;
}
.prod-grid thead th:first-child { border-radius:13px 0 0 0; }
.prod-grid thead th:last-child  { border-radius:0 13px 0 0; }
.prod-grid tbody tr { border-bottom:1px solid rgba(180,150,220,0.2); transition:background .15s; }
.prod-grid tbody tr:hover { background:rgba(122,74,170,0.05); }
.prod-grid tbody td { padding:10px 14px; vertical-align:middle; }

/* ── Carrusel ───────────────────────────────────────────────── */
.carousel-cell {
  position:relative; width:120px; height:85px;
  border-radius:10px; overflow:hidden;
  background:rgba(219,39,119,0.08);
}
.carousel-cell .slide { position:absolute; inset:0; opacity:0; transition:opacity .5s; }
.carousel-cell .slide.active { opacity:1; }
.carousel-cell img { width:100%; height:100%; object-fit:cover; border-radius:10px; }
.carousel-cell .prev, .carousel-cell .next {
  position:absolute; top:50%; transform:translateY(-50%);
  background:rgba(219,39,119,0.85); color:#fff; border:none; cursor:pointer;
  border-radius:50%; width:20px; height:20px; font-size:.7rem;
  display:flex; align-items:center; justify-content:center;
  transition:all .2s; z-index:2;
}
.carousel-cell .prev { left:4px; }
.carousel-cell .next { right:4px; }
.carousel-cell .prev:hover, .carousel-cell .next:hover { background:rgba(244,63,94,0.95); transform:translateY(-50%) scale(1.15); }
.carousel-cell .dots { position:absolute; bottom:6px; left:50%; transform:translateX(-50%); display:flex; gap:5px; }
.carousel-cell .dot { width:5px; height:5px; border-radius:50%; background:rgba(255,255,255,0.6); cursor:pointer; transition:background .2s; }
.carousel-cell .dot.on { background:#f43f5e; box-shadow:0 0 5px rgba(244,63,94,0.9); }
.no-foto {
  width:120px; height:85px; border-radius:10px;
  display:flex; align-items:center; justify-content:center;
  background:rgba(219,39,119,0.07); color:rgba(219,39,119,0.35); font-size:1.3rem;
}
.btn-excel-procesar {
  padding: 13px 26px !important;
  font-size: 0.92rem !important;
  height: 48px !important;
  display: inline-flex !important;
  align-items: center !important;
  justify-content: center !important;
  gap: 10px !important;
  border-radius: 30px !important;
}

/* ── Custom File Upload styling ── */
.custom-file-upload {
  border: 2px dashed rgba(124, 58, 237, 0.4);
  background: linear-gradient(135deg, rgba(253, 242, 248, 0.7) 0%, rgba(245, 243, 255, 0.7) 100%);
  border-radius: 16px;
  padding: 24px 20px;
  text-align: center;
  cursor: pointer;
  transition: all 0.25s ease;
  position: relative;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-height: 120px;
  margin-bottom: 8px;
}
.custom-file-upload:hover, .custom-file-upload.dragover {
  border-color: #db2777;
  background: linear-gradient(135deg, rgba(253, 242, 248, 0.9) 0%, rgba(245, 243, 255, 0.9) 100%);
  box-shadow: 0 8px 24px rgba(219, 39, 119, 0.12);
  transform: translateY(-2px);
}
.custom-file-upload .upload-content {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 6px;
  pointer-events: none;
}
.custom-file-upload .upload-icon {
  font-size: 2rem;
  background: linear-gradient(135deg, #db2777, #7c3aed);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  margin-bottom: 2px;
}
.custom-file-upload .upload-text {
  font-size: 0.88rem;
  color: #4c0519;
  font-weight: 700;
}
.custom-file-upload .upload-file-info {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 6px;
  pointer-events: none;
}
.custom-file-upload .file-icon {
  font-size: 2.2rem;
  color: #27ae60;
}
.custom-file-upload .file-name {
  font-size: 0.85rem;
  font-weight: 700;
  color: #1e293b;
  word-break: break-all;
  max-width: 280px;
}


/* ── Badge ──────────────────────────────────────────────────── */
.badge {
  display:inline-flex; align-items:center; gap:5px;
  padding:3px 11px; border-radius:20px;
  font-size:.72rem; font-weight:700; letter-spacing:.3px;
}
.badge-activo   { background:rgba(39,174,96,.14);  color:#1e8449; }
.badge-inactivo { background:rgba(192,57,43,.11);   color:#c0392b; }

/* ── Paginador pill (estilo unificado) ─────────────────────── */
.pager-wrap { display:flex; align-items:center; justify-content:center; flex-wrap:wrap; gap:12px; margin-top:20px; }
.pager-info { display:none; }
.pager-pill { display:inline-flex; align-items:center; background:rgba(255,255,255,0.72); backdrop-filter:blur(10px); border:1.5px solid rgba(219,39,119,0.22); border-radius:40px; box-shadow:0 2px 12px rgba(190,24,93,0.09); overflow:hidden; }
.pager-btn-pill { display:inline-flex; align-items:center; gap:6px; padding:9px 22px; background:transparent; border:none; color:var(--accent); font-weight:700; font-size:.85rem; cursor:pointer; font-family:inherit; transition:background .18s,color .18s; white-space:nowrap; text-decoration:none; }
.pager-btn-pill:hover:not(.aspNetDisabled) { background:rgba(219,39,119,0.09); }
.pager-btn-pill.aspNetDisabled { opacity:.38; cursor:default; pointer-events:none; }
.pager-info-pill { padding:9px 20px; font-size:.85rem; font-weight:700; color:var(--accent2); border-left:1.5px solid rgba(219,39,119,0.18); border-right:1.5px solid rgba(219,39,119,0.18); white-space:nowrap; }

/* ── Modal ──────────────────────────────────────────────────── */
.modal-overlay {
  display:none; position:fixed; inset:0;
  background:rgba(40,20,70,0.52); backdrop-filter:blur(6px);
  z-index:999; align-items:center; justify-content:center;
}
.modal-overlay.open { display:flex; }
.modal-box {
  background:rgba(246,242,255,0.97); border-radius:22px;
  padding:32px 34px; max-width:490px; width:93%;
  box-shadow:0 20px 60px rgba(90,42,138,0.28);
  animation:popIn .3s cubic-bezier(.34,1.56,.64,1);
  max-height:90vh; overflow-y:auto;
}
@keyframes popIn {
  from { opacity:0; transform:scale(.88) translateY(18px); }
  to   { opacity:1; transform:none; }
}
.modal-title   { font-size:1.08rem; font-weight:700; color:var(--accent2); margin-bottom:18px; }
.modal-row     { display:flex; gap:12px; flex-wrap:wrap; margin-bottom:14px; }
.modal-actions { display:flex; gap:10px; justify-content:flex-end; margin-top:6px; }

.dashboard-grid {
  display:grid;
  grid-template-columns:repeat(auto-fit, minmax(280px, 1fr));
  gap:18px;
}
.dashboard-card {
  background:linear-gradient(180deg, rgba(248,244,255,0.96) 0%, rgba(255,255,255,0.95) 100%);
  border:1px solid rgba(180,150,220,0.26);
  border-radius:18px;
  padding:20px;
  box-shadow:inset 0 1px 0 rgba(255,255,255,0.7);
  min-height:340px;
  display:flex;
  flex-direction:column;
}
.dashboard-card.wide { grid-column:span 2; }
.dashboard-header { display:flex; align-items:flex-start; justify-content:space-between; gap:12px; margin-bottom:16px; }
.dashboard-title { font-size:1rem; font-weight:700; color:#3b245f; margin:0; }
.dashboard-subtitle { font-size:.8rem; color:#7b6a94; margin-top:4px; }
.dashboard-badge {
  display:inline-flex;
  align-items:center;
  gap:6px;
  padding:6px 10px;
  border-radius:999px;
  background:rgba(122,74,170,0.10);
  color:var(--accent2);
  font-size:.74rem;
  font-weight:700;
}
.chart-shell { position:relative; flex:1; min-height:240px; }
.chart-shell canvas { width:100% !important; height:100% !important; }
.chart-empty {
  display:none;
  height:100%;
  align-items:center;
  justify-content:center;
  text-align:center;
  color:#7b6a94;
  border:1px dashed rgba(122,74,170,0.25);
  border-radius:14px;
  padding:18px;
  background:rgba(255,255,255,0.72);
}
.chart-empty.visible { display:flex; }
.summary-layout {
  display:grid;
  grid-template-columns:minmax(180px, 220px) 1fr;
  gap:18px;
  align-items:center;
  flex:1;
}
.gauge-wrap { display:flex; align-items:center; justify-content:center; }
.gauge-ring {
  width:180px;
  height:180px;
  border-radius:50%;
  background:conic-gradient(var(--accent) 0deg, rgba(224,210,240,0.95) 0deg);
  display:flex;
  align-items:center;
  justify-content:center;
  box-shadow:0 16px 26px rgba(122,74,170,0.12);
}
.gauge-ring::before {
  content:"";
  width:132px;
  height:132px;
  border-radius:50%;
  background:linear-gradient(180deg, #ffffff 0%, #f7f2ff 100%);
  box-shadow:inset 0 0 0 1px rgba(148,120,180,0.16);
}
.gauge-center { position:absolute; text-align:center; }
.gauge-value { display:block; font-size:2rem; font-weight:800; color:#3b245f; line-height:1; }
.gauge-label { display:block; margin-top:6px; font-size:.82rem; color:#7b6a94; }
.summary-metrics {
  display:grid;
  grid-template-columns:repeat(2, minmax(120px, 1fr));
  gap:12px;
}
.summary-item {
  background:rgba(255,255,255,0.88);
  border:1px solid rgba(180,150,220,0.18);
  border-radius:14px;
  padding:14px;
}
.summary-item .label { display:block; font-size:.78rem; color:#7b6a94; margin-bottom:6px; }
.summary-item .value { display:block; font-size:1.38rem; font-weight:800; color:#3b245f; }
.summary-footnote {
  margin-top:14px;
  padding-top:14px;
  border-top:1px solid rgba(180,150,220,0.16);
  font-size:.8rem;
  color:#7b6a94;
}

@media(max-width:600px){
  .card { padding:14px 12px; }
  .modal-box { padding:20px 16px; }
  .modal-row { flex-direction:column; }
  .range-group { flex-direction:column; }
  .summary-metrics { grid-template-columns:1fr; }
}

@media(max-width:900px){
  .dashboard-card.wide { grid-column:span 1; }
  .summary-layout { grid-template-columns:1fr; }
  .massive-layout { grid-template-columns:1fr; }
}
</style>
</asp:Content>

<asp:Content ID="bodyContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

  <!-- ══ Encabezado ════════════════════════════════════════════ -->
  <div class="page-header">
    <div class="page-title">
      <i class="fa-solid fa-box" style="color:var(--accent)"></i> Productos
    </div>
    <asp:LinkButton ID="btnNuevo" runat="server" CssClass="btn btn-primary"
                    OnClick="btnNuevo_Click" CausesValidation="false">
      <i class="fa-solid fa-plus"></i> Nuevo Producto
    </asp:LinkButton>
  </div>

  <!-- ══ Mensajes ══════════════════════════════════════════════ -->

  <div class="card">
    <div class="card-title">
      <i class="fa-solid fa-file-arrow-up"></i> Carga Excel
    </div>

    <div class="massive-layout">
      <div>
        <div class="custom-file-upload" id="uploadZoneExcel">
            <div class="upload-content">
                <i class="fa-solid fa-cloud-arrow-up upload-icon"></i>
                <span class="upload-text">Arrastra tu archivo aquí o</span>
                <button type="button" class="btn btn-secondary btn-sm" style="margin-top: 4px; pointer-events: none;">
                    <i class="fa-solid fa-plus"></i> Seleccionar archivo
                </button>
                <small style="color:#7b6a94;font-size:0.75rem;margin-top:4px;">Formatos permitidos: .csv, .xlsx y .xls. Encabezados sugeridos: nombre, cantidad, precio, prov_id, foto_ruta, estado.</small>
            </div>
            <div class="upload-file-info" style="display:none;">
                <i class="fa-solid fa-file-excel file-icon"></i>
                <span class="file-name"></span>
            </div>
            <asp:FileUpload ID="fuCargaMasiva" runat="server" Style="display:none;" onchange="handleFileSelect(this);" />
        </div>

          <div style="display:flex;gap:10px;flex-wrap:wrap;margin-top:16px;">
            <asp:LinkButton ID="btnDescargarFormato" runat="server" CssClass="btn btn-secondary"
                            CausesValidation="false" OnClick="btnDescargarFormato_Click">
              <i class="fa-solid fa-download"></i> Descargar Formato
            </asp:LinkButton>
            <asp:LinkButton ID="btnPrevisualizarCarga" runat="server" CssClass="btn btn-primary"
                            CausesValidation="false" OnClick="btnPrevisualizarCarga_Click">
              <i class="fa-solid fa-eye"></i> Visualizar archivo
            </asp:LinkButton>
            <asp:LinkButton ID="btnLimpiarCarga" runat="server" CssClass="btn btn-secondary"
                            CausesValidation="false" OnClick="btnLimpiarCarga_Click">
              <i class="fa-solid fa-broom"></i> Limpiar carga
            </asp:LinkButton>
          </div>

        <div class="preview-meta">
          <span><asp:Literal ID="litArchivoCarga" runat="server" Text="Sin archivo cargado." /></span>
          <span><asp:Literal ID="litResumenCarga" runat="server" Text="Aun no hay vista previa." /></span>
        </div>
      </div>

      <div>
        <div class="fg">
          <label>Tipo de insercion</label>
          <asp:DropDownList ID="ddlTipoInsercionMasiva" runat="server" CssClass="form-control">
            <asp:ListItem Value="1" Text="Anadir sin borrar"/>
            <asp:ListItem Value="2" Text="Borrar todo y volver a cargar"/>
          </asp:DropDownList>
        </div>
        <div style="display:flex;gap:10px;flex-wrap:wrap;margin-top:16px;">
          <asp:LinkButton ID="btnProcesarCargaMasiva" runat="server" CssClass="btn btn-success btn-excel-procesar"
                          CausesValidation="false" OnClick="btnProcesarCargaMasiva_Click">
            <i class="fa-solid fa-file-excel"></i> Procesar carga en excel
          </asp:LinkButton>
        </div>
      </div>
    </div>

    <div style="margin-top:18px;">
      <asp:PlaceHolder ID="phPreviewVacia" runat="server">
        <div class="empty-preview">
          <i class="fa-solid fa-file-excel" style="font-size:2.4rem;color:#27ae60;display:block;margin-bottom:10px;"></i>
          Aquí puedes previsualizar tus archivos
        </div>
      </asp:PlaceHolder>

      <div class="preview-shell">
        <asp:GridView ID="gvPreviewCarga" runat="server" AutoGenerateColumns="false" CssClass="preview-grid"
                      GridLines="None" Visible="false">
          <Columns>
            <asp:TemplateField>
              <HeaderTemplate><i class="fa-solid fa-list-ol"></i> FILA</HeaderTemplate>
              <ItemTemplate><%# Eval("NumeroFilaArchivo") %></ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField>
              <HeaderTemplate><i class="fa-solid fa-hashtag"></i> ID</HeaderTemplate>
              <ItemTemplate><%# Eval("ProductoIdTexto") %></ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField>
              <HeaderTemplate><i class="fa-solid fa-box"></i> NOMBRE</HeaderTemplate>
              <ItemTemplate><%# Eval("NombreProducto") %></ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField>
              <HeaderTemplate><i class="fa-solid fa-cubes"></i> CANTIDAD</HeaderTemplate>
              <ItemTemplate><%# Eval("Cantidad") %></ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField>
              <HeaderTemplate><i class="fa-solid fa-tags"></i> PRECIO</HeaderTemplate>
              <ItemTemplate><%# Eval("Precio") %></ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField>
              <HeaderTemplate><i class="fa-solid fa-industry"></i> PROVEEDOR</HeaderTemplate>
              <ItemTemplate><%# Eval("ProveedorIdTexto") %></ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField>
              <HeaderTemplate><i class="fa-solid fa-image"></i> FOTO RUTA</HeaderTemplate>
              <ItemTemplate><%# Eval("FotoRuta") %></ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField>
              <HeaderTemplate><i class="fa-solid fa-toggle-on"></i> ESTADO</HeaderTemplate>
              <ItemTemplate><%# Eval("EstadoTexto") %></ItemTemplate>
            </asp:TemplateField>
          </Columns>
        </asp:GridView>
      </div>
    </div>
  </div>

  <!-- ══ Buscador + Filtros ════════════════════════════════════ -->


  <div class="card">

    <div class="search-bar">
      <span class="si"><i class="fa-solid fa-magnifying-glass"></i></span>
      <asp:TextBox ID="txtBuscar" runat="server"
                   placeholder="Buscar producto por nombre..."
                   AutoPostBack="false" OnTextChanged="Buscar_Changed"/>
    </div>

    <button class="filtros-toggle" onclick="toggleFiltros(); return false;">
      <i class="fa-solid fa-sliders"></i> Filtros avanzados
      <span id="arrowFilt"><i class="fa-solid fa-chevron-down"></i></span>
    </button>

    <div class="filtros-panel" id="filtrosPanel">

      
      <div class="fg">
        <label><i class="fa-solid fa-truck"></i> Proveedor</label>
        <asp:DropDownList ID="ddlFiltroProveedor" runat="server" CssClass="form-control"
                          AutoPostBack="true" OnSelectedIndexChanged="Buscar_Changed"/>
      </div>

      
      <div class="fg" style="max-width:170px;">
        <label><i class="fa-solid fa-toggle-on"></i> Estado</label>
        <asp:DropDownList ID="ddlFiltroEstado" runat="server" CssClass="form-control"
                          AutoPostBack="true" OnSelectedIndexChanged="Buscar_Changed">
          <asp:ListItem Value=""  Text="Todos los estados"/>
          <asp:ListItem Value="A" Text="Solo activos"/>
          <asp:ListItem Value="I" Text="Solo inactivos"/>
        </asp:DropDownList>
      </div>

     
      <div class="range-group">
        <div class="fg">
          <label><i class="fa-solid fa-dollar-sign"></i> Precio minimo</label>
          <asp:TextBox ID="txtPrecioMin" runat="server" CssClass="form-control"
                       placeholder="0.00" TextMode="Number"
                       AutoPostBack="true" OnTextChanged="Buscar_Changed"/>
        </div>
        <span class="range-sep">—</span>
        <div class="fg">
          <label><i class="fa-solid fa-dollar-sign"></i> Precio maximo</label>
          <asp:TextBox ID="txtPrecioMax" runat="server" CssClass="form-control"
                       placeholder="9999" TextMode="Number"
                       AutoPostBack="true" OnTextChanged="Buscar_Changed"/>
        </div>
      </div>

      
      <div class="range-group">
        <div class="fg">
          <label><i class="fa-solid fa-cubes"></i> Stock minimo</label>
          <asp:TextBox ID="txtStockMin" runat="server" CssClass="form-control"
                       placeholder="0" TextMode="Number"
                       AutoPostBack="true" OnTextChanged="Buscar_Changed"/>
        </div>
        <span class="range-sep">—</span>
        <div class="fg">
          <label><i class="fa-solid fa-cubes"></i> Stock maximo</label>
          <asp:TextBox ID="txtStockMax" runat="server" CssClass="form-control"
                       placeholder="9999" TextMode="Number"
                       AutoPostBack="true" OnTextChanged="Buscar_Changed"/>
        </div>
      </div>
      </div>

      
      <div style="display:flex;align-items:flex-end;">
        <asp:LinkButton ID="btnLimpiarFiltros" runat="server"
                        CssClass="btn btn-secondary btn-sm" CausesValidation="false"
                        OnClientClick="return limpiarFiltrosCliente();"
                        OnClick="btnLimpiarFiltros_Click">
          <i class="fa-solid fa-eraser"></i> Limpiar
        </asp:LinkButton>
      </div>
  </div>

  <!-- ══ Grid + Paginador ══════════════════════════════════════ -->
  <asp:UpdatePanel ID="upGridProductos" runat="server" UpdateMode="Conditional">
    <ContentTemplate>
      <asp:HiddenField ID="hfPagina" runat="server" Value="1" />
      <asp:HiddenField ID="hfTotalPags" runat="server" Value="1" />
      <asp:HiddenField ID="hfOrdenId" runat="server" Value="DESC" />
      <div class="card">
      <div class="card-title">
        <i class="fa-solid fa-table-list"></i> Lista de Productos
        <span style="margin-left:auto;font-size:.78rem;color:#aaa;font-weight:400;">
          <asp:Literal ID="litTotal" runat="server"/> &mdash; orden configurable por ID
        </span>
      </div>
      <div class="grid-wrapper">
      <asp:GridView ID="gvProductos" runat="server"
                    AutoGenerateColumns="false" CssClass="prod-grid"
                    DataKeyNames="pro_id" GridLines="None"
                    OnRowCommand="gvProductos_RowCommand">
        <Columns>

          <asp:TemplateField ItemStyle-Width="50px">
            <HeaderTemplate>
              <i class="fa-solid fa-hashtag"></i> ID
            </HeaderTemplate>
            <ItemTemplate>
              <%# Eval("pro_id") %>
            </ItemTemplate>
          </asp:TemplateField>

          <asp:TemplateField>
            <HeaderTemplate>
              <i class="fa-solid fa-box"></i> PRODUCTO
            </HeaderTemplate>
            <ItemTemplate>
              <%# Eval("pro_nombre") %>
            </ItemTemplate>
          </asp:TemplateField>

          <asp:TemplateField ItemStyle-Width="165px">
            <HeaderTemplate>
              <i class="fa-solid fa-images"></i> FOTOS
            </HeaderTemplate>
            <ItemTemplate>
              <%# GenerarCarrusel(Eval("pro_id"), Eval("tbl_pro_fotos")) %>
            </ItemTemplate>
          </asp:TemplateField>

          <asp:TemplateField>
            <HeaderTemplate>
              <i class="fa-solid fa-industry"></i> PROVEEDOR
            </HeaderTemplate>
            <ItemTemplate>
              <span style="font-weight:600;color:var(--accent2);">
                <%# Eval("tbl_proveedor.prov_nombre") %>
              </span>
            </ItemTemplate>
          </asp:TemplateField>

          <asp:TemplateField ItemStyle-Width="80px">
            <HeaderTemplate>
              <i class="fa-solid fa-cubes"></i> STOCK
            </HeaderTemplate>
            <ItemTemplate>
              <%# Eval("pro_cantidad", "{0:N0}") %>
            </ItemTemplate>
          </asp:TemplateField>

          <asp:TemplateField ItemStyle-Width="90px">
            <HeaderTemplate>
              <i class="fa-solid fa-tags"></i> PRECIO
            </HeaderTemplate>
            <ItemTemplate>
              <%# Eval("pro_precio", "${0:N2}") %>
            </ItemTemplate>
          </asp:TemplateField>

          <asp:TemplateField ItemStyle-Width="110px">
            <HeaderTemplate>
              <i class="fa-solid fa-toggle-on"></i> ESTADO
            </HeaderTemplate>
            <ItemTemplate>
              <span class='badge <%# Convert.ToString(Eval("pro_estado")) == "A" ? "badge-activo":"badge-inactivo" %>'>
                <i class='fa-solid <%# Convert.ToString(Eval("pro_estado")) == "A" ? "fa-circle-check":"fa-circle-xmark" %>'></i>
                <%# Convert.ToString(Eval("pro_estado")) == "A" ? "Activo":"Inactivo" %>
              </span>
            </ItemTemplate>
          </asp:TemplateField>

          <asp:TemplateField ItemStyle-Width="200px">
            <HeaderTemplate>
              <i class="fa-solid fa-gears"></i> ACCIONES
            </HeaderTemplate>
            <ItemTemplate>
              <div style="display:flex; gap:8px; align-items:center; justify-content:center;">
                <asp:LinkButton runat="server" CommandName="Editar"
                    CommandArgument='<%# Eval("pro_id") %>'
                    CssClass="action-btn action-btn-warn" ToolTip="Editar">
                  <i class="fa-solid fa-pen"></i>
                </asp:LinkButton>

                <asp:LinkButton runat="server"
                    CommandName='<%# Convert.ToString(Eval("pro_estado")) == "A" ? "ElimLog" : "Activar" %>'
                    CommandArgument='<%# Eval("pro_id") %>'
                    CssClass='<%# "action-btn " + (Convert.ToString(Eval("pro_estado")) == "A" ? "action-btn-secondary":"action-btn-success") %>'
                    ToolTip='<%# Convert.ToString(Eval("pro_estado")) == "A" ? "Desactivar":"Activar" %>'
                    OnClientClick='<%# Convert.ToString(Eval("pro_estado")) == "A"
                        ? "return confirm(\"Desactivar este producto?\");"
                        : "return confirm(\"Reactivar este producto?\");" %>'>
                  <i class='fa-solid <%# Convert.ToString(Eval("pro_estado")) == "A" ? "fa-toggle-off":"fa-toggle-on" %>'></i>
                </asp:LinkButton>

                <asp:LinkButton runat="server" CommandName="ElimFis"
                    CommandArgument='<%# Eval("pro_id") %>'
                    CssClass="action-btn action-btn-danger" ToolTip="Eliminar permanentemente"
                    OnClientClick="return confirm('ELIMINAR permanentemente. No se puede deshacer.');">
                  <i class="fa-solid fa-trash"></i>
                </asp:LinkButton>

                <a href='FotosProducto.aspx?id=<%# Eval("pro_id") %>'
                   class="action-btn action-btn-primary" title="Administrar fotos">
                  <i class="fa-solid fa-camera"></i>
                </a>
              </div>
            </ItemTemplate>
          </asp:TemplateField>

        </Columns>
        <EmptyDataTemplate>
          <div style="padding:38px;text-align:center;color:#bbb;font-size:.93rem;">
            <i class="fa-solid fa-box-open" style="font-size:2.2rem;display:block;margin-bottom:10px;color:rgba(122,74,170,0.2)"></i>
            No se encontraron productos con los filtros actuales.
          </div>
        </EmptyDataTemplate>
      </asp:GridView>
    </div>

    <div class="pager-wrap">
      <span class="pager-info"><asp:Literal ID="litPagerInfo" runat="server"/></span>
      <div class="pager-pill">
        <asp:LinkButton ID="btnPrev" runat="server" CssClass="pager-btn-pill"
                    CausesValidation="false" OnClick="btnPrev_Click">
          <i class="fa-solid fa-chevron-left"></i> Anterior
        </asp:LinkButton>
        <span class="pager-info-pill"><asp:Literal ID="litPagerInfoPill" runat="server" Text="Página 1 de 1"/></span>
        <asp:LinkButton ID="btnNext" runat="server" CssClass="pager-btn-pill"
                    CausesValidation="false" OnClick="btnNext_Click">
          Siguiente <i class="fa-solid fa-chevron-right"></i>
        </asp:LinkButton>
      </div>
    </div>

  </div>

  <!-- ══ Modal Crear / Editar ══════════════════════════════════ -->
  <div class="modal-overlay" id="modalProducto">
    <div class="modal-box">
      <div class="modal-title">
        <i class="fa-solid fa-box" style="color:var(--accent)"></i>
        <asp:Literal ID="litTituloModal" runat="server" Text=" Nuevo Producto"/>
      </div>

      <asp:HiddenField ID="hfProdId" runat="server" Value="0"/>

      <div class="modal-row">
        <div class="fg" style="min-width:100%">
          <label>Nombre del producto *</label>
          <asp:TextBox ID="txtNombre" runat="server" CssClass="form-control"
                       placeholder="Ej. Laptop Dell Inspiron" MaxLength="50"/>
          <asp:RequiredFieldValidator runat="server" ControlToValidate="txtNombre"
               ErrorMessage="El nombre es obligatorio." ForeColor="#c0392b"
               Display="Dynamic" ValidationGroup="vgProd" Style="font-size:.75rem;margin-top:3px"/>
        </div>
      </div>
    <div class="modal-row">
      <div class="fg">
        <label>Cantidad *</label>
        <asp:TextBox ID="txtCantidad" runat="server" CssClass="form-control"
                     TextMode="Number" min="0" step="1" placeholder="0"/>
        <asp:RequiredFieldValidator runat="server" ControlToValidate="txtCantidad"
             ErrorMessage="Requerido." ForeColor="#c0392b"
             Display="Dynamic" ValidationGroup="vgProd" Style="font-size:.75rem"/>
        <asp:RangeValidator runat="server" ControlToValidate="txtCantidad"
             MinimumValue="0" MaximumValue="2147483647" Type="Integer"
             ErrorMessage="Debe ser un entero positivo." ForeColor="#c0392b"
             Display="Dynamic" ValidationGroup="vgProd" Style="font-size:.75rem"/>
      </div>
      <div class="fg">
        <label>Precio *</label>
        <asp:TextBox ID="txtPrecio" runat="server" CssClass="form-control" placeholder="0.00"/>
        
        <asp:RequiredFieldValidator runat="server" ControlToValidate="txtPrecio"
             ErrorMessage="Requerido." ForeColor="#c0392b"
             Display="Dynamic" ValidationGroup="vgProd" Style="font-size:.75rem"/>
        
        <asp:RegularExpressionValidator runat="server" ControlToValidate="txtPrecio"
             ValidationExpression="^\d+([.,]\d+)?$"
             ErrorMessage="Ingresa un valor positivo válido (ej. 30.8 o 30,8)." ForeColor="#c0392b"
             Display="Dynamic" ValidationGroup="vgProd" Style="font-size:.75rem"/>
      </div>
</div>
      <div class="modal-row">
        <div class="fg" style="min-width:100%">
          <label>Proveedor</label>
          <asp:DropDownList ID="ddlProveedor" runat="server" CssClass="form-control"/>
        </div>
      </div>

      <div class="modal-actions">
        <button type="button" class="btn btn-secondary" onclick="cerrarModal(); return false;">
          <i class="fa-solid fa-xmark"></i> Cancelar
        </button>
        <asp:LinkButton ID="btnGuardarProd" runat="server"
                        CssClass="btn btn-primary" ValidationGroup="vgProd"
                        OnClick="btnGuardar_Click">
          <i class="fa-solid fa-floppy-disk"></i> Guardar
        </asp:LinkButton>
      </div>
    </div>
  </div>

  <asp:HiddenField ID="hfModalAbierto"    runat="server" Value="0"/>
  <asp:HiddenField ID="hfFiltrosAbiertos" runat="server" Value="1"/>
    </ContentTemplate>
       <Triggers>
        <asp:AsyncPostBackTrigger ControlID="txtBuscar" EventName="TextChanged" />
        <asp:AsyncPostBackTrigger ControlID="ddlFiltroProveedor" EventName="SelectedIndexChanged" />
        <asp:AsyncPostBackTrigger ControlID="ddlFiltroEstado" EventName="SelectedIndexChanged" />
        <asp:AsyncPostBackTrigger ControlID="txtPrecioMin" EventName="TextChanged" />
        <asp:AsyncPostBackTrigger ControlID="txtPrecioMax" EventName="TextChanged" />
        <asp:AsyncPostBackTrigger ControlID="txtStockMin" EventName="TextChanged" />
        <asp:AsyncPostBackTrigger ControlID="txtStockMax" EventName="TextChanged" />
        <asp:AsyncPostBackTrigger ControlID="btnLimpiarFiltros" EventName="Click" />
        <asp:AsyncPostBackTrigger ControlID="btnGuardarProd" EventName="Click" />
    </Triggers>
    </asp:UpdatePanel>

  <script>
  // ── Modal ────────────────────────────────────────────────────
  function abrirModal() {
    document.getElementById('modalProducto').classList.add('open');
    document.getElementById('<%= hfModalAbierto.ClientID %>').value = '1';
  }
  function cerrarModal() {
    document.getElementById('modalProducto').classList.remove('open');
    document.getElementById('<%= hfModalAbierto.ClientID %>').value = '0';
  }
  document.addEventListener('keydown', e => { if (e.key === 'Escape') cerrarModal(); });
  document.getElementById('modalProducto')
          .addEventListener('click', function(e){ if(e.target===this) cerrarModal(); });



  function inicializarBusquedaPredictivaProducto() {
    var input = document.getElementById('<%= txtBuscar.ClientID %>');
    if (!input || input.dataset.liveSearchBound === '1') return;

    var timeoutId = 0;
    input.dataset.liveSearchBound = '1';
    input.addEventListener('input', function() {
      window.clearTimeout(timeoutId);
      timeoutId = window.setTimeout(function() {
        __doPostBack('<%= txtBuscar.UniqueID %>', '');
      }, 250);
    });
  }

  function handleFileSelect(input) {
    var zone = document.getElementById('uploadZoneExcel');
    if (!zone) return;
    var content = zone.querySelector('.upload-content');
    var fileInfo = zone.querySelector('.upload-file-info');
    var nameSpan = zone.querySelector('.file-name');

    if (input.files && input.files.length > 0) {
      var fileName = input.files[0].name;
      nameSpan.textContent = fileName;
      content.style.display = 'none';
      fileInfo.style.display = 'flex';
    } else {
      content.style.display = 'flex';
      fileInfo.style.display = 'none';
      nameSpan.textContent = '';
    }
  }

  function initDragAndDrop() {
    var zone = document.getElementById('uploadZoneExcel');
    var fileInput = document.getElementById('<%= fuCargaMasiva.ClientID %>');
    if (!zone || !fileInput) return;

    // Guard: solo inicializar una vez por elemento
    if (zone.dataset.dndBound === '1') return;
    zone.dataset.dndBound = '1';

    zone.addEventListener('click', function(e) {
      if (e.target !== fileInput) {
        // Resetear el valor para que se pueda re-seleccionar el mismo archivo tras limpiar
        fileInput.value = '';
        fileInput.click();
      }
    });

    zone.addEventListener('dragover', function(e) {
      e.preventDefault();
      zone.classList.add('dragover');
    });

    zone.addEventListener('dragleave', function(e) {
      e.preventDefault();
      zone.classList.remove('dragover');
    });

    zone.addEventListener('drop', function(e) {
      e.preventDefault();
      zone.classList.remove('dragover');
      if (e.dataTransfer.files && e.dataTransfer.files.length > 0) {
        // Usar DataTransfer para asignar archivos y disparar change
        var dt = new DataTransfer();
        for (var i = 0; i < e.dataTransfer.files.length; i++) {
          dt.items.add(e.dataTransfer.files[i]);
        }
        fileInput.files = dt.files;
        handleFileSelect(fileInput);
        fileInput.dispatchEvent(new Event('change', { bubbles: true }));
      }
    });

    handleFileSelect(fileInput);
  }

  function inicializarCarruseles() {
    document.querySelectorAll('.carousel-cell').forEach(function(c) {
      if (c.dataset.carouselBound === '1') return;

      c.dataset.carouselBound = '1';
      var slides = c.querySelectorAll('.slide');
      var dots = c.querySelectorAll('.dot');
      if (!slides.length) return;
      var cur = 0;

      function goTo(n) {
        slides[cur].classList.remove('active');
        if (dots[cur]) dots[cur].classList.remove('on');
        cur = (n + slides.length) % slides.length;
        slides[cur].classList.add('active');
        if (dots[cur]) dots[cur].classList.add('on');
      }

      if (slides.length > 1) {
        window.setInterval(function() { goTo(cur + 1); }, 3000);
      }

      var prev = c.querySelector('.prev'), next = c.querySelector('.next');
      if (prev) prev.addEventListener('click', function (e) { e.stopPropagation(); goTo(cur - 1); });
      if (next) next.addEventListener('click', function (e) { e.stopPropagation(); goTo(cur + 1); });
      dots.forEach(function (d, i) { d.addEventListener('click', function () { goTo(i); }); });
    });
  }

  function inicializarComponentesProductos() {
    if (document.getElementById('<%= hfModalAbierto.ClientID %>').value === '1') {
      document.getElementById('modalProducto').classList.add('open');
    } else {
      document.getElementById('modalProducto').classList.remove('open');
    }

    if (document.getElementById('<%= hfFiltrosAbiertos.ClientID %>').value === '0') {
      document.getElementById('filtrosPanel').classList.add('closed');
      document.getElementById('arrowFilt').innerHTML = '<i class="fa-solid fa-chevron-down"></i>';
    } else {
      document.getElementById('arrowFilt').innerHTML = '<i class="fa-solid fa-chevron-up"></i>';
    }
    inicializarBusquedaPredictivaProducto();
    initDragAndDrop();
    inicializarCarruseles();
  }

  window.addEventListener('DOMContentLoaded', inicializarComponentesProductos);

  if (typeof Sys !== 'undefined') {
    var prm = Sys.WebForms.PageRequestManager.getInstance();
    prm.add_endRequest(inicializarComponentesProductos);

    var activeElementId = null;
    var activeElementRef = null;
    var selectionStart = 0;
    var selectionEnd = 0;

    prm.add_beginRequest(function (sender, args) {
      var activeEl = document.activeElement;
      if (activeEl && (activeEl.tagName === 'INPUT' || activeEl.tagName === 'TEXTAREA')) {
        activeElementId = activeEl.id;
        activeElementRef = activeEl;
        try {
          selectionStart = activeEl.selectionStart;
          selectionEnd = activeEl.selectionEnd;
        } catch (e) {
          selectionStart = 0;
          selectionEnd = 0;
        }
      } else {
        activeElementId = null;
        activeElementRef = null;
      }
    });

    prm.add_endRequest(function (sender, args) {
      if (activeElementId) {
        var el = document.getElementById(activeElementId);
        if (el && el !== activeElementRef) {
          el.focus();
          try {
            el.setSelectionRange(selectionStart, selectionEnd);
          } catch (e) {}
        }
      }
    });
  }

  // ── Filtros ──────────────────────────────────────────────────
  function limpiarFiltrosCliente() {
    var txt = document.getElementById('<%= txtBuscar.ClientID %>');
    if (txt) txt.value = '';
    var ddlP = document.getElementById('<%= ddlFiltroProveedor.ClientID %>');
    if (ddlP) ddlP.selectedIndex = 0;
    var ddlE = document.getElementById('<%= ddlFiltroEstado.ClientID %>');
    if (ddlE) ddlE.selectedIndex = 0;
    var txtPMin = document.getElementById('<%= txtPrecioMin.ClientID %>');
    if (txtPMin) txtPMin.value = '';
    var txtPMax = document.getElementById('<%= txtPrecioMax.ClientID %>');
    if (txtPMax) txtPMax.value = '';
    var txtSMin = document.getElementById('<%= txtStockMin.ClientID %>');
    if (txtSMin) txtSMin.value = '';
    var txtSMax = document.getElementById('<%= txtStockMax.ClientID %>');
    if (txtSMax) txtSMax.value = '';
    return true;
  }

  function toggleFiltros() {
    var p  = document.getElementById('filtrosPanel');
    var a  = document.getElementById('arrowFilt');
    var hf = document.getElementById('<%= hfFiltrosAbiertos.ClientID %>');
          p.classList.toggle('closed');
          var closed = p.classList.contains('closed');
          a.innerHTML = closed ? '<i class="fa-solid fa-chevron-down"></i>'
              : '<i class="fa-solid fa-chevron-up"></i>';
          hf.value = closed ? '0' : '1';
      }

  </script>

</asp:Content>
