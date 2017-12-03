package casa.galgos;

import java.io.IOException;
import java.io.Serializable;
import java.nio.charset.Charset;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.file.StandardOpenOption;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collection;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.log4j.Logger;

import casa.galgos.gbgb.GalgoAgregados;
import casa.galgos.gbgb.GalgosGuardable;
import casa.galgos.gbgb.GbgbCarrera;
import casa.galgos.gbgb.GbgbDownloader;
import casa.galgos.gbgb.GbgbGalgoHistorico;
import casa.galgos.gbgb.GbgbGalgoHistoricoCarrera;
import casa.galgos.gbgb.GbgbParserCarreraDetalle;
import casa.galgos.gbgb.GbgbParserGalgoHistorico;
import casa.galgos.gbgb.GbgbPosicionEnCarrera;
import casa.galgos.sportium.SportiumCarrera;
import casa.galgos.sportium.SportiumDownloader;
import casa.galgos.sportium.SportiumParserCarrerasFuturas;
import casa.galgos.sportium.SportiumParserDetalleCarreraFutura;
import utilidades.Constantes;

public class GalgosManager implements Serializable {

	private static final long serialVersionUID = 1L;

	static Logger MY_LOGGER = Logger.getLogger(GalgosManager.class);

	public static final Integer DISTANCIA_CORTA = 1; // distancia<400m
	public static final Integer DISTANCIA_LONGITUD_MEDIA = 2;// 400m<=distancia<600m
	public static final Integer DISTANCIA_LARGA = 3;// distancia>=600m

	public static final Integer TIPO_VEL_REAL = 1;
	public static final Integer TIPO_VEL_CON_GOING = 2;

	public static final Integer TIPO_ESTADISTICO_MEDIANA = 1;
	public static final Integer TIPO_ESTADISTICO_MAXIMO = 2;

	public Map<String, Boolean> idCarrerasCampeonatoProcesadas = new HashMap<String, Boolean>(); // ID_carrera-ID_campeonato,
																									// procesada
																									// (boolean)
	public Map<String, Boolean> galgosYaGuardados = new HashMap<String, Boolean>();

	// LISTAS con datos DEFINITIVOS para guardar en sistema de ficheros
	public List<SportiumCarrera> galgosFuturos = new ArrayList<SportiumCarrera>(); // Galgos en los que vamos a apostar
																					// dinero real
	public List<GalgosGuardable> guardableCarreras = new ArrayList<GalgosGuardable>();
	public List<GalgosGuardable> guardablePosicionesEnCarreras = new ArrayList<GalgosGuardable>();
	public HashSet<String> urlsHistoricoGalgos = new HashSet<String>(); // URLs de historicos SIN DUPLICADOS
	public List<GalgosGuardable> guardableHistoricosGalgos = new ArrayList<GalgosGuardable>();
	public Map<String, GalgosGuardable> guardableGalgoAgregados = new HashMap<String, GalgosGuardable>();

	// --- SINGLETON
	private static GalgosManager instancia;

	private GalgosManager() {
	}

	public static GalgosManager getInstancia() {
		if (instancia == null) {
			instancia = new GalgosManager();
		}
		return instancia;
	}

	/**
	 * @param prefijoPathDatosBruto
	 * @param guardarEnFicheros
	 * @param fileGalgosIniciales
	 * @throws InterruptedException
	 */
	public void descargarYParsearSemillas(String prefijoPathDatosBruto, boolean guardarEnFicheros,
			String fileGalgosIniciales) throws InterruptedException {

		MY_LOGGER.info("Descargando carreras FUTURAS con sus galgos (semillas)...");

		(new SportiumDownloader()).descargarDeURLsAFicheros(Constantes.GALGOS_FUTUROS_SPORTIUM, prefijoPathDatosBruto,
				guardarEnFicheros);

		MY_LOGGER.info("Parseando carreras FUTURAS con sus galgos (semillas)...");
		galgosFuturos = (new SportiumParserCarrerasFuturas()).ejecutar(prefijoPathDatosBruto);

		MY_LOGGER.info("Filas parseadas: " + galgosFuturos.size());

		if (galgosFuturos != null && !galgosFuturos.isEmpty()) {

			String tag = "_BRUTOCARRERADET_";
			int contador = 0;
			SportiumParserDetalleCarreraFutura spdcf = new SportiumParserDetalleCarreraFutura();

			String pathCarreraDetalle = "";

			for (SportiumCarrera carrera : galgosFuturos) {
				contador++;
				pathCarreraDetalle = prefijoPathDatosBruto + tag + contador;

				(new SportiumDownloader()).descargarDeURLsAFicheros(carrera.urlDetalle, pathCarreraDetalle,
						guardarEnFicheros);

				spdcf.ejecutar(pathCarreraDetalle, carrera);

			}

			desnormalizarSemillasYGuardarlasEnFicheros(fileGalgosIniciales);

			MY_LOGGER.info("Carreras FUTURAS con sus galgos (semillas): OK");

		} else {
			MY_LOGGER.info("Carreras FUTURAS con sus galgos (semillas): ERROR!!!!");
		}

	}

	/**
	 * @param fileGalgosIniciales
	 */
	public void desnormalizarSemillasYGuardarlasEnFicheros(String fileGalgosIniciales) {

		// *********************************************************************
		// Desnormalizar, llevando a relaciones carrera-galgo
		Set<SportiumCarreraGalgo> carreraGalgos = new HashSet<SportiumCarreraGalgo>();
		for (SportiumCarrera carrera : galgosFuturos) {
			if (carrera.galgosNombres != null && !carrera.galgosNombres.isEmpty()) {
				for (String galgoNombre : carrera.galgosNombres) {

					String id = carrera.estadio + "#" + carrera.dia + "#" + carrera.hora + "#" + galgoNombre;
					carreraGalgos.add(new SportiumCarreraGalgo(id, galgoNombre, carrera));
				}
			}
		}

		// *********************************************************************
		Set<String> galgosIniciales = new HashSet<String>();
		for (SportiumCarreraGalgo fila : carreraGalgos) {
			galgosIniciales.add(fila.galgoNombre);
		}

		// ******************************************************************

		if (carreraGalgos != null && !carreraGalgos.isEmpty()) {

			String path = fileGalgosIniciales;
			String pathFull = fileGalgosIniciales + "_full";

			MY_LOGGER.info("Guardando GALGOS SEMILLA en: " + path);
			MY_LOGGER.info("Guardando CARRERA-GALGO SEMILLA en: " + pathFull);

			try {

				MY_LOGGER.debug("Borrando posibles ficheros preexistentes...");
				Files.deleteIfExists(Paths.get(path));
				Files.deleteIfExists(Paths.get(pathFull));

				MY_LOGGER.debug("Escribiendo...");

				// ****************************
				boolean primero = true;
				for (String galgoNombre : galgosIniciales) {
					if (primero) {
						Files.write(Paths.get(path), (galgoNombre + "\n").getBytes(), StandardOpenOption.CREATE);
						primero = false;
					} else {
						Files.write(Paths.get(path), (galgoNombre + "\n").getBytes(), StandardOpenOption.APPEND);
					}
				}
				MY_LOGGER.info("Galgos iniciales: " + galgosIniciales.size());

				// ****************************
				primero = true;
				for (SportiumCarreraGalgo fila : carreraGalgos) {

					MY_LOGGER.debug("Fila=" + fila.toString());

					if (primero) {
						Files.write(Paths.get(pathFull), (fila.toString() + "\n").getBytes(),
								StandardOpenOption.CREATE);
						primero = false;
					} else {
						Files.write(Paths.get(pathFull), (fila.toString() + "\n").getBytes(),
								StandardOpenOption.APPEND);
					}
				}
				MY_LOGGER.info("Carrera-Galgo iniciales: " + carreraGalgos.size());

				// ******** LIMPIAR LISTAS, porque ya he guardado a fichero **********
				galgosFuturos.clear();
				carreraGalgos.clear();
				MY_LOGGER.debug("Limpiando lista en memoria. Estado de la lista tras limpiar: " + galgosFuturos.size());

			} catch (IOException e) {
				MY_LOGGER.error("Error:" + e.getMessage());
				e.printStackTrace();
			}

		} else {
			MY_LOGGER.error("Sin datos. No guardamos fichero!!!");
		}
	}

	/**
	 * AUXILIAR
	 *
	 */
	private class SportiumCarreraGalgo {
		public String id;// dia#hora#estadio#galgo_nombre
		public String galgoNombre;
		public SportiumCarrera modelo;

		public SportiumCarreraGalgo(String id, String galgoNombre, SportiumCarrera modelo) {
			super();
			this.id = id;
			this.galgoNombre = galgoNombre;
			this.modelo = modelo;
		}

		@Override
		public String toString() {
			return id;
		}

	}

	/**
	 * @param prefijoPathDatosBruto
	 * @param guardarEnFicheros
	 * @param fileGalgosIniciales
	 * @throws InterruptedException
	 */
	public void descargarYparsearCarrerasDeGalgos(String prefijoPathDatosBruto, boolean guardarEnFicheros,
			String fileGalgosIniciales) throws InterruptedException {

		MY_LOGGER.info("MAX_NUM_CARRERAS_PROCESADAS = " + Constantes.MAX_NUM_CARRERAS_PROCESADAS);

		boolean primeraEscritura = true;

		GbgbParserGalgoHistorico gpgh = new GbgbParserGalgoHistorico();

		cargarUrlsHistoricosDeGalgosIniciales(fileGalgosIniciales);

		if (urlsHistoricoGalgos != null && !urlsHistoricoGalgos.isEmpty()) {

			descargarTodosLosHistoricos(prefijoPathDatosBruto, gpgh);

			// ------ Procesar las carreras de las que conozco la URL
			// (embuclandose)-----------------------------------

			do {

				MY_LOGGER.info("Carreras PENDIENTES de procesar: " + contarPendientes());
				MY_LOGGER.info("Carreras YA PROCESADAS: " + contarCarrerasYaProcesadas());

				Map<String, Boolean> pendientes = extraerSoloCarrerasPendientes();

				String idCarreraIdcampeonatoAProcesar = pendientes.keySet().iterator().next();

				MY_LOGGER.info("Procesando carrera " + idCarreraIdcampeonatoAProcesar + " ...");

				String[] partes = idCarreraIdcampeonatoAProcesar.split("-");

				GbgbCarrera carrera = descargarYProcesarCarreraYAcumularUrlsHistoricos(Long.valueOf(partes[0]),
						Long.valueOf(partes[1]), prefijoPathDatosBruto);

				if (carrera != null) {

					MY_LOGGER.debug("GUARDABLE - Anhadiendo " + carrera.posiciones.size() + " posiciones...");
					for (GbgbPosicionEnCarrera posicion : carrera.posiciones) {
						guardablePosicionesEnCarreras.add(posicion);
					}

					descargarTodosLosHistoricos(prefijoPathDatosBruto, gpgh);

				}

				// lo marco como procesado
				idCarrerasCampeonatoProcesadas.replace(idCarreraIdcampeonatoAProcesar, true);

				if (guardarEnFicheros && guardableHistoricosGalgos
						.size() >= Constantes.MAX_NUM_FILAS_EN_MEMORIA_SIN_ESCRIBIR_EN_FICHERO) {

					guardarEnFicheroYLimpiarLista(guardableCarreras, primeraEscritura);
					guardarEnFicheroYLimpiarLista(guardablePosicionesEnCarreras, primeraEscritura);
					guardarEnFicheroYLimpiarLista(guardableHistoricosGalgos, primeraEscritura);
					guardarEnFicheroYLimpiarLista(guardableGalgoAgregados.values(), primeraEscritura);

					primeraEscritura = false;
				}

				MY_LOGGER.debug("Esperando " + Constantes.ESPERA_ENTRE_DESCARGA_CARRERAS_MSEC + " mseg...");
				Thread.sleep(Constantes.ESPERA_ENTRE_DESCARGA_CARRERAS_MSEC);

			} while (contarPendientes() >= 1 && contarCarrerasYaProcesadas() <= Constantes.MAX_NUM_CARRERAS_PROCESADAS);

			MY_LOGGER.info("El BUCLE ha TERMINADO: carreras_pendientes (que no las vamos a procesar)="
					+ contarPendientes() + " carreras_guardadas=" + guardableCarreras.size() + " historicos_galgos="
					+ guardableHistoricosGalgos.size());

			// RESTANTES: fuera del bucle while, guardo lo que ya tenga descargado, pero no
			// descargo nada mas para evitar que me baneen.
			if (guardarEnFicheros) {
				guardarEnFicheroYLimpiarLista(guardableCarreras, primeraEscritura);
				guardarEnFicheroYLimpiarLista(guardablePosicionesEnCarreras, primeraEscritura);
				guardarEnFicheroYLimpiarLista(guardableHistoricosGalgos, primeraEscritura);
				guardarEnFicheroYLimpiarLista(guardableGalgoAgregados.values(), primeraEscritura);
			}

			// Mostrar las claves que no hemos podido traducir
			mostrarRemarksSinTraducir(gpgh);

		} else {
			MY_LOGGER.warn("No hay historicos de galgos INICIALES!!");
		}

	}

	/**
	 * @param fileGalgosIniciales
	 */
	public void cargarUrlsHistoricosDeGalgosIniciales(String fileGalgosIniciales) {

		String bruto = "";

		try {
			bruto = readFile(fileGalgosIniciales, Charset.forName("ISO-8859-1"));

			String[] partes = bruto.split("\n");
			if (partes != null && partes.length > 0) {
				String urlGenerada = "";
				for (String parte : partes) {
					urlGenerada = Constantes.GALGOS_GBGB_HISTORICO_GALGO + parte.trim().replace(" ", "%20");

					// Escribimos las URLs de GBGB
					urlsHistoricoGalgos.add(urlGenerada);
				}
			}

		} catch (IOException e) {
			MY_LOGGER.error("Error:" + e.getMessage());
			e.printStackTrace();
		}

	}

	/**
	 * Lee fichero desde Sistema de ficheros local.
	 * 
	 * @param path
	 * @param encoding
	 * @return
	 * @throws IOException
	 */
	public static String readFile(String path, Charset encoding) throws IOException {

		MY_LOGGER.info("Leyendo " + path + " ...");
		byte[] encoded = Files.readAllBytes(Paths.get(path));
		return new String(encoded, encoding);
	}

	/**
	 * @param gpgh
	 * @return
	 */
	public static String mostrarRemarksSinTraducir(GbgbParserGalgoHistorico gpgh) {

		List<String> ordenadas = new ArrayList<String>();
		ordenadas.addAll(gpgh.remarksClavesSinTraduccion);
		ordenadas.sort(null);// natural ordening de String: alfabetico

		MY_LOGGER.info("Numero de remarks que no hemos podido traducir: " + ordenadas.size());

		int num = 0;
		String clavesSinTraducir = "";
		for (String clave : ordenadas) {
			if (num > 0) {
				clavesSinTraducir += "|";
			}
			clavesSinTraducir += clave;
			num++;
		}
		MY_LOGGER.info("Claves: " + clavesSinTraducir);

		return clavesSinTraducir;
	}

	/**
	 * Cuenta las carreras pendientes de ser procesadas
	 * 
	 * @return
	 */
	public int contarPendientes() {
		int num = 0;
		Collection<Boolean> valores = idCarrerasCampeonatoProcesadas.values();
		if (valores != null && !valores.isEmpty()) {
			for (Boolean valor : valores) {
				if (!valor) {// pendiente (=false)
					num++;
				}
			}
		}
		return num;

	}

	/**
	 * Cuenta las carreras YA PROCESADAS
	 * 
	 * @return
	 */
	public int contarCarrerasYaProcesadas() {
		int num = 0;
		Collection<Boolean> valores = idCarrerasCampeonatoProcesadas.values();
		if (valores != null && !valores.isEmpty()) {
			for (Boolean valor : valores) {
				if (valor) {
					num++;
				}
			}
		}
		return num;

	}

	/**
	 * Genera un mapa con SOLO las carreras pendientes.
	 * 
	 * @return
	 */
	public Map<String, Boolean> extraerSoloCarrerasPendientes() {

		Map<String, Boolean> soloPendientes = new HashMap<String, Boolean>();
		Boolean aux = null;

		for (String clave : idCarrerasCampeonatoProcesadas.keySet()) {
			aux = idCarrerasCampeonatoProcesadas.get(clave);
			if (!aux) {// pendiente
				soloPendientes.put(clave, aux);
			}

		}

		return soloPendientes;

	}

	/**
	 * @param listaFilas
	 * @param resetearFichero
	 * @return
	 */
	public int guardarEnFicheroYLimpiarLista(Collection<GalgosGuardable> listaFilas, boolean resetearFichero) {

		int numFilasGuardadas = 0;

		if (listaFilas != null && !listaFilas.isEmpty()) {

			String path = listaFilas.iterator().hasNext()
					? listaFilas.iterator().next().generarPath(Constantes.PATH_DIR_DATOS_LIMPIOS_GALGOS)
					: "";

			MY_LOGGER.info("Guardando FICHEROS FINALES en: " + path);

			try {

				if (resetearFichero) {
					MY_LOGGER.debug("Borrando posible fichero preexistente...");
					Files.deleteIfExists(Paths.get(path));
				}

				MY_LOGGER.debug("Escribiendo...");
				boolean primero = true;
				for (GalgosGuardable fila : listaFilas) {
					if (primero && resetearFichero) {
						Files.write(Paths.get(path), fila.generarDatosParaExportarSql().getBytes(),
								StandardOpenOption.CREATE);
						primero = false;
					} else {
						Files.write(Paths.get(path), fila.generarDatosParaExportarSql().getBytes(),
								StandardOpenOption.APPEND);
					}

				}

				numFilasGuardadas = listaFilas.size();

				// ******** LIMPIAR LISTA, porque ya he guardado a fichero **********
				listaFilas.clear();
				MY_LOGGER.debug("Limpiando lista en memoria. Estado de la lista tras limpiar: " + listaFilas.size());

			} catch (IOException e) {
				MY_LOGGER.error("Error:" + e.getMessage());
				e.printStackTrace();
			}

		} else {
			MY_LOGGER.error("Sin datos. No guardamos fichero!!!");
		}

		MY_LOGGER.info("Filas escritas en fichero: " + numFilasGuardadas);

		return numFilasGuardadas;
	}

	/**
	 * @param idCarrera
	 * @param idCampeonato
	 * @param param3
	 *            Prefijo de ficheros brutos
	 */
	public GbgbCarrera descargarYProcesarCarreraYAcumularUrlsHistoricos(Long idCarrera, Long idCampeonato,
			String param3) {

		String SUFIJO_CARRERA = "_carrera_";
		String pathFileCarreraDetalleBruto = "";
		GbgbCarrera carrera = null;

		String urlCarrera = Constantes.GALGOS_GBGB_CARRERA_DETALLE_PREFIJO + idCarrera;

		MY_LOGGER.info("Descargando DETALLE de CARRERA con URL = " + urlCarrera);

		pathFileCarreraDetalleBruto = param3 + SUFIJO_CARRERA + idCarrera;

		MY_LOGGER.debug("Fichero carrera bruto = " + pathFileCarreraDetalleBruto);
		(new GbgbDownloader()).descargarCarreraDetalle(urlCarrera, pathFileCarreraDetalleBruto, true);

		MY_LOGGER.debug("Parseando carrera...");
		carrera = (new GbgbParserCarreraDetalle()).ejecutar(idCarrera, idCampeonato, pathFileCarreraDetalleBruto);

		if (carrera != null) {

			MY_LOGGER.debug("GUARDABLE - Carrera (EVITANDO DUPLICADOS)");
			guardableCarreras.add(carrera);

			MY_LOGGER.debug("GUARDABLE - URLs de historicos de galgos (EVITANDO DUPLICADOS)");
			for (GbgbPosicionEnCarrera posicion : carrera.posiciones) {
				if (!urlsHistoricoGalgos.contains(posicion.url_galgo_historico)) {
					urlsHistoricoGalgos.add(posicion.url_galgo_historico);
				}
			}
		}

		return carrera;

	}

	/**
	 * @param param3
	 *            Prefijo de ficheros brutos
	 * @param gpgh
	 *            Parser de historicos
	 */
	public void descargarTodosLosHistoricos(String param3, GbgbParserGalgoHistorico gpgh) {

		MY_LOGGER.info("Descargando HISTORICOS (tenemos " + urlsHistoricoGalgos.size() + " URLs)...");
		String pathFileGalgoHistorico = "";

		Calendar fechaUmbralAnterior = getFechaUmbralAnterior();

		int numCarrerasDescubiertas = 0;

		for (String urlGalgo : urlsHistoricoGalgos) {

			if (urlGalgo != null && urlGalgo.contains("=")) {

				String galgo_nombre = urlGalgo.split("=")[1];

				// Si no he mirado su historico ya, entonces lo proceso
				if (!galgosYaGuardados.containsKey(galgo_nombre)) {

					pathFileGalgoHistorico = param3 + "_galgohistorico_" + galgo_nombre;
					MY_LOGGER.debug("URL Historico galgo = " + urlGalgo);
					MY_LOGGER.debug("Galgo nombre = " + galgo_nombre);
					MY_LOGGER.debug("Path historico = " + pathFileGalgoHistorico);

					MY_LOGGER.debug("Descargando historico...");
					(new GbgbDownloader()).descargarHistoricoGalgo(urlGalgo, pathFileGalgoHistorico, true);

					MY_LOGGER.debug("GUARDABLE - Historico de galgo (EVITANDO DUPLICADOS)");
					GbgbGalgoHistorico historico = gpgh.ejecutar(pathFileGalgoHistorico, galgo_nombre);
					guardableHistoricosGalgos.add(historico);

					MY_LOGGER.debug("Con el historico, calculamos AGREGADOS estadisticos..");
					calcularAgregados(historico);
					MY_LOGGER.debug("Numero de agregados acumulado: " + guardableGalgoAgregados.size());

					MY_LOGGER.debug(
							"Del historico, cogemos el ID de carreras anteriores que queremos descargar (de los ultimos X meses)...");
					MY_LOGGER.debug("Fecha umbral (hace X meses): "
							+ GbgbCarrera.FORMATO.format(fechaUmbralAnterior.getTime()));

					MY_LOGGER.debug(
							"Con el historico, descubrimos mas carreras RECIENTES para procesarlas luego (el historico tiene "
									+ historico.carrerasHistorico.size()
									+ " carreras), comprobando que no las tengamos ya...");
					for (GbgbGalgoHistoricoCarrera fila : historico.carrerasHistorico) {

						String clave = fila.id_carrera + "-" + fila.id_campeonato;

						if (isHistoricoInsertable(fila, fechaUmbralAnterior)) {
							MY_LOGGER.debug("Carrera RECIENTE descubierta! La apunto para luego: " + clave);
							idCarrerasCampeonatoProcesadas.put(clave, false);
							numCarrerasDescubiertas++;
						}
					}

					galgosYaGuardados.put(galgo_nombre, true);

				}
			}
		}

		MY_LOGGER.info("Acumuladas " + numCarrerasDescubiertas + " carreras nuevas");

		MY_LOGGER.debug("Limpiando lista de URLs de historicos...\n");
		urlsHistoricoGalgos.clear();
	}

	/**
	 * @return
	 */
	public static Calendar getFechaUmbralAnterior() {
		Calendar fechaUmbralAnterior = Calendar.getInstance();
		fechaUmbralAnterior.add(Calendar.DAY_OF_MONTH, -1 * Constantes.GALGOS_UMBRAL_DIAS_CARRERAS_ANTERIORES);

		SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSZ");
		MY_LOGGER.debug("fechaUmbralAnterior = " + sdf.format(fechaUmbralAnterior.getTime()));

		return fechaUmbralAnterior;
	}

	/**
	 * @param fila
	 * @param fechaUmbralAnterior
	 *            Fecha umbral en el pasado. No cogeremos nada anterior a esa fecha
	 *            porque es demasiado antiguo.
	 * @return
	 */
	public boolean isHistoricoInsertable(GbgbGalgoHistoricoCarrera fila, Calendar fechaUmbralAnterior) {

		Boolean out = false;
		String clave = fila.id_carrera + "-" + fila.id_campeonato;
		Calendar hoy = Calendar.getInstance();

		// --------------------
		// SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSZ");
		// MY_LOGGER.debug("fila.fecha=" + sdf.format(fila.fecha.getTime()));
		// MY_LOGGER.debug("fechaUmbralAnterior=" +
		// sdf.format(fechaUmbralAnterior.getTime()));
		// ------------------------

		if (fila.fecha != null && fila.fecha.before(fechaUmbralAnterior)) {
			MY_LOGGER.debug("Carrera descubierta, pero con FECHA ANTERIOR AL UMBRAL");

		} else if (fila.fecha != null && fila.fecha.after(hoy)) {
			MY_LOGGER.debug("Carrera descubierta, pero con FECHA FUTURA (despues a hoy)");

		} else if (idCarrerasCampeonatoProcesadas.containsKey(clave) == true) {
			MY_LOGGER.debug("Carrera descubierta, pero YA LA TENEMOS");

		} else if (fila != null && fila.posicion != null && !"".equals(fila.posicion)) {
			// Carrera realizada: conocemos la posicion
			MY_LOGGER.debug("Carrera descubierta y la METEMOS");
			out = true;
		}
		return out;
	}

	/**
	 * Analiza el historico para calcular los AGREGADOS y GUARDARLOS en una lista
	 * guardable.
	 * 
	 * @param historico
	 *            Historico de carreras de UN galgo.
	 */
	public void calcularAgregados(GbgbGalgoHistorico historico) {

		if (
		// Que haya carreras en el historico
		historico != null && historico.carrerasHistorico != null && !historico.carrerasHistorico.isEmpty() &&

		// no guardar agregados de galgos que ya tengo
				!guardableGalgoAgregados.containsKey(historico.galgo_nombre.trim())) {

			guardableGalgoAgregados.put(historico.galgo_nombre.trim(), new GalgoAgregados(historico.galgo_nombre.trim(),

					calcularVelocidadEstadistico(historico.carrerasHistorico, DISTANCIA_CORTA, TIPO_VEL_REAL,
							TIPO_ESTADISTICO_MEDIANA),
					calcularVelocidadEstadistico(historico.carrerasHistorico, DISTANCIA_CORTA, TIPO_VEL_REAL,
							TIPO_ESTADISTICO_MAXIMO),
					calcularVelocidadEstadistico(historico.carrerasHistorico, DISTANCIA_CORTA, TIPO_VEL_CON_GOING,
							TIPO_ESTADISTICO_MEDIANA),
					calcularVelocidadEstadistico(historico.carrerasHistorico, DISTANCIA_CORTA, TIPO_VEL_CON_GOING,
							TIPO_ESTADISTICO_MAXIMO),

					calcularVelocidadEstadistico(historico.carrerasHistorico, DISTANCIA_LONGITUD_MEDIA, TIPO_VEL_REAL,
							TIPO_ESTADISTICO_MEDIANA),
					calcularVelocidadEstadistico(historico.carrerasHistorico, DISTANCIA_LONGITUD_MEDIA, TIPO_VEL_REAL,
							TIPO_ESTADISTICO_MAXIMO),
					calcularVelocidadEstadistico(historico.carrerasHistorico, DISTANCIA_LONGITUD_MEDIA,
							TIPO_VEL_CON_GOING, TIPO_ESTADISTICO_MEDIANA),
					calcularVelocidadEstadistico(historico.carrerasHistorico, DISTANCIA_LONGITUD_MEDIA,
							TIPO_VEL_CON_GOING, TIPO_ESTADISTICO_MAXIMO),

					calcularVelocidadEstadistico(historico.carrerasHistorico, DISTANCIA_LARGA, TIPO_VEL_REAL,
							TIPO_ESTADISTICO_MEDIANA),
					calcularVelocidadEstadistico(historico.carrerasHistorico, DISTANCIA_LARGA, TIPO_VEL_REAL,
							TIPO_ESTADISTICO_MAXIMO),
					calcularVelocidadEstadistico(historico.carrerasHistorico, DISTANCIA_LARGA, TIPO_VEL_CON_GOING,
							TIPO_ESTADISTICO_MEDIANA),
					calcularVelocidadEstadistico(historico.carrerasHistorico, DISTANCIA_LARGA, TIPO_VEL_CON_GOING,
							TIPO_ESTADISTICO_MAXIMO)

			));

		}
	}

	/**
	 * @param carrerasHistorico
	 * @param tipoDistancia
	 * @param tipoVelocidad
	 * @param tipoEstadistico
	 * @return
	 */
	public Float calcularVelocidadEstadistico(List<GbgbGalgoHistoricoCarrera> carrerasHistorico, Integer tipoDistancia,
			Integer tipoVelocidad, Integer tipoEstadistico) {

		Calendar fechaUmbralAnterior = getFechaUmbralAnterior();

		List<Float> valores = new ArrayList<Float>();

		for (GbgbGalgoHistoricoCarrera fila : carrerasHistorico) {

			// ---------------------------
			Float velocidad = null;
			if (tipoVelocidad.equals(TIPO_VEL_REAL)) {
				velocidad = fila.velocidadReal;
			} else if (tipoVelocidad.equals(TIPO_VEL_CON_GOING)) {
				velocidad = fila.velocidadConGoing;
			}

			// --------------------------

			if (fila.fecha.after(fechaUmbralAnterior) && velocidad != null) {

				if (tipoDistancia != null && fila.distancia != null
						&& distanciaEstaEnTipoDistanciaAnalizada(fila.distancia, tipoDistancia)) {
					valores.add(velocidad);
				}

				// TODO REAPROVECHAR CARRERAS DE UNA DISTANCIA, para deducir su velocidad en
				// OTRA distancia. Ej: si corrio 800m, deberia calcular cuanto fue su velocidad
				// en los primeros 250 metros y en los primeros 450m, para aprovechar esa info.

			}
		}

		Float out = null;

		if (!valores.isEmpty()) {

			if (tipoEstadistico.equals(TIPO_ESTADISTICO_MEDIANA)) {

				int indiceMediana = Float.valueOf(valores.size() / 2).intValue();

				if (!valores.isEmpty()) {
					out = valores.get(indiceMediana);
				}

			} else if (tipoEstadistico.equals(TIPO_ESTADISTICO_MAXIMO)) {
				Float max = null;
				if (!valores.isEmpty()) {
					for (Float v : valores) {
						if (max == null || max.floatValue() < v.floatValue()) {
							max = v;
						}
					}

					out = max;
				}

			}

		}
		return out;
	}

	/**
	 * @param distancia
	 * @param tipoDistanciaAnalizada
	 * @return TRUE Si distancia esta dentro del tipoDistanciaAnalizada
	 */
	public static Boolean distanciaEstaEnTipoDistanciaAnalizada(Integer distancia, Integer tipoDistanciaAnalizada) {

		Boolean out = false;
		if (distancia != null && tipoDistanciaAnalizada != null) {

			if (distancia.intValue() < 400 && tipoDistanciaAnalizada.equals(DISTANCIA_CORTA)) {
				out = true;
			} else if (distancia.intValue() >= 400 && distancia.intValue() < 600
					&& tipoDistanciaAnalizada.equals(DISTANCIA_LONGITUD_MEDIA)) {
				out = true;
			} else if (distancia.intValue() > 600 && tipoDistanciaAnalizada.equals(DISTANCIA_LARGA)) {
				out = true;
			}

		} else {
			MY_LOGGER.error("La distancia debe estar en un tipo...");
		}

		return out;
	}

}
