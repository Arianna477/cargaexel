using Capa_Datos;
using Capa_Negocios;
using System;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data.Linq;

namespace Monolito4bm
{
    public partial class FotosProducto : System.Web.UI.Page
    {
        // ── Controles declarados manualmente (evita errores de designer) ──
        protected global::System.Web.UI.WebControls.HiddenField hfProId;
        protected global::System.Web.UI.WebControls.Literal litNombreProducto;
        protected global::System.Web.UI.WebControls.DropDownList ddlProducto;
        protected global::System.Web.UI.WebControls.Literal litMensaje;
        protected global::System.Web.UI.WebControls.Literal litAviso;
        protected global::System.Web.UI.WebControls.Literal litTotalFotos;
        protected global::System.Web.UI.WebControls.Literal litSinFotos;
        protected global::System.Web.UI.WebControls.FileUpload fuFotos;
        protected global::System.Web.UI.WebControls.Button btnSubir;
        protected global::System.Web.UI.WebControls.Button btnCancelar;
        protected global::System.Web.UI.WebControls.Repeater rptFotos;
        protected global::System.Web.UI.WebControls.Repeater rptFotosPreview;
        protected global::System.Web.UI.WebControls.Button btnPrevisualizar;
        protected global::System.Web.UI.WebControls.Literal lblFotosPreviewInfo;

        [Serializable]
        private sealed class FotoTemporal
        {
            public string Id { get; set; }
            public string NombreArchivo { get; set; }
            public string ContentType { get; set; }
            public byte[] Contenido { get; set; }

            public string PreviewUrl
            {
                get { return "data:" + ContentType + ";base64," + Convert.ToBase64String(Contenido); }
            }
        }

        private System.Collections.Generic.List<FotoTemporal> FotosTemporales
        {
            get { return Session["SessionFotosProducto_" + hfProId.Value] as System.Collections.Generic.List<FotoTemporal> ?? new System.Collections.Generic.List<FotoTemporal>(); }
            set { Session["SessionFotosProducto_" + hfProId.Value] = value; }
        }

        private void LimpiarFotosTemporales()
        {
            Session.Remove("SessionFotosProducto_" + hfProId.Value);
        }

        // Carpeta donde se guardan las fotos de productos
        private const string CARPETA_VIRTUAL = "~/Uploads/Productos/";

        // ── Page Load ─────────────────────────────────────────────
        protected void Page_Load(object sender, EventArgs e)
        {
            if (fuFotos != null)
            {
                fuFotos.Attributes["multiple"] = "multiple";
            }

            int proId = 0;
            if (!int.TryParse(Request.QueryString["id"], out proId) || proId == 0)
            {
                Response.Redirect("Productos.aspx");
                return;
            }

            hfProId.Value = proId.ToString();

            if (!IsPostBack)
            {
                CargarProductosDropdown(proId);
                CargarFotos(proId);
                LimpiarFotosTemporales();
                BindFotosPreview();
            }
        }

        // ── Cargar Dropdown de Productos ───────────────────────────
        private void CargarProductosDropdown(int proId)
        {
            try
            {
                var productos = CN_tbl_producto.Listar()
                    .Where(p => p.pro_estado == 'A')
                    .OrderBy(p => p.pro_nombre)
                    .ToList();

                ddlProducto.DataSource = productos;
                ddlProducto.DataTextField = "pro_nombre";
                ddlProducto.DataValueField = "pro_id";
                ddlProducto.DataBind();
                ddlProducto.SelectedValue = proId.ToString();
            }
            catch (Exception ex)
            {
                MostrarMensaje("Error al cargar la lista de productos: " + ex.Message, false);
            }
        }

        protected void ddlProducto_SelectedIndexChanged(object sender, EventArgs e)
        {
            string id = ddlProducto.SelectedValue;
            if (!string.IsNullOrEmpty(id))
            {
                Response.Redirect("FotosProducto.aspx?id=" + id);
            }
        }

        // ── Cargar fotos en el Repeater ───────────────────────────
        private void CargarFotos(int proId)
        {
            // Fotos con datos del producto incluidos (para mostrar nombre)
            var fotos = CN_tbl_pro_fotos.ObtenerConProducto(proId);

            int total = fotos.Count;
            litTotalFotos.Text = $"{total} / 4 foto(s)";

            // Aviso de límite
            litAviso.Text = total >= 4
                ? "<div class='limite-aviso'>" +
                  "<i class='fa-solid fa-triangle-exclamation'></i> " +
                  "L&iacute;mite de 4 fotos alcanzado. Elimina una para poder subir m&aacute;s.</div>"
                : string.Empty;

            if (fotos.Any())
            {
                rptFotos.DataSource = fotos;
                rptFotos.DataBind();
                litSinFotos.Text = string.Empty;
            }
            else
            {
                rptFotos.DataSource = null;
                rptFotos.DataBind();
                litSinFotos.Text =
                    "<div class='empty-state'>" +
                    "<i class='fa-solid fa-camera-slash'></i>" +
                    "Este producto a&uacute;n no tiene fotos.</div>";
            }
        }

        private void BindFotosPreview()
        {
            var fotos = FotosTemporales;
            rptFotosPreview.DataSource = fotos;
            rptFotosPreview.DataBind();

            if (fotos.Count > 0)
            {
                lblFotosPreviewInfo.Text = "Fotos listas para subir: " + fotos.Count + ". Presiona \"Subir fotos\" para guardarlas en el servidor.";
            }
            else
            {
                lblFotosPreviewInfo.Text = "No hay fotos en la previsualización temporal.";
            }
        }

        protected void btnPrevisualizar_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(ddlProducto.SelectedValue) || ddlProducto.SelectedValue == "0")
            {
                MostrarMensaje("Debes seleccionar un producto antes de previsualizar y subir las fotos.", false);
                return;
            }

            int proId = int.Parse(ddlProducto.SelectedValue);
            int yaExisten = CN_tbl_pro_fotos.Contar(proId);
            int disponibles = 4 - yaExisten;

            try
            {
                if (disponibles <= 0)
                {
                    throw new Exception("El producto ya tiene el límite de 4 fotos guardadas. Elimina alguna antes de previsualizar nuevas.");
                }

                if (!fuFotos.HasFiles)
                {
                    throw new Exception("Selecciona al menos una imagen JPG o PNG para previsualizar.");
                }

                var fotosActuales = FotosTemporales;

                int totalEnCola = fotosActuales.Count;
                if (totalEnCola >= disponibles)
                {
                    throw new Exception("Ya has previsualizado el límite de fotos permitidas para este producto.");
                }

                var nuevasFotos = new System.Collections.Generic.List<FotoTemporal>();
                foreach (HttpPostedFile file in fuFotos.PostedFiles)
                {
                    if (file == null || file.ContentLength <= 0)
                        continue;

                    if (file.ContentLength > 2 * 1024 * 1024)
                    {
                        throw new Exception("El archivo '" + file.FileName + "' supera el límite de 2 MB.");
                    }

                    string ext = Path.GetExtension(file.FileName).ToLowerInvariant();
                    string contentType = (file.ContentType ?? string.Empty).ToLowerInvariant();
                    if ((ext != ".jpg" && ext != ".jpeg" && ext != ".png") ||
                        (contentType != "image/jpeg" && contentType != "image/png"))
                    {
                        throw new Exception("El archivo '" + file.FileName + "' no es una imagen JPG o PNG válida.");
                    }

                    if (totalEnCola + nuevasFotos.Count >= disponibles)
                    {
                        break;
                    }

                    using (var reader = new BinaryReader(file.InputStream))
                    {
                        nuevasFotos.Add(new FotoTemporal
                        {
                            Id = Guid.NewGuid().ToString("N"),
                            NombreArchivo = Path.GetFileName(file.FileName),
                            ContentType = file.ContentType,
                            Contenido = reader.ReadBytes(file.ContentLength)
                        });
                    }
                }

                if (!nuevasFotos.Any())
                {
                    throw new Exception("No se encontraron imágenes válidas para previsualizar.");
                }

                fotosActuales.AddRange(nuevasFotos);
                FotosTemporales = fotosActuales;
                BindFotosPreview();
                MostrarMensaje("Previsualización generada en C#. Presiona 'Subir fotos' para confirmarlas.", true);
            }
            catch (Exception ex)
            {
                MostrarMensaje(ex.Message, false);
            }

            CargarFotos(proId);
        }

        protected void rptFotosPreview_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "Eliminar")
                return;

            string id = Convert.ToString(e.CommandArgument);
            var fotos = FotosTemporales;
            var foto = fotos.FirstOrDefault(f => f.Id == id);
            if (foto != null)
            {
                fotos.Remove(foto);
                FotosTemporales = fotos;
            }

            BindFotosPreview();
            CargarFotos(int.Parse(hfProId.Value));
        }

        // ── Subir fotos ───────────────────────────────────────────
        protected void btnSubir_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(ddlProducto.SelectedValue) || ddlProducto.SelectedValue == "0")
            {
                MostrarMensaje("Debes seleccionar un producto antes de previsualizar y subir las fotos.", false);
                return;
            }

            int proId = int.Parse(ddlProducto.SelectedValue);
            int yaExisten = CN_tbl_pro_fotos.Contar(proId);
            int disponibles = 4 - yaExisten;

            if (disponibles <= 0)
            {
                MostrarMensaje("Ya tiene 4 fotos. Elimina alguna antes de subir.", false);
                CargarFotos(proId);
                return;
            }

            var listTemp = FotosTemporales;
            if (!listTemp.Any())
            {
                MostrarMensaje("Debes previsualizar las fotos primero antes de subirlas.", false);
                CargarFotos(proId);
                return;
            }

            var validos = listTemp.Take(disponibles).ToList();

            // Crear carpeta física si no existe
            string carpetaFisica = Server.MapPath(CARPETA_VIRTUAL);
            if (!Directory.Exists(carpetaFisica))
                Directory.CreateDirectory(carpetaFisica);

            try
            {
                var nuevas = validos.Select(f =>
                {
                    string ext = f.ContentType == "image/png" ? ".png" : ".jpg";
                    string archivo = $"prod_{proId}_{Guid.NewGuid():N}{ext}";
                    string rutaFisica = Path.Combine(carpetaFisica, archivo);
                    File.WriteAllBytes(rutaFisica, f.Contenido);

                    return new tbl_pro_fotos
                    {
                        pro_id = proId,
                        foto_bit = null,
                        foto_ruta = $"Uploads/Productos/{archivo}",
                        foto_estado = 'A',
                        fecha_subida = DateTime.Now
                    };
                }).ToList();

                CN_tbl_pro_fotos.GuardarFotos(nuevas);
                LimpiarFotosTemporales();
                BindFotosPreview();
                // Recargar página tras cerrar el alert para mostrar las fotos nuevas
                string safeMsg = HttpUtility.JavaScriptStringEncode($"{nuevas.Count} foto(s) subida(s) correctamente.");
                string scriptReload = $"Swal.fire({{ title: '\u00a1Éxito!', text: '{safeMsg}', icon: 'success', confirmButtonColor: '#7a4aaa' }}).then(function(){{ window.location.reload(); }});";
                ClientScript.RegisterStartupScript(this.GetType(), "swal_reload", scriptReload, true);
                CargarFotos(proId);
                return;
            }
            catch (Exception ex)
            {
                MostrarMensaje("Error al subir: " + ex.Message, false);
            }

            CargarFotos(proId);
        }

        // ── Volver a productos ────────────────────────────────────
        protected void btnCancelar_Click(object sender, EventArgs e)
        {
            Response.Redirect("Productos.aspx");
        }

        // ── Comandos del Repeater ─────────────────────────────────
        protected void rptFotos_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int fotoId = int.Parse(e.CommandArgument.ToString());
            int proId = int.Parse(hfProId.Value);

            switch (e.CommandName)
            {
                // ── Desactivación lógica ──────────────────────────
                case "Desactivar":
                    try
                    {
                        CN_tbl_pro_fotos.CambiarEstado(fotoId, 'I');
                        MostrarMensaje("Foto desactivada.", true);
                    }
                    catch (Exception ex) { MostrarMensaje("Error: " + ex.Message, false); }
                    break;

                // ── Reactivación lógica ───────────────────────────
                case "Reactivar":
                    try
                    {
                        CN_tbl_pro_fotos.CambiarEstado(fotoId, 'A');
                        MostrarMensaje("Foto reactivada.", true);
                    }
                    catch (Exception ex) { MostrarMensaje("Error: " + ex.Message, false); }
                    break;

                // ── Eliminación física permanente ─────────────────
                case "ElimFis":
                    try
                    {
                        string ruta = CN_tbl_pro_fotos.EliminarFisico(fotoId);
                        if (!string.IsNullOrEmpty(ruta))
                        {
                            string rutaFis = Server.MapPath("~/" + ruta);
                            if (File.Exists(rutaFis))
                                File.Delete(rutaFis);
                        }
                        MostrarMensaje("Foto eliminada permanentemente.", true);
                    }
                    catch (Exception ex) { MostrarMensaje("Error: " + ex.Message, false); }
                    break;
            }

            CargarFotos(proId);
        }

        // ── Helper mensajes ───────────────────────────────────────
        private void MostrarMensaje(string texto, bool exito)
        {
            string icon = exito ? "success" : "error";
            string safeTitle = HttpUtility.JavaScriptStringEncode(exito ? "¡Éxito!" : "¡Atención!");
            string safeText = HttpUtility.JavaScriptStringEncode(texto ?? string.Empty);
            string script = "Swal.fire({ title: '" + safeTitle + "', text: '" + safeText + "', icon: '" + icon + "', confirmButtonColor: '#7a4aaa' });";
            ClientScript.RegisterStartupScript(this.GetType(), "swal_msg_fotos", script, true);
        }

        public string ResolverUrlFoto(object rutaObj, object fotoIdObj)
        {
            string ruta = (rutaObj ?? string.Empty).ToString().Trim();
            int fotoId;
            int.TryParse(Convert.ToString(fotoIdObj), out fotoId);

            if (!string.IsNullOrWhiteSpace(ruta))
            {
                string limpia = ruta.TrimStart('~', '/').Replace("\\", "/");
                return ResolveUrl("~/" + limpia);
            }

            return fotoId > 0
                ? ResolveUrl("~/ImagenProductoFallback.ashx?id=" + fotoId)
                : "data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///ywAAAAAAQABAAACAUwAOw==";
        }
    }
}