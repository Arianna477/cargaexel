<%@ Page Title="Administrar Fotos de Productos" Language="C#" MasterPageFile="~/Site1.Master"
    AutoEventWireup="true" CodeBehind="FotosProductosGeneral.aspx.cs"
    Inherits="Monolito4bm.FotosProductosGeneral" %>

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

        .page-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 24px;
            flex-wrap: wrap;
            gap: 12px;
        }

        .page-title {
            font-size: 1.5rem;
            font-weight: 700;
            color: var(--accent2);
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .back-link {
            display: inline-flex;
            align-items: center;
            gap: 7px;
            color: var(--accent);
            font-weight: 700;
            font-size: .88rem;
            text-decoration: none;
            padding: 8px 18px;
            border-radius: 30px;
            border: 1.5px solid rgba(219,39,119,.3);
            transition: all .2s;
        }

        .back-link:hover {
            background: rgba(219,39,119,0.1);
            transform: translateX(-2px);
        }

        .card {
            background: rgba(255,255,255,.76);
            backdrop-filter: blur(12px);
            border: 1px solid rgba(244,143,177,0.4);
            border-radius: 18px;
            padding: 22px 26px;
            box-shadow: 0 4px 24px rgba(190,24,93,0.10);
            margin-bottom: 22px;
        }

        .card-title {
            font-size: .98rem;
            font-weight: 700;
            color: var(--accent2);
            margin-bottom: 14px;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .guide-list {
            margin: 0 0 16px 18px;
            color: rgba(60,30,90,.78);
            font-size: .88rem;
        }

        .guide-list li { margin-bottom: 6px; }

        .form-control {
            background: rgba(255,255,255,.82);
            border: 1px solid rgba(180,150,220,.4);
            color: #2c1a4a;
            padding: 10px 14px;
            border-radius: 10px;
            width: 100%;
            font-size: .88rem;
            box-shadow: inset 0 1px 3px rgba(0,0,0,.05);
        }

        .form-label {
            font-weight: 700;
            color: var(--accent2);
            display: block;
            margin-bottom: 6px;
            font-size: .86rem;
        }

        .btn {
            padding: 9px 18px;
            border-radius: 30px;
            border: none;
            cursor: pointer;
            font-size: .85rem;
            font-weight: 700;
            display: inline-flex;
            align-items: center;
            gap: 7px;
            text-decoration: none;
        }

        .btn-primary { background: var(--accent); color: #fff; }
        .btn-secondary { background: rgba(122,74,170,.12); color: var(--accent2); border: 1px solid rgba(122,74,170,.3); }
        .btn-success { background: var(--success); color: #fff; }
        .btn-danger { background: var(--danger); color: #fff; }
        .btn-sm { padding: 6px 12px; font-size: .76rem; border-radius: 20px; }

        .alert {
            padding: 11px 16px;
            border-radius: 12px;
            margin-bottom: 14px;
            font-size: .86rem;
            font-weight: 600;
        }

        .alert-success { background: rgba(39,174,96,.15); color: #1e8449; border: 1px solid rgba(39,174,96,.3); }
        .alert-danger { background: rgba(192,57,43,.12); color: #c0392b; border: 1px solid rgba(192,57,43,.25); }

        .upload-box {
            border: 2px dashed rgba(122,74,170,.32);
            border-radius: 14px;
            padding: 18px;
            background: rgba(122,74,170,.03);
        }

        .preview-strip {
            display: flex;
            flex-wrap: wrap;
            gap: 12px;
            margin-top: 14px;
        }

        .preview-card {
            width: 130px;
            border-radius: 12px;
            overflow: hidden;
            background: rgba(122,74,170,.04);
            border: 1px solid rgba(122,74,170,.18);
        }

        .preview-card img {
            width: 100%;
            height: 90px;
            object-fit: cover;
            display: block;
        }

        .preview-meta {
            padding: 8px;
            font-size: .75rem;
            color: #5b476f;
            word-break: break-word;
        }

        .steps-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
            gap: 14px;
        }

        .step-panel {
            padding: 14px;
            border-radius: 14px;
            background: rgba(122,74,170,.05);
            border: 1px solid rgba(122,74,170,.14);
        }

        .step-panel strong {
            display: block;
            color: var(--accent2);
            margin-bottom: 6px;
        }

        .preview-shell {
            overflow-x: auto;
            border-radius: 12px;
            border: 1px solid rgba(180,150,220,.22);
        }

        .preview-grid {
            width: 100%;
            border-collapse: collapse;
        }

        .preview-grid th,
        .preview-grid td {
            padding: 10px 12px;
            border-bottom: 1px solid rgba(180,150,220,.18);
            font-size: .83rem;
        }

        .preview-grid th {
            background: linear-gradient(90deg,var(--accent),var(--accent2));
            color: #fff;
            text-align: left;
        }

        .empty-preview,
        .empty-state {
            text-align: center;
            padding: 26px 18px;
            color: rgba(60,30,90,.45);
            font-size: .9rem;
        }

        .search-bar {
            display: flex;
            align-items: center;
            gap: 10px;
            background: rgba(255,255,255,.9);
            border: 1.5px solid rgba(219,39,119,0.28);
            border-radius: 40px;
            padding: 9px 18px;
            margin-bottom: 14px;
        }

        .search-bar input {
            border: none;
            background: transparent;
            flex: 1;
            outline: none;
            color: var(--accent2);
            font-family: inherit;
            font-size: .95rem;
        }

        .filtros-toggle {
            background: none;
            border: none;
            cursor: pointer;
            font-size: .83rem;
            font-weight: 700;
            color: var(--accent);
            display: flex;
            align-items: center;
            gap: 6px;
            padding: 4px 0;
            margin-bottom: 10px;
        }

        .filtros-panel {
            display: flex;
            gap: 14px;
            flex-wrap: wrap;
            padding: 16px;
            background: rgba(122,74,170,.04);
            border-radius: 14px;
            border: 1px solid rgba(122,74,170,.14);
            margin-bottom: 14px;
        }

        .filtros-panel.closed { display: none; }

        .fg {
            display: flex;
            flex-direction: column;
            gap: 5px;
            min-width: 150px;
            flex: 1;
        }

        .fotos-table {
            width: 100%;
            border-collapse: collapse;
            font-size: .87rem;
        }

        .fotos-table thead tr {
            background: linear-gradient(90deg,var(--accent),var(--accent2));
            color: #fff;
        }

        .fotos-table th,
        .fotos-table td {
            padding: 11px 14px;
            text-align: left;
            border-bottom: 1px solid rgba(180,150,220,.18);
            vertical-align: middle;
        }

        .foto-thumb {
            width: 64px;
            height: 64px;
            border-radius: 8px;
            overflow: hidden;
            border: 2px solid rgba(180,150,220,.35);
            background: rgba(122,74,170,.06);
        }

        .foto-thumb img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            display: block;
        }

        .prod-name-cell {
            font-weight: 600;
            color: var(--accent2);
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .prod-name-cell span.sub {
            font-size: .74rem;
            font-weight: 400;
            color: #888;
            display: block;
        }

        .badge {
            display: inline-block;
            padding: 3px 10px;
            border-radius: 20px;
            font-size: .72rem;
            font-weight: 700;
        }

        .badge-activo { background: rgba(39,174,96,.15); color: #1e8449; }
        .badge-inactivo { background: rgba(192,57,43,.12); color: #c0392b; }
        .row-actions { display: flex; gap: 7px; flex-wrap: wrap; }

        @media(max-width: 700px) {
            .card { padding: 16px 14px; }
            .fotos-table thead { display: none; }
            .fotos-table tbody tr {
                display: flex;
                flex-wrap: wrap;
                padding: 12px;
                gap: 8px;
                border-radius: 12px;
                margin-bottom: 10px;
                border: 1px solid rgba(180,150,220,.3);
            }
            .fotos-table td { padding: 2px 4px; }
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

    <div class="card">
        <div class="card-title">
            <i class="fa-solid fa-list-check"></i> Flujo recomendado de carga masiva
        </div>
        <ol class="guide-list">
            <li>Sube varias imagenes JPG o PNG y revisa la previsualizacion sin usar JavaScript.</li>
            <li>Guarda esas imagenes en el servidor para generar un Excel con las rutas listas.</li>
            <li>Completa en ese Excel el <code>pro_id</code> y, si quieres, el estado de cada foto.</li>
            <li>Vuelve a cargar el Excel para insertar o actualizar las fotos en la tabla <code>tbl_pro_fotos</code>.</li>
        </ol>

        <div class="steps-grid">
            <div class="step-panel">
                <strong>Paso 1. Selecciona imagenes</strong>
                <div class="upload-box">
                    <label class="form-label" for="<%= fuFotos.ClientID %>">Lista de fotos a subir</label>
                    <asp:FileUpload ID="fuFotos" runat="server" CssClass="form-control" AllowMultiple="true" />
                    <div style="font-size:.78rem;color:#6b5b82;margin-top:8px;">
                        Seguridad: solo se aceptan archivos <code>.jpg</code>, <code>.jpeg</code> y <code>.png</code>, maximo 2 MB por imagen.
                    </div>
                </div>
                <div class="upload-box" style="margin-top: 10px;">
                    <label class="form-label" for="<%= ddlProductoCarga.ClientID %>">Seleccione el Producto *</label>
                    <asp:DropDownList ID="ddlProductoCarga" runat="server" CssClass="form-control" />
                </div>
                <div style="display:flex;gap:10px;flex-wrap:wrap;margin-top:14px;">
                    <asp:Button ID="btnPrevisualizar" runat="server" CssClass="btn btn-secondary"
                        Text="1. Previsualizar fotos" OnClick="btnPrevisualizar_Click" />
                    <asp:Button ID="btnPrepararExcelRutas" runat="server" CssClass="btn btn-primary"
                        Text="2. Guardar en servidor y generar Excel" OnClick="btnPrepararExcelRutas_Click" />
                </div>
            </div>

            <div class="step-panel">
                <strong>Paso 2. Resultado de rutas preparadas</strong>
                <asp:Literal ID="litRutasPreparadasInfo" runat="server" Text="Aun no hay rutas preparadas en servidor." />
                <div style="display:flex;gap:10px;flex-wrap:wrap;margin-top:12px;">
                    <asp:Button ID="btnDescargarRutasPreparadas" runat="server" CssClass="btn btn-success"
                        Text="3. Descargar Excel con rutas" OnClick="btnDescargarRutasPreparadas_Click" Visible="false" />
                    <asp:Button ID="btnDescargarFormato" runat="server" CssClass="btn btn-secondary"
                        Text="Descargar plantilla base" OnClick="btnDescargarFormato_Click" />
                </div>
                <div class="preview-strip">
                    <asp:Repeater ID="rptRutasPreparadas" runat="server">
                        <ItemTemplate>
                            <div class="preview-card" style="width:230px;">
                                <div class="preview-meta">
                                    <strong style="display:block;color:var(--accent2);margin-bottom:4px;"><%# Eval("NombreArchivo") %></strong>
                                    <span><%# Eval("RutaRelativa") %></span>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </div>
        </div>

        <div class="preview-strip">
            <asp:Repeater ID="rptFotosPreview" runat="server" OnItemCommand="rptFotosPreview_ItemCommand">
                <ItemTemplate>
                    <div class="preview-card">
                        <img src='<%# Eval("PreviewUrl") %>' alt="Preview" />
                        <div class="preview-meta">
                            <strong style="display:block;margin-bottom:6px;"><%# Eval("NombreArchivo") %></strong>
                            <asp:LinkButton runat="server" CommandName="Eliminar" CommandArgument='<%# Eval("Id") %>'
                                CssClass="btn btn-danger btn-sm" OnClientClick="return confirm('Quitar esta foto de la previsualizacion?');">
                                Quitar
                            </asp:LinkButton>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>
        <div style="font-size:.82rem;color:#6b5b82;margin-top:8px;font-weight:600;">
            <asp:Literal ID="lblFotosPreviewInfo" runat="server" />
        </div>
    </div>

    <div class="card">
        <div class="card-title">
            <i class="fa-solid fa-file-excel" style="color:var(--success)"></i> Carga masiva por Excel
        </div>
        <div class="steps-grid">
            <div>
                <label class="form-label" for="<%= fuCargaMasiva.ClientID %>">Archivo Excel o CSV</label>
                <asp:FileUpload ID="fuCargaMasiva" runat="server" CssClass="form-control" />
                <div style="font-size:.78rem;color:#6b5b82;margin-top:8px;">
                    Encabezados esperados: <code>foto_id</code>, <code>pro_id</code>, <code>foto_ruta</code> o <code>foto_bit</code>, <code>estado</code>.
                </div>
                <div style="display:flex;gap:10px;flex-wrap:wrap;margin-top:14px;">
                    <asp:Button ID="btnPrevisualizarCarga" runat="server" CssClass="btn btn-secondary"
                        Text="Visualizar archivo" OnClick="btnPrevisualizarCarga_Click" />
                    <asp:Button ID="btnLimpiarCarga" runat="server" CssClass="btn btn-secondary"
                        Text="Limpiar carga" OnClick="btnLimpiarCarga_Click" />
                </div>
                <div style="margin-top:12px;font-size:.8rem;color:#6b5b82;">
                    <asp:Literal ID="litArchivoCarga" runat="server" Text="Sin archivo cargado." />
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
                <div style="font-size:.78rem;color:#6b5b82;margin-top:8px;">
                    En este modulo puedes cargar por <code>foto_ruta</code> o por <code>foto_bit</code> en base64. Si llega <code>foto_bit</code>, se guarda el binario; si llega <code>foto_ruta</code>, el binario queda en <code>null</code>.
                </div>
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
                        <asp:TemplateField>
                            <HeaderTemplate><i class="fa-solid fa-list-ol"></i> FILA</HeaderTemplate>
                            <ItemTemplate><%# Eval("NumeroFilaArchivo") %></ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField>
                            <HeaderTemplate><i class="fa-solid fa-hashtag"></i> ID FOTO</HeaderTemplate>
                            <ItemTemplate><%# Eval("FotoIdTexto") %></ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField>
                            <HeaderTemplate><i class="fa-solid fa-box"></i> PRO_ID</HeaderTemplate>
                            <ItemTemplate><%# Eval("ProductoId") %></ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField>
                            <HeaderTemplate><i class="fa-solid fa-image"></i> FOTO_RUTA</HeaderTemplate>
                            <ItemTemplate><%# Eval("RutaFoto") %></ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField>
                            <HeaderTemplate><i class="fa-solid fa-file-invoice"></i> ORIGEN</HeaderTemplate>
                            <ItemTemplate><%# Eval("OrigenFoto") %></ItemTemplate>
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

    <asp:HiddenField ID="hfAccionRutasFaltantes" runat="server" Value="" />

    <div class="card">
        <div class="search-bar">
            <span class="si"><i class="fa-solid fa-magnifying-glass"></i></span>
            <asp:TextBox ID="txtBuscar" runat="server" placeholder="Buscar foto por nombre de producto o ruta..."
                AutoPostBack="false" OnTextChanged="Filtros_Changed" />
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
                    OnClick="btnLimpiarFiltros_Click">
                    Limpiar
                </asp:LinkButton>
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
                            <table class="fotos-table">
                                <thead>
                                    <tr>
                                        <th style="width:76px;"><i class="fa-solid fa-image"></i> FOTO</th>
                                        <th><i class="fa-solid fa-box"></i> PRODUCTO</th>
                                        <th style="width:80px;"><i class="fa-solid fa-hashtag"></i> ID FOTO</th>
                                        <th style="width:90px;"><i class="fa-solid fa-toggle-on"></i> ESTADO</th>
                                        <th><i class="fa-solid fa-calendar-days"></i> FECHA SUBIDA</th>
                                        <th style="width:210px;"><i class="fa-solid fa-gears"></i> ACCIONES</th>
                                    </tr>
                                </thead>
                                <tbody>
                        </HeaderTemplate>
                        <ItemTemplate>
                            <tr>
                                <td>
                                    <div class="foto-thumb">
                                        <img src='<%# ResolverUrlFoto(Eval("foto_ruta"), Eval("foto_id")) %>'
                                            alt="Foto <%# Eval("foto_id") %>"
                                            onerror="this.onerror=null;this.src='ImagenProductoFallback.ashx?id=<%# Eval("foto_id") %>';" />
                                    </div>
                                </td>
                                <td>
                                    <div class="prod-name-cell">
                                        <i class="fa-solid fa-box" style="color:var(--accent);font-size:.85rem;"></i>
                                        <div>
                                            <%# Eval("pro_nombre") %>
                                            <span class="sub">ID prod.: <%# Eval("pro_id") %></span>
                                        </div>
                                    </div>
                                </td>
                                <td style="color:#888;font-size:.8rem;">#<%# Eval("foto_id") %></td>
                                <td>
                                    <span class='badge <%# (char)Eval("foto_estado") == 'A' ? "badge-activo" : "badge-inactivo" %>'>
                                        <%# (char)Eval("foto_estado") == 'A' ? "Activa" : "Inactiva" %>
                                    </span>
                                </td>
                                <td style="font-size:.8rem;color:#888;">
                                    <%# Eval("fecha_subida", "{0:dd/MM/yyyy HH:mm}") %>
                                </td>
                                <td>
                                    <div class="row-actions">
                                        <asp:LinkButton runat="server"
                                            CommandName='<%# Eval("foto_estado").ToString() == "A" ? "Desactivar" : "Reactivar" %>'
                                            CommandArgument='<%# Eval("foto_id") %>'
                                            CssClass='<%# "btn btn-sm " + (Eval("foto_estado").ToString() == "A" ? "btn-secondary" : "btn-success") %>'
                                            OnClientClick='<%# Eval("foto_estado").ToString() == "A" ? "return confirm(\"Desactivar esta foto?\");" : "return confirm(\"Reactivar esta foto?\");" %>'>
                                            <%# (char)Eval("foto_estado") == 'A' ? "Desactivar" : "Reactivar" %>
                                        </asp:LinkButton>

                                        <asp:LinkButton runat="server"
                                            CommandName="ElimFis"
                                            CommandArgument='<%# Eval("foto_id") %>'
                                            CssClass="btn btn-danger btn-sm"
                                            OnClientClick="return confirm('Eliminar esta foto permanentemente?');">
                                            Eliminar
                                        </asp:LinkButton>
                                    </div>
                                </td>
                            </tr>
                        </ItemTemplate>
                        <FooterTemplate>
                                </tbody>
                            </table>
                        </FooterTemplate>
                    </asp:Repeater>
                </div>

                <asp:Literal ID="litSinFotos" runat="server" />
            </div>

            <asp:HiddenField ID="hfFiltrosAbiertos" runat="server" Value="1" />
        </ContentTemplate>
        <Triggers>
            <asp:AsyncPostBackTrigger ControlID="ddlFiltroProducto" EventName="SelectedIndexChanged" />
            <asp:AsyncPostBackTrigger ControlID="ddlFiltroEstado" EventName="SelectedIndexChanged" />
            <asp:AsyncPostBackTrigger ControlID="btnLimpiarFiltros" EventName="Click" />
        </Triggers>
    </asp:UpdatePanel>

    <script>
        function toggleFiltros() {
            const panel = document.getElementById('filtrosPanel');
            const arrow = document.getElementById('arrowFilt');
            const hidden = document.getElementById('<%= hfFiltrosAbiertos.ClientID %>');
            if (!panel || !arrow || !hidden) return;
            const closed = panel.classList.toggle('closed');
            arrow.innerHTML = closed
                ? "<i class='fa-solid fa-chevron-down'></i>"
                : "<i class='fa-solid fa-chevron-up'></i>";
            hidden.value = closed ? "0" : "1";
        }

        document.addEventListener('DOMContentLoaded', function () {
            const hidden = document.getElementById('<%= hfFiltrosAbiertos.ClientID %>');
            if (hidden && hidden.value === "0") {
                const panel = document.getElementById('filtrosPanel');
                const arrow = document.getElementById('arrowFilt');
                if (panel) panel.classList.add('closed');
                if (arrow) arrow.innerHTML = "<i class='fa-solid fa-chevron-down'></i>";
            }
        });
    </script>
</asp:Content>
