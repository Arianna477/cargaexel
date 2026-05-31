using System;
using System.Collections.Generic;
using System.Data.Linq;
using System.Linq;
using Capa_Datos;

namespace Capa_Negocios
{
    public class CN_tbl_producto
    {
        private static MonolitoDataContext dc = new MonolitoDataContext();
        private const string NombreProveedorPredeterminado = "Sin proveedor";

        private class FotoProyectada
        {
            public int foto_id { get; set; }
            public int pro_id { get; set; }
            public string foto_ruta { get; set; }
            public DateTime fecha_subida { get; set; }
            public char? foto_estado { get; set; }
        }

        private class ProductoProyectado
        {
            public int pro_id { get; set; }
            public string pro_nombre { get; set; }
            public int? pro_cantidad { get; set; }
            public decimal? pro_precio { get; set; }
            public char? pro_estado { get; set; }
            public int? prov_id { get; set; }
            public string prov_nombre { get; set; }
            public List<FotoProyectada> fotos { get; set; }
        }

        private static List<tbl_producto> ConvertirProyeccion(IEnumerable<ProductoProyectado> lista)
        {
            return lista.Select(p =>
            {
                var prod = new tbl_producto
                {
                    pro_id = p.pro_id,
                    pro_nombre = p.pro_nombre,
                    pro_cantidad = p.pro_cantidad,
                    pro_precio = p.pro_precio,
                    pro_estado = p.pro_estado,
                    prov_id = p.prov_id,
                    tbl_proveedor = new tbl_proveedor { prov_nombre = string.IsNullOrWhiteSpace(p.prov_nombre) ? "Sin proveedor" : p.prov_nombre }
                };
                var set = new EntitySet<tbl_pro_fotos>();
                set.AddRange(p.fotos.Select(f => new tbl_pro_fotos
                {
                    foto_id = f.foto_id,
                    pro_id = f.pro_id,
                    foto_ruta = f.foto_ruta,
                    fecha_subida = f.fecha_subida,
                    foto_estado = f.foto_estado
                }));
                prod.tbl_pro_fotos = set;
                return prod;
            }).ToList();
        }

        private static IEnumerable<tbl_producto> QueryConRelaciones(bool ordenarAscendente)
        {
            var query = dc.tbl_producto
                .OrderBy(p => ordenarAscendente ? p.pro_id : -p.pro_id)
                .Select(p => new ProductoProyectado
                {
                    pro_id = p.pro_id,
                    pro_nombre = p.pro_nombre,
                    pro_cantidad = p.pro_cantidad,
                    pro_precio = p.pro_precio,
                    pro_estado = p.pro_estado,
                    prov_id = p.prov_id,
                    prov_nombre = p.tbl_proveedor != null ? p.tbl_proveedor.prov_nombre : null,
                    fotos = p.tbl_pro_fotos
                              .Select(f => new FotoProyectada
                              {
                                  foto_id = f.foto_id,
                                  pro_id = f.pro_id,
                                  foto_ruta = f.foto_ruta,
                                  fecha_subida = f.fecha_subida,
                                  foto_estado = f.foto_estado
                              }).ToList()
                }).ToList();

            return ConvertirProyeccion(query);
        }

        public static List<tbl_producto> Listar(bool ordenarAscendente = false)
            => QueryConRelaciones(ordenarAscendente).ToList();

        public static tbl_producto BuscarPorId(int id)
        {
            return dc.tbl_producto.FirstOrDefault(p => p.pro_id == id);
        }

        public static List<tbl_producto> traerproductos()
        {
            return dc.tbl_producto.Where(p => p.pro_estado == 'A').ToList();
        }

        public static tbl_producto traerproductoxid(int id)
        {
            return dc.tbl_producto.FirstOrDefault(p => p.pro_id == id && p.pro_estado == 'A');
        }

        public static List<tbl_producto> Buscar(
            string nombre = null,
            int? proveedorId = null,
            char? estado = null,
            decimal? precioMin = null,
            decimal? precioMax = null,
            int? stockMin = null,
            int? stockMax = null,
            bool ordenarAscendente = false)
        {
            var query = dc.tbl_producto.AsQueryable();

            if (!string.IsNullOrWhiteSpace(nombre))
                query = query.Where(p => p.pro_nombre.Contains(nombre));
            if (proveedorId.HasValue && proveedorId.Value == -1)
                query = query.Where(p => !p.prov_id.HasValue);
            else if (proveedorId.HasValue)
                query = query.Where(p => p.prov_id == proveedorId.Value);
            if (estado.HasValue)
                query = query.Where(p => p.pro_estado == estado.Value);
            if (precioMin.HasValue)
                query = query.Where(p => p.pro_precio >= precioMin.Value);
            if (precioMax.HasValue)
                query = query.Where(p => p.pro_precio <= precioMax.Value);
            if (stockMin.HasValue)
                query = query.Where(p => p.pro_cantidad >= stockMin.Value);
            if (stockMax.HasValue)
                query = query.Where(p => p.pro_cantidad <= stockMax.Value);

            var resultados = query
                .OrderBy(p => ordenarAscendente ? p.pro_id : -p.pro_id)
                .Select(p => new ProductoProyectado
                {
                    pro_id = p.pro_id,
                    pro_nombre = p.pro_nombre,
                    pro_cantidad = p.pro_cantidad,
                    pro_precio = p.pro_precio,
                    pro_estado = p.pro_estado,
                    prov_id = p.prov_id,
                    prov_nombre = p.tbl_proveedor != null ? p.tbl_proveedor.prov_nombre : null,
                    fotos = p.tbl_pro_fotos
                              .Select(f => new FotoProyectada
                              {
                                  foto_id = f.foto_id,
                                  pro_id = f.pro_id,
                                  foto_ruta = f.foto_ruta,
                                  fecha_subida = f.fecha_subida,
                                  foto_estado = f.foto_estado
                              }).Take(5).ToList()
                }).ToList();

            return ConvertirProyeccion(resultados);
        }

        public static List<tbl_producto> BuscarPaginado(
            int pagina, int porPagina, out int totalRegistros,
            string nombre = null, int? proveedorId = null,
            char? estado = null, decimal? precioMin = null, decimal? precioMax = null, int? stockMin = null, int? stockMax = null,
            bool ordenarAscendente = false)
        {
            var todos = Buscar(nombre, proveedorId, estado, precioMin, precioMax, stockMin, stockMax, ordenarAscendente);
            totalRegistros = todos.Count;
            return todos.Skip((pagina - 1) * porPagina).Take(porPagina).ToList();
        }

        public static bool ExisteNombre(string nombre, int idIgnorar = 0)
        {
            return dc.tbl_producto.Any(p => p.pro_nombre == nombre && p.pro_estado == 'A' && p.pro_id != idIgnorar);
        }

        public static List<ProductoCargaFila> LeerArchivoCargaMasiva(byte[] contenidoArchivo, string nombreArchivo)
        {
            return ProductoCargaMasivaParser.Leer(contenidoArchivo, nombreArchivo);
        }

        public static byte[] GenerarPlantillaCargaMasiva(byte[] plantillaBase)
        {
            return ProductoCargaMasivaParser.GenerarExcelDesdePlantilla(plantillaBase);
        }

        public static ResultadoCargaProductos ProcesarCargaMasiva(IEnumerable<ProductoCargaFila> filas, TipoInsercionProveedor tipoInsercion)
        {
            var resultado = new ResultadoCargaProductos
            {
                FilasProcesadas = 0
            };
            var filasNormalizadas = NormalizarFilasCarga(filas, resultado);
            resultado.FilasProcesadas = filasNormalizadas.Count;

            using (var scope = new System.Transactions.TransactionScope(System.Transactions.TransactionScopeOption.Required,
                new System.Transactions.TransactionOptions
                {
                    IsolationLevel = System.Transactions.IsolationLevel.ReadCommitted
                }))
            {
                if (tipoInsercion == TipoInsercionProveedor.ReemplazarTodo)
                {
                    EjecutarReemplazoTotal(dc, filasNormalizadas, resultado);
                }
                else
                {
                    EjecutarCargaIncremental(dc, filasNormalizadas, resultado);
                }

                scope.Complete();
            }

            return resultado;
        }

        public static void Guardar(tbl_producto producto)
        {
            try
            {
                producto.prov_id = ValidarProveedorExistente(dc, producto.prov_id);
                producto.pro_estado = 'A';
                dc.tbl_producto.InsertOnSubmit(producto);
                dc.SubmitChanges();
            }
            catch (Exception ex) { throw new Exception("Error al guardar el producto: " + ex.Message); }
        }

        public static void Modificar(tbl_producto producto)
        {
            try
            {
                var e = dc.tbl_producto.FirstOrDefault(p => p.pro_id == producto.pro_id)
                    ?? throw new Exception("Producto no encontrado.");
                e.pro_nombre = producto.pro_nombre;
                e.pro_cantidad = producto.pro_cantidad;
                e.pro_precio = producto.pro_precio;
                e.prov_id = ValidarProveedorExistente(dc, producto.prov_id);
                dc.SubmitChanges();
            }
            catch (Exception ex) { throw new Exception("Error al modificar el producto: " + ex.Message); }
        }

        public static void Activar(int id)
        {
            try
            {
                var prod = dc.tbl_producto.FirstOrDefault(p => p.pro_id == id)
                    ?? throw new Exception("Producto no encontrado.");
                prod.pro_estado = 'A';
                dc.SubmitChanges();
            }
            catch (Exception ex) { throw new Exception("Error al activar el producto: " + ex.Message); }
        }

        public static void EliminarLogico(int id)
        {
            try
            {
                var prod = dc.tbl_producto.FirstOrDefault(p => p.pro_id == id)
                    ?? throw new Exception("Producto no encontrado.");
                prod.pro_estado = 'I';
                dc.SubmitChanges();
            }
            catch (Exception ex) { throw new Exception("Error al desactivar el producto: " + ex.Message); }
        }

        public static List<string> EliminarFisico(int id)
        {
            try
            {
                var prod = dc.tbl_producto.FirstOrDefault(p => p.pro_id == id)
                    ?? throw new Exception("Producto no encontrado.");

                var fotos = dc.tbl_pro_fotos.Where(f => f.pro_id == id).ToList();
                var rutas = fotos.Select(f => f.foto_ruta).Where(r => !string.IsNullOrWhiteSpace(r)).Distinct().ToList();

                if (fotos.Any())
                {
                    dc.tbl_pro_fotos.DeleteAllOnSubmit(fotos);
                }

                dc.tbl_producto.DeleteOnSubmit(prod);
                dc.SubmitChanges();
                return rutas;
            }
            catch (Exception ex) { throw new Exception("Error al eliminar el producto: " + ex.Message); }
        }

        private static List<ProductoCargaFilaNormalizada> NormalizarFilasCarga(IEnumerable<ProductoCargaFila> filas, ResultadoCargaProductos resultado)
        {
            var normalizadas = new List<ProductoCargaFilaNormalizada>();
            var nombres = new HashSet<string>();
            var ids = new HashSet<int>();

            // Precargamos el diccionario de proveedores activos para resolver por nombre
            var proveedoresPorNombre = dc.tbl_proveedor
                .Where(p => p.prov_estado == 'A')
                .ToList()
                .GroupBy(p => (p.prov_nombre ?? string.Empty).Trim().ToUpperInvariant())
                .ToDictionary(g => g.Key, g => g.First().prov_id);

            foreach (var f in filas ?? Enumerable.Empty<ProductoCargaFila>())
            {
                string nombreOriginal = f.NombreProducto ?? string.Empty;
                string nombreSaneado = SanearNombre(nombreOriginal);
                if (nombreSaneado != nombreOriginal.Trim())
                {
                    resultado.CorregidosAutomaticamente++;
                }

                if (string.IsNullOrWhiteSpace(nombreSaneado))
                {
                    resultado.Omitidos++;
                    continue;
                }

                string nombreNormalizado = NormalizarNombreProductoCarga(nombreSaneado);
                if (!nombres.Add(nombreNormalizado))
                {
                    resultado.Omitidos++;
                    continue;
                }

                if (f.ProductoId.HasValue && !ids.Add(f.ProductoId.Value))
                {
                    resultado.Omitidos++;
                    continue;
                }

                // Resolver proveedor por nombre si se proporcionó
                int? proveedorId = f.ProveedorId;
                if (!string.IsNullOrWhiteSpace(f.ProveedorNombre))
                {
                    string clave = f.ProveedorNombre.Trim().ToUpperInvariant();
                    int idEncontrado;
                    proveedorId = proveedoresPorNombre.TryGetValue(clave, out idEncontrado) ? idEncontrado : (int?)null;
                }

                normalizadas.Add(new ProductoCargaFilaNormalizada
                {
                    NumeroFilaArchivo = f.NumeroFilaArchivo,
                    ProductoId = f.ProductoId,
                    NombreProducto = nombreSaneado,
                    NombreNormalizado = nombreNormalizado,
                    Cantidad = f.Cantidad,
                    Precio = f.Precio,
                    ProveedorId = proveedorId,
                    FotoRuta = NormalizarRutaFotoCarga(f.FotoRuta),
                    EstadoProducto = f.EstadoProducto == 'I' ? 'I' : 'A'
                });
            }

            if (!normalizadas.Any())
            {
                throw new Exception("No hay filas preparadas para importar.");
            }

            return normalizadas;
        }

        private static void EjecutarCargaIncremental(MonolitoDataContext dc, List<ProductoCargaFilaNormalizada> filas, ResultadoCargaProductos resultado)
        {
            var productosActuales = dc.tbl_producto.ToList();
            var productosPorId = productosActuales.ToDictionary(p => p.pro_id);
            var productosPorNombre = productosActuales.GroupBy(p => NormalizarNombreProductoCarga(p.pro_nombre)).ToDictionary(g => g.Key, g => g.First());
            var proveedoresValidos = dc.tbl_proveedor.Where(p => p.prov_estado == 'A').Select(p => p.prov_id).ToHashSet();
            int? proveedorFallbackId = null;
            var insertarConId = new List<ProductoCargaFilaNormalizada>();
            var insertarSinId = new List<ProductoCargaFilaNormalizada>();

            foreach (var fila in filas)
            {
                tbl_producto existente = null;
                if (fila.ProductoId.HasValue) productosPorId.TryGetValue(fila.ProductoId.Value, out existente);
                if (existente == null) productosPorNombre.TryGetValue(fila.NombreNormalizado, out existente);

                int? proveedorId = ResolverProveedorRelacionado(dc, proveedoresValidos, fila.ProveedorId, resultado, ref proveedorFallbackId);

                if (existente != null)
                {
                    existente.pro_nombre = fila.NombreProducto;
                    existente.pro_cantidad = fila.Cantidad;
                    existente.pro_precio = fila.Precio;
                    existente.pro_estado = fila.EstadoProducto;
                    existente.prov_id = proveedorId;
                    UpsertFotoDesdeCarga(dc, existente.pro_id, fila.FotoRuta, resultado);
                    resultado.Actualizados++;
                    continue;
                }

                fila.ProveedorId = proveedorId;
                if (fila.ProductoId.HasValue) insertarConId.Add(fila);
                else insertarSinId.Add(fila);
            }

            dc.SubmitChanges();
            InsertarProductosConId(dc, insertarConId);
            resultado.Insertados += insertarConId.Count;
            foreach (var fila in insertarConId)
            {
                UpsertFotoDesdeCarga(dc, fila.ProductoId.Value, fila.FotoRuta, resultado);
            }

            if (insertarSinId.Any())
            {
                foreach (var fila in insertarSinId)
                {
                    var nuevo = new tbl_producto
                    {
                        pro_nombre = fila.NombreProducto,
                        pro_cantidad = fila.Cantidad,
                        pro_precio = fila.Precio,
                        pro_estado = fila.EstadoProducto,
                        prov_id = fila.ProveedorId
                    };

                    dc.tbl_producto.InsertOnSubmit(nuevo);
                    dc.SubmitChanges();
                    resultado.Insertados++;
                    fila.ProductoId = nuevo.pro_id;
                    UpsertFotoDesdeCarga(dc, nuevo.pro_id, fila.FotoRuta, resultado);
                }
            }
        }

        private static void EjecutarReemplazoTotal(MonolitoDataContext dc, List<ProductoCargaFilaNormalizada> filas, ResultadoCargaProductos resultado)
        {
            var fotosRespaldadas = dc.tbl_pro_fotos
                .Select(f => new
                {
                    f.pro_id,
                    f.foto_bit,
                    f.foto_ruta,
                    f.fecha_subida,
                    f.foto_estado
                })
                .ToList();

            var fotos = dc.tbl_pro_fotos.ToList();
            resultado.FotosEliminadas = fotos.Count;
            if (fotos.Any())
            {
                dc.tbl_pro_fotos.DeleteAllOnSubmit(fotos);
                dc.SubmitChanges();
            }

            var productos = dc.tbl_producto.ToList();
            if (productos.Any())
            {
                dc.tbl_producto.DeleteAllOnSubmit(productos);
                dc.SubmitChanges();
            }

            dc.ExecuteCommand("DBCC CHECKIDENT ('dbo.tbl_pro_fotos', RESEED, 0)");
            dc.ExecuteCommand("DBCC CHECKIDENT ('dbo.tbl_producto', RESEED, 0)");

            var proveedoresValidos = dc.tbl_proveedor.Where(p => p.prov_estado == 'A').Select(p => p.prov_id).ToHashSet();
            int? proveedorFallbackId = null;
            foreach (var fila in filas)
            {
                int? proveedorId = ResolverProveedorRelacionado(dc, proveedoresValidos, fila.ProveedorId, resultado, ref proveedorFallbackId);

                var producto = new tbl_producto
                {
                    pro_nombre = fila.NombreProducto,
                    pro_cantidad = fila.Cantidad,
                    pro_precio = fila.Precio,
                    pro_estado = fila.EstadoProducto,
                    prov_id = proveedorId
                };

                dc.tbl_producto.InsertOnSubmit(producto);
                dc.SubmitChanges();
                fila.ProductoId = producto.pro_id;
                resultado.Insertados++;
            }

            var productosRecargados = dc.tbl_producto
                .Select(p => p.pro_id)
                .ToHashSet();

            var fotosAReinsertar = fotosRespaldadas
                .Where(f => productosRecargados.Contains(f.pro_id))
                .Select(f => new tbl_pro_fotos
                {
                    pro_id = f.pro_id,
                    foto_bit = f.foto_bit,
                    foto_ruta = f.foto_ruta,
                    fecha_subida = f.fecha_subida,
                    foto_estado = f.foto_estado
                })
                .ToList();

            if (fotosAReinsertar.Any())
            {
                dc.tbl_pro_fotos.InsertAllOnSubmit(fotosAReinsertar);
                dc.SubmitChanges();
            }

            foreach (var fila in filas)
            {
                UpsertFotoDesdeCarga(dc, fila.ProductoId ?? 0, fila.FotoRuta, resultado);
            }
        }

        private static void InsertarProductosConId(MonolitoDataContext dc, IEnumerable<ProductoCargaFilaNormalizada> filas)
        {
            var lista = (filas ?? Enumerable.Empty<ProductoCargaFilaNormalizada>()).ToList();
            if (!lista.Any()) return;

            dc.ExecuteCommand("SET IDENTITY_INSERT dbo.tbl_producto ON");
            try
            {
                foreach (var fila in lista)
                {
                    dc.ExecuteCommand(
                        "INSERT INTO dbo.tbl_producto (pro_id, pro_nombre, pro_cantidad, pro_precio, pro_estado, prov_id) VALUES ({0}, {1}, {2}, {3}, {4}, {5})",
                        fila.ProductoId.Value, fila.NombreProducto, fila.Cantidad, fila.Precio, fila.EstadoProducto, fila.ProveedorId);
                }
            }
            finally
            {
                dc.ExecuteCommand("SET IDENTITY_INSERT dbo.tbl_producto OFF");
            }
        }

        private static int? ValidarProveedorExistente(MonolitoDataContext dc, int? proveedorId)
        {
            if (!proveedorId.HasValue) return null;
            return dc.tbl_proveedor.Any(p => p.prov_id == proveedorId.Value && p.prov_estado == 'A')
                ? proveedorId
                : (int?)null;
        }

        private static int? ResolverProveedorRelacionado(
            MonolitoDataContext dc,
            HashSet<int> proveedoresValidos,
            int? proveedorId,
            ResultadoCargaProductos resultado,
            ref int? proveedorFallbackId)
        {
            if (!proveedorId.HasValue)
            {
                return null;
            }

            if (proveedoresValidos.Contains(proveedorId.Value))
            {
                return proveedorId;
            }

            if (!proveedorFallbackId.HasValue)
            {
                proveedorFallbackId = ObtenerOCrearProveedorPredeterminado(dc);
                proveedoresValidos.Add(proveedorFallbackId.Value);
            }

            resultado.ProductosSinProveedor++;
            return proveedorFallbackId;
        }

        private static int ObtenerOCrearProveedorPredeterminado(MonolitoDataContext dc)
        {
            var proveedor = dc.tbl_proveedor.FirstOrDefault(p => p.prov_nombre == NombreProveedorPredeterminado);
            if (proveedor == null)
            {
                proveedor = new tbl_proveedor
                {
                    prov_nombre = NombreProveedorPredeterminado,
                    prov_estado = 'A'
                };
                dc.tbl_proveedor.InsertOnSubmit(proveedor);
                dc.SubmitChanges();
            }
            else if (proveedor.prov_estado != 'A')
            {
                proveedor.prov_estado = 'A';
                dc.SubmitChanges();
            }

            return proveedor.prov_id;
        }

        private static void UpsertFotoDesdeCarga(MonolitoDataContext dc, int productoId, string fotoRuta, ResultadoCargaProductos resultado)
        {
            string rutaNormalizada = NormalizarRutaFotoCarga(fotoRuta);
            if (productoId <= 0 || string.IsNullOrWhiteSpace(rutaNormalizada))
            {
                return;
            }

            var fotoExistente = dc.tbl_pro_fotos
                .Where(f => f.pro_id == productoId)
                .OrderByDescending(f => f.fecha_subida)
                .ThenByDescending(f => f.foto_id)
                .FirstOrDefault();

            if (fotoExistente == null)
            {
                dc.tbl_pro_fotos.InsertOnSubmit(new tbl_pro_fotos
                {
                    pro_id = productoId,
                    foto_ruta = rutaNormalizada,
                    foto_bit = null,
                    foto_estado = 'A',
                    fecha_subida = DateTime.Now
                });
            }
            else
            {
                fotoExistente.foto_ruta = rutaNormalizada;
                fotoExistente.foto_bit = null;
                fotoExistente.foto_estado = 'A';
                fotoExistente.fecha_subida = DateTime.Now;
            }

            dc.SubmitChanges();
            resultado.FotosAsignadas++;
        }

        private static string NormalizarRutaFotoCarga(string ruta)
        {
            string limpia = (ruta ?? string.Empty).Trim().Replace("\\", "/");
            limpia = limpia.TrimStart('~').TrimStart('/');
            return limpia;
        }

        private static string SanearNombre(string nombre)
        {
            var partes = (nombre ?? string.Empty)
                .Trim()
                .Split(new[] { ' ', '\t', '\r', '\n' }, StringSplitOptions.RemoveEmptyEntries);
            return string.Join(" ", partes);
        }

        private static string NormalizarNombreProductoCarga(string nombre)
        {
            return (nombre ?? string.Empty).Trim().ToUpperInvariant();
        }
    }
}
