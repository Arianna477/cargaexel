using System;
using System.Collections.Generic;
using System.Data;
using System.Data.OleDb;
using System.Globalization;
using System.IO;
using System.IO.Compression;
using System.Linq;
using System.Text;
using System.Xml.Linq;

namespace Capa_Negocios
{
    [Serializable]
    public sealed class FotoCargaFila
    {
        public int NumeroFilaArchivo { get; set; }
        public int? FotoId { get; set; }
        public string ProductoIdentificador { get; set; }
        public string RutaFoto { get; set; }
        public byte[] FotoBit { get; set; }
        public char EstadoFoto { get; set; }
    }

    public sealed class ResultadoCargaFotos
    {
        public int FilasProcesadas { get; set; }
        public int Insertados { get; set; }
        public int Actualizados { get; set; }
        public int FotosSinProducto { get; set; }
        public int Omitidos { get; set; }
        public int CorregidosAutomaticamente { get; set; }
    }

    [Serializable]
    public sealed class FotoRutaPreparada
    {
        public string NombreArchivo { get; set; }
        public string RutaRelativa { get; set; }
        public int ProductoId { get; set; }
    }

    internal sealed class FotoCargaFilaNormalizada
    {
        public int NumeroFilaArchivo { get; set; }
        public int? FotoId { get; set; }
        public string ProductoIdentificador { get; set; }
        public int ProductoId { get; set; }
        public string RutaFoto { get; set; }
        public byte[] FotoBit { get; set; }
        public char EstadoFoto { get; set; }
    }

    internal static class FotoCargaMasivaParser
    {
        private static readonly string[] HeadersFotoId = { "id", "fotoid", "idfoto", "codigo", "codigofoto" };
        private static readonly string[] HeadersProductoId = { "proid", "productoid", "idproducto", "idpro", "pro_id", "producto", "nombreproducto", "productonombre" };
        private static readonly string[] HeadersRuta = { "fotoruta", "ruta", "path", "rutafoto", "archivo", "ubicacion", "foto_ruta" };
        private static readonly string[] HeadersBit = { "fotobit", "foto_bit", "bit", "base64", "imagenbase64", "bytesbase64" };
        private static readonly string[] HeadersEstado = { "estado", "fotoestado", "estadofoto" };

        public static List<FotoCargaFila> Leer(byte[] contenido, string nombreArchivo)
        {
            if (contenido == null || contenido.Length == 0)
            {
                throw new Exception("El archivo seleccionado esta vacio.");
            }

            string extension = Path.GetExtension(nombreArchivo ?? string.Empty).ToLowerInvariant();
            switch (extension)
            {
                case ".csv":
                    return ConvertirFilas(ParsearCsv(DetectarTexto(contenido)));
                case ".xlsx":
                    return ConvertirFilas(LeerXlsx(contenido));
                case ".xls":
                    return ConvertirFilas(LeerXls(contenido, extension));
                default:
                    throw new Exception("Formato no soportado. Solo se permiten archivos .csv, .xlsx y .xls.");
            }
        }

        public static byte[] GenerarExcelDesdePlantilla(byte[] plantilla, IEnumerable<FotoRutaPreparada> rutas, int productoId = 0)
        {
            var datos = (rutas ?? Enumerable.Empty<FotoRutaPreparada>()).ToList();
            if (plantilla == null || plantilla.Length == 0)
            {
                throw new Exception("No se encontro la plantilla base de fotos.");
            }

            using (var memory = new MemoryStream())
            {
                memory.Write(plantilla, 0, plantilla.Length);
                memory.Position = 0;

                using (var zip = new ZipArchive(memory, ZipArchiveMode.Update, true))
                {
                    XNamespace ns = "http://schemas.openxmlformats.org/spreadsheetml/2006/main";
                    XNamespace relNs = "http://schemas.openxmlformats.org/officeDocument/2006/relationships";
                    XNamespace pkgRelNs = "http://schemas.openxmlformats.org/package/2006/relationships";

                    var workbookEntry = zip.GetEntry("xl/workbook.xml")
                        ?? throw new Exception("La plantilla de fotos no contiene workbook.xml.");
                    var workbookRelsEntry = zip.GetEntry("xl/_rels/workbook.xml.rels")
                        ?? throw new Exception("La plantilla de fotos no contiene workbook.xml.rels.");

                    XDocument workbookDoc;
                    XDocument workbookRelsDoc;
                    using (var workbookStream = workbookEntry.Open())
                    {
                        workbookDoc = XDocument.Load(workbookStream);
                    }
                    using (var relsStream = workbookRelsEntry.Open())
                    {
                        workbookRelsDoc = XDocument.Load(relsStream);
                    }

                    var firstSheet = workbookDoc.Descendants(ns + "sheet").FirstOrDefault()
                        ?? throw new Exception("La plantilla de fotos no contiene hojas.");
                    string relationId = (string)firstSheet.Attribute(relNs + "id");
                    string target = workbookRelsDoc.Descendants(pkgRelNs + "Relationship")
                        .Where(r => string.Equals((string)r.Attribute("Id"), relationId, StringComparison.Ordinal))
                        .Select(r => (string)r.Attribute("Target"))
                        .FirstOrDefault();

                    if (string.IsNullOrWhiteSpace(target))
                    {
                        throw new Exception("No fue posible localizar la primera hoja de la plantilla.");
                    }

                    string sheetPath = "xl/" + target.TrimStart('/').Replace("\\", "/");
                    var sheetEntry = zip.GetEntry(sheetPath)
                        ?? throw new Exception("No fue posible abrir la hoja principal de la plantilla.");

                    XDocument sheetDoc;
                    using (var sheetStream = sheetEntry.Open())
                    {
                        sheetDoc = XDocument.Load(sheetStream);
                    }

                    var worksheet = sheetDoc.Root;
                    if (worksheet == null)
                    {
                        throw new Exception("La hoja principal de la plantilla no tiene una estructura valida.");
                    }

                    var sheetData = worksheet.Element(ns + "sheetData");
                    if (sheetData == null)
                    {
                        sheetData = new XElement(ns + "sheetData");
                        worksheet.Add(sheetData);
                    }

                    sheetData.RemoveNodes();

                    string[] headers = { "foto_id", "producto", "foto_ruta", "foto_bit", "estado" };
                    sheetData.Add(CrearFilaWorksheet(ns, 1, headers));

                    int fila = 2;
                    foreach (var item in datos)
                    {
                        int targetProId = item.ProductoId > 0 ? item.ProductoId : productoId;
                        string productoNombre = ObtenerNombreProductoPorId(targetProId);

                        sheetData.Add(CrearFilaWorksheet(ns, fila++, new[]
                        {
                            string.Empty,
                            productoNombre,
                            item.RutaRelativa ?? string.Empty,
                            string.Empty,
                            "A"
                        }));
                    }

                    sheetEntry.Delete();
                    var nuevaEntry = zip.CreateEntry(sheetPath, CompressionLevel.Optimal);
                    using (var output = nuevaEntry.Open())
                    {
                        sheetDoc.Save(output);
                    }
                }

                return memory.ToArray();
            }
        }

        private static XElement CrearFilaWorksheet(XNamespace ns, int numeroFila, IEnumerable<string> valores)
        {
            var row = new XElement(ns + "row", new XAttribute("r", numeroFila));
            int columna = 0;
            foreach (var valor in valores)
            {
                row.Add(new XElement(ns + "c",
                    new XAttribute("r", ObtenerReferenciaCelda(columna++, numeroFila)),
                    new XAttribute("t", "inlineStr"),
                    new XElement(ns + "is", new XElement(ns + "t", valor ?? string.Empty))));
            }
            return row;
        }

        private static string ObtenerReferenciaCelda(int indiceColumna, int fila)
        {
            var letras = new StringBuilder();
            int valor = indiceColumna + 1;
            while (valor > 0)
            {
                int modulo = (valor - 1) % 26;
                letras.Insert(0, (char)('A' + modulo));
                valor = (valor - modulo - 1) / 26;
            }

            return letras + fila.ToString(CultureInfo.InvariantCulture);
        }

        private static List<FotoCargaFila> ConvertirFilas(List<List<string>> filas)
        {
            if (filas == null || filas.Count == 0)
            {
                throw new Exception("El archivo no contiene datos para procesar.");
            }

            int headerIndex = filas.FindIndex(f => f != null && f.Any(c => !string.IsNullOrWhiteSpace(c)));
            if (headerIndex < 0)
            {
                throw new Exception("No se encontro una fila de encabezados valida.");
            }

            var headers = filas[headerIndex].Select(NormalizarHeader).ToList();
            int indexFotoId = BuscarIndiceHeader(headers, HeadersFotoId);
            int indexProductoId = BuscarIndiceHeader(headers, HeadersProductoId);
            int indexRuta = BuscarIndiceHeader(headers, HeadersRuta);
            int indexBit = BuscarIndiceHeader(headers, HeadersBit);
            int indexEstado = BuscarIndiceHeader(headers, HeadersEstado);

            if (indexProductoId < 0 || (indexRuta < 0 && indexBit < 0))
            {
                throw new Exception("El archivo debe contener el ID o nombre del producto y al menos una columna foto_ruta o foto_bit.");
            }

            var resultado = new List<FotoCargaFila>();
            for (int i = headerIndex + 1; i < filas.Count; i++)
            {
                var fila = filas[i] ?? new List<string>();
                string fotoIdTexto = ObtenerValor(fila, indexFotoId).Trim();
                string productoIdTexto = ObtenerValor(fila, indexProductoId).Trim();
                string ruta = ObtenerValor(fila, indexRuta).Trim();
                string fotoBitTexto = ObtenerValor(fila, indexBit).Trim();
                string estadoTexto = ObtenerValor(fila, indexEstado).Trim();

                if (string.IsNullOrWhiteSpace(fotoIdTexto) &&
                    string.IsNullOrWhiteSpace(productoIdTexto) &&
                    string.IsNullOrWhiteSpace(ruta) &&
                    string.IsNullOrWhiteSpace(fotoBitTexto) &&
                    string.IsNullOrWhiteSpace(estadoTexto))
                {
                    continue;
                }

                try
                {
                    int? fotoId = ParsearEnteroOpcional(fotoIdTexto, $"El ID de foto '{fotoIdTexto}' no es un numero entero positivo valido.");
                    
                    if (string.IsNullOrWhiteSpace(productoIdTexto))
                    {
                        throw new Exception("El identificador del producto (ID o nombre) no puede estar vacio.");
                    }

                    byte[] fotoBit = ParsearFotoBitOpcional(fotoBitTexto);
                    string rutaNormalizada = NormalizarRuta(ruta);

                    if (string.IsNullOrWhiteSpace(rutaNormalizada) && (fotoBit == null || fotoBit.Length == 0))
                    {
                        throw new Exception("Debes enviar una foto en foto_ruta o foto_bit.");
                    }

                    resultado.Add(new FotoCargaFila
                    {
                        NumeroFilaArchivo = i + 1,
                        FotoId = fotoId,
                        ProductoIdentificador = productoIdTexto,
                        RutaFoto = rutaNormalizada,
                        FotoBit = fotoBit,
                        EstadoFoto = ParsearEstado(estadoTexto)
                    });
                }
                catch (Exception ex)
                {
                    throw new Exception($"Error en la fila {i + 1}: {ex.Message}");
                }
            }

            if (!resultado.Any())
            {
                throw new Exception("No se encontraron filas validas para importar.");
            }

            return resultado;
        }

        private static int BuscarIndiceHeader(List<string> headers, IEnumerable<string> alias)
        {
            return headers.FindIndex(h => alias.Contains(h));
        }

        private static string ObtenerValor(List<string> fila, int indice)
        {
            return indice >= 0 && indice < fila.Count ? (fila[indice] ?? string.Empty) : string.Empty;
        }

        private static int? ParsearEnteroOpcional(string valor, string mensajeError)
        {
            if (string.IsNullOrWhiteSpace(valor))
            {
                return null;
            }

            int numero;
            if (!int.TryParse(valor, NumberStyles.Integer, CultureInfo.InvariantCulture, out numero) || numero <= 0)
            {
                throw new Exception(mensajeError);
            }

            return numero;
        }

        private static int ParsearEnteroRequerido(string valor, string mensajeError)
        {
            int? numero = ParsearEnteroOpcional(valor, mensajeError);
            if (!numero.HasValue)
            {
                throw new Exception(mensajeError);
            }

            return numero.Value;
        }

        private static char ParsearEstado(string estadoTexto)
        {
            if (string.IsNullOrWhiteSpace(estadoTexto))
            {
                return 'A';
            }

            string valor = NormalizarHeader(estadoTexto);
            if (valor == "a" || valor == "activo") return 'A';
            if (valor == "i" || valor == "inactivo") return 'I';
            throw new Exception($"Estado no valido: '{estadoTexto}'. Usa A/Activo o I/Inactivo.");
        }

        private static string NormalizarRuta(string ruta)
        {
            string limpia = (ruta ?? string.Empty).Trim().Replace("\\", "/");
            limpia = limpia.TrimStart('~').TrimStart('/');
            return limpia;
        }

        private static byte[] ParsearFotoBitOpcional(string valor)
        {
            if (string.IsNullOrWhiteSpace(valor))
            {
                return null;
            }

            string base64 = valor.Trim();
            int coma = base64.IndexOf(',');
            if (base64.StartsWith("data:", StringComparison.OrdinalIgnoreCase) && coma >= 0)
            {
                base64 = base64.Substring(coma + 1);
            }

            try
            {
                return Convert.FromBase64String(base64);
            }
            catch
            {
                throw new Exception("El valor de foto_bit no es un base64 valido.");
            }
        }

        private static string NormalizarHeader(string valor)
        {
            if (string.IsNullOrWhiteSpace(valor)) return string.Empty;
            string sinTildes = new string(valor.Normalize(NormalizationForm.FormD)
                .Where(c => CharUnicodeInfo.GetUnicodeCategory(c) != UnicodeCategory.NonSpacingMark)
                .ToArray());
            return sinTildes.Trim().ToLowerInvariant().Replace(" ", string.Empty).Replace("_", string.Empty).Replace("-", string.Empty);
        }

        private static string DetectarTexto(byte[] contenido)
        {
            if (contenido.Length >= 3 && contenido[0] == 0xEF && contenido[1] == 0xBB && contenido[2] == 0xBF)
            {
                return Encoding.UTF8.GetString(contenido, 3, contenido.Length - 3);
            }

            try
            {
                return new UTF8Encoding(false, true).GetString(contenido);
            }
            catch
            {
                return Encoding.GetEncoding(1252).GetString(contenido);
            }
        }

        private static List<List<string>> ParsearCsv(string texto)
        {
            var resultado = new List<List<string>>();
            var filaActual = new List<string>();
            var valorActual = new StringBuilder();
            bool enComillas = false;

            for (int i = 0; i < texto.Length; i++)
            {
                char c = texto[i];
                if (enComillas)
                {
                    if (c == '"')
                    {
                        if (i + 1 < texto.Length && texto[i + 1] == '"')
                        {
                            valorActual.Append('"');
                            i++;
                        }
                        else
                        {
                            enComillas = false;
                        }
                    }
                    else
                    {
                        valorActual.Append(c);
                    }

                    continue;
                }

                if (c == '"') enComillas = true;
                else if (c == ',')
                {
                    filaActual.Add(valorActual.ToString());
                    valorActual.Clear();
                }
                else if (c == '\r' || c == '\n')
                {
                    filaActual.Add(valorActual.ToString());
                    valorActual.Clear();
                    if (c == '\r' && i + 1 < texto.Length && texto[i + 1] == '\n') i++;
                    resultado.Add(filaActual);
                    filaActual = new List<string>();
                }
                else valorActual.Append(c);
            }

            filaActual.Add(valorActual.ToString());
            if (filaActual.Any(c => !string.IsNullOrWhiteSpace(c)) || !resultado.Any()) resultado.Add(filaActual);
            return resultado;
        }

        private static List<List<string>> LeerXls(byte[] contenido, string extension)
        {
            string rutaTemporal = Path.Combine(Path.GetTempPath(), Guid.NewGuid().ToString("N") + extension);
            File.WriteAllBytes(rutaTemporal, contenido);
            try
            {
                var filas = new List<List<string>>();
                string connectionString = $"Provider=Microsoft.ACE.OLEDB.12.0;Data Source={rutaTemporal};Extended Properties=\"Excel 8.0;HDR=YES;IMEX=1\";";
                using (var connection = new OleDbConnection(connectionString))
                {
                    connection.Open();
                    var schema = connection.GetOleDbSchemaTable(OleDbSchemaGuid.Tables, null);
                    string sheetName = schema.Rows.Cast<DataRow>()
                        .Select(r => Convert.ToString(r["TABLE_NAME"]))
                        .FirstOrDefault(n => !string.IsNullOrWhiteSpace(n));
                    using (var adapter = new OleDbDataAdapter($"SELECT * FROM [{sheetName}]", connection))
                    {
                        var table = new DataTable();
                        adapter.Fill(table);
                        filas.Add(table.Columns.Cast<DataColumn>().Select(c => Convert.ToString(c.ColumnName)).ToList());
                        foreach (DataRow row in table.Rows)
                        {
                            filas.Add(table.Columns.Cast<DataColumn>().Select(c => Convert.ToString(row[c] ?? string.Empty)).ToList());
                        }
                    }
                }
                return filas;
            }
            finally
            {
                if (File.Exists(rutaTemporal)) File.Delete(rutaTemporal);
            }
        }

        private static List<List<string>> LeerXlsx(byte[] contenido)
        {
            using (var stream = new MemoryStream(contenido))
            using (var zip = new ZipArchive(stream, ZipArchiveMode.Read, false))
            {
                XNamespace ns = "http://schemas.openxmlformats.org/spreadsheetml/2006/main";
                XNamespace relNs = "http://schemas.openxmlformats.org/officeDocument/2006/relationships";
                XNamespace pkgRelNs = "http://schemas.openxmlformats.org/package/2006/relationships";

                var workbookEntry = zip.GetEntry("xl/workbook.xml");
                var workbookRelsEntry = zip.GetEntry("xl/_rels/workbook.xml.rels");
                XDocument workbookDoc;
                XDocument workbookRelsDoc;
                using (var workbookStream = workbookEntry.Open())
                {
                    workbookDoc = XDocument.Load(workbookStream);
                }
                using (var relsStream = workbookRelsEntry.Open())
                {
                    workbookRelsDoc = XDocument.Load(relsStream);
                }

                var firstSheet = workbookDoc.Descendants(ns + "sheet").First();
                string relationId = (string)firstSheet.Attribute(relNs + "id");
                string target = workbookRelsDoc.Descendants(pkgRelNs + "Relationship")
                    .Where(r => string.Equals((string)r.Attribute("Id"), relationId, StringComparison.Ordinal))
                    .Select(r => (string)r.Attribute("Target"))
                    .First();

                var sharedStrings = LeerSharedStrings(zip, ns);
                var filas = new List<List<string>>();
                var sheetEntry = zip.GetEntry("xl/" + target.TrimStart('/').Replace("\\", "/"));
                using (var sheetStream = sheetEntry.Open())
                {
                    var sheetDoc = XDocument.Load(sheetStream);
                    foreach (var row in sheetDoc.Descendants(ns + "row"))
                    {
                        var celdas = new SortedDictionary<int, string>();
                        foreach (var cell in row.Elements(ns + "c"))
                        {
                            string referencia = (string)cell.Attribute("r");
                            int columna = ObtenerIndiceColumna(referencia);
                            celdas[columna] = LeerValorCelda(cell, ns, sharedStrings);
                        }

                        if (!celdas.Any()) continue;
                        int maxColumna = celdas.Keys.Max();
                        var fila = new List<string>();
                        for (int i = 0; i <= maxColumna; i++)
                        {
                            string valor;
                            fila.Add(celdas.TryGetValue(i, out valor) ? valor : string.Empty);
                        }
                        filas.Add(fila);
                    }
                }

                return filas;
            }
        }

        private static List<string> LeerSharedStrings(ZipArchive zip, XNamespace ns)
        {
            var entry = zip.GetEntry("xl/sharedStrings.xml");
            if (entry == null) return new List<string>();

            using (var stream = entry.Open())
            {
                var doc = XDocument.Load(stream);
                return doc.Descendants(ns + "si")
                    .Select(si => string.Concat(si.Descendants(ns + "t").Select(t => t.Value)))
                    .ToList();
            }
        }

        private static string LeerValorCelda(XElement cell, XNamespace ns, List<string> sharedStrings)
        {
            string type = (string)cell.Attribute("t");
            if (string.Equals(type, "inlineStr", StringComparison.OrdinalIgnoreCase))
            {
                return string.Concat(cell.Descendants(ns + "t").Select(t => t.Value));
            }

            var valueElement = cell.Element(ns + "v");
            if (valueElement == null)
            {
                return string.Empty;
            }

            string rawValue = valueElement.Value ?? string.Empty;
            if (string.Equals(type, "s", StringComparison.OrdinalIgnoreCase))
            {
                int index;
                return int.TryParse(rawValue, out index) && index >= 0 && index < sharedStrings.Count
                    ? sharedStrings[index]
                    : string.Empty;
            }

            if (string.Equals(type, "b", StringComparison.OrdinalIgnoreCase))
            {
                return rawValue == "1" ? "TRUE" : "FALSE";
            }

            return rawValue;
        }

        private static int ObtenerIndiceColumna(string referencia)
        {
            if (string.IsNullOrWhiteSpace(referencia))
            {
                return 0;
            }

            int indice = 0;
            foreach (char c in referencia.ToUpperInvariant())
            {
                if (c < 'A' || c > 'Z')
                {
                    break;
                }

                indice = (indice * 26) + (c - 'A' + 1);
            }

            return Math.Max(0, indice - 1);
        }

        private static string ObtenerNombreProductoPorId(int proId)
        {
            if (proId <= 0) return string.Empty;
            try
            {
                using (var db = new Capa_Datos.MonolitoDataContext())
                {
                    var prod = db.tbl_producto.FirstOrDefault(p => p.pro_id == proId);
                    return prod != null ? prod.pro_nombre : string.Empty;
                }
            }
            catch
            {
                return string.Empty;
            }
        }
    }
}
