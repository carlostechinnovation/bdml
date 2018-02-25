package casa.galgos.betbright;

import java.io.IOException;
import java.io.Serializable;
import java.nio.charset.Charset;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.file.StandardOpenOption;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.log4j.Logger;

import casa.galgos.gbgb.GalgosGuardable;
import utilidades.Constantes;

public class BetbrightManager implements Serializable {

	private static final long serialVersionUID = 1L;

	static Logger MY_LOGGER = Logger.getLogger(BetbrightManager.class);

	// LISTAS con datos DEFINITIVOS para guardar en sistema de ficheros
	public List<CarreraSemillaBetright> carreras = new ArrayList<CarreraSemillaBetright>();
	public List<GalgosGuardable> guardableCarreras = new ArrayList<GalgosGuardable>();
	public List<GalgosGuardable> guardablePosicionesEnCarreras = new ArrayList<GalgosGuardable>();
	public Set<String> urlsHistoricoGalgos = new LinkedHashSet<String>(); // URLs de historicos SIN DUPLICADOS
	public List<GalgosGuardable> guardableHistoricosGalgos = new ArrayList<GalgosGuardable>();
	public Map<String, GalgosGuardable> guardableGalgoAgregados = new HashMap<String, GalgosGuardable>();

	// --- SINGLETON
	private static BetbrightManager instancia;

	private BetbrightManager() {
	}

	public static BetbrightManager getInstancia() {
		if (instancia == null) {
			instancia = new BetbrightManager();
		}
		return instancia;
	}

	/**
	 * Descarga y parsea las carreras FUTURAS de BETBRIGHT.
	 * 
	 * @param pathPrefijoDatosBruto
	 *            Path absoluto de los ficheros que contienen las WEBs FUTURAS
	 *            (TODAY y TOMORROW) separados por pipe (|).
	 * @param guardarEnFicheros
	 *            BOOLEAN que indica si se quieren GUARDAR los resultados en la
	 *            carpeta (o no, si son pruebas).
	 * @param fileUrlsDetalleCarreras
	 *            Fichero SALIDA, con la lista de URLs de detalle de carreras: cada
	 *            URL en una fila.
	 * @throws InterruptedException
	 * @throws IOException
	 */
	public void descargarYParsearSemillas(String pathPrefijoDatosBruto, boolean guardarEnFicheros,
			String fileUrlsDetalleCarreras) throws Exception {

		MY_LOGGER.info("Descarga de paginas web de DETALLE...");
		MY_LOGGER.info("[pathPrefijoDatosBruto] --> " + pathPrefijoDatosBruto);
		MY_LOGGER.info("[guardarEnFicheros] --> " + guardarEnFicheros);
		MY_LOGGER.info("[fileUrlsDetalleCarreras] --> " + fileUrlsDetalleCarreras);

		String pathToday = pathPrefijoDatosBruto + "today.html";
		String pathTomorrow = pathPrefijoDatosBruto + "tomorrow.html";

		if (Constantes.GALGOS_FUTUROS_BETBRIGHT_DESCARGAR_DESDE_JAVA) {

			MY_LOGGER.info("Descargando pagina de entrada en BETBRIGHT con carreras FUTURAS --> TODAY...");
			(new BetbrightDownloader()).descargarDeURLsAFicheros(Constantes.GALGOS_FUTUROS_BETBRIGHT_TODAY, pathToday,
					guardarEnFicheros);

			MY_LOGGER.info("Descargando pagina de entrada en BETBRIGHT con carreras FUTURAS --> TOMORROW...");
			(new BetbrightDownloader()).descargarDeURLsAFicheros(Constantes.GALGOS_FUTUROS_BETBRIGHT_TOMORROW,
					pathTomorrow, guardarEnFicheros);

		} else {
			MY_LOGGER.info(
					"ATENCION: se supone que las carreras futuras TODAY + TOMORROW de BB las ha descargado un script (hack) externo en: \n"
							+ pathToday + "\n" + pathTomorrow);
		}

		MY_LOGGER.info(
				"Tenemos los ficheros brutos TODAY y TOMORROW, de los que podremos extraer las URLs del detalle de cada carrera BETBRIGHT-FUTURA.");

		MY_LOGGER.info("Parseando la pagina de carreras de TODAY para extraer las URLs...");
		List<String> urlsCarrerasFuturasToday = (new BetbrightParserCarrerasFuturas()).ejecutar(pathToday);
		MY_LOGGER.info("Parseando la pagina de carreras de TOMORROW para extraer las URLs...");
		List<String> urlsCarrerasFuturasTomorrow = (new BetbrightParserCarrerasFuturas()).ejecutar(pathTomorrow);

		MY_LOGGER.info("URLs obtenidas = TODAY | TOMORROW: " + urlsCarrerasFuturasToday.size() + " | "
				+ urlsCarrerasFuturasTomorrow.size());
		List<String> urlsCarrerasFuturas = new ArrayList<String>();
		urlsCarrerasFuturas.addAll(urlsCarrerasFuturasToday);
		urlsCarrerasFuturas.addAll(urlsCarrerasFuturasTomorrow);

		MY_LOGGER
				.info("NO LIMITAMOS numero de carreras procesadas porque las semillas IMPORTANTES son las de SPORTIUM. "
						+ "Estas semillas de Betbright solo nos sirven para extraer cierta info (distancia...) y pueden venir en otro orden de aparicion distinto de SPORTIUM."
						+ "Así que debemos descargar TODAS los DETALLES de las carreras FUTURAS de BETBRIGHT, sin poner limites.");

		if (urlsCarrerasFuturas == null || urlsCarrerasFuturas.isEmpty()) {
			MY_LOGGER.error("BB-ERROR: No hemos descargado NINGUNA carrera FUTURA (semilla)!!!!");
			throw new Exception("BB-ERROR: No hemos descargado NINGUNA carrera FUTURA (semilla)!!!!");
		} else {
			guardarListaEnFichero(urlsCarrerasFuturas, fileUrlsDetalleCarreras);
		}
	}

	/**
	 * Guarda los elementos de la lista, en un fichero. Mete cada elemento en una
	 * fila.
	 * 
	 * @param urlsCarrerasFuturas
	 * @param pathListaUrlsDetalles
	 * @throws IOException
	 */
	public void guardarListaEnFichero(List<String> urlsCarrerasFuturas, String pathListaUrlsDetalles)
			throws IOException {

		MY_LOGGER.info("Lista de URLs de detalle - Guardando en = " + pathListaUrlsDetalles);
		if (Files.exists(Paths.get(pathListaUrlsDetalles))) {
			MY_LOGGER.debug("Borrando fichero de listaurlsdetalles preexistente...");
			Files.delete(Paths.get(pathListaUrlsDetalles));
		}

		boolean primero = true;
		for (String urlCarrera : urlsCarrerasFuturas) {

			String aux = primero ? "" : "\n";
			aux += urlCarrera;

			Files.write(Paths.get(pathListaUrlsDetalles), aux.getBytes(), StandardOpenOption.CREATE_NEW);

			primero = false;
		}
		MY_LOGGER.info("Lista de URLs de detalle - Guardada OK");
	}

	/**
	 * Descarga y parsea las carreras FUTURAS de BETBRIGHT.
	 * 
	 * @param prefijoPathDatosBruto
	 *            Path absoluto de la CARPETA+PREFIJO donde se van a GUARDAR los
	 *            DATOS BRUTOS.
	 * @param guardarEnFicheros
	 *            BOOLEAN que indica si se quieren GUARDAR los resultados en la
	 *            carpeta (o no, si son pruebas).
	 * @param pathListaUrlsDetalles
	 *            SALIDA
	 * @throws InterruptedException
	 * @throws IOException
	 */
	public void descargarYParsearSemillasDetalles(String prefijoPathDatosBruto, boolean guardarEnFicheros,
			String pathListaUrlsDetalles) throws Exception {

		MY_LOGGER.info("Descarga de paginas web de DETALLE...");
		MY_LOGGER.info("[PPDB] --> " + prefijoPathDatosBruto);
		MY_LOGGER.info("[GEF] --> " + guardarEnFicheros);
		MY_LOGGER.info("[PLUD] --> " + pathListaUrlsDetalles);

		String tag = "_DET_";
		int contador = 0;
		BetbrightParserDetalleCarreraFutura spdcf = new BetbrightParserDetalleCarreraFutura();

		String pathCarreraDetalle = "";

		List<String> urlsDetalles = leerFicheroConListaDeUrlsDetalles(pathListaUrlsDetalles);

		for (String urlCarreraDetalle : urlsDetalles) {
			contador++;
			pathCarreraDetalle = prefijoPathDatosBruto + tag + contador;

			if (Constantes.GALGOS_FUTUROS_BETBRIGHT_DESCARGAR_DESDE_JAVA) {
				(new BetbrightDownloader()).descargarDeURLsAFicheros(urlCarreraDetalle, pathCarreraDetalle,
						guardarEnFicheros);
			} else {
				MY_LOGGER.info(
						"ATENCION: se supone que la carrera futura de BB se ha descargado mediante script (hack) externo en: "
								+ pathCarreraDetalle);
			}

			// Para cada carrera, extraigo toda la info que pueda y la meto en la instancia
			spdcf.ejecutar(pathCarreraDetalle, urlCarreraDetalle);
		}

		desnormalizarSemillasYGuardarlasEnFicheros(prefijoPathDatosBruto);

		MY_LOGGER.info("BB-Carreras FUTURAS con sus galgos (semillas): OK");

	}

	/**
	 * Lee todos los elementos de un fichero (que contiene URLs de las paginas de
	 * detalle de carreras FUTURAS) y las carga en un ARRAYLIST.
	 * 
	 * @param pathListaUrlsDetalles
	 * @return
	 * @throws Exception
	 */
	public List<String> leerFicheroConListaDeUrlsDetalles(String pathListaUrlsDetalles) throws Exception {

		MY_LOGGER.info("Fichero con la lista de URLs de detalle: " + pathListaUrlsDetalles);
		if (!Files.exists(Paths.get(pathListaUrlsDetalles))) {
			MY_LOGGER.error("leerFicheroConListaDeUrlsDetalles --> El fichero no existe = " + pathListaUrlsDetalles);
			throw new Exception(
					"leerFicheroConListaDeUrlsDetalles --> El fichero no existe = " + pathListaUrlsDetalles);
		}

		return Files.readAllLines(Paths.get(pathListaUrlsDetalles), Charset.forName("ISO-8859-1"));

	}

	/**
	 * @param fileGalgosIniciales
	 */
	public void desnormalizarSemillasYGuardarlasEnFicheros(String fileGalgosIniciales) {

		MY_LOGGER.info("La lista galgosFuturos contiene = " + carreras.size());

		// *********************************************************************
		Set<String> galgosIniciales = new HashSet<String>();

		for (CarreraSemillaBetright c : carreras) {
			for (CarreraGalgoSemillaBetright cg : c.listaCG) {
				galgosIniciales.add(cg.galgoNombre);
			}

		}
		// *** ACUMULO TODOS los cg ******
		List<CarreraGalgoSemillaBetright> carreraGalgos = new ArrayList<CarreraGalgoSemillaBetright>();
		for (CarreraSemillaBetright c : carreras) {
			carreraGalgos.addAll(c.listaCG);
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
				for (CarreraGalgoSemillaBetright fila : carreraGalgos) {

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
				carreras.clear();
				carreraGalgos.clear();
				MY_LOGGER.debug("Limpiando lista en memoria. Estado de la lista tras limpiar: " + carreras.size());

			} catch (IOException e) {
				MY_LOGGER.error("Error:" + e.getMessage());
				e.printStackTrace();
			}

		} else {
			MY_LOGGER.error("Sin datos. No guardamos fichero!!!");
		}
	}

}
