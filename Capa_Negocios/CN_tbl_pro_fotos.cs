using Capa_Datos;
using System;
using System.Collections.Generic;
using System.Data.Linq;
using System.Linq;
using System.IO;

namespace Capa_Negocios
{
    public class CN_tbl_pro_fotos
    {
        private const string NombreProductoPredeterminado = "Sin producto";

        public static List<tbl_pro_fotos> ObtenerPorProducto(int proId)
        {
            using (var db = new MonolitoDataContext())
            {
                var query = db.tbl_pro_fotos
                              .Where(f => f.pro_id == proId)
                              .OrderByDescending(f => f.fecha_subida);
                return query.ToList();
            }
        }

        public static string EliminarFisico(int fotoId)
        {
            using (var db = new MonolitoDataContext())
            {
                var foto = db.tbl_pro_fotos.FirstOrDefault(f => f.foto_id == fotoId);
                if (foto == null) throw new Exception("Foto no encontrada.");

                string ruta = foto.foto_ruta;
                db.tbl_pro_fotos.DeleteOnSubmit(foto);
                db.SubmitChanges();
                return ruta;
            }
        }

        public static List<tbl_pro_fotos> ObtenerConProducto(int productoId)
        {
            using (var db = new MonolitoDataContext())
            {
                var query = db.tbl_pro_fotos
                    .Where(f => f.pro_id == productoId)
                    .Select(f => new
                    {
                        f.foto_id,
                        f.pro_id,
                        f.foto_bit,
                        f.foto_ruta,
                        f.foto_estado,
                        f.fecha_subida,
                        pro_nombre = f.tbl_producto.pro_nombre
                    })
                    .OrderByDescending(f => f.fecha_subida);

                var datosCrudos = query.ToList();

                return datosCrudos.Select(x => new tbl_pro_fotos
                {
                    foto_id = x.foto_id,
                    pro_id = x.pro_id,
                    foto_bit = x.foto_bit,
                    foto_ruta = x.foto_ruta,
                    foto_estado = x.foto_estado,
                    fecha_subida = x.fecha_subida,
                    tbl_producto = new tbl_producto
                    {
                        pro_nombre = x.pro_nombre
                    }
                }).ToList();
            }
        }

        public static List<tbl_pro_fotos> ObtenerPorProductoiN(int productoId)
        {
            return ObtenerPorProducto(productoId);
        }

        public static int Contar(int productoId)
        {
            using (var db = new MonolitoDataContext())
            {
                var query = db.tbl_pro_fotos.Where(f => f.pro_id == productoId);
                return query.Count();
            }
        }

        public static tbl_pro_fotos BuscarPorId(int fotoId)
        {
            using (var db = new MonolitoDataContext())
            {
                var query = db.tbl_pro_fotos.Where(f => f.foto_id == fotoId);
                return query.FirstOrDefault();
            }
        }

        public static List<FotoCargaFila> LeerArchivoCargaMasiva(byte[] contenidoArchivo, string nombreArchivo)
        {
            return FotoCargaMasivaParser.Leer(contenidoArchivo, nombreArchivo);
        }

        public static byte[] GenerarExcelRutasDesdePlantilla(byte[] plantilla, IEnumerable<FotoRutaPreparada> rutas, int productoId = 0)
        {
            return FotoCargaMasivaParser.GenerarExcelDesdePlantilla(plantilla, rutas, productoId);
        }

        public static ResultadoCargaFotos ProcesarCargaMasiva(IEnumerable<FotoCargaFila> filas, TipoInsercionProveedor tipoInsercion)
        {
            var resultado = new ResultadoCargaFotos
            {
                FilasProcesadas = 0
            };
            var filasNormalizadas = NormalizarFilasCarga(filas, resultado);
            resultado.FilasProcesadas = filasNormalizadas.Count;

            using (var scope = new System.Transactions.TransactionScope(
                System.Transactions.TransactionScopeOption.Required,
                new System.Transactions.TransactionOptions
                {
                    IsolationLevel = System.Transactions.IsolationLevel.ReadCommitted
                }))
            {
                using (var db = new MonolitoDataContext())
                {
                    if (tipoInsercion == TipoInsercionProveedor.ReemplazarTodo)
                    {
                        EjecutarReemplazoTotal(db, filasNormalizadas, resultado);
                    }
                    else
                    {
                        EjecutarCargaIncremental(db, filasNormalizadas, resultado);
                    }
                }

                scope.Complete();
            }

            return resultado;
        }

        public static void GuardarFotos(List<tbl_pro_fotos> fotos)
        {
            try
            {
                using (var db = new MonolitoDataContext())
                {
                    db.tbl_pro_fotos.InsertAllOnSubmit(fotos);
                    db.SubmitChanges();
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error al guardar fotos: " + ex.Message);
            }
        }

        public static void Guardar(tbl_pro_fotos foto)
        {
            try
            {
                using (var db = new MonolitoDataContext())
                {
                    foto.fecha_subida = DateTime.Now;
                    foto.foto_estado = 'A';
                    db.tbl_pro_fotos.InsertOnSubmit(foto);
                    db.SubmitChanges();
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error al guardar foto: " + ex.Message);
            }
        }

        public static void CambiarEstado(int fotoId, char nuevoEstado)
        {
            try
            {
                using (var db = new MonolitoDataContext())
                {
                    var foto = db.tbl_pro_fotos.FirstOrDefault(f => f.foto_id == fotoId)
                        ?? throw new Exception("Foto no encontrada.");
                    foto.foto_estado = nuevoEstado;
                    db.SubmitChanges();
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Error al cambiar estado de foto: " + ex.Message);
            }
        }

        public static tbl_pro_fotos ObtenerFallback(int fotoId)
        {
            using (var db = new MonolitoDataContext())
            {
                var query = db.tbl_pro_fotos.Where(f => f.foto_id == fotoId && f.foto_bit != null);
                return query.FirstOrDefault();
            }
        }

        public static tbl_pro_fotos ObtenerParaResolver(int fotoId)
        {
            using (var db = new MonolitoDataContext())
            {
                var query = db.tbl_pro_fotos
                    .Where(f => f.foto_id == fotoId)
                    .Select(f => new
                    {
                        f.foto_id,
                        f.foto_bit,
                        f.foto_ruta
                    });

                var result = query.FirstOrDefault();
                if (result == null) return null;

                return new tbl_pro_fotos
                {
                    foto_id = result.foto_id,
                    foto_bit = result.foto_bit,
                    foto_ruta = result.foto_ruta
                };
            }
        }

        private static List<FotoCargaFilaNormalizada> NormalizarFilasCarga(IEnumerable<FotoCargaFila> filas, ResultadoCargaFotos resultado)
        {
            var normalizadas = new List<FotoCargaFilaNormalizada>();
            var ids = new HashSet<int>();
            var rutas = new HashSet<string>(StringComparer.OrdinalIgnoreCase);

            foreach (var f in filas ?? Enumerable.Empty<FotoCargaFila>())
            {
                string rutaNormalizada = NormalizarRuta(f.RutaFoto);
                if (!string.Equals(rutaNormalizada, f.RutaFoto ?? string.Empty, StringComparison.Ordinal))
                {
                    resultado.CorregidosAutomaticamente++;
                }

                if (f.FotoId.HasValue && !ids.Add(f.FotoId.Value))
                {
                    resultado.Omitidos++;
                    continue;
                }

                if (!string.IsNullOrWhiteSpace(rutaNormalizada) && !rutas.Add(rutaNormalizada))
                {
                    resultado.Omitidos++;
                    continue;
                }

                if ((f.FotoBit == null || f.FotoBit.Length == 0) && string.IsNullOrWhiteSpace(rutaNormalizada))
                {
                    resultado.Omitidos++;
                    continue;
                }

                if (f.FotoBit != null && f.FotoBit.Length > 0)
                {
                    if (f.FotoBit.Length > 2 * 1024 * 1024 || !EsImagenSoportada(f.FotoBit))
                    {
                        resultado.Omitidos++;
                        continue;
                    }
                }

                normalizadas.Add(new FotoCargaFilaNormalizada
                {
                    NumeroFilaArchivo = f.NumeroFilaArchivo,
                    FotoId = f.FotoId,
                    ProductoIdentificador = f.ProductoIdentificador,
                    ProductoId = 0,
                    RutaFoto = rutaNormalizada,
                    FotoBit = f.FotoBit,
                    EstadoFoto = f.EstadoFoto == 'I' ? 'I' : 'A'
                });
            }

            if (!normalizadas.Any())
            {
                throw new Exception("No hay filas preparadas para importar.");
            }

            return normalizadas;
        }

        private static void EjecutarCargaIncremental(MonolitoDataContext dc, List<FotoCargaFilaNormalizada> filas, ResultadoCargaFotos resultado)
        {
            var productosDb = dc.tbl_producto.ToList();
            var productosPorId = productosDb.ToDictionary(p => p.pro_id, p => p.pro_id);
            var productosPorNombre = new Dictionary<string, int>(StringComparer.OrdinalIgnoreCase);
            foreach (var p in productosDb)
            {
                if (!string.IsNullOrWhiteSpace(p.pro_nombre))
                {
                    string nom = p.pro_nombre.Trim();
                    if (!productosPorNombre.ContainsKey(nom))
                    {
                        productosPorNombre[nom] = p.pro_id;
                    }
                }
            }

            int? productoFallbackId = null;
            var existentes = dc.tbl_pro_fotos.ToList();
            var porId = existentes.ToDictionary(f => f.foto_id);
            var insertarConId = new List<FotoCargaFilaNormalizada>();
            var insertarSinId = new List<FotoCargaFilaNormalizada>();

            foreach (var fila in filas)
            {
                fila.ProductoId = ResolverProductoRelacionado(dc, productosPorId, productosPorNombre, fila, resultado, ref productoFallbackId);

                tbl_pro_fotos existente = null;
                if (fila.FotoId.HasValue)
                {
                    porId.TryGetValue(fila.FotoId.Value, out existente);
                }

                if (existente != null)
                {
                    existente.pro_id = fila.ProductoId;
                    existente.foto_ruta = fila.RutaFoto;
                    existente.foto_bit = fila.FotoBit;
                    existente.foto_estado = fila.EstadoFoto;
                    if (existente.fecha_subida == default(DateTime))
                    {
                        existente.fecha_subida = DateTime.Now;
                    }
                    resultado.Actualizados++;
                    continue;
                }

                if (fila.FotoId.HasValue) insertarConId.Add(fila);
                else insertarSinId.Add(fila);
            }

            dc.SubmitChanges();
            InsertarFotosConId(dc, insertarConId);
            resultado.Insertados += insertarConId.Count;

            if (insertarSinId.Any())
            {
                var nuevas = insertarSinId.Select(f => new tbl_pro_fotos
                {
                    pro_id = f.ProductoId,
                    foto_ruta = f.RutaFoto,
                    foto_bit = f.FotoBit,
                    foto_estado = f.EstadoFoto,
                    fecha_subida = DateTime.Now
                }).ToList();

                dc.tbl_pro_fotos.InsertAllOnSubmit(nuevas);
                dc.SubmitChanges();
                resultado.Insertados += nuevas.Count;
            }
        }

        private static void EjecutarReemplazoTotal(MonolitoDataContext dc, List<FotoCargaFilaNormalizada> filas, ResultadoCargaFotos resultado)
        {
            var productosDb = dc.tbl_producto.ToList();
            var productosPorId = productosDb.ToDictionary(p => p.pro_id, p => p.pro_id);
            var productosPorNombre = new Dictionary<string, int>(StringComparer.OrdinalIgnoreCase);
            foreach (var p in productosDb)
            {
                if (!string.IsNullOrWhiteSpace(p.pro_nombre))
                {
                    string nom = p.pro_nombre.Trim();
                    if (!productosPorNombre.ContainsKey(nom))
                    {
                        productosPorNombre[nom] = p.pro_id;
                    }
                }
            }

            int? productoFallbackId = null;
            foreach (var fila in filas)
            {
                fila.ProductoId = ResolverProductoRelacionado(dc, productosPorId, productosPorNombre, fila, resultado, ref productoFallbackId);
            }

            var fotos = dc.tbl_pro_fotos.ToList();
            if (fotos.Any())
            {
                dc.tbl_pro_fotos.DeleteAllOnSubmit(fotos);
                dc.SubmitChanges();
            }

            dc.ExecuteCommand("DBCC CHECKIDENT ('dbo.tbl_pro_fotos', RESEED, 0)");

            var insertarConId = filas.Where(f => f.FotoId.HasValue).ToList();
            var insertarSinId = filas.Where(f => !f.FotoId.HasValue).ToList();

            InsertarFotosConId(dc, insertarConId);
            resultado.Insertados += insertarConId.Count;

            if (insertarSinId.Any())
            {
                var nuevas = insertarSinId.Select(f => new tbl_pro_fotos
                {
                    pro_id = f.ProductoId,
                    foto_ruta = f.RutaFoto,
                    foto_bit = f.FotoBit,
                    foto_estado = f.EstadoFoto,
                    fecha_subida = DateTime.Now
                }).ToList();

                dc.tbl_pro_fotos.InsertAllOnSubmit(nuevas);
                dc.SubmitChanges();
                resultado.Insertados += nuevas.Count;
            }
        }

        private static void InsertarFotosConId(MonolitoDataContext dc, IEnumerable<FotoCargaFilaNormalizada> filas)
        {
            var lista = (filas ?? Enumerable.Empty<FotoCargaFilaNormalizada>()).ToList();
            if (!lista.Any()) return;

            dc.ExecuteCommand("SET IDENTITY_INSERT dbo.tbl_pro_fotos ON");
            try
            {
                foreach (var fila in lista)
                {
                    dc.ExecuteCommand(
                        "INSERT INTO dbo.tbl_pro_fotos (foto_id, pro_id, foto_bit, foto_ruta, fecha_subida, foto_estado) VALUES ({0}, {1}, {2}, {3}, {4}, {5})",
                        fila.FotoId.Value, fila.ProductoId, fila.FotoBit, fila.RutaFoto, DateTime.Now, fila.EstadoFoto);
                }
            }
            finally
            {
                dc.ExecuteCommand("SET IDENTITY_INSERT dbo.tbl_pro_fotos OFF");
            }
        }

        private static int ResolverProductoRelacionado(
            MonolitoDataContext dc,
            Dictionary<int, int> productosPorId,
            Dictionary<string, int> productosPorNombre,
            FotoCargaFilaNormalizada fila,
            ResultadoCargaFotos resultado,
            ref int? productoFallbackId)
        {
            string identificador = (fila.ProductoIdentificador ?? string.Empty).Trim();
            if (string.IsNullOrEmpty(identificador))
            {
                return ObtenerFallbackId(dc, ref productoFallbackId, resultado);
            }

            int id;
            if (int.TryParse(identificador, out id))
            {
                if (productosPorId.ContainsKey(id))
                {
                    return id;
                }
            }

            // Búsqueda case-insensitive: el dict usa OrdinalIgnoreCase, la clave puede tener cualquier capitalización
            string nombreBusqueda = identificador.Trim();
            if (productosPorNombre.ContainsKey(nombreBusqueda))
            {
                return productosPorNombre[nombreBusqueda];
            }

            // Fallback: buscar directamente en BD ignorando mayúsculas
            string nombreLower = nombreBusqueda.ToLowerInvariant();
            var prodDb = dc.tbl_producto.ToList().FirstOrDefault(p => p.pro_nombre != null && p.pro_nombre.Trim().ToLowerInvariant() == nombreLower);
            if (prodDb != null)
            {
                productosPorNombre[prodDb.pro_nombre.Trim()] = prodDb.pro_id;
                productosPorId[prodDb.pro_id] = prodDb.pro_id;
                return prodDb.pro_id;
            }

            return ObtenerFallbackId(dc, ref productoFallbackId, resultado);
        }

        private static int ObtenerFallbackId(MonolitoDataContext dc, ref int? productoFallbackId, ResultadoCargaFotos resultado)
        {
            if (!productoFallbackId.HasValue)
            {
                productoFallbackId = ObtenerOCrearProductoPredeterminado(dc);
            }
            resultado.FotosSinProducto++;
            return productoFallbackId.Value;
        }

        private static string NormalizarRuta(string ruta)
        {
            string limpia = (ruta ?? string.Empty).Trim().Replace("\\", "/");
            limpia = limpia.TrimStart('~').TrimStart('/');
            return limpia;
        }

        private static bool EsImagenSoportada(byte[] contenido)
        {
            if (contenido == null || contenido.Length < 4)
            {
                return false;
            }

            bool esJpg = contenido[0] == 0xFF && contenido[1] == 0xD8;
            bool esPng = contenido[0] == 0x89 && contenido[1] == 0x50 && contenido[2] == 0x4E && contenido[3] == 0x47;
            return esJpg || esPng;
        }

        private static int ObtenerOCrearProductoPredeterminado(MonolitoDataContext dc)
        {
            var producto = dc.tbl_producto.FirstOrDefault(p => p.pro_nombre == NombreProductoPredeterminado);
            if (producto == null)
            {
                producto = new tbl_producto
                {
                    pro_nombre = NombreProductoPredeterminado,
                    pro_cantidad = 0,
                    pro_precio = 0m,
                    pro_estado = 'A',
                    prov_id = null
                };
                dc.tbl_producto.InsertOnSubmit(producto);
                dc.SubmitChanges();
            }
            else if (producto.pro_estado != 'A')
            {
                producto.pro_estado = 'A';
                dc.SubmitChanges();
            }

            return producto.pro_id;
        }
    }
}
