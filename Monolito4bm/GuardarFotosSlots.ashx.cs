using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System.Web;
using System.Web.SessionState;
using Capa_Negocios;
using System.Linq;

namespace Monolito4bm
{
    /// <summary>
    /// Handler HTTP para guardar fotos de múltiples slots via fetch() desde el cliente,
    /// preparar el Excel de rutas en sesión vía AJAX y descargarlo sin recargar la página.
    /// </summary>
    public class GuardarFotosSlots : IHttpHandler, IRequiresSessionState
    {
        private const string CarpetaVirtual = "~/Uploads/Productos/";

        public void ProcessRequest(HttpContext context)
        {
            context.Response.Cache.SetNoStore();
            string action = context.Request.QueryString["action"] ?? string.Empty;

            if (context.Request.HttpMethod == "POST")
            {
                if (action == "generar_excel")
                {
                    GenerarExcelRutasAjax(context);
                }
                else if (action == "subir_excel_carga")
                {
                    SubirExcelCargaMasiva(context);
                }
                else
                {
                    GuardarFotosSlot(context);
                }
            }
            else if (context.Request.HttpMethod == "GET")
            {
                if (action == "descargar_excel")
                {
                    DescargarExcelRutas(context);
                }
                else if (action == "descargar_plantilla")
                {
                    DescargarPlantillaBase(context);
                }
                else
                {
                    context.Response.ContentType = "text/html; charset=utf-8";
                    context.Response.Write("<h3>Accion GET no soportada.</h3>");
                }
            }
        }

        private void GuardarFotosSlot(HttpContext context)
        {
            context.Response.ContentType = "application/json; charset=utf-8";
            try
            {
                // Verificar autenticación básica via sesión
                if (context.Session == null || context.Session["UsuarioId"] == null)
                {
                    // Si no hay sesión de usuario, igual permitir (el proyecto podría no usar UsuarioId)
                }

                string proIdStr = (context.Request.Form["pro_id"] ?? string.Empty).Trim();
                if (string.IsNullOrEmpty(proIdStr))
                    throw new Exception("Se requiere pro_id para identificar el producto.");

                int proId;
                if (!int.TryParse(proIdStr, out proId) || proId <= 0)
                    throw new Exception("pro_id inválido: " + proIdStr);

                var files = context.Request.Files;
                if (files == null || files.Count == 0)
                    throw new Exception("No se recibieron archivos en este slot.");

                string carpetaFisica = context.Server.MapPath(CarpetaVirtual);
                if (!Directory.Exists(carpetaFisica))
                    Directory.CreateDirectory(carpetaFisica);

                var rutasSaved = new List<string[]>(); // [nombreArchivo, rutaRelativa]

                for (int i = 0; i < files.Count; i++)
                {
                    var file = files[i];
                    if (file == null || file.ContentLength <= 0) continue;

                    if (file.ContentLength > 2 * 1024 * 1024)
                        throw new Exception("'" + Path.GetFileName(file.FileName) + "' supera los 2 MB permitidos.");

                    string ext = Path.GetExtension(file.FileName).ToLowerInvariant();
                    string ct = (file.ContentType ?? string.Empty).ToLowerInvariant();

                    if ((ext != ".jpg" && ext != ".jpeg" && ext != ".png") ||
                        (ct != "image/jpeg" && ct != "image/png"))
                        throw new Exception("'" + Path.GetFileName(file.FileName) + "' no es una imagen JPG o PNG válida.");

                    string archivo = "foto_masiva_" + Guid.NewGuid().ToString("N") + ext;
                    string rutaFisica = Path.Combine(carpetaFisica, archivo);
                    file.SaveAs(rutaFisica);

                    rutasSaved.Add(new string[] { Path.GetFileName(file.FileName), "Uploads/Productos/" + archivo });
                }

                if (rutasSaved.Count == 0)
                    throw new Exception("Ningún archivo válido fue recibido para este slot.");

                // Construir JSON manualmente (Newtonsoft disponible, pero evitamos dependencia aquí)
                var sb = new StringBuilder();
                sb.Append("{\"ok\":true,\"rutas\":[");
                for (int i = 0; i < rutasSaved.Count; i++)
                {
                    if (i > 0) sb.Append(',');
                    sb.Append("{\"nombreArchivo\":\"");
                    sb.Append(EscapeJson(rutasSaved[i][0]));
                    sb.Append("\",\"rutaRelativa\":\"");
                    sb.Append(EscapeJson(rutasSaved[i][1]));
                    sb.Append("\",\"proId\":");
                    sb.Append(proId);
                    sb.Append('}');
                }
                sb.Append("],\"error\":null}");
                context.Response.Write(sb.ToString());
            }
            catch (Exception ex)
            {
                var sb = new StringBuilder();
                sb.Append("{\"ok\":false,\"rutas\":null,\"error\":\"");
                sb.Append(EscapeJson(ex.Message));
                sb.Append("\"}");
                context.Response.Write(sb.ToString());
            }
        }

        private void GenerarExcelRutasAjax(HttpContext context)
        {
            context.Response.ContentType = "application/json; charset=utf-8";
            try
            {
                string json = string.Empty;
                using (var reader = new StreamReader(context.Request.InputStream, Encoding.UTF8))
                {
                    json = reader.ReadToEnd();
                }

                if (string.IsNullOrEmpty(json))
                {
                    throw new Exception("No se recibieron datos de rutas preparadas.");
                }

                var resultRutas = new List<FotoRutaPreparada>();
                var arr = Newtonsoft.Json.Linq.JArray.Parse(json);
                foreach (var item in arr)
                {
                    string nombre = item["nombreArchivo"]?.ToString() ?? string.Empty;
                    string ruta   = item["rutaRelativa"]?.ToString() ?? string.Empty;
                    int proId     = 0;
                    int.TryParse(item["proId"]?.ToString(), out proId);

                    if (!string.IsNullOrWhiteSpace(ruta))
                    {
                        resultRutas.Add(new FotoRutaPreparada
                        {
                            NombreArchivo = nombre,
                            RutaRelativa  = ruta,
                            ProductoId    = proId
                        });
                    }
                }

                if (resultRutas.Count == 0)
                {
                    throw new Exception("No hay rutas validas recibidas.");
                }

                var rutasSesion = context.Session["FotosRutasPreparadas"] as List<FotoRutaPreparada> ?? new List<FotoRutaPreparada>();
                rutasSesion.AddRange(resultRutas);
                context.Session["FotosRutasPreparadas"] = rutasSesion;

                string plantillaPath = context.Server.MapPath("~/Plantillas/Fotos.xlsx");
                if (!File.Exists(plantillaPath))
                {
                    throw new Exception("La plantilla 'Fotos.xlsx' no existe en el servidor.");
                }

                byte[] plantilla = File.ReadAllBytes(plantillaPath);
                byte[] excelBytes = CN_tbl_pro_fotos.GenerarExcelRutasDesdePlantilla(plantilla, rutasSesion);

                context.Session["FotosExcelRutas"] = excelBytes;

                context.Response.Write("{\"ok\":true}");
            }
            catch (Exception ex)
            {
                context.Response.Write("{\"ok\":false,\"error\":\"" + EscapeJson(ex.Message) + "\"}");
            }
        }

        private void DescargarExcelRutas(HttpContext context)
        {
            try
            {
                byte[] excel = context.Session["FotosExcelRutas"] as byte[];
                if (excel == null || excel.Length == 0)
                {
                    context.Response.ContentType = "text/html; charset=utf-8";
                    context.Response.Write("<h3>No hay un Excel de rutas preparado en sesion. Intente subir fotos primero.</h3>");
                    return;
                }

                context.Response.Clear();
                context.Response.Buffer = true;
                context.Response.ContentType = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
                context.Response.AddHeader("content-disposition", "attachment;filename=Fotos_Rutas_Preparadas.xlsx");
                context.Response.BinaryWrite(excel);
                context.Response.End();
            }
            catch (System.Threading.ThreadAbortException)
            {
            }
            catch (Exception ex)
            {
                context.Response.ContentType = "text/html; charset=utf-8";
                context.Response.Write("<h3>Error al descargar el Excel de rutas: " + HttpUtility.HtmlEncode(ex.Message) + "</h3>");
            }
        }

        private void DescargarPlantillaBase(HttpContext context)
        {
            try
            {
                string path = context.Server.MapPath("~/Plantillas/Fotos.xlsx");
                if (!File.Exists(path))
                {
                    context.Response.ContentType = "text/html; charset=utf-8";
                    context.Response.Write("<h3>El archivo de plantilla 'Fotos.xlsx' no existe en el servidor.</h3>");
                    return;
                }

                byte[] plantillaBase = File.ReadAllBytes(path);
                byte[] plantilla = CN_tbl_pro_fotos.GenerarExcelRutasDesdePlantilla(plantillaBase, Enumerable.Empty<FotoRutaPreparada>());

                context.Response.Clear();
                context.Response.Buffer = true;
                context.Response.ContentType = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
                context.Response.AddHeader("content-disposition", "attachment;filename=Fotos.xlsx");
                context.Response.BinaryWrite(plantilla);
                context.Response.End();
            }
            catch (System.Threading.ThreadAbortException)
            {
            }
            catch (Exception ex)
            {
                context.Response.ContentType = "text/html; charset=utf-8";
                context.Response.Write("<h3>Error al descargar la plantilla base: " + HttpUtility.HtmlEncode(ex.Message) + "</h3>");
            }
        }

        private void SubirExcelCargaMasiva(HttpContext context)
        {
            context.Response.ContentType = "application/json; charset=utf-8";
            try
            {
                if (context.Request.Files.Count == 0)
                {
                    throw new Exception("No se recibio ningun archivo.");
                }

                var file = context.Request.Files[0];
                if (file.ContentLength == 0)
                {
                    throw new Exception("El archivo seleccionado esta vacio.");
                }

                byte[] fileBytes;
                using (var ms = new MemoryStream())
                {
                    file.InputStream.CopyTo(ms);
                    fileBytes = ms.ToArray();
                }

                context.Session["CargaMasivaFileBytes"] = fileBytes;
                context.Session["CargaMasivaFileName"] = file.FileName;

                context.Response.Write("{\"ok\":true,\"fileName\":\"" + EscapeJson(file.FileName) + "\"}");
            }
            catch (Exception ex)
            {
                context.Response.Write("{\"ok\":false,\"error\":\"" + EscapeJson(ex.Message) + "\"}");
            }
        }

        private static string EscapeJson(string s)
        {
            if (s == null) return string.Empty;
            return s.Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("\n", "\\n").Replace("\r", "\\r").Replace("\t", "\\t");
        }

        public bool IsReusable { get { return false; } }
    }
}
