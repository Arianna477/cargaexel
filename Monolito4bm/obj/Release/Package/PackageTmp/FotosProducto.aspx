<%@ Page Title="Fotos del Producto" Language="C#" MasterPageFile="~/Site1.Master"
         AutoEventWireup="true" CodeBehind="FotosProducto.aspx.cs"
         Inherits="Monolito4bm.FotosProducto" %>

<asp:Content ID="headContent" ContentPlaceHolderID="head" runat="server">
<%-- Font Awesome via CDN --%>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<link rel="stylesheet"
      href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css"
      crossorigin="anonymous"/>
<style>
:root {
  --accent:#7a4aaa; --accent2:#5a2a8a;
  --danger:#c0392b; --success:#27ae60; --warn:#e67e22;
}

/* ── Encabezado ─────────────────────────────────── */
.page-header {
  display:flex; align-items:center; justify-content:space-between;
  margin-bottom:24px; flex-wrap:wrap; gap:12px;
}
.page-title {
  font-size:1.5rem; font-weight:700; color:var(--accent2);
  display:flex; align-items:center; gap:10px;
}
.back-link {
  display:inline-flex; align-items:center; gap:7px;
  color:var(--accent); font-weight:700; font-size:.88rem;
  text-decoration:none; padding:8px 18px; border-radius:30px;
  border:1.5px solid rgba(122,74,170,0.3); transition:all .2s;
}
.back-link:hover { background:rgba(122,74,170,0.1); transform:translateX(-2px); }

/* Dropdown rosa */
.product-select-dropdown {
  background: rgba(255, 255, 255, 0.95);
  border: 1.5px solid #db2777; /* Rosa */
  color: #9d174d; /* Rosa oscuro */
  font-family: inherit;
  font-size: .92rem;
  font-weight: 700;
  padding: 8px 16px;
  border-radius: 30px;
  outline: none;
  cursor: pointer;
  box-shadow: 0 4px 12px rgba(219,39,119,0.12);
  transition: all .2s;
  max-width: 320px;
  display: inline-block;
}
.product-select-dropdown:hover {
  background: #fff;
  border-color: #9d174d;
  box-shadow: 0 4px 16px rgba(219,39,119,0.2);
}
.product-select-dropdown:focus {
  border-color: #9d174d;
  box-shadow: 0 0 0 3px rgba(219, 39, 119, 0.25);
}

/* ── Cards ──────────────────────────────────────── */
.card {
  background:rgba(255,255,255,0.72); backdrop-filter:blur(12px);
  border:1px solid rgba(180,150,220,0.4); border-radius:18px;
  padding:22px 26px; box-shadow:0 4px 24px rgba(120,80,180,0.10);
  margin-bottom:22px;
}
.card-title {
  font-size:.98rem; font-weight:700; color:var(--accent2);
  margin-bottom:16px; display:flex; align-items:center; gap:8px;
}

/* ── Upload zone ────────────────────────────────── */
.upload-zone {
  border:2.5px dashed rgba(122,74,170,0.4); border-radius:14px;
  padding:28px 20px; text-align:center; cursor:pointer;
  transition:all .25s; background:rgba(122,74,170,0.03);
  position:relative;
}
.upload-zone:hover, .upload-zone.drag-over {
  border-color:var(--accent); background:rgba(122,74,170,0.08);
}
.upload-zone .uz-icon { font-size:2.2rem; color:var(--accent); margin-bottom:8px; }
.upload-zone p { color:rgba(60,30,90,0.6); font-size:.88rem; margin:3px 0; }
.upload-zone strong { color:var(--accent2); }
.upload-zone input[type=file] {
  position:absolute; inset:0; opacity:0; cursor:pointer;
}

/* ── Preview mini ───────────────────────────────── */
.preview-strip {
  display:flex; flex-wrap:wrap; gap:12px; margin-top:14px;
}
.preview-card {
  width:130px; border-radius:12px; overflow:hidden;
  background:rgba(122,74,170,.04); border:1px solid rgba(122,74,170,.18);
}
.preview-card img {
  width:100%; height:90px; object-fit:cover; display:block;
}
.preview-meta {
  padding:8px; font-size:.75rem; color:#5b476f; word-break:break-word;
}

/* ── Botones generales ──────────────────────────── */
.btn {
  padding:9px 20px; border-radius:30px; border:none; cursor:pointer;
  font-family:inherit; font-size:.86rem; font-weight:700;
  display:inline-flex; align-items:center; gap:7px;
  transition:all .2s; white-space:nowrap; text-decoration:none;
}
.btn i { pointer-events:none; }
.btn-primary  { background:var(--accent); color:#fff; }
.btn-primary:hover  { background:var(--accent2); transform:translateY(-1px); box-shadow:0 4px 12px rgba(90,42,138,.25); }
.btn-secondary{ background:rgba(122,74,170,0.12); color:var(--accent2); border:1.5px solid rgba(122,74,170,0.3); }
.btn-secondary:hover{ background:rgba(122,74,170,0.22); }
.btn-danger   { background:var(--danger); color:#fff; }
.btn-danger:hover   { background:#a93226; transform:translateY(-1px); }
.btn-success  { background:var(--success); color:#fff; }
.btn-success:hover  { background:#1e8449; transform:translateY(-1px); }
.btn-sm { padding:5px 12px; font-size:.76rem; border-radius:20px; }

/* ── Alertas ────────────────────────────────────── */
.alert {
  padding:11px 16px; border-radius:12px; margin-bottom:14px;
  font-size:.86rem; font-weight:600;
  display:flex; align-items:center; gap:9px;
  animation:fadeIn .3s ease;
}
.alert-success { background:rgba(39,174,96,.15); color:#1e8449; border:1px solid rgba(39,174,96,.3); }
.alert-danger  { background:rgba(192,57,43,.12); color:#c0392b; border:1px solid rgba(192,57,43,.25); }
@keyframes fadeIn { from{opacity:0;transform:translateY(-4px)} to{opacity:1;transform:none} }

.limite-aviso {
  background:rgba(230,126,34,0.12); border:1px solid rgba(230,126,34,0.3);
  border-radius:10px; padding:10px 16px; font-size:.83rem;
  color:#7d4e00; font-weight:600; margin-bottom:14px;
  display:flex; align-items:center; gap:8px;
}

/* ══════════════════════════════════════════════════
   FOTOS LISTADO  –  tabla compacta con thumb pequeño
   ══════════════════════════════════════════════════ */
.fotos-table {
  width:100%; border-collapse:collapse; font-size:.87rem;
}
.fotos-table thead tr {
  background:linear-gradient(90deg,var(--accent),var(--accent2));
  color:#fff;
}
.fotos-table thead th {
  padding:11px 14px; text-align:left;
  font-size:.78rem; font-weight:700; letter-spacing:.4px;
  white-space:nowrap;
}
.fotos-table thead th:first-child { border-radius:12px 0 0 0; }
.fotos-table thead th:last-child  { border-radius:0 12px 0 0; }
.fotos-table tbody tr {
  border-bottom:1px solid rgba(180,150,220,0.2);
  transition:background .15s;
}
.fotos-table tbody tr:hover { background:rgba(122,74,170,0.05); }
.fotos-table tbody td { padding:10px 14px; vertical-align:middle; }

/* Thumb 64x64 */
.foto-thumb {
  width:64px; height:64px; border-radius:8px; overflow:hidden;
  border:2px solid rgba(180,150,220,0.35);
  background:rgba(122,74,170,0.06); flex-shrink:0;
}
.foto-thumb img { width:100%; height:100%; object-fit:cover; display:block; }
.foto-thumb-empty {
  width:64px; height:64px; border-radius:8px;
  background:rgba(122,74,170,0.06);
  display:flex; align-items:center; justify-content:center;
  color:rgba(122,74,170,0.3); font-size:1.5rem;
}

/* Nombre producto en tabla */
.prod-name-cell {
  font-weight:600; color:var(--accent2);
  display:flex; align-items:center; gap:8px;
}
.prod-name-cell span.sub {
  font-size:.74rem; font-weight:400; color:#aaa; display:block;
}

/* Badge estado foto */
.badge {
  display:inline-block; padding:3px 10px; border-radius:20px;
  font-size:.72rem; font-weight:700; letter-spacing:.3px;
}
.badge-activo   { background:rgba(39,174,96,.15);  color:#1e8449; }
.badge-inactivo { background:rgba(192,57,43,.12);   color:#c0392b; }

/* Acciones en fila */
.row-actions { display:flex; gap:7px; flex-wrap:wrap; }

/* Empty state */
.empty-state {
  text-align:center; padding:38px 20px;
  color:rgba(60,30,90,0.4); font-size:.93rem;
}
.empty-state i { font-size:2.8rem; display:block; margin-bottom:10px; color:rgba(122,74,170,0.22); }

@media(max-width:600px){
  .card { padding:14px 12px; }
  .fotos-table thead { display:none; }
  .fotos-table tbody tr {
    display:flex; flex-wrap:wrap; padding:12px; gap:8px;
    border-radius:12px; margin-bottom:10px;
    border:1px solid rgba(180,150,220,0.3);
  }
  .fotos-table tbody td { padding:2px 4px; }
}
</style>
</asp:Content>

<asp:Content ID="bodyContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

  <asp:HiddenField ID="hfProId" runat="server" Value="0"/>

  <!-- ══ Encabezado ══════════════════════════════════════════════ -->
  <div class="page-header">
    <div class="page-title">
      <i class="fa-solid fa-camera" style="color:var(--accent)"></i>
      Fotos &mdash;
      <span style="color:rgba(90,42,138,0.65);font-size:1.05rem;font-weight:500;display:inline-flex;align-items:center;">
        <asp:DropDownList ID="ddlProducto" runat="server" AutoPostBack="true"
                          OnSelectedIndexChanged="ddlProducto_SelectedIndexChanged"
                          CssClass="product-select-dropdown" style="margin-left: 10px;" />
      </span>
    </div>
    <a href="Productos.aspx" class="back-link">
      <i class="fa-solid fa-arrow-left"></i> Volver a Productos
    </a>
  </div>

  <!-- ══ Mensajes ════════════════════════════════════════════════ -->
  <asp:Literal ID="litMensaje" runat="server"/>
  <asp:Literal ID="litAviso"   runat="server"/>

  <!-- ══ Subir fotos ════════════════════════════════════════════ -->
  <div class="card">
    <div class="card-title">
      <i class="fa-solid fa-upload"></i> Subir fotos
      <span style="font-size:.76rem;color:#aaa;font-weight:400;margin-left:4px;">
        (max. 4 por producto &mdash; JPG o PNG &mdash; 2&nbsp;MB c/u)
      </span>
    </div>

    <div class="upload-zone" id="uploadZone">
      <div class="uz-icon"><i class="fa-solid fa-cloud-arrow-up"></i></div>
      <p><strong>Haz clic o arrastra</strong> las imágenes aquí</p>
      <p style="font-size:.78rem;">JPG, PNG hasta 2&nbsp;MB</p>
      <asp:FileUpload ID="fuFotos" runat="server"
                      AllowMultiple="true"
                      accept="image/jpeg,image/png" />
    </div>

    <div class="preview-strip">
      <asp:Repeater ID="rptFotosPreview" runat="server" OnItemCommand="rptFotosPreview_ItemCommand">
        <ItemTemplate>
          <div class="preview-card">
            <img src='<%# Eval("PreviewUrl") %>' alt="Preview" />
            <div class="preview-meta">
              <strong style="display:block;margin-bottom:6px;"><%# Eval("NombreArchivo") %></strong>
              <asp:LinkButton runat="server" CommandName="Eliminar" CommandArgument='<%# Eval("Id") %>'
                  CssClass="btn btn-danger btn-sm" OnClientClick="return confirm('¿Quitar esta foto de la previsualización?');">
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

    <div style="margin-top:16px;display:flex;gap:12px;flex-wrap:wrap;">
      <asp:Button ID="btnPrevisualizar" runat="server" CssClass="btn btn-secondary"
                  Text="Previsualizar fotos" OnClick="btnPrevisualizar_Click" style="display:none;" />
      <asp:Button ID="btnSubir" runat="server" CssClass="btn btn-primary"
                  Text="Subir fotos" OnClick="btnSubir_Click"/>
      <asp:Button ID="btnCancelar" runat="server" CssClass="btn btn-secondary"
                  Text="Volver" OnClick="btnCancelar_Click" CausesValidation="false"/>
    </div>
  </div>

  <!-- ══ Lista de fotos ══════════════════════════════════════════ -->
  <div class="card">
    <div class="card-title">
      <i class="fa-solid fa-images"></i> Fotos guardadas
      <span style="margin-left:auto;font-size:.79rem;color:#aaa;font-weight:400;">
        <asp:Literal ID="litTotalFotos" runat="server"/>
      </span>
    </div>

    <div style="overflow-x:auto;border-radius:12px;">
      <asp:Repeater ID="rptFotos" runat="server"
                    OnItemCommand="rptFotos_ItemCommand">

        <HeaderTemplate>
          <table class="fotos-table">
            <thead>
              <tr>
                <th style="width:76px;">FOTO</th>
                <th>PRODUCTO</th>
                <th style="width:80px;">ID</th>
                <th style="width:90px;">ESTADO</th>
                <th>SUBIDA</th>
                <th style="width:210px;">ACCIONES</th>
              </tr>
            </thead>
            <tbody>
        </HeaderTemplate>

        <ItemTemplate>
          <tr>
            <!-- Miniatura -->
            <td>
              <div class="foto-thumb">
                <img src='<%# ResolverUrlFoto(Eval("foto_ruta"), Eval("foto_id")) %>'
                     alt="Foto <%# Eval("foto_id") %>"
                     onerror="this.onerror=null;this.src='ImagenProductoFallback.ashx?id=<%# Eval("foto_id") %>';" />
              </div>
            </td>

            <!-- Nombre del producto -->
            <td>
              <div class="prod-name-cell">
                <i class="fa-solid fa-box" style="color:var(--accent);font-size:.85rem;"></i>
                <div>
                  <%# Eval("tbl_producto.pro_nombre") %>
                  <span class="sub">ID prod.: <%# Eval("pro_id") %></span>
                </div>
              </div>
            </td>

            <!-- ID foto -->
            <td style="color:#aaa;font-size:.8rem;">#<%# Eval("foto_id") %></td>

            <!-- Estado -->
            <td>
              <span class='badge <%# (char)Eval("foto_estado") == 'A' ? "badge-activo" : "badge-inactivo" %>'>
                <%# (char)Eval("foto_estado") == 'A' ? "Activa" : "Inactiva" %>
              </span>
            </td>

            <!-- Fecha subida -->
            <td style="font-size:.8rem;color:#999;">
              <%# Eval("fecha_subida", "{0:dd/MM/yyyy HH:mm}") %>
            </td>

            <!-- Acciones -->
            <td>
              <div class="row-actions">
                <%-- Desactivar / Reactivar segun estado --%>
                <asp:LinkButton runat="server"
                    CommandName='<%# Eval("foto_estado").ToString() == "A" ? "Desactivar" : "Reactivar" %>'
                    CommandArgument='<%# Eval("foto_id") %>'
                    CssClass='<%# "btn btn-sm " + (Eval("foto_estado").ToString() == "A" ? "btn-secondary" : "btn-success") %>'
                    OnClientClick='<%# Eval("foto_estado").ToString() == "A"
                        ? "return confirm(\"Desactivar esta foto?\");"
                        : "return confirm(\"Reactivar esta foto?\");" %>'>
                  <i class='<%# (char)Eval("foto_estado") == 'A' ? "fa-solid fa-eye-slash" : "fa-solid fa-eye" %>'></i>
                  <%# (char)Eval("foto_estado") == 'A' ? " Desactivar" : " Reactivar" %>
                </asp:LinkButton>

                <%-- Eliminar permanente --%>
                <asp:LinkButton runat="server"
                    CommandName="ElimFis"
                    CommandArgument='<%# Eval("foto_id") %>'
                    CssClass="btn btn-danger btn-sm"
                    OnClientClick="return confirm('Eliminar esta foto PERMANENTEMENTE?');">
                  <i class="fa-solid fa-trash"></i> Eliminar
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

    <asp:Literal ID="litSinFotos" runat="server"/>
  </div>

  <script>
      document.addEventListener('DOMContentLoaded', function () {
          var input = document.getElementById('<%= fuFotos.ClientID %>');
          var ddlProd = document.getElementById('<%= ddlProducto.ClientID %>');
          var btnPrev = document.getElementById('<%= btnPrevisualizar.ClientID %>');
          var btnSubir = document.getElementById('<%= btnSubir.ClientID %>');

          if (input) {
              input.addEventListener('change', function () {
                  if (!ddlProd || ddlProd.value === '' || ddlProd.value === '0') {
                      Swal.fire({
                          title: '¡Atención!',
                          text: 'Debes seleccionar un producto antes de previsualizar y subir las fotos.',
                          icon: 'warning',
                          confirmButtonColor: '#7a4aaa'
                      });
                      input.value = '';
                      return;
                  }

                  var files = Array.from(input.files);
                  var maxBytes = 2 * 1024 * 1024; // 2 MB
                  for (var i = 0; i < files.length; i++) {
                      var file = files[i];
                      if (file.size > maxBytes) {
                          Swal.fire({
                              title: 'Archivo muy pesado',
                              text: 'La foto "' + file.name + '" supera los 2 MB permitidos.',
                              icon: 'warning',
                              confirmButtonColor: '#7a4aaa'
                          });
                          input.value = '';
                          return;
                      }
                      var ext = file.name.split('.').pop().toLowerCase();
                      if (ext !== 'jpg' && ext !== 'jpeg' && ext !== 'png') {
                          Swal.fire({
                              title: 'Formato no válido',
                              text: 'El archivo "' + file.name + '" no es una imagen JPG o PNG válida.',
                              icon: 'warning',
                              confirmButtonColor: '#7a4aaa'
                          });
                          input.value = '';
                          return;
                      }
                  }

                  if (files.length > 0 && btnPrev) {
                      btnPrev.click();
                  }
              });
          }

          if (btnSubir) {
              btnSubir.addEventListener('click', function (e) {
                  var cards = document.querySelectorAll('.preview-strip .preview-card');
                  if (cards.length === 0) {
                      e.preventDefault();
                      Swal.fire({
                          title: '¡Atención!',
                          text: 'Debes previsualizar las fotos primero antes de subirlas.',
                          icon: 'warning',
                          confirmButtonColor: '#7a4aaa'
                      });
                  }
              });
          }

          // Drag & drop sobre la zona
          var zone = document.getElementById('uploadZone');
          if (zone && input) {
              zone.addEventListener('dragover', function (e) { e.preventDefault(); zone.classList.add('drag-over'); });
              zone.addEventListener('dragleave', function () { zone.classList.remove('drag-over'); });
              zone.addEventListener('drop', function (e) {
                  e.preventDefault(); zone.classList.remove('drag-over');
                  input.files = e.dataTransfer.files;
                  input.dispatchEvent(new Event('change'));
              });
          }
      });
  </script>
</asp:Content>