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
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashSet;
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
import casa.galgos.sportium.SportiumCarreraGalgo;
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

	public static final Integer PROFUNDIDAD_DEFAULT = 1;

	public List<String> carrerasProcesadasIncluidasFallidas = new ArrayList<String>();// ID_carrera-ID_campeonato
	public List<ProfundidadCarreras> profCarrerasPendientes = new ArrayList<ProfundidadCarreras>();
	public List<String> galgosYaAnalizados = new ArrayList<String>();

	// LISTAS con datos DEFINITIVOS para guardar en sistema de ficheros
	public List<SportiumCarrera> galgosFuturos = new ArrayList<SportiumCarrera>(); // Galgos en los que vamos a apostar
																					// dinero real
	public List<GalgosGuardable> guardableCarreras = new ArrayList<GalgosGuardable>();
	public List<GalgosGuardable> guardablePosicionesEnCarreras = new ArrayList<GalgosGuardable>();
	public Set<String> urlsHistoricoGalgos = new LinkedHashSet<String>(); // URLs de historicos SIN DUPLICADOS
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

				int trap = 1;// La lista de galgosNombres esta ordenada segun el TRAP

				for (String galgoNombre : carrera.galgosNombres) {

					String id = carrera.estadio + "#" + carrera.dia + "#" + carrera.hora + "#" + galgoNombre;
					carreraGalgos.add(new SportiumCarreraGalgo(id, galgoNombre, trap, carrera));
					trap++;
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
						Files.write(Paths.get(pathFull), (fila.toString()).getBytes(), StandardOpenOption.CREATE);
						primero = false;
					} else {
						Files.write(Paths.get(pathFull), (fila.toString()).getBytes(), StandardOpenOption.APPEND);
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
	 * @param prefijoPathDatosBruto
	 * @param guardarEnFicheros
	 * @param fileGalgosIniciales
	 * @throws InterruptedException
	 */
	public void descargarYparsearCarrerasDeGalgos(String prefijoPathDatosBruto, boolean guardarEnFicheros,
			String fileGalgosIniciales) throws InterruptedException {

		MY_LOGGER.info("descargarYparsearCarrerasDeGalgos:  MAX_NUM_CARRERAS_PROCESADAS = "
				+ Constantes.MAX_NUM_CARRERAS_PROCESADAS + "  MAX_PROFUNDIDAD_PROCESADA="
				+ Constantes.MAX_PROFUNDIDAD_PROCESADA);

		boolean primeraEscritura = true;

		GbgbParserGalgoHistorico gpgh = new GbgbParserGalgoHistorico();

		cargarUrlsHistoricosDeGalgosIniciales(fileGalgosIniciales);

		if (urlsHistoricoGalgos != null && !urlsHistoricoGalgos.isEmpty()) {

			MY_LOGGER.info(
					"descargarYparsearCarrerasDeGalgos - Descargando " + urlsHistoricoGalgos.size() + " historicos...");
			Boolean inicialesListosParaGuardar = descargarTodosLosHistoricos(prefijoPathDatosBruto, gpgh,
					PROFUNDIDAD_DEFAULT);

			if (inicialesListosParaGuardar == false) {
				MY_LOGGER.warn("PROBLEMA al descargar los historicos de los galgos INICIALES!!");
			}

			MY_LOGGER.info(
					"descargarYparsearCarrerasDeGalgos - Procesando las carreras de las que conozco la URL (embuclandose)...");

			do {

				MY_LOGGER.info("descargarYparsearCarrerasDeGalgos - Carreras PROCESADAS / PENDIENTES = "
						+ carrerasProcesadasIncluidasFallidas.size() + "/" + contarCarrerasPendientes());

				int profundidadCarreraAProcesar = extraerProfundidadMinimaConCarrerasPendientes();
				String idCarreraIdcampeonatoAProcesar = extraerSiguienteCarreraPendiente();

				if (idCarreraIdcampeonatoAProcesar == null) {
					MY_LOGGER.warn("Siguiente carrera pendiente es NULL.");

				} else {

					MY_LOGGER.info("descargarYparsearCarrerasDeGalgos -  Procesando carrera="
							+ idCarreraIdcampeonatoAProcesar + " profundidad=" + profundidadCarreraAProcesar + " ...");

					String[] partes = idCarreraIdcampeonatoAProcesar.split("-");

					GbgbCarrera carrera = descargarYProcesarCarreraYAcumularUrlsHistoricos(Long.valueOf(partes[0]),
							Long.valueOf(partes[1]), prefijoPathDatosBruto);

					if (carrera == null) {
						MY_LOGGER.warn("Carrera procesada es nula. REVISAR. Su id=" + idCarreraIdcampeonatoAProcesar);

					} else {

						MY_LOGGER.debug("GUARDABLE - Anhadiendo " + carrera.posiciones.size() + " posiciones...");
						for (GbgbPosicionEnCarrera posicion : carrera.posiciones) {
							guardablePosicionesEnCarreras.add(posicion);
						}

						Boolean descargaCorrecta = descargarTodosLosHistoricos(prefijoPathDatosBruto, gpgh,
								profundidadCarreraAProcesar + 1);

						if (descargaCorrecta == false) {
							MY_LOGGER.warn(
									"Dentro del bucle while, no se han descargado bien algunos historicos pendientes. Da igual, seguimos...");
						}

					}

					// ---------------------
					MY_LOGGER.debug("Carrera procesada OK. Quitando carrera de PENDIENTES y metiéndola en procesadas: "
							+ idCarreraIdcampeonatoAProcesar + " con profundidad=" + profundidadCarreraAProcesar);
					carrerasProcesadasIncluidasFallidas.add(idCarreraIdcampeonatoAProcesar);

					for (ProfundidadCarreras pcp : profCarrerasPendientes) {
						if (pcp.profundidad.equals(profundidadCarreraAProcesar)) {
							pcp.carrerasPendientes.remove(idCarreraIdcampeonatoAProcesar);
						}
					}
					// ---------------------

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
				}

				MY_LOGGER.debug("CONTROL_BUCLE: pendientes=" + contarCarrerasPendientes());
				MY_LOGGER.debug(
						"CONTROL_BUCLE: procesadas (incluidas fallidas)=" + carrerasProcesadasIncluidasFallidas.size()
								+ " (limite=" + Constantes.MAX_NUM_CARRERAS_PROCESADAS + ")");

			} while (condicionBucle());

			MY_LOGGER.info("El BUCLE ha TERMINADO: carreras_pendientes (que no las vamos a procesar)="
					+ contarCarrerasPendientes() + " carreras_guardadas=" + guardableCarreras.size()
					+ " historicos_galgos=" + guardableHistoricosGalgos.size());

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
	 * @return
	 */
	public boolean condicionBucle() {

		boolean quedanPendientes = contarCarrerasPendientes() >= 1;
		boolean debajoUmbralCarrerasProcesadasMax = carrerasProcesadasIncluidasFallidas
				.size() < Constantes.MAX_NUM_CARRERAS_PROCESADAS;
		boolean debajoUmbralProfundidadMax = extraerProfundidadMinimaConCarrerasPendientes() <= Constantes.MAX_PROFUNDIDAD_PROCESADA;

		boolean out = quedanPendientes && debajoUmbralCarrerasProcesadasMax && debajoUmbralProfundidadMax;

		MY_LOGGER.info(
				"BUCLE-Condiciones: Ya se han procesado las carreras de profundidad 1, 2... (desde los galgos semillas) y ahora la profundidad mínima de las carreras PENDIENTES es ="
						+ extraerProfundidadMinimaConCarrerasPendientes());

		MY_LOGGER.info("BUCLE-Condiciones --> quedanPendientes =" + quedanPendientes);
		MY_LOGGER.info("BUCLE-Condiciones --> debajoUmbralCarrerasProcesadasMax =" + debajoUmbralCarrerasProcesadasMax);
		MY_LOGGER.info("BUCLE-Condiciones --> debajoUmbralProfundidadMax =" + debajoUmbralProfundidadMax + " = " + out);
		MY_LOGGER.info("BUCLE-Condiciones --> TOTAL (para ver si seguimos procesando mas carreras) = " + out);

		return out;

	}

	/**
	 * @return
	 */
	public int contarCarrerasPendientes() {
		int contador = 0;
		for (ProfundidadCarreras pc : profCarrerasPendientes) {
			contador += pc.carrerasPendientes.size();
		}
		return contador;
	}

	/**
	 * @param fileGalgosIniciales
	 */
	public void cargarUrlsHistoricosDeGalgosIniciales(String fileGalgosIniciales) {

		MY_LOGGER.info("cargarUrlsHistoricosDeGalgosIniciales - File de galgos iniciales: " + fileGalgosIniciales);

		String bruto = "";

		try {
			bruto = readFile(fileGalgosIniciales, Charset.forName("ISO-8859-1"));

			String[] partes = bruto.split("\n");
			if (partes != null && partes.length > 0) {
				String urlGenerada = "";
				for (String parte : partes) {
					urlGenerada = parte.trim().replace(" ", "%20");

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

		Map<String, Integer> ordenadoPorClave = Constantes.sortByValues(gpgh.remarksClavesSinTraduccion);

		MY_LOGGER.info("Numero de remarks que no hemos podido traducir y asignarles puntuacion: "
				+ ordenadoPorClave.keySet().size());

		String clavesSinTraducir = "";
		for (String clave : ordenadoPorClave.keySet()) {

			if (ordenadoPorClave.get(clave).intValue() > 50) {// Que haya aparecido mucho
				clavesSinTraducir += ordenadoPorClave.get(clave) + "|" + clave + "\n";
			}
		}
		MY_LOGGER.info("Claves: \n" + clavesSinTraducir);

		return clavesSinTraducir;
	}

	/**
	 * Extrae la siguiente carrera a procesar.
	 * 
	 * @return ID de la carrera. NULL en otro caso.
	 */
	public String extraerSiguienteCarreraPendiente() {
		String idCarreraPendienteSiguiente = null;
		if (profCarrerasPendientes != null && !profCarrerasPendientes.isEmpty()) {
			Integer profundidadMinima = extraerProfundidadMinimaConCarrerasPendientes();

			for (ProfundidadCarreras pc : profCarrerasPendientes) {

				if (pc.profundidad.equals(profundidadMinima)) {
					idCarreraPendienteSiguiente = pc.carrerasPendientes.iterator().next();
				}
			}

		}

		MY_LOGGER.debug("extraerSiguienteCarreraPendiente: " + idCarreraPendienteSiguiente);

		return idCarreraPendienteSiguiente;
	}

	/**
	 * @return De las carreras pendientes,devuelve que la minima profundidad.
	 */
	public Integer extraerProfundidadMinimaConCarrerasPendientes() {

		Integer out = PROFUNDIDAD_DEFAULT; // default

		if (profCarrerasPendientes != null) {
			List<Integer> profundidades = new ArrayList<Integer>();

			for (ProfundidadCarreras pc : profCarrerasPendientes) {
				if (pc.carrerasPendientes != null && !pc.carrerasPendientes.isEmpty()) {
					profundidades.add(pc.profundidad);
				}
			}

			if (profundidades != null && !profundidades.isEmpty()) {
				for (Integer item : profundidades) {
					out = Collections.min(profundidades); // MINIMA
				}
			}

		}

		return out;
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
			MY_LOGGER.error("Sin datos en la lista. No guardamos nada en el fichero (append)!!!");
		}
		MY_LOGGER.info("Filas escritas en fichero (append): " + numFilasGuardadas);

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

		MY_LOGGER.debug("Descargando DETALLE de CARRERA con URL = " + urlCarrera);

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
				if (!urlsHistoricoGalgos.contains(posicion.urlparteB_galgo_historico)) {
					urlsHistoricoGalgos.add(posicion.urlparteB_galgo_historico);
				}
			}
		}

		return carrera;

	}

	/**
	 * Descarga todas las URLs de urlsHistoricoGalgos, las parsea y las guarda en
	 * guardableHistoricosGalgos (que luego se guardaran en ficheros). Ademas,
	 * apunta las carreras recientes que aparezcan en ese historico.
	 * 
	 * @param param3
	 *            Prefijo de ficheros brutos
	 * @param gpgh
	 *            Parser de historicos
	 */
	public Boolean descargarTodosLosHistoricos(String param3, GbgbParserGalgoHistorico gpgh,
			Integer profundidadParaNuevasCarreras) {

		MY_LOGGER.info("descargarTodosLosHistoricos - Descargando HISTORICOS (tenemos " + urlsHistoricoGalgos.size()
				+ " URLs). Las carreras descubiertas las pondremos con profundidad=" + profundidadParaNuevasCarreras
				+ " ...");

		String pathFileGalgoHistorico = "";

		Calendar fechaUmbralAnterior = getFechaUmbralAnterior();

		int numCarrerasDescubiertas = 0;

		int numHistoricosAnalizados = 0;

		for (String urlGalgo : urlsHistoricoGalgos) {

			String urlGalgoFull = Constantes.GALGOS_GBGB_HISTORICO_GALGO + urlGalgo;
			MY_LOGGER.debug("URL Historico galgo = " + urlGalgoFull);

			if (urlGalgoFull != null && urlGalgoFull.contains("=")) {

				String[] partesDeUrl = urlGalgoFull.split("=");

				String galgo_nombre = partesDeUrl.length == 2 ? (urlGalgoFull.split("=")[1]).replaceAll("%20", " ")
						: null;

				if (galgo_nombre == null) {
					MY_LOGGER.error("descargarTodosLosHistoricos - urlGalgoFull no tiene ID en la URL -> urlGalgoFull=|"
							+ urlGalgoFull + "|");

				} else if (galgosYaAnalizados.contains(galgo_nombre)) {
					MY_LOGGER.debug("Historico (galgo_nombre) ya analizado. No lo procesamos.");
					numHistoricosAnalizados++;

				} else {
					// Si no he mirado su historico ya, entonces lo proceso y lo marco como ya
					// analizado
					galgosYaAnalizados.add(galgo_nombre);

					pathFileGalgoHistorico = param3 + "_galgohistorico_" + galgo_nombre;
					MY_LOGGER.debug("Galgo nombre = " + galgo_nombre);
					MY_LOGGER.debug("Path historico = " + pathFileGalgoHistorico);

					MY_LOGGER.debug("Descargando historico...");
					(new GbgbDownloader()).descargarHistoricoGalgo(urlGalgoFull, pathFileGalgoHistorico, true);

					MY_LOGGER.debug("GUARDABLE - Historico de galgo (EVITANDO DUPLICADOS)");
					GbgbGalgoHistorico historico = gpgh.ejecutar(pathFileGalgoHistorico, galgo_nombre);

					if (historico == null) {
						MY_LOGGER.error(
								"Fallo al parsear historico de galgo=" + galgo_nombre + " y no sabemos la causa!!!");
						break;

					} else if (historico.error_causa < 0) {
						MY_LOGGER.warn("Fallo al parsear historico de galgo=" + galgo_nombre + " Causa="
								+ historico.error_causa);

					} else {
						MY_LOGGER.debug("Historico analizado: " + galgo_nombre);
						guardableHistoricosGalgos.add(historico);
						numHistoricosAnalizados++;

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

							if (isHistoricoInsertable(fila, fechaUmbralAnterior) ||

							// Si he llegado al maximo deseado, no sigo acumulando mas (para ahorrar
							// memoria)
									contarCarrerasPendientes() >= Constantes.MAX_NUM_CARRERAS_PROCESADAS) {

								if (anhadirCarreraAPendientes(profundidadParaNuevasCarreras, clave)) {
									MY_LOGGER.debug(
											"descargarTodosLosHistoricos - Carrera RECIENTE descubierta! Apuntada como pendiente (no estaba en pendientes ni en ya-procesadas): "
													+ clave);
									numCarrerasDescubiertas++;
								}
							}
						}

					}

				}

			} else {
				MY_LOGGER.error("Historico con URL inesperada: " + urlGalgoFull);
			}

		} // FIN de FOR

		MY_LOGGER.info("descargarTodosLosHistoricos - Historicos procesados (galgos)=" + numHistoricosAnalizados
				+ " (de " + urlsHistoricoGalgos.size()
				+ " URLs procesables). Carreras DESCUBIERTAS en historicos (sin repetidas ni conocidas)="
				+ numCarrerasDescubiertas);

		Boolean out = (urlsHistoricoGalgos.size() == numHistoricosAnalizados);

		MY_LOGGER.debug(
				"descargarTodosLosHistoricos- Limpiando lista de URLs de historicos (ya los hemos descargado)...\n");
		urlsHistoricoGalgos.clear();

		MY_LOGGER.debug("Descargando HISTORICOS: FIN");

		return out;
	}

	/**
	 * Añade una carrera la la lista de pendientes. Comprueba que no esté yá como
	 * pendiente y que no haya sido procesada ya.
	 * 
	 * @return True si la he anhadido a pendientes. False en otro caso.
	 */
	public boolean anhadirCarreraAPendientes(Integer profundidad, String idCarrera) {

		boolean anhadidaOk = false;

		boolean tieneEstaProfundidadYa = false;
		for (ProfundidadCarreras pcp : profCarrerasPendientes) {
			if (pcp.profundidad.equals(profundidad)) {
				tieneEstaProfundidadYa = true;
			}
		}

		if (tieneEstaProfundidadYa) {
			for (ProfundidadCarreras pcp : profCarrerasPendientes) {
				if (pcp.profundidad.equals(profundidad)) {
					pcp.carrerasPendientes.add(idCarrera);
					anhadidaOk = true;
					break;
				}
			}

		} else {
			// No tiene esta profundidad todavia. Por tanto, va a ser la primera carrera
			// pendiente que meto a esta profundidad.
			ProfundidadCarreras pc = new ProfundidadCarreras(profundidad, new ArrayList<String>());
			pc.carrerasPendientes.add(idCarrera);
			profCarrerasPendientes.add(pc);
			anhadidaOk = true;
		}

		return anhadidaOk;
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

		// Comprueba si ya está en pendientes (en cualquier profundidad)
		boolean estaEnPendientes = false;
		if (profCarrerasPendientes != null) {
			for (ProfundidadCarreras pcp : profCarrerasPendientes) {
				for (String ic : pcp.carrerasPendientes) {
					if (clave.equals(ic)) {
						estaEnPendientes = true;
						break;
					}
				}
			}
		}

		// Comprueba si ya ha sido procesada
		boolean yaHaSidoProcesada = false;
		if (carrerasProcesadasIncluidasFallidas != null && carrerasProcesadasIncluidasFallidas.contains(clave)) {
			yaHaSidoProcesada = true;
		}

		// -----------------------
		if (fila.fecha != null && fila.fecha.before(fechaUmbralAnterior)) {
			MY_LOGGER.debug("Carrera descubierta, pero con FECHA ANTERIOR AL UMBRAL");

		} else if (fila.fecha != null && fila.fecha.after(hoy)) {
			MY_LOGGER.debug("Carrera descubierta, pero con FECHA FUTURA (despues a hoy)");

		} else if (yaHaSidoProcesada) {
			MY_LOGGER.debug("Carrera descubierta, pero YA la hemos PROCESADO");

		} else if (estaEnPendientes) {
			MY_LOGGER.debug("Carrera descubierta, pero YA la tenemos PENDIENTE");

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

			GalgoAgregados ga = new GalgoAgregados(historico.galgo_nombre.trim(),

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

			);

			guardableGalgoAgregados.put(historico.galgo_nombre.trim(), ga);

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
