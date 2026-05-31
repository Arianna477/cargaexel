using Capa_Datos;
using Capa_Negocios;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Monolito4bm
{
    public partial class FotosProductosGeneral : System.Web.UI.Page
    {
        protected global::System.Web.UI.WebControls.Literal litMensaje;
        protected global::System.Web.UI.WebControls.Literal litTotalFotos;
        protected global::System.Web.UI.WebControls.Literal litSinFotos;
        protected global::System.Web.UI.WebControls.FileUpload fuFotos;
        protected global::System.Web.UI.WebControls.FileUpload fuCargaMasiva;
        protected global::System.Web.UI.WebControls.DropDownList ddlFiltroProducto;
        protected global::System.Web.UI.WebControls.DropDownList ddlProductoCarga;
        protected global::System.Web.UI.WebControls.DropDownList ddlFiltroEstado;
        protected global::System.Web.UI.WebControls.DropDownList ddlTipoInsercionMasiva;
        protected global::System.Web.UI.WebControls.TextBox txtBuscar;
        protected global::System.Web.UI.WebControls.TextBox txtFechaDesde;
        protected global::System.Web.UI.WebControls.TextBox txtFechaHasta;
        protected global::System.Web.UI.WebControls.Button btnPrevisualizar;
        protected global::System.Web.UI.WebControls.Button btnPrepararExcelRutas;
        protected global::System.Web.UI.WebControls.Button btnDescargarRutasPreparadas;
        protected global::System.Web.UI.WebControls.Button btnDescargarFormato;
        protected global::System.Web.UI.WebControls.Button btnProcesarCargaMasiva;
        protected global::System.Web.UI.WebControls.Button btnLimpiarCarga;
        protected global::System.Web.UI.WebControls.Button btnPrevisualizarCarga;
        protected global::System.Web.UI.WebControls.LinkButton btnLimpiarFiltros;
        protected global::System.Web.UI.WebControls.Repeater rptFotos;
        protected global::System.Web.UI.WebControls.Repeater rptFotosPreview;
        protected global::System.Web.UI.WebControls.Repeater rptRutasPreparadas;
        protected global::System.Web.UI.WebControls.GridView gvPreviewCarga;
        protected global::System.Web.UI.WebControls.PlaceHolder phPreviewVacia;
        protected global::System.Web.UI.WebControls.Literal lblFotosPreviewInfo;
        protected global::System.Web.UI.WebControls.Literal litArchivoCarga;
        protected global::System.Web.UI.WebControls.Literal litResumenCarga;
        protected global::System.Web.UI.WebControls.Literal litRutasPreparadasInfo;
        protected global::System.Web.UI.WebControls.HiddenField hfFiltrosAbiertos;
        protected global::System.Web.UI.WebControls.HiddenField hfAccionRutasFaltantes;

        private const string CarpetaVirtual = "~/Uploads/Productos/";
        private const int MaxFilasPreview = 20;
        private const string SessionFotosKey = "GeneralFotosPreview";
        private const string SessionCargaMasivaKey = "FotosCargaMasivaRows";
        private const string SessionRutasPreparadasKey = "FotosRutasPreparadas";
        private const string SessionExcelRutasKey = "FotosExcelRutas";

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

        private List<FotoTemporal> FotosTemporales
        {
            get { return Session[SessionFotosKey] as List<FotoTemporal> ?? new List<FotoTemporal>(); }
            set { Session[SessionFotosKey] = value; }
        }

        private List<FotoCargaFila> FilasCargaMasiva
        {
            get { return Session[SessionCargaMasivaKey] as List<FotoCargaFila>; }
            set { Session[SessionCargaMasivaKey] = value; }
        }

        private List<FotoRutaPreparada> RutasPreparadas
        {
            get { return Session[SessionRutasPreparadasKey] as List<FotoRutaPreparada> ?? new List<FotoRutaPreparada>(); }
            set { Session[SessionRutasPreparadasKey] = value; }
        }

        private byte[] ExcelRutasPreparadas
        {
            get { return Session[SessionExcelRutasKey] as byte[]; }
            set { Session[SessionExcelRutasKey] = value; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            ConfigurarCargaMasiva();

            if (!IsPostBack)
            {
                CargarProductosDropdowns();
                CargarFotos();
                LimpiarFotosTemporales();
                LimpiarPreviewCarga();
                LimpiarRutasPreparadas();
                BindFotosPreview();
            }
        }

        private void ConfigurarCargaMasiva()
        {
            if (fuFotos != null)
            {
                fuFotos.Attributes["accept"] = ".jpg,.jpeg,.png,image/jpeg,image/png";
            }

            if (fuCargaMasiva != null)
            {
                fuCargaMasiva.Attributes["accept"] = ".csv,.xlsx,.xls";
            }
        }

        private void CargarProductosDropdowns()
        {
            try
            {
                var productos = CN_tbl_producto.Listar()
                    .Where(p => p.pro_estado == 'A')
                    .OrderBy(p => p.pro_nombre)
                    .ToList();

                ddlFiltroProducto.DataSource = productos;
                ddlFiltroProducto.DataTextField = "pro_nombre";
                ddlFiltroProducto.DataValueField = "pro_id";
                ddlFiltroProducto.DataBind();
                ddlFiltroProducto.Items.Insert(0, new ListItem("Todos los productos", ""));

                ddlProductoCarga.DataSource = productos;
                ddlProductoCarga.DataTextField = "pro_nombre";
                ddlProductoCarga.DataValueField = "pro_id";
                ddlProductoCarga.DataBind();
                ddlProductoCarga.Items.Insert(0, new ListItem("-- Seleccione un producto --", ""));
            }
            catch (Exception ex)
            {
                MostrarMensaje("Error al cargar la lista de productos: " + ex.Message, false);
            }
        }

        private void CargarFotos()
        {
            try
            {
                using (var dc = new MonolitoDataContext())
                {
                    var query = dc.tbl_pro_fotos.AsQueryable();

                    string busqueda = (txtBuscar.Text ?? string.Empty).Trim();
                    if (!string.IsNullOrWhiteSpace(busqueda))
                    {
                        query = query.Where(f =>
                            (f.tbl_producto != null && f.tbl_producto.pro_nombre.Contains(busqueda)) ||
                            (f.foto_ruta != null && f.foto_ruta.Contains(busqueda)));
                    }

                    int filtroProId;
                    if (int.TryParse(ddlFiltroProducto.SelectedValue, out filtroProId) && filtroProId > 0)
                    {
                        query = query.Where(f => f.pro_id == filtroProId);
                    }

                    string filtroEstado = ddlFiltroEstado.SelectedValue;
                    if (!string.IsNullOrEmpty(filtroEstado))
                    {
                        char est = filtroEstado[0];
                        query = query.Where(f => f.foto_estado == est);
                    }

                    DateTime fechaDesde;
                    if (DateTime.TryParse(txtFechaDesde.Text, out fechaDesde))
                    {
                        query = query.Where(f => f.fecha_subida >= fechaDesde.Date);
                    }

                    DateTime fechaHasta;
                    if (DateTime.TryParse(txtFechaHasta.Text, out fechaHasta))
                    {
                        DateTime limiteHasta = fechaHasta.Date.AddDays(1);
                        query = query.Where(f => f.fecha_subida < limiteHasta);
                    }

                    var listado = query
                        .OrderByDescending(f => f.fecha_subida)
                        .Select(f => new
                        {
                            f.foto_id,
                            f.pro_id,
                            f.foto_ruta,
                            f.foto_estado,
                            f.fecha_subida,
                            TieneBinario = f.foto_bit != null,
                            pro_nombre = f.tbl_producto != null ? f.tbl_producto.pro_nombre : "Sin Producto"
                        })
                        .ToList();

                    litTotalFotos.Text = listado.Count + " foto(s) encontrada(s)";

                    if (listado.Any())
                    {
                        rptFotos.DataSource = listado;
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
                            "No se encontraron fotos con los filtros aplicados.</div>";
                    }
                }
            }
            catch (Exception ex)
            {
                MostrarMensaje("Error al filtrar las fotos: " + ex.Message, false);
            }
        }

        private void BindFotosPreview()
        {
            var fotos = FotosTemporales;
            rptFotosPreview.DataSource = fotos;
            rptFotosPreview.DataBind();

            if (fotos.Count > 0)
            {
                lblFotosPreviewInfo.Text = "Fotos listas para preparar: " + fotos.Count + ". Siguiente paso: guardar en servidor y generar el Excel de rutas.";
            }
            else
            {
                lblFotosPreviewInfo.Text = "No hay fotos en la previsualizacion temporal.";
            }
        }

        private void BindRutasPreparadas()
        {
            var rutas = RutasPreparadas;
            rptRutasPreparadas.DataSource = rutas;
            rptRutasPreparadas.DataBind();
            btnDescargarRutasPreparadas.Visible = rutas.Any() && ExcelRutasPreparadas != null && ExcelRutasPreparadas.Length > 0;
            litRutasPreparadasInfo.Text = rutas.Any()
                ? "Rutas preparadas en servidor: " + rutas.Count + ". Descarga el Excel, completa pro_id/estado si hace falta y luego usa la carga masiva."
                : "Aun no hay rutas preparadas en servidor.";
        }

        protected void btnPrevisualizar_Click(object sender, EventArgs e)
        {
            try
            {
                if (string.IsNullOrEmpty(ddlProductoCarga.SelectedValue))
                {
                    throw new Exception("Selecciona un producto antes de previsualizar.");
                }

                if (!fuFotos.HasFiles)
                {
                    throw new Exception("Selecciona al menos una imagen JPG o PNG para preparar la carga.");
                }

                var fotosActuales = FotosTemporales;
                var nuevasFotos = new List<FotoTemporal>();

                foreach (HttpPostedFile file in fuFotos.PostedFiles)
                {
                    if (file == null || file.ContentLength <= 0)
                    {
                        continue;
                    }

                    if (file.ContentLength > 2 * 1024 * 1024)
                    {
                        throw new Exception("El archivo '" + file.FileName + "' supera el limite de 2 MB.");
                    }

                    string ext = Path.GetExtension(file.FileName).ToLowerInvariant();
                    string contentType = (file.ContentType ?? string.Empty).ToLowerInvariant();
                    if ((ext != ".jpg" && ext != ".jpeg" && ext != ".png") ||
                        (contentType != "image/jpeg" && contentType != "image/png"))
                    {
                        throw new Exception("El archivo '" + file.FileName + "' no es una imagen JPG o PNG valida.");
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
                    throw new Exception("No se encontraron imagenes validas para previsualizar.");
                }

                fotosActuales.AddRange(nuevasFotos);
                FotosTemporales = fotosActuales;
                BindFotosPreview();
                MostrarMensaje("Previsualizacion lista. Ahora puedes revisar las imagenes y generar el Excel de rutas.", true);
            }
            catch (Exception ex)
            {
                MostrarMensaje(ex.Message, false);
            }
        }

        protected void rptFotosPreview_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "Eliminar")
            {
                return;
            }

            string id = Convert.ToString(e.CommandArgument);
            var fotos = FotosTemporales;
            var foto = fotos.FirstOrDefault(f => f.Id == id);
            if (foto != null)
            {
                fotos.Remove(foto);
                FotosTemporales = fotos;
            }

            BindFotosPreview();
        }

        protected void btnPrepararExcelRutas_Click(object sender, EventArgs e)
        {
            try
            {
                if (string.IsNullOrEmpty(ddlProductoCarga.SelectedValue))
                {
                    throw new Exception("Selecciona un producto antes de subir.");
                }

                var fotos = FotosTemporales;
                if (!fotos.Any())
                {
                    throw new Exception("Debes previsualizar las fotos primero antes de subirlas.");
                }

                string carpetaFisica = Server.MapPath(CarpetaVirtual);
                if (!Directory.Exists(carpetaFisica))
                {
                    Directory.CreateDirectory(carpetaFisica);
                }

                var rutas = new List<FotoRutaPreparada>();
                foreach (var foto in fotos)
                {
                    string ext = Path.GetExtension(foto.NombreArchivo).ToLowerInvariant();
                    if (string.IsNullOrWhiteSpace(ext))
                    {
                        ext = string.Equals(foto.ContentType, "image/png", StringComparison.OrdinalIgnoreCase) ? ".png" : ".jpg";
                    }

                    string archivo = "foto_masiva_" + Guid.NewGuid().ToString("N") + ext;
                    string rutaFisica = Path.Combine(carpetaFisica, archivo);
                    File.WriteAllBytes(rutaFisica, foto.Contenido);

                    rutas.Add(new FotoRutaPreparada
                    {
                        NombreArchivo = foto.NombreArchivo,
                        RutaRelativa = "Uploads/Productos/" + archivo
                    });
                }

                string plantillaPath = Server.MapPath("~/Plantillas/Fotos.xlsx");
                if (!File.Exists(plantillaPath))
                {
                    throw new Exception("La plantilla 'Fotos.xlsx' no existe en el servidor.");
                }

                byte[] plantilla = File.ReadAllBytes(plantillaPath);
                int selectedProId = int.Parse(ddlProductoCarga.SelectedValue);
                ExcelRutasPreparadas = CN_tbl_pro_fotos.GenerarExcelRutasDesdePlantilla(plantilla, rutas, selectedProId);
                RutasPreparadas = rutas;

                LimpiarFotosTemporales();
                BindFotosPreview();
                BindRutasPreparadas();

                MostrarMensaje("Fotos guardadas en servidor correctamente. Ya puedes descargar el Excel con las rutas generadas.", true);
            }
            catch (Exception ex)
            {
                MostrarMensaje("Error al preparar las rutas: " + ex.Message, false);
            }
        }

        protected void btnDescargarRutasPreparadas_Click(object sender, EventArgs e)
        {
            try
            {
                var excel = ExcelRutasPreparadas;
                if (excel == null || excel.Length == 0)
                {
                    throw new Exception("No hay un Excel de rutas listo para descargar.");
                }

                Response.Clear();
                Response.Buffer = true;
                Response.ContentType = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
                Response.AddHeader("content-disposition", "attachment;filename=Fotos_Rutas_Preparadas.xlsx");
                Response.BinaryWrite(excel);
                Response.End();
            }
            catch (System.Threading.ThreadAbortException)
            {
            }
            catch (Exception ex)
            {
                MostrarMensaje("Error al descargar el Excel de rutas: " + ex.Message, false);
            }
        }

        protected void btnDescargarFormato_Click(object sender, EventArgs e)
        {
            try
            {
                string path = Server.MapPath("~/Plantillas/Fotos.xlsx");
                if (!File.Exists(path))
                {
                    throw new Exception("El archivo de plantilla 'Fotos.xlsx' no existe en el servidor.");
                }

                byte[] plantillaBase = File.ReadAllBytes(path);
                byte[] plantilla = CN_tbl_pro_fotos.GenerarExcelRutasDesdePlantilla(plantillaBase, Enumerable.Empty<FotoRutaPreparada>());

                Response.Clear();
                Response.Buffer = true;
                Response.ContentType = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
                Response.AddHeader("content-disposition", "attachment;filename=Fotos.xlsx");
                Response.BinaryWrite(plantilla);
                Response.End();
            }
            catch (System.Threading.ThreadAbortException)
            {
            }
            catch (Exception ex)
            {
                MostrarMensaje("Error al descargar el formato: " + ex.Message, false);
            }
        }

        protected void btnPrevisualizarCarga_Click(object sender, EventArgs e)
        {
            try
            {
                if (!fuCargaMasiva.HasFile)
                {
                    throw new Exception("Primero debes seleccionar un archivo para la carga masiva.");
                }

                ValidarArchivoCarga(fuCargaMasiva.FileName);

                byte[] contenido;
                using (var memory = new MemoryStream())
                {
                    fuCargaMasiva.PostedFile.InputStream.CopyTo(memory);
                    contenido = memory.ToArray();
                }

                FilasCargaMasiva = CN_tbl_pro_fotos.LeerArchivoCargaMasiva(contenido, fuCargaMasiva.FileName);
                BindPreviewCarga();
                MostrarMensaje("Vista previa generada correctamente. Se detectaron " + FilasCargaMasiva.Count + " fila(s).", true);
            }
            catch (Exception ex)
            {
                LimpiarPreviewCarga();
                MostrarMensaje(ex.Message, false);
            }
        }

        protected void btnProcesarCargaMasiva_Click(object sender, EventArgs e)
        {
            try
            {
                var filas = FilasCargaMasiva;
                if (filas == null || !filas.Any())
                {
                    throw new Exception("No hay una vista previa lista. Carga y visualiza el archivo antes de procesarlo.");
                }

                var tipo = (TipoInsercionProveedor)int.Parse(ddlTipoInsercionMasiva.SelectedValue);
                var filasConRutasFaltantes = ObtenerFilasConRutasFaltantes(filas);
                string accionRutas = (hfAccionRutasFaltantes.Value ?? string.Empty).Trim().ToLowerInvariant();

                if (filasConRutasFaltantes.Any() && string.IsNullOrWhiteSpace(accionRutas))
                {
                    MostrarDecisionRutasFaltantes(filasConRutasFaltantes);
                    return;
                }

                if (accionRutas == "cancelar")
                {
                    hfAccionRutasFaltantes.Value = string.Empty;
                    MostrarMensaje("La carga masiva fue cancelada por el usuario.", false);
                    return;
                }

                if (accionRutas == "omitir" && filasConRutasFaltantes.Any())
                {
                    var filasOmitidas = new HashSet<int>(filasConRutasFaltantes.Select(f => f.NumeroFilaArchivo));
                    filas = filas.Where(f => !filasOmitidas.Contains(f.NumeroFilaArchivo)).ToList();
                    if (!filas.Any())
                    {
                        hfAccionRutasFaltantes.Value = string.Empty;
                        throw new Exception("Todas las filas fueron omitidas porque las rutas indicadas no existen en el servidor.");
                    }
                }

                var resultado = CN_tbl_pro_fotos.ProcesarCargaMasiva(filas, tipo);
                hfAccionRutasFaltantes.Value = string.Empty;

                LimpiarPreviewCarga();
                CargarFotos();

                string mensaje = "Carga masiva completada. Filas: " + resultado.FilasProcesadas +
                    ". Insertadas: " + resultado.Insertados +
                    ". Actualizadas: " + resultado.Actualizados + ".";
                if (resultado.Omitidos > 0)
                {
                    mensaje += " Omitidas: " + resultado.Omitidos + ".";
                }
                if (resultado.CorregidosAutomaticamente > 0)
                {
                    mensaje += " Corregidas automaticamente: " + resultado.CorregidosAutomaticamente + ".";
                }
                if (accionRutas == "omitir" && filasConRutasFaltantes.Any())
                {
                    mensaje += " Filas omitidas por rutas inexistentes: " + filasConRutasFaltantes.Count + ".";
                }
                if (resultado.FotosSinProducto > 0)
                {
                    mensaje += " Reasignadas a Sin producto: " + resultado.FotosSinProducto + ".";
                }

                MostrarMensaje(mensaje, true);
            }
            catch (Exception ex)
            {
                hfAccionRutasFaltantes.Value = string.Empty;
                MostrarMensaje(ex.Message, false);
            }
        }

        protected void btnLimpiarCarga_Click(object sender, EventArgs e)
        {
            LimpiarPreviewCarga();
        }

        protected void Filtros_Changed(object sender, EventArgs e)
        {
            CargarFotos();
        }

        protected void btnLimpiarFiltros_Click(object sender, EventArgs e)
        {
            txtBuscar.Text = string.Empty;
            ddlFiltroProducto.SelectedIndex = 0;
            ddlFiltroEstado.SelectedIndex = 0;
            txtFechaDesde.Text = string.Empty;
            txtFechaHasta.Text = string.Empty;
            hfFiltrosAbiertos.Value = "1";

            CargarFotos();
        }

        protected void rptFotos_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int fotoId = int.Parse(e.CommandArgument.ToString());

            try
            {
                switch (e.CommandName)
                {
                    case "Desactivar":
                        CN_tbl_pro_fotos.CambiarEstado(fotoId, 'I');
                        MostrarMensaje("Foto desactivada con exito.", true);
                        break;

                    case "Reactivar":
                        CN_tbl_pro_fotos.CambiarEstado(fotoId, 'A');
                        MostrarMensaje("Foto reactivada con exito.", true);
                        break;

                    case "ElimFis":
                        string ruta = CN_tbl_pro_fotos.EliminarFisico(fotoId);
                        if (!string.IsNullOrWhiteSpace(ruta))
                        {
                            string rutaFisica = Server.MapPath("~/" + ruta.TrimStart('~', '/').Replace("\\", "/"));
                            if (File.Exists(rutaFisica))
                            {
                                File.Delete(rutaFisica);
                            }
                        }
                        MostrarMensaje("La foto se elimino fisicamente de forma permanente.", true);
                        break;
                }
            }
            catch (Exception ex)
            {
                MostrarMensaje("Error al procesar la foto: " + ex.Message, false);
            }

            CargarFotos();
        }

        private void BindPreviewCarga()
        {
            var filas = FilasCargaMasiva ?? new List<FotoCargaFila>();
            var preview = filas.Take(MaxFilasPreview)
                .Select(f => new
                {
                    f.NumeroFilaArchivo,
                    FotoIdTexto = f.FotoId.HasValue ? f.FotoId.Value.ToString() : "(nueva)",
                    f.ProductoId,
                    f.RutaFoto,
                    OrigenFoto = (f.FotoBit != null && f.FotoBit.Length > 0) ? "foto_bit" : "foto_ruta",
                    EstadoTexto = f.EstadoFoto == 'I' ? "Inactiva" : "Activa"
                })
                .ToList();

            gvPreviewCarga.Visible = preview.Any();
            gvPreviewCarga.DataSource = preview;
            gvPreviewCarga.DataBind();
            phPreviewVacia.Visible = !preview.Any();
            litArchivoCarga.Text = "Archivo listo: " + HttpUtility.HtmlEncode(fuCargaMasiva.FileName);
            litResumenCarga.Text = filas.Count > MaxFilasPreview
                ? "Mostrando " + MaxFilasPreview + " de " + filas.Count + " fila(s)."
                : "Mostrando " + filas.Count + " fila(s).";
        }

        private void LimpiarPreviewCarga()
        {
            FilasCargaMasiva = null;
            gvPreviewCarga.Visible = false;
            gvPreviewCarga.DataSource = null;
            gvPreviewCarga.DataBind();
            if (phPreviewVacia != null) phPreviewVacia.Visible = true;
            if (litArchivoCarga != null) litArchivoCarga.Text = "Sin archivo cargado.";
            if (litResumenCarga != null) litResumenCarga.Text = "Aun no hay vista previa.";
            if (ddlTipoInsercionMasiva != null) ddlTipoInsercionMasiva.SelectedValue = "1";
        }

        private void LimpiarFotosTemporales()
        {
            FotosTemporales = new List<FotoTemporal>();
        }

        private void LimpiarRutasPreparadas()
        {
            RutasPreparadas = new List<FotoRutaPreparada>();
            ExcelRutasPreparadas = null;
            if (rptRutasPreparadas != null)
            {
                rptRutasPreparadas.DataSource = null;
                rptRutasPreparadas.DataBind();
            }

            if (btnDescargarRutasPreparadas != null)
            {
                btnDescargarRutasPreparadas.Visible = false;
            }

            if (litRutasPreparadasInfo != null)
            {
                litRutasPreparadasInfo.Text = "Aun no hay rutas preparadas en servidor.";
            }
        }

        private void ValidarArchivoCarga(string nombreArchivo)
        {
            string extension = Path.GetExtension(nombreArchivo ?? string.Empty).ToLowerInvariant();
            var permitidos = new[] { ".csv", ".xlsx", ".xls" };
            if (!permitidos.Contains(extension))
            {
                throw new Exception("Archivo no permitido. Solo se aceptan archivos .csv, .xlsx y .xls.");
            }
        }

        private void ValidarRutasAntesDeProcesar(IEnumerable<FotoCargaFila> filas)
        {
            foreach (var fila in filas ?? Enumerable.Empty<FotoCargaFila>())
            {
                if (fila.FotoBit != null && fila.FotoBit.Length > 0)
                {
                    continue;
                }

                string ruta = (fila.RutaFoto ?? string.Empty).Trim();
                if (string.IsNullOrWhiteSpace(ruta))
                {
                    throw new Exception("La fila " + fila.NumeroFilaArchivo + " no tiene una foto valida en foto_ruta o foto_bit.");
                }

                string rutaFisica = Server.MapPath("~/" + ruta.TrimStart('~', '/').Replace("\\", "/"));
                if (!File.Exists(rutaFisica))
                {
                    throw new Exception("La ruta '" + ruta + "' de la fila " + fila.NumeroFilaArchivo + " no existe en el servidor.");
                }
            }
        }

        private List<FotoCargaFila> ObtenerFilasConRutasFaltantes(IEnumerable<FotoCargaFila> filas)
        {
            var faltantes = new List<FotoCargaFila>();
            foreach (var fila in filas ?? Enumerable.Empty<FotoCargaFila>())
            {
                if (fila.FotoBit != null && fila.FotoBit.Length > 0)
                {
                    continue;
                }

                string ruta = (fila.RutaFoto ?? string.Empty).Trim();
                if (string.IsNullOrWhiteSpace(ruta))
                {
                    faltantes.Add(fila);
                    continue;
                }

                string rutaFisica = Server.MapPath("~/" + ruta.TrimStart('~', '/').Replace("\\", "/"));
                if (!File.Exists(rutaFisica))
                {
                    faltantes.Add(fila);
                }
            }

            return faltantes;
        }

        private void MostrarDecisionRutasFaltantes(IList<FotoCargaFila> filasConRutasFaltantes)
        {
            string detalle = string.Join(", ", filasConRutasFaltantes
                .Take(5)
                .Select(f => "fila " + f.NumeroFilaArchivo));

            if (filasConRutasFaltantes.Count > 5)
            {
                detalle += " y " + (filasConRutasFaltantes.Count - 5) + " mas";
            }

            string mensaje = "Algunas rutas no existen en el servidor (" + detalle + "). ¿Deseas seguir, omitir esas filas o cancelar la carga?";
            string hiddenId = hfAccionRutasFaltantes.ClientID;
            string botonId = btnProcesarCargaMasiva.UniqueID;
            string safeText = HttpUtility.JavaScriptStringEncode(mensaje);

            string script = @"
Swal.fire({
  title: 'Rutas inexistentes',
  text: '" + safeText + @"',
  icon: 'warning',
  showCancelButton: true,
  showDenyButton: true,
  confirmButtonText: 'Seguir',
  denyButtonText: 'Omitir',
  cancelButtonText: 'Cancelar',
  confirmButtonColor: '#27ae60',
  denyButtonColor: '#e67e22',
  cancelButtonColor: '#c0392b'
}).then(function(result) {
  var hidden = document.getElementById('" + hiddenId + @"');
  if (!hidden) return;
  if (result.isConfirmed) {
    hidden.value = 'seguir';
    __doPostBack('" + botonId + @"','');
  } else if (result.isDenied) {
    hidden.value = 'omitir';
    __doPostBack('" + botonId + @"','');
  } else {
    hidden.value = 'cancelar';
    __doPostBack('" + botonId + @"','');
  }
});";

            ScriptManager.RegisterStartupScript(this, GetType(), "rutas_faltantes_decision", script, true);
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

        private void MostrarMensaje(string texto, bool exito)
        {
            string icon = exito ? "success" : "error";
            string title = exito ? "Exito" : "Atencion";
            string safeTitle = HttpUtility.JavaScriptStringEncode(title);
            string safeText = HttpUtility.JavaScriptStringEncode(texto ?? string.Empty);
            string script = "Swal.fire({ title: '" + safeTitle + "', text: '" + safeText + "', icon: '" + icon + "', confirmButtonColor: '#7a4aaa' });";
            ScriptManager.RegisterStartupScript(this, GetType(), "swal_msg_general_fotos", script, true);

            string css = exito ? "alert alert-success" : "alert alert-danger";
            litMensaje.Text = "<div class='" + css + "'>" + HttpUtility.HtmlEncode(texto) + "</div>";
        }
    }
}
