<%@ Page Title="Administrar Fotos de Productos" Language="C#" MasterPageFile="~/Site1.Master"
    AutoEventWireup="true" CodeBehind="FotosProductosGeneral.aspx.cs"
    Inherits="Monolito4bm.FotosProductosGeneral" MaintainScrollPositionOnPostback="true" %>

<asp:Content ID="headContent" ContentPlaceHolderID="head" runat="server">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <link rel="stylesheet"
        href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css"
        crossorigin="anonymous" />
    <style>
        :root {
            --accent: #db2777;
            --accent2: #9d174d;
            --danger: #c0392b;
            --success: #27ae60;
        }
        .page-header { display:flex;align-items:center;justify-content:space-between;margin-bottom:24px;flex-wrap:wrap;gap:12px; }
        .page-title { font-size:1.5rem;font-weight:700;color:var(--accent2);display:flex;align-items:center;gap:10px; }
        .back-link { display:inline-flex;align-items:center;gap:7px;color:var(--accent);font-weight:700;font-size:.88rem;text-decoration:none;padding:8px 18px;border-radius:30px;border:1.5px solid rgba(219,39,119,.3);transition:all .2s; }
        .back-link:hover { background:rgba(219,39,119,0.1);transform:translateX(-2px); }
        .card { background:rgba(255,255,255,.76);backdrop-filter:blur(12px);border:1px solid rgba(244,143,177,0.4);border-radius:18px;padding:22px 26px;box-shadow:0 4px 24px rgba(190,24,93,0.10);margin-bottom:22px; }
        .card-title { font-size:.98rem;font-weight:700;color:var(--accent2);margin-bottom:14px;display:flex;align-items:center;gap:8px; }
        .guide-list { margin:0 0 16px 18px;color:rgba(60,30,90,.78);font-size:.88rem; }
        .guide-list li { margin-bottom:6px; }
        .form-control { background:rgba(255,255,255,.82);border:1px solid rgba(180,150,220,.4);color:#2c1a4a;padding:10px 14px;border-radius:10px;width:100%;font-size:.88rem;box-shadow:inset 0 1px 3px rgba(0,0,0,.05); }
        .form-label { font-weight:700;color:var(--accent2);display:block;margin-bottom:6px;font-size:.86rem; }
        .btn { padding:9px 18px;border-radius:30px;border:none;cursor:pointer;font-size:.85rem;font-weight:700;display:inline-flex;align-items:center;gap:7px;text-decoration:none; }
        .btn-primary { background:var(--accent);color:#fff; }
        .btn-secondary { background:rgba(122,74,170,.12);color:var(--accent2);border:1px solid rgba(122,74,170,.3); }
        .btn-success { background:var(--success);color:#fff; }
        .btn-danger { background:var(--danger);color:#fff; }
        .btn-sm { padding:6px 12px;font-size:.76rem;border-radius:20px; }
        .alert { padding:11px 16px;border-radius:12px;margin-bottom:14px;font-size:.86rem;font-weight:600; }
        .alert-success { background:rgba(39,174,96,.15);color:#1e8449;border:1px solid rgba(39,174,96,.3); }
        .alert-danger { background:rgba(192,57,43,.12);color:#c0392b;border:1px solid rgba(192,57,43,.25); }

        /* ── SLOTS TRACK ── */
        .slots-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 10px;
            margin-bottom: 14px;
        }
        .slots-counter {
            font-size: .78rem;
            color: rgba(157,23,77,0.6);
            font-weight: 600;
        }
        .slots-track {
            display: flex;
            flex-direction: row;
            gap: 12px;
            overflow-x: auto;
            overflow-y: visible;
            padding: 6px 2px 16px 2px;
            scroll-behavior: smooth;
            scrollbar-width: thin;
            scrollbar-color: var(--accent) rgba(219,39,119,0.1);
            align-items: flex-start;
        }
        .slots-track::-webkit-scrollbar { height: 6px; }
        .slots-track::-webkit-scrollbar-track { background: rgba(219,39,119,0.07); border-radius:8px; }
        .slots-track::-webkit-scrollbar-thumb { background: var(--accent); border-radius:8px; }

        /* ── SLOT CARD ── */
        .slot-card {
            flex: 0 0 210px;
            min-width: 210px;
            max-width: 210px;
            background: rgba(255,255,255,0.95);
            border: 1.5px solid rgba(219,39,119,0.22);
            border-radius: 14px;
            padding: 10px 10px 12px 10px;
            box-shadow: 0 2px 10px rgba(190,24,93,0.07);
            display: flex;
            flex-direction: column;
            gap: 8px;
            position: relative;
            transition: box-shadow .2s, border-color .2s;
        }
        .slot-card.has-product { border-color: rgba(219,39,119,0.45); }
        .slot-card.has-files { box-shadow: 0 0 0 2px rgba(219,39,119,0.18), 0 4px 14px rgba(190,24,93,0.12); }
        .slot-card.saving { opacity: .65; pointer-events: none; }
        .slot-card.saved-ok { border-color: var(--success); }

        .slot-num-badge {
            font-size: .65rem;
            font-weight: 700;
            color: var(--accent);
            background: rgba(219,39,119,0.09);
            border-radius: 20px;
            padding: 1px 7px;
            display: inline-block;
            margin-bottom: 2px;
        }

        /* ── ADD SLOT BUTTON ── */
        .add-slot-btn {
            flex: 0 0 52px;
            min-width: 52px;
            align-self: stretch;
            min-height: 160px;
            display: flex;
            align-items: center;
            justify-content: center;
            background: rgba(219,39,119,0.04);
            border: 2px dashed rgba(219,39,119,0.3);
            border-radius: 14px;
            cursor: pointer;
            transition: all .2s;
        }
        .add-slot-btn:hover { background: rgba(219,39,119,0.1); border-color: var(--accent); transform: scale(1.04); }
        .add-slot-btn i { font-size: 1.5rem; color: var(--accent); }

        /* ── CUSTOM DROPDOWN ── */
        .custom-ddl-wrap { position: relative; width: 100%; }
        .custom-ddl-trigger {
            display: flex; align-items: center; gap: 5px;
            width: 100%; padding: 4px 9px;
            border-radius: 18px;
            border: 1.5px solid rgba(219,39,119,0.35);
            background: #fff;
            cursor: pointer; font-size: .72rem; font-weight: 700; color: var(--accent2);
            transition: all .18s; box-shadow: 0 1px 4px rgba(219,39,119,0.07);
            min-height: 28px; text-align: left;
        }
        .custom-ddl-trigger:hover { border-color: var(--accent); background: rgba(219,39,119,0.03); }
        .custom-ddl-trigger .ddl-label { flex:1; overflow:hidden; text-overflow:ellipsis; white-space:nowrap; display:block; }
        .custom-ddl-trigger .ddl-arrow { flex-shrink:0; font-size:.6rem; transition:transform .18s; }
        .custom-ddl-wrap.open .ddl-arrow { transform: rotate(180deg); }
        .custom-ddl-panel {
            display: none; position: absolute;
            top: calc(100% + 4px); left: 0; z-index: 9999;
            background: #fff; border: 1.5px solid rgba(219,39,119,0.35);
            border-radius: 11px;
            box-shadow: 0 8px 28px rgba(100,0,60,0.16);
            width: 250px; max-height: 240px; overflow: hidden;
            flex-direction: column;
        }
        .custom-ddl-wrap.open .custom-ddl-panel { display: flex; }
        .custom-ddl-search {
            padding: 7px 10px; border: none;
            border-bottom: 1px solid rgba(219,39,119,0.15);
            font-size: .8rem; color: var(--accent2); outline: none;
            width: 100%; box-sizing: border-box; font-family: inherit;
        }
        .custom-ddl-search::placeholder { color: rgba(157,23,77,0.4); font-style: italic; }
        .custom-ddl-list { overflow-y: auto; flex: 1; scrollbar-width: thin; scrollbar-color: var(--accent) transparent; }
        .custom-ddl-list::-webkit-scrollbar { width: 4px; }
        .custom-ddl-list::-webkit-scrollbar-thumb { background: var(--accent); border-radius: 4px; }
        .custom-ddl-option {
            padding: 7px 11px; font-size: .79rem; color: #2c1a4a;
            cursor: pointer; word-break: break-word;
            transition: background .1s;
            border-bottom: 1px solid rgba(180,150,220,0.07);
        }
        .custom-ddl-option:hover, .custom-ddl-option.selected { background: rgba(219,39,119,0.09); color: var(--accent2); font-weight:700; }
        .custom-ddl-option.placeholder-opt { color: rgba(157,23,77,0.45); font-style: italic; font-weight: 400; }

        /* ── UPLOAD ZONE (compact) ── */
        .slot-upload-zone {
            border: 1.8px dashed rgba(219,39,119,0.3);
            border-radius: 9px; padding: 10px 8px;
            text-align: center; cursor: pointer;
            transition: all .2s; background: rgba(219,39,119,0.02);
            position: relative; font-size: .72rem;
        }
        .slot-upload-zone:hover, .slot-upload-zone.drag-over { border-color: var(--accent); background: rgba(219,39,119,0.06); }
        .slot-upload-zone .uz-icon { font-size: 1.2rem; color: var(--accent); margin-bottom: 2px; }
        .slot-upload-zone p { color: rgba(157,23,77,0.6); margin: 1px 0; }
        .slot-upload-zone input[type=file] { position:absolute;inset:0;opacity:0;cursor:pointer; }

        /* ── PRODUCT LABEL (above carousel) ── */
        .slot-product-label {
            font-size: .7rem; font-weight: 700; color: var(--accent2);
            display: flex; align-items: center; gap: 4px;
            min-height: 16px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;
        }

        /* ── CAROUSEL ── */
        .slot-carousel {
            display: flex; flex-direction: row; gap: 6px;
            overflow-x: auto; padding-bottom: 4px;
            scrollbar-width: thin; scrollbar-color: rgba(219,39,119,0.3) transparent;
            min-height: 72px;
        }
        .slot-carousel::-webkit-scrollbar { height: 3px; }
        .slot-carousel::-webkit-scrollbar-thumb { background: rgba(219,39,119,0.35); border-radius: 3px; }
        .carousel-photo {
            position: relative; flex: 0 0 66px; width: 66px; height: 66px;
            border-radius: 8px; overflow: hidden;
            border: 1.5px solid rgba(219,39,119,0.18);
            background: rgba(122,74,170,0.06);
            transition: transform .14s;
        }
        .carousel-photo:hover { transform: scale(1.05); border-color: var(--accent); }
        .carousel-photo img { width:100%;height:100%;object-fit:cover;display:block; }
        .photo-remove {
            position: absolute; top: 2px; right: 2px;
            width: 16px; height: 16px; border-radius: 50%;
            background: rgba(192,57,43,0.82); color: #fff; border: none; cursor: pointer;
            font-size: .55rem; display: flex; align-items: center; justify-content: center;
            transition: background .12s; line-height: 1; padding: 0;
        }
        .photo-remove:hover { background: #c0392b; }
        .slot-carousel-empty {
            width: 100%; min-height: 66px;
            display: flex; align-items: center; justify-content: center;
            font-size: .7rem; color: rgba(157,23,77,0.38); font-style: italic;
            gap: 5px;
        }

        /* ── SLOT SAVE STATUS ── */
        .slot-status { font-size: .68rem; min-height: 14px; font-weight: 600; }
        .slot-status.ok { color: var(--success); }
        .slot-status.err { color: var(--danger); }
        .slot-status.saving { color: rgba(219,39,119,0.7); }

        /* ── SLOT ACTIONS ── */
        .slot-actions { display: flex; gap: 6px; flex-wrap: wrap; align-items: center; }
        .slot-clear-btn {
            font-size: .68rem; padding: 4px 8px;
            background: rgba(192,57,43,0.08); color: #c0392b;
            border: 1px solid rgba(192,57,43,0.2);
            border-radius: 18px; cursor: pointer;
            display: inline-flex; align-items: center; gap: 4px;
            transition: all .12s;
        }
        .slot-clear-btn:hover { background: rgba(192,57,43,0.16); }
        .slot-remove-btn {
            font-size: .68rem; padding: 4px 8px;
            background: rgba(180,150,220,0.1); color: #6b5b82;
            border: 1px solid rgba(180,150,220,0.25);
            border-radius: 18px; cursor: pointer;
            display: inline-flex; align-items: center; gap: 4px;
            transition: all .12s; margin-left: auto;
        }
        .slot-remove-btn:hover { background: rgba(192,57,43,0.1); color: #c0392b; }

        /* ── GLOBAL GUARDAR BUTTON ── */
        .guardar-todo-wrap {
            display: flex; align-items: center; gap: 12px; flex-wrap: wrap;
            margin-top: 14px;
        }
        .btn-guardar-todo {
            padding: 10px 22px; border-radius: 30px; border: none; cursor: pointer;
            font-size: .88rem; font-weight: 700;
            background: linear-gradient(135deg, var(--accent), var(--accent2));
            color: #fff; display: inline-flex; align-items: center; gap: 8px;
            box-shadow: 0 4px 14px rgba(219,39,119,0.28);
            transition: all .2s;
        }
        .btn-guardar-todo:hover { transform: translateY(-1px); box-shadow: 0 6px 20px rgba(219,39,119,0.38); }
        .btn-guardar-todo:disabled { opacity: .55; cursor: not-allowed; transform: none; }
        .global-progress {
            font-size: .82rem; color: rgba(157,23,77,0.7); font-weight: 600;
            display: none;
        }

        /* ── RUTAS PREPARADAS – horizontal scroll ── */
        .rutas-track {
            display: flex;
            flex-direction: row;
            gap: 10px;
            overflow-x: auto;
            padding: 4px 2px 12px 2px;
            margin-top: 12px;
            scrollbar-width: thin;
            scrollbar-color: var(--success) rgba(39,174,96,0.1);
        }
        .rutas-track::-webkit-scrollbar { height: 5px; }
        .rutas-track::-webkit-scrollbar-track { background: rgba(39,174,96,0.08); border-radius: 6px; }
        .rutas-track::-webkit-scrollbar-thumb { background: var(--success); border-radius: 6px; }
        .ruta-card {
            flex: 0 0 200px; min-width: 200px;
            border-radius: 11px; overflow: hidden;
            background: rgba(122,74,170,.04);
            border: 1px solid rgba(122,74,170,.18);
            padding: 8px 10px;
        }
        .ruta-card strong { display:block;color:var(--accent2);margin-bottom:3px;font-size:.75rem;word-break:break-word; }
        .ruta-card span { font-size:.71rem;color:#5b476f;word-break:break-all; }

        /* ── STEP PANEL ── */
        .step-panel { padding:14px;border-radius:14px;background:rgba(122,74,170,.05);border:1px solid rgba(122,74,170,.14); }
        .step-panel strong { display:block;color:var(--accent2);margin-bottom:6px; }
        .steps-grid { display:grid;grid-template-columns:repeat(auto-fit,minmax(240px,1fr));gap:14px; }

        /* ── EXCEL PREVIEW TABLE ── */
        .preview-shell { max-height:200px; overflow-y:auto; overflow-x:auto; border-radius:12px; border:1px solid rgba(180,150,220,.22); }
        .preview-grid { width:100%;border-collapse:collapse; }
        .preview-grid th,.preview-grid td { padding:10px 12px;border-bottom:1px solid rgba(180,150,220,.18);font-size:.83rem; }
        .preview-grid th { background:linear-gradient(90deg,var(--accent),var(--accent2));color:#fff;text-align:left; }
        .empty-preview,.empty-state { text-align:center;padding:26px 18px;color:rgba(60,30,90,.45);font-size:.9rem; }

        /* ── SEARCH & FILTERS ── */
        .search-bar { display:flex;align-items:center;gap:10px;background:rgba(255,255,255,.9);border:1.5px solid rgba(219,39,119,0.28);border-radius:40px;padding:9px 18px;margin-bottom:14px; }
        .search-bar input { border:none;background:transparent;flex:1;outline:none;color:var(--accent2);font-family:inherit;font-size:.95rem; }
        .filtros-toggle { background:none;border:none;cursor:pointer;font-size:.83rem;font-weight:700;color:var(--accent);display:flex;align-items:center;gap:6px;padding:4px 0;margin-bottom:10px; }
        .filtros-panel { display:flex;gap:14px;flex-wrap:wrap;padding:16px;background:rgba(122,74,170,.04);border-radius:14px;border:1px solid rgba(122,74,170,.14);margin-bottom:14px; }
        .filtros-panel.closed { display:none; }
        .fg { display:flex;flex-direction:column;gap:5px;min-width:150px;flex:1; }

        /* ── FOTOS TABLE ── */
        .fotos-table { width:100%;border-collapse:collapse;font-size:.87rem; }
        .fotos-table thead tr { background:linear-gradient(90deg,var(--accent),var(--accent2));color:#fff; }
        .fotos-table th,.fotos-table td { padding:11px 14px;text-align:left;border-bottom:1px solid rgba(180,150,220,.18);vertical-align:middle; }
        .foto-thumb { width:64px;height:64px;border-radius:8px;overflow:hidden;border:2px solid rgba(180,150,220,.35);background:rgba(122,74,170,.06); }
        .foto-thumb img { width:100%;height:100%;object-fit:cover;display:block; }
        .prod-name-cell { font-weight:600;color:var(--accent2);display:flex;align-items:center;gap:8px; }
        .prod-name-cell span.sub { font-size:.74rem;font-weight:400;color:#888;display:block; }
        .badge { display:inline-block;padding:3px 10px;border-radius:20px;font-size:.72rem;font-weight:700; }
        .badge-activo { background:rgba(39,174,96,.15);color:#1e8449; }
        .badge-inactivo { background:rgba(192,57,43,.12);color:#c0392b; }
        .row-actions { display:flex;gap:7px;flex-wrap:wrap; }

        @media(max-width:700px) {
            .card { padding:16px 14px; }
            .fotos-table thead { display:none; }
            .fotos-table tbody tr { display:flex;flex-wrap:wrap;padding:12px;gap:8px;border-radius:12px;margin-bottom:10px;border:1px solid rgba(180,150,220,.3); }
            .fotos-table td { padding:2px 4px; }
        }
    </style>
</asp:Content>

<asp:Content ID="bodyContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="page-header">
        <div class="page-title">
            <i class="fa-solid fa-images" style="color:var(--accent)"></i>
            Administracion General de Fotos
        </div>
        <a href="Productos.aspx" class="back-link">
            <i class="fa-solid fa-arrow-left"></i> Volver a Productos
        </a>
    </div>

    <asp:Literal ID="litMensaje" runat="server" />

    <%-- Controles de servidor mínimos para Excel y filtros --%>
    <asp:HiddenField ID="hfProductosJson"      runat="server" />
    <asp:HiddenField ID="hfAccumulatedRoutes"  runat="server" />
    <asp:HiddenField ID="hfFiltrosAbiertos"    runat="server" Value="1" />
    <asp:HiddenField ID="hfAccionRutasFaltantes" runat="server" Value="" />

    <%-- Controles originales (compatibilidad con code-behind) --%>
    <div style="display:none !important;">
        <asp:FileUpload  ID="fuFotos"           runat="server" AllowMultiple="true" accept="image/jpeg,image/png" />
        <asp:DropDownList ID="ddlProductoCarga" runat="server" />
        <asp:Button ID="btnPrevisualizar"       runat="server" Text="prev" OnClick="btnPrevisualizar_Click" />
        <asp:Button ID="btnPrepararExcelRutas" runat="server" Text="subir" OnClick="btnPrepararExcelRutas_Click" />
        <asp:Button ID="btnGenerarExcelTodo"   runat="server" Text="genExcel" OnClick="btnGenerarExcelTodo_Click" />
    </div>

    <%-- ═══════════════════════════════════════════════════════
         PASO 1 – CARGA MULTI-PRODUCTO (SLOTS ILIMITADOS)
         ═══════════════════════════════════════════════════════ --%>
    <div class="card">
        <div class="card-title">
            <i class="fa-solid fa-list-check"></i> Paso 1. Carga masiva de fotos por producto
        </div>
        <ol>sigue el flujo para facilitar tu carga en excel</ol>
        <ol class="guide-list">
            <li>Presiona <strong>+</strong> para agregar un slot por cada producto que desees cargar.</li>
            <li>En cada slot: elige el producto en el dropdown y arrastra o selecciona las fotos (JPG/PNG MB).</li>
            <li>Cuando tengas todos los slots listos, presiona <strong>Guardar Todo en servidor</strong></li>
            <li>Descarga el Excel generado, completa datos si hace falta y usa la carga masiva de abajo.</li>
        </ol>

        <div class="slots-header">
            <div class="slots-counter" id="slotsCounter">0 slots activos</div>
            <div style="display:flex;gap:8px;align-items:center;">
                <button type="button" class="btn btn-secondary btn-sm" onclick="addSlot()">
                    <i class="fa-solid fa-plus"></i> Agregar slot
                </button>
            </div>
        </div>

        <div class="slots-track" id="slotsTrack">
            <%-- slots se inyectan por JS --%>
        </div>

        <div class="guardar-todo-wrap">
            <button type="button" class="btn-guardar-todo" id="btnGuardarTodo" onclick="guardarTodo()" disabled>
                <i class="fa-solid fa-cloud-arrow-up"></i> Guardar Todo en servidor
            </button>
            <span class="global-progress" id="globalProgress"></span>
        </div>
    </div>

    <%-- ═══════════════════════════════════════════════════════
         PASO 2 – RUTAS PREPARADAS (scroll horizontal)
         ═══════════════════════════════════════════════════════ --%>
    <div class="card">
        <div class="card-title">
            <i class="fa-solid fa-route" style="color:var(--success)"></i> Paso 2. Rutas preparadas en servidor
        </div>
        <span id="litRutasPreparadasInfoCliente">
            <asp:Literal ID="litRutasPreparadasInfo" runat="server" Text="Aún no hay rutas preparadas en servidor." />
        </span>
        <div style="display:flex;gap:10px;flex-wrap:wrap;margin-top:12px;">
            <button type="button" id="btnDescargarExcelRutasCliente" class="btn btn-success" 
                style="display:<%= (ExcelRutasPreparadas != null && ExcelRutasPreparadas.Length > 0) ? "inline-flex" : "none" %>;" 
                onclick="window.location.href='GuardarFotosSlots.ashx?action=descargar_excel';">
                <i class="fa-solid fa-file-excel"></i> 3. Descargar Excel con rutas
            </button>
            <asp:Button ID="btnDescargarRutasPreparadas" runat="server" CssClass="btn btn-success"
                Text="3. Descargar Excel con rutas (servidor)" OnClick="btnDescargarRutasPreparadas_Click" Visible="false" />
            
            <button type="button" class="btn btn-secondary" onclick="window.location.href='GuardarFotosSlots.ashx?action=descargar_plantilla';">
                <i class="fa-solid fa-download"></i> Descargar plantilla base
            </button>
            <asp:Button ID="btnDescargarFormato" runat="server" CssClass="btn btn-secondary"
                Text="Descargar plantilla base (servidor)" OnClick="btnDescargarFormato_Click" Visible="false" />
        </div>
        <%-- Rutas en scroll horizontal (cliente) --%>
        <div class="rutas-track" id="rutasTrackClient">
            <%-- se añaden por JS al guardar --%>
        </div>
        <asp:Repeater ID="rptRutasPreparadas" runat="server">
            <HeaderTemplate><div class="rutas-track"></HeaderTemplate>
            <ItemTemplate>
                <div class="ruta-card">
                    <strong><%# Eval("NombreArchivo") %></strong>
                    <span><%# Eval("RutaRelativa") %></span>
                </div>
            </ItemTemplate>
            <FooterTemplate></div></FooterTemplate>
        </asp:Repeater>
    </div>

    <%-- ═══════════════════════════════════════════════════════
         CARGA MASIVA POR EXCEL
         ═══════════════════════════════════════════════════════ --%>
    <asp:UpdatePanel ID="upCargaMasiva" runat="server" UpdateMode="Conditional">
        <ContentTemplate>
            <div class="card">
                <div class="card-title">
                    <i class="fa-solid fa-file-excel" style="color:var(--success)"></i> Carga masiva por Excel
                </div>
                <div class="steps-grid">
                    <div>
                        <label class="form-label" for="<%= fuCargaMasiva.ClientID %>">Archivo Excel o CSV</label>
                        <asp:FileUpload ID="fuCargaMasiva" runat="server" CssClass="form-control" />
                        <div style="font-size:.78rem;color:#6b5b82;margin-top:8px;">
                            Encabezados: <code>foto_id</code>, <code>producto</code>, <code>foto_ruta</code> o <code>foto_bit</code>, <code>estado</code>.
                        </div>
                        <div style="display:flex;gap:10px;flex-wrap:wrap;margin-top:14px;">
                            <asp:Button ID="btnPrevisualizarCarga" runat="server" CssClass="btn btn-secondary"
                                Text="Visualizar archivo" OnClick="btnPrevisualizarCarga_Click" />
                            <asp:Button ID="btnLimpiarCarga" runat="server" CssClass="btn btn-secondary"
                                Text="Limpiar carga" OnClick="btnLimpiarCarga_Click" />
                        </div>
                        <div style="margin-top:12px;font-size:.8rem;color:#6b5b82;">
                            <span id="litArchivoCargaCliente"><asp:Literal ID="litArchivoCarga" runat="server" Text="Sin archivo cargado." /></span>
                            <br />
                            <asp:Literal ID="litResumenCarga" runat="server" Text="Aun no hay vista previa." />
                        </div>
                    </div>
                    <div>
                        <label class="form-label" for="<%= ddlTipoInsercionMasiva.ClientID %>">Tipo de insercion</label>
                        <asp:DropDownList ID="ddlTipoInsercionMasiva" runat="server" CssClass="form-control">
                            <asp:ListItem Value="1" Text="Anadir sin borrar" />
                            <asp:ListItem Value="2" Text="Borrar todo y volver a cargar" />
                        </asp:DropDownList>
                        <div style="font-size:.78rem;color:#6b5b82;margin-top:8px;">Puedes cargar por <code>foto_ruta</code> o por <code>foto_bit</code> en base64.</div>
                        <div style="display:flex;gap:10px;flex-wrap:wrap;margin-top:14px;">
                            <asp:Button ID="btnProcesarCargaMasiva" runat="server" CssClass="btn btn-success"
                                Text="Procesar carga masiva" OnClick="btnProcesarCargaMasiva_Click" />
                        </div>
                    </div>
                </div>
                <div style="margin-top:18px;">
                    <asp:PlaceHolder ID="phPreviewVacia" runat="server">
                        <div class="empty-preview">
                            <i class="fa-solid fa-table-list" style="font-size:1.6rem;display:block;margin-bottom:10px;"></i>
                            Selecciona un archivo y presiona "Visualizar archivo" para revisar las fotos antes de importarlas.
                        </div>
                    </asp:PlaceHolder>
                    <div class="preview-shell">
                        <asp:GridView ID="gvPreviewCarga" runat="server" AutoGenerateColumns="false" CssClass="preview-grid"
                            GridLines="None" Visible="false">
                            <Columns>
                                <asp:TemplateField><HeaderTemplate><i class="fa-solid fa-list-ol"></i> FILA</HeaderTemplate><ItemTemplate><%# Eval("NumeroFilaArchivo") %></ItemTemplate></asp:TemplateField>
                                <asp:TemplateField><HeaderTemplate><i class="fa-solid fa-hashtag"></i> ID FOTO</HeaderTemplate><ItemTemplate><%# Eval("FotoIdTexto") %></ItemTemplate></asp:TemplateField>
                                <asp:TemplateField><HeaderTemplate><i class="fa-solid fa-box"></i> PRODUCTO</HeaderTemplate><ItemTemplate><%# Eval("ProductoId") %></ItemTemplate></asp:TemplateField>
                                <asp:TemplateField><HeaderTemplate><i class="fa-solid fa-image"></i> FOTO_RUTA</HeaderTemplate><ItemTemplate><%# Eval("RutaFoto") %></ItemTemplate></asp:TemplateField>
                                <asp:TemplateField><HeaderTemplate><i class="fa-solid fa-file-invoice"></i> ORIGEN</HeaderTemplate><ItemTemplate><%# Eval("OrigenFoto") %></ItemTemplate></asp:TemplateField>
                                <asp:TemplateField><HeaderTemplate><i class="fa-solid fa-toggle-on"></i> ESTADO</HeaderTemplate><ItemTemplate><%# Eval("EstadoTexto") %></ItemTemplate></asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </div>
                </div>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>

    <%-- FILTROS --%>
    <div class="card">
        <div class="search-bar">
            <span><i class="fa-solid fa-magnifying-glass"></i></span>
            <asp:TextBox ID="txtBuscar" runat="server" placeholder="Buscar foto por nombre de producto o ruta..."
                AutoPostBack="true" OnTextChanged="Filtros_Changed" />
        </div>
        <button class="filtros-toggle" onclick="toggleFiltros(); return false;">
            <i class="fa-solid fa-sliders"></i> Filtros avanzados
            <span id="arrowFilt"><i class="fa-solid fa-chevron-down"></i></span>
        </button>
        <div class="filtros-panel" id="filtrosPanel">
            <div class="fg">
                <label><i class="fa-solid fa-box"></i> Producto</label>
                <asp:DropDownList ID="ddlFiltroProducto" runat="server" CssClass="form-control"
                    AutoPostBack="true" OnSelectedIndexChanged="Filtros_Changed" />
            </div>
            <div class="fg" style="max-width:170px;">
                <label><i class="fa-solid fa-toggle-on"></i> Estado</label>
                <asp:DropDownList ID="ddlFiltroEstado" runat="server" CssClass="form-control"
                    AutoPostBack="true" OnSelectedIndexChanged="Filtros_Changed">
                    <asp:ListItem Value="" Text="Todos los estados" />
                    <asp:ListItem Value="A" Text="Solo activas" />
                    <asp:ListItem Value="I" Text="Solo inactivas" />
                </asp:DropDownList>
            </div>
            <div class="fg">
                <label><i class="fa-solid fa-calendar-plus"></i> Desde fecha</label>
                <asp:TextBox ID="txtFechaDesde" runat="server" CssClass="form-control"
                    TextMode="Date" AutoPostBack="true" OnTextChanged="Filtros_Changed" />
            </div>
            <div class="fg">
                <label><i class="fa-solid fa-calendar-minus"></i> Hasta fecha</label>
                <asp:TextBox ID="txtFechaHasta" runat="server" CssClass="form-control"
                    TextMode="Date" AutoPostBack="true" OnTextChanged="Filtros_Changed" />
            </div>
            <div style="display:flex;align-items:flex-end;">
                <asp:LinkButton ID="btnLimpiarFiltros" runat="server"
                    CssClass="btn btn-secondary btn-sm" CausesValidation="false"
                    OnClick="btnLimpiarFiltros_Click">Limpiar</asp:LinkButton>
            </div>
        </div>
    </div>

    <asp:UpdatePanel ID="upFotosGeneral" runat="server" UpdateMode="Conditional">
        <ContentTemplate>
            <div class="card">
                <div class="card-title">
                    <i class="fa-solid fa-images"></i> Todas las fotos guardadas
                    <span style="margin-left:auto;font-size:.79rem;color:#888;font-weight:400;">
                        <asp:Literal ID="litTotalFotos" runat="server" />
                    </span>
                </div>
                <div style="overflow-x:auto;border-radius:12px;">
                    <asp:Repeater ID="rptFotos" runat="server" OnItemCommand="rptFotos_ItemCommand">
                        <HeaderTemplate>
                            <table class="fotos-table"><thead><tr>
                                <th style="width:76px;"><i class="fa-solid fa-image"></i> FOTO</th>
                                <th><i class="fa-solid fa-box"></i> PRODUCTO</th>
                                <th style="width:80px;"><i class="fa-solid fa-hashtag"></i> ID FOTO</th>
                                <th style="width:90px;"><i class="fa-solid fa-toggle-on"></i> ESTADO</th>
                                <th><i class="fa-solid fa-calendar-days"></i> FECHA</th>
                                <th style="width:210px;"><i class="fa-solid fa-gears"></i> ACCIONES</th>
                            </tr></thead><tbody>
                        </HeaderTemplate>
                        <ItemTemplate>
                            <tr>
                                <td><div class="foto-thumb"><img src='<%# ResolverUrlFoto(Eval("foto_ruta"), Eval("foto_id")) %>'
                                    alt="Foto <%# Eval("foto_id") %>"
                                    onerror="this.onerror=null;this.src='ImagenProductoFallback.ashx?id=<%# Eval("foto_id") %>';" /></div></td>
                                <td><div class="prod-name-cell"><i class="fa-solid fa-box" style="color:var(--accent);font-size:.85rem;"></i>
                                    <div><%# Eval("pro_nombre") %><span class="sub">ID: <%# Eval("pro_id") %></span></div></div></td>
                                <td style="color:#888;font-size:.8rem;">#<%# Eval("foto_id") %></td>
                                <td><span class='badge <%# (char)Eval("foto_estado") == 'A' ? "badge-activo" : "badge-inactivo" %>'><%# (char)Eval("foto_estado") == 'A' ? "Activa" : "Inactiva" %></span></td>
                                <td style="font-size:.8rem;color:#888;"><%# Eval("fecha_subida", "{0:dd/MM/yyyy HH:mm}") %></td>
                                <td><div class="row-actions">
                                    <asp:LinkButton runat="server"
                                        CommandName='<%# Eval("foto_estado").ToString() == "A" ? "Desactivar" : "Reactivar" %>'
                                        CommandArgument='<%# Eval("foto_id") %>'
                                        CssClass='<%# "btn btn-sm " + (Eval("foto_estado").ToString() == "A" ? "btn-secondary" : "btn-success") %>'
                                        OnClientClick='<%# Eval("foto_estado").ToString() == "A" ? "return confirm(\"Desactivar esta foto?\");" : "return confirm(\"Reactivar esta foto?\");" %>'>
                                        <%# (char)Eval("foto_estado") == 'A' ? "Desactivar" : "Reactivar" %>
                                    </asp:LinkButton>
                                    <asp:LinkButton runat="server" CommandName="ElimFis"
                                        CommandArgument='<%# Eval("foto_id") %>'
                                        CssClass="btn btn-danger btn-sm"
                                        OnClientClick="return confirm('Eliminar esta foto permanentemente?');">Eliminar</asp:LinkButton>
                                </div></td>
                            </tr>
                        </ItemTemplate>
                        <FooterTemplate></tbody></table></FooterTemplate>
                    </asp:Repeater>
                </div>
                <asp:Literal ID="litSinFotos" runat="server" />
                
                <%-- Paginación manual para el Repeater --%>
                <div class="paginacion-container" id="divPaginacion" runat="server" style="display:flex;align-items:center;justify-content:center;gap:12px;margin-top:14px;">
                    <asp:LinkButton ID="btnPaginaPrev" runat="server" CssClass="btn btn-secondary btn-sm" OnClick="btnPaginaPrev_Click">
                        <i class="fa-solid fa-chevron-left"></i> Anterior
                    </asp:LinkButton>
                    <span style="font-size:.85rem;font-weight:600;color:var(--accent2);">
                        Página <asp:Label ID="lblPaginaActual" runat="server" Text="1" /> de <asp:Label ID="lblTotalPaginas" runat="server" Text="1" />
                    </span>
                    <asp:LinkButton ID="btnPaginaNext" runat="server" CssClass="btn btn-secondary btn-sm" OnClick="btnPaginaNext_Click">
                        Siguiente <i class="fa-solid fa-chevron-right"></i>
                    </asp:LinkButton>
                </div>
            </div>
        </ContentTemplate>
        <Triggers>
            <asp:AsyncPostBackTrigger ControlID="ddlFiltroProducto" EventName="SelectedIndexChanged" />
            <asp:AsyncPostBackTrigger ControlID="ddlFiltroEstado"   EventName="SelectedIndexChanged" />
            <asp:AsyncPostBackTrigger ControlID="btnLimpiarFiltros" EventName="Click" />
            <asp:AsyncPostBackTrigger ControlID="txtBuscar"         EventName="TextChanged" />
            <asp:AsyncPostBackTrigger ControlID="txtFechaDesde"     EventName="TextChanged" />
            <asp:AsyncPostBackTrigger ControlID="txtFechaHasta"     EventName="TextChanged" />
        </Triggers>
    </asp:UpdatePanel>

    <script>
    (function () {
        'use strict';

        function init() {

        // ── Productos desde servidor
        var productos = [];
        try {
            var raw = document.getElementById('<%= hfProductosJson.ClientID %>').value;
            if (raw) productos = JSON.parse(raw);
        } catch (e) {}

        var HANDLER_URL = 'GuardarFotosSlots.ashx';
        var slots = [];   // [{id, selectedValue, selectedText, files:[{id,name,dataUrl,file}], saved}]
        var slotIdCounter = 0;
        var photoIdCounter = 0;
        var track = document.getElementById('slotsTrack');
        var rutasClientTrack = document.getElementById('rutasTrackClient');
        var btnGuardarTodo = document.getElementById('btnGuardarTodo');
        var globalProgress = document.getElementById('globalProgress');
        var slotsCounter = document.getElementById('slotsCounter');
        var hfRoutes = document.getElementById('<%= hfAccumulatedRoutes.ClientID %>');

        if (!track || !btnGuardarTodo) { return; } // DOM not ready or controls missing

        // Close dropdowns when clicking outside
        document.addEventListener('click', function (e) {
            if (!e.target.closest('.custom-ddl-wrap')) {
                document.querySelectorAll('.custom-ddl-wrap.open').forEach(function (w) {
                    w.classList.remove('open');
                });
            }
        });

        // ── Update global save button state
        function updateSaveBtn() {
            var anyReady = slots.some(function (s) { return s.selectedValue && s.files.length > 0 && !s.saved; });
            btnGuardarTodo.disabled = !anyReady;
            var total = slots.length;
            slotsCounter.textContent = total + ' slot' + (total !== 1 ? 's' : '') + ' activo' + (total !== 1 ? 's' : '');
        }

        // ── Add a new slot
        function addSlot() {
            var slot = { id: ++slotIdCounter, selectedValue: '', selectedText: '-- Seleccione --', files: [], saved: false };
            slots.push(slot);
            renderTrack();
            setTimeout(function () { track.scrollLeft = track.scrollWidth; }, 60);
            updateSaveBtn();
        }

        // ── Remove a slot
        function removeSlot(slotId) {
            slots = slots.filter(function (s) { return s.id !== slotId; });
            renderTrack();
            updateSaveBtn();
        }

        // ── Clear photos in a slot
        function clearSlotFiles(slotId) {
            var slot = slots.find(function (s) { return s.id === slotId; });
            if (!slot) return;
            slot.files = [];
            slot.saved = false;
            refreshCarousel(slotId);
            var st = document.getElementById('slotStatus_' + slotId);
            if (st) { st.textContent = ''; st.className = 'slot-status'; }
        }

        // ── Remove one photo from a slot
        function removePhoto(slotId, photoId) {
            var slot = slots.find(function (s) { return s.id === slotId; });
            if (!slot) return;
            slot.files = slot.files.filter(function (f) { return f.id !== photoId; });
            refreshCarousel(slotId);
        }

        // ── Render all slot cards
        function renderTrack() {
            track.innerHTML = '';
            slots.forEach(function (slot) { track.appendChild(buildCard(slot)); });
            // (+) button at end
            var addBtn = document.createElement('div');
            addBtn.className = 'add-slot-btn';
            addBtn.title = 'Agregar otro producto';
            addBtn.innerHTML = '<i class="fa-solid fa-plus"></i>';
            addBtn.addEventListener('click', addSlot);
            track.appendChild(addBtn);
        }

        // ── Build a slot card DOM element
        function buildCard(slot) {
            var card = document.createElement('div');
            var cls = 'slot-card';
            if (slot.selectedValue) cls += ' has-product';
            if (slot.files.length > 0) cls += ' has-files';
            if (slot.saved) cls += ' saved-ok';
            card.className = cls;
            card.id = 'slotCard_' + slot.id;

            // Badge
            var slotNum = slots.findIndex(function (s) { return s.id === slot.id; }) + 1;
            var badge = document.createElement('div');
            badge.innerHTML = '<span class="slot-num-badge">Slot ' + slotNum + '</span>';
            card.appendChild(badge);

            // Custom dropdown
            card.appendChild(buildDdl(slot));

            // Upload zone
            card.appendChild(buildUploadZone(slot));

            // Product label
            var prodLabel = document.createElement('div');
            prodLabel.className = 'slot-product-label';
            prodLabel.id = 'prodLabel_' + slot.id;
            if (slot.selectedValue) {
                prodLabel.innerHTML = '<i class="fa-solid fa-box" style="color:var(--accent)"></i> ' + esc(slot.selectedText);
            }
            card.appendChild(prodLabel);

            // Carousel
            var carousel = document.createElement('div');
            carousel.className = 'slot-carousel';
            carousel.id = 'carousel_' + slot.id;
            fillCarousel(slot, carousel);
            card.appendChild(carousel);

            // Status
            var status = document.createElement('div');
            status.className = 'slot-status' + (slot.saved ? ' ok' : '');
            status.id = 'slotStatus_' + slot.id;
            status.textContent = slot.saved ? '✓ Guardado en servidor' : '';
            card.appendChild(status);

            // Actions
            var actions = document.createElement('div');
            actions.className = 'slot-actions';

            var clearBtn = document.createElement('button');
            clearBtn.type = 'button';
            clearBtn.className = 'slot-clear-btn';
            clearBtn.innerHTML = '<i class="fa-solid fa-trash"></i> Borrar fotos';
            clearBtn.addEventListener('click', (function (s) { return function () { clearSlotFiles(s.id); }; })(slot));
            actions.appendChild(clearBtn);

            var removeBtn = document.createElement('button');
            removeBtn.type = 'button';
            removeBtn.className = 'slot-remove-btn';
            removeBtn.innerHTML = '<i class="fa-solid fa-xmark"></i>';
            removeBtn.title = 'Eliminar este slot';
            removeBtn.addEventListener('click', (function (s) { return function () { removeSlot(s.id); }; })(slot));
            actions.appendChild(removeBtn);

            card.appendChild(actions);
            return card;
        }

        // ── Build custom dropdown
        function buildDdl(slot) {
            var wrap = document.createElement('div');
            wrap.className = 'custom-ddl-wrap';
            wrap.id = 'ddlWrap_' + slot.id;

            var trigger = document.createElement('button');
            trigger.type = 'button';
            trigger.className = 'custom-ddl-trigger';
            trigger.id = 'ddlTrigger_' + slot.id;
            trigger.innerHTML = '<span class="ddl-label">' + esc(slot.selectedText) + '</span><i class="fa-solid fa-chevron-down ddl-arrow"></i>';
            trigger.addEventListener('click', function (e) {
                e.stopPropagation();
                var isOpen = wrap.classList.contains('open');
                document.querySelectorAll('.custom-ddl-wrap.open').forEach(function (w) { w.classList.remove('open'); });
                if (!isOpen) {
                    wrap.classList.add('open');
                    var si = wrap.querySelector('.custom-ddl-search');
                    if (si) { si.value = ''; si.focus(); filterDdl(slot.id, ''); }
                }
            });
            wrap.appendChild(trigger);

            var panel = document.createElement('div');
            panel.className = 'custom-ddl-panel';
            panel.id = 'ddlPanel_' + slot.id;

            var search = document.createElement('input');
            search.type = 'text';
            search.className = 'custom-ddl-search';
            search.placeholder = 'Buscar producto...';
            search.addEventListener('input', function () { filterDdl(slot.id, this.value); });
            search.addEventListener('click', function (e) { e.stopPropagation(); });
            panel.appendChild(search);

            var list = document.createElement('div');
            list.className = 'custom-ddl-list';
            list.id = 'ddlList_' + slot.id;
            panel.appendChild(list);
            wrap.appendChild(panel);

            fillDdlList(slot, list);
            return wrap;
        }

        function fillDdlList(slot, list, filter) {
            list.innerHTML = '';
            var placeholder = document.createElement('div');
            placeholder.className = 'custom-ddl-option placeholder-opt';
            placeholder.textContent = '-- Seleccione un producto --';
            placeholder.addEventListener('click', function () {
                selectProduct(slot.id, '', '-- Seleccione --');
                var wrap = document.getElementById('ddlWrap_' + slot.id);
                if (wrap) wrap.classList.remove('open');
            });
            list.appendChild(placeholder);

            var f = (filter || '').toLowerCase();
            var found = 0;
            productos.forEach(function (p) {
                var label = p.nombre + ' (ID: ' + p.id + ')';
                if (f && label.toLowerCase().indexOf(f) === -1) return;
                found++;
                var opt = document.createElement('div');
                opt.className = 'custom-ddl-option' + (p.id.toString() === slot.selectedValue ? ' selected' : '');
                opt.textContent = label;
                opt.addEventListener('click', function (e) {
                    e.stopPropagation();
                    selectProduct(slot.id, p.id.toString(), label);
                    var wrap = document.getElementById('ddlWrap_' + slot.id);
                    if (wrap) wrap.classList.remove('open');
                });
                list.appendChild(opt);
            });
            if (found === 0 && f) {
                var none = document.createElement('div');
                none.className = 'custom-ddl-option placeholder-opt';
                none.textContent = 'Sin resultados para "' + filter + '"';
                list.appendChild(none);
            }
        }

        function filterDdl(slotId, term) {
            var slot = slots.find(function (s) { return s.id === slotId; });
            if (!slot) return;
            var list = document.getElementById('ddlList_' + slotId);
            if (list) fillDdlList(slot, list, term);
        }

        function selectProduct(slotId, value, text) {
            var slot = slots.find(function (s) { return s.id === slotId; });
            if (!slot) return;
            slot.selectedValue = value;
            slot.selectedText = text;
            slot.saved = false;
            // Update trigger label
            var trig = document.getElementById('ddlTrigger_' + slotId);
            if (trig) trig.querySelector('.ddl-label').textContent = text;
            // Update product label
            var pl = document.getElementById('prodLabel_' + slotId);
            if (pl) {
                if (value) pl.innerHTML = '<i class="fa-solid fa-box" style="color:var(--accent)"></i> ' + esc(text);
                else pl.innerHTML = '';
            }
            updateCardClass(slot);
            updateSaveBtn();
        }

        // ── Build upload zone
        function buildUploadZone(slot) {
            var zone = document.createElement('div');
            zone.className = 'slot-upload-zone';
            zone.innerHTML = '<div class="uz-icon"><i class="fa-solid fa-cloud-arrow-up"></i></div>' +
                '<p>Arrastra fotos aquí</p><p style="font-size:.65rem;opacity:.7;">JPG / PNG · max 2 MB</p>';

            var input = document.createElement('input');
            input.type = 'file';
            input.multiple = true;
            input.accept = 'image/jpeg,image/png';
            input.addEventListener('change', function () { handleFiles(slot.id, this.files); this.value = ''; });
            zone.appendChild(input);

            zone.addEventListener('dragover', function (e) { e.preventDefault(); zone.classList.add('drag-over'); });
            zone.addEventListener('dragleave', function () { zone.classList.remove('drag-over'); });
            zone.addEventListener('drop', function (e) {
                e.preventDefault(); zone.classList.remove('drag-over');
                handleFiles(slot.id, e.dataTransfer.files);
            });
            return zone;
        }

        // ── Handle file selection
        function handleFiles(slotId, fileList) {
            var slot = slots.find(function (s) { return s.id === slotId; });
            if (!slot) return;
            Array.prototype.forEach.call(fileList, function (file) {
                if (!file.type.match(/^image\/(jpeg|png)$/)) return;
                if (file.size > 2 * 1024 * 1024) { Swal.fire({ icon: 'warning', title: 'Archivo grande', text: file.name + ' supera 2 MB y fue omitido.' }); return; }
                var fid = ++photoIdCounter;
                var reader = new FileReader();
                reader.onload = function (e) {
                    slot.files.push({ id: fid, name: file.name, dataUrl: e.target.result, file: file });
                    slot.saved = false;
                    refreshCarousel(slotId);
                };
                reader.readAsDataURL(file);
            });
        }

        // ── Fill carousel with photos
        function fillCarousel(slot, carousel) {
            carousel.innerHTML = '';
            if (slot.files.length === 0) {
                var empty = document.createElement('div');
                empty.className = 'slot-carousel-empty';
                empty.innerHTML = '<i class="fa-solid fa-camera-slash"></i> Sin fotos';
                carousel.appendChild(empty);
                return;
            }
            slot.files.forEach(function (f) {
                var photo = document.createElement('div');
                photo.className = 'carousel-photo';
                var img = document.createElement('img');
                img.src = f.dataUrl; img.alt = '';
                photo.appendChild(img);
                var rm = document.createElement('button');
                rm.className = 'photo-remove'; rm.type = 'button'; rm.title = 'Quitar';
                rm.innerHTML = '<i class="fa-solid fa-xmark"></i>';
                rm.addEventListener('click', (function (sid, fid) {
                    return function (e) { e.stopPropagation(); removePhoto(sid, fid); };
                })(slot.id, f.id));
                photo.appendChild(rm);
                carousel.appendChild(photo);
            });
        }

        function refreshCarousel(slotId) {
            var slot = slots.find(function (s) { return s.id === slotId; });
            if (!slot) return;
            var c = document.getElementById('carousel_' + slotId);
            if (c) fillCarousel(slot, c);
            updateCardClass(slot);
            updateSaveBtn();
        }

        function updateCardClass(slot) {
            var card = document.getElementById('slotCard_' + slot.id);
            if (!card) return;
            var cls = 'slot-card';
            if (slot.selectedValue) cls += ' has-product';
            if (slot.files.length > 0) cls += ' has-files';
            if (slot.saved) cls += ' saved-ok';
            card.className = cls;
        }

        // ── GUARDAR TODO: upload all pending slots
        function guardarTodo() {
            var pending = slots.filter(function (s) { return s.selectedValue && s.files.length > 0 && !s.saved; });
            if (pending.length === 0) return;

            btnGuardarTodo.disabled = true;
            globalProgress.style.display = 'inline';
            globalProgress.textContent = 'Subiendo ' + pending.length + ' slot(s)…';

            var promises = pending.map(function (slot) { return uploadSlot(slot); });

            Promise.all(promises).then(function (results) {
                var ok = results.filter(function (r) { return r.ok; }).length;
                var fail = results.filter(function (r) { return !r.ok; }).length;
                globalProgress.style.display = 'none';
                updateSaveBtn();

                // Collect all routes
                var allRoutes = [];
                results.forEach(function (r) { if (r.rutas) allRoutes = allRoutes.concat(r.rutas); });
                if (allRoutes.length > 0) {
                    appendRoutesToTrack(allRoutes);
                    var existing = [];
                    try { existing = JSON.parse(hfRoutes.value || '[]'); } catch (e) { existing = []; }
                    hfRoutes.value = JSON.stringify(existing.concat(allRoutes));
                }

                if (allRoutes.length > 0) {
                    globalProgress.style.display = 'inline';
                    globalProgress.textContent = 'Preparando archivo de descarga…';

                    fetch('GuardarFotosSlots.ashx?action=generar_excel', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify(allRoutes)
                    })
                    .then(function(r) { return r.json(); })
                    .then(function(data) {
                        globalProgress.style.display = 'none';
                        if (data.ok) {
                            // Mostrar botón de descarga en el cliente
                            var btnDescarga = document.getElementById('btnDescargarExcelRutasCliente');
                            if (btnDescarga) {
                                btnDescarga.style.display = 'inline-flex';
                            }
                            
                            // Actualizar etiqueta informativa
                            var infoText = document.getElementById('litRutasPreparadasInfoCliente');
                            if (infoText) {
                                var count = document.querySelectorAll('#rutasTrackClient .ruta-card').length;
                                infoText.textContent = "Rutas preparadas en servidor: " + count + ". Descarga el Excel, completa producto/estado si hace falta y luego usa la carga masiva.";
                            }

                            if (fail === 0) {
                                Swal.fire({ icon: 'success', title: '¡Listo!', text: ok + ' slot(s) guardados correctamente y Excel preparado para descargar.' });
                            } else {
                                Swal.fire({ icon: 'warning', title: 'Parcialmente completado', html: ok + ' slot(s) guardados.<br>' + fail + ' slot(s) con error (ver indicadores en cada tarjeta).' });
                            }
                        } else {
                            Swal.fire({ icon: 'error', title: 'Error al preparar Excel', text: data.error || 'Ocurrió un error en el servidor.' });
                        }
                    })
                    .catch(function(err) {
                        globalProgress.style.display = 'none';
                        Swal.fire({ icon: 'error', title: 'Error de red', text: 'No se pudo conectar con el servidor para preparar el Excel.' });
                    });
                } else {
                    if (fail > 0) {
                        Swal.fire({ icon: 'error', title: 'Error', text: 'No se pudo guardar ningún slot (ver tarjetas).' });
                    }
                }
            });
        };

        // ── Upload a single slot
        function uploadSlot(slot) {
            var card = document.getElementById('slotCard_' + slot.id);
            var statusEl = document.getElementById('slotStatus_' + slot.id);

            if (card) { card.classList.add('saving'); }
            if (statusEl) { statusEl.className = 'slot-status saving'; statusEl.textContent = 'Subiendo…'; }

            var fd = new FormData();
            fd.append('pro_id', slot.selectedValue);
            slot.files.forEach(function (f, i) { fd.append('foto_' + i, f.file, f.name); });

            return fetch(HANDLER_URL, { method: 'POST', body: fd })
                .then(function (resp) { return resp.json(); })
                .then(function (data) {
                    if (card) { card.classList.remove('saving'); }
                    if (data.ok) {
                        slot.saved = true;
                        if (card) card.classList.add('saved-ok');
                        if (statusEl) { statusEl.className = 'slot-status ok'; statusEl.textContent = '✓ Guardado en servidor'; }
                        return { ok: true, rutas: data.rutas };
                    } else {
                        if (statusEl) { statusEl.className = 'slot-status err'; statusEl.textContent = '✗ ' + (data.error || 'Error'); }
                        return { ok: false, rutas: null };
                    }
                })
                .catch(function (err) {
                    if (card) card.classList.remove('saving');
                    if (statusEl) { statusEl.className = 'slot-status err'; statusEl.textContent = '✗ Error de red'; }
                    return { ok: false, rutas: null };
                });
        }

        // ── Append route cards to the client track (horizontal scroll)
        function appendRoutesToTrack(rutas) {
            rutas.forEach(function (r) {
                var c = document.createElement('div');
                c.className = 'ruta-card';
                c.innerHTML = '<strong>' + esc(r.nombreArchivo) + '</strong><span>' + esc(r.rutaRelativa) + '</span>';
                rutasClientTrack.appendChild(c);
            });
        }

        // ── Filtros toggle
        function toggleFiltros() {
            var panel = document.getElementById('filtrosPanel');
            var arrow = document.getElementById('arrowFilt');
            if (!panel) return;
            var open = !panel.classList.contains('closed');
            if (open) {
                panel.classList.add('closed');
                if (arrow) arrow.innerHTML = '<i class="fa-solid fa-chevron-down"></i>';
            } else {
                panel.classList.remove('closed');
                if (arrow) arrow.innerHTML = '<i class="fa-solid fa-chevron-up"></i>';
            }
        };

        // Restore filtros state
        (function () {
            var hf = document.getElementById('<%= hfFiltrosAbiertos.ClientID %>');
            if (hf && hf.value === '0') {
                var panel = document.getElementById('filtrosPanel');
                if (panel) panel.classList.add('closed');
            }
        })();

        // ── HTML escape helper
        function esc(s) {
            if (!s) return '';
            return String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
        }

        // Subida automática de archivo de carga masiva
        var fuCarga = document.getElementById('<%= fuCargaMasiva.ClientID %>');
        if (fuCarga) {
            fuCarga.addEventListener('change', function() {
                if (fuCarga.files.length === 0) return;
                var file = fuCarga.files[0];
                var fd = new FormData();
                fd.append('excel_file', file);

                Swal.fire({
                    title: 'Subiendo archivo...',
                    html: 'Espere un momento por favor.',
                    allowOutsideClick: false,
                    didOpen: () => { Swal.showLoading(); }
                });

                fetch('GuardarFotosSlots.ashx?action=subir_excel_carga', {
                    method: 'POST',
                    body: fd
                })
                .then(function(r) { return r.json(); })
                .then(function(data) {
                    Swal.close();
                    if (data.ok) {
                        Swal.fire({ icon: 'success', title: '¡Archivo subido!', text: 'El archivo ' + data.fileName + ' se cargo correctamente en el servidor.' });
                        var lbl = document.getElementById('litArchivoCargaCliente');
                        if (lbl) lbl.textContent = "Archivo listo: " + data.fileName;
                    } else {
                        Swal.fire({ icon: 'error', title: 'Error', text: data.error });
                        fuCarga.value = '';
                    }
                })
                .catch(function() {
                    Swal.close();
                    Swal.fire({ icon: 'error', title: 'Error de red', text: 'No se pudo subir el archivo al servidor.' });
                    fuCarga.value = '';
                });
            });
        }

        // ── Init: add first slot and expose addSlot globally
        window.addSlot = addSlot;
        window.guardarTodo = guardarTodo;
        window.toggleFiltros = toggleFiltros;
        addSlot(); // slot inicial por defecto

        } // end init()

        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', init);
        } else {
            init();
        }

    })();
    </script>
</asp:Content>