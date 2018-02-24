package casa.galgos.betbright;

import java.io.IOException;
import java.io.Serializable;
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
	 * @param prefijoPathDatosBruto
	 *            Path absoluto de la CARPETA donde se van a GUARDAR los DATOS
	 *            BRUTOS.
	 * @param guardarEnFicheros
	 *            BOOLEAN que indica si se quieren GUARDAR los resultados en la
	 *            carpeta (o no, si son pruebas).
	 * @param fileGalgosIniciales
	 *            SALIDA
	 * @throws InterruptedException
	 * @throws IOException
	 */
	public void descargarYParsearSemillas(String prefijoPathDatosBruto, boolean guardarEnFicheros,
			String fileGalgosIniciales) throws InterruptedException, IOException {

		if (Constantes.GALGOS_FUTUROS_BETBRIGHT_DESCARGAR_DESDE_JAVA) {

			MY_LOGGER.info("Descargando pagina de entrada en BETBRIGHT con carreras FUTURAS --> TODAY...");
			boolean borrarCarpeta = true;
			(new BetbrightDownloader()).descargarDeURLsAFicheros(Constantes.GALGOS_FUTUROS_BETBRIGHT_TODAY,
					prefijoPathDatosBruto, guardarEnFicheros && borrarCarpeta);

			MY_LOGGER.info("Descargando pagina de entrada en BETBRIGHT con carreras FUTURAS --> TOMORROW...");
			borrarCarpeta = false;// porque no quiero borrar lo que ya he descargado (today)
			(new BetbrightDownloader()).descargarDeURLsAFicheros(Constantes.GALGOS_FUTUROS_BETBRIGHT_TOMORROW,
					prefijoPathDatosBruto, guardarEnFicheros && borrarCarpeta);

		} else {
			MY_LOGGER.info(
					"ATENCION: se supone que las carreras futuras TODAY + TOMORROW de BB las ha descargado un script (hack) externo en: "
							+ prefijoPathDatosBruto);
		}

		MY_LOGGER.info(
				"Tenemos los ficheros brutos TODAY y TOMORROW, de los que podremos extraer las URLs del detalle de cada carrera BETBRIGHT-FUTURA...");
		List<String> urlsCarrerasFuturas = (new BetbrightParserCarrerasFuturas()).ejecutar(prefijoPathDatosBruto);
		MY_LOGGER.info("URLs obtenidas: " + urlsCarrerasFuturas.size());

		MY_LOGGER.info("LIMITAMOS numero de carreras procesadas: " + Constantes.MAX_NUM_CARRERAS_SEMILLA);
		int anhadidas = 0;
		for (String urlCarrera : urlsCarrerasFuturas) {
			carreras.add(new CarreraSemillaBetright(urlCarrera, null, null, null, null, null,
					new ArrayList<CarreraGalgoSemillaBetright>()));
			anhadidas++;
			if (anhadidas >= Constantes.MAX_NUM_CARRERAS_SEMILLA) {
				break;
			}
		}

		if (urlsCarrerasFuturas == null || urlsCarrerasFuturas.isEmpty()) {
			MY_LOGGER.error("BB-ERROR: No hemos descargado NINGUNA carrera FUTURA (semilla)!!!!");

		} else {

			guardarListaEnFichero(urlsCarrerasFuturas, prefijoPathDatosBruto + "_listaurlsdetalles");

		}
	}

	/**
	 * Descarga y parsea las carreras FUTURAS de BETBRIGHT.
	 * 
	 * @param prefijoPathDatosBruto
	 *            Path absoluto de la CARPETA donde se van a GUARDAR los DATOS
	 *            BRUTOS.
	 * @param guardarEnFicheros
	 *            BOOLEAN que indica si se quieren GUARDAR los resultados en la
	 *            carpeta (o no, si son pruebas).
	 * @param fileGalgosIniciales
	 *            SALIDA
	 * @throws InterruptedException
	 * @throws IOException
	 */
	public void descargarYParsearSemillasDetalles(String prefijoPathDatosBruto, boolean guardarEnFicheros,
			String fileGalgosIniciales) throws InterruptedException, IOException {

		MY_LOGGER.info("Descarga de paginas web de DETALLE...");

		String tag = "_DET_";
		int contador = 0;
		BetbrightParserDetalleCarreraFutura spdcf = new BetbrightParserDetalleCarreraFutura();

		String pathCarreraDetalle = "";

		for (CarreraSemillaBetright carrera : carreras) {
			contador++;
			pathCarreraDetalle = prefijoPathDatosBruto + tag + contador;

			if (Constantes.GALGOS_FUTUROS_BETBRIGHT_DESCARGAR_DESDE_JAVA) {
				(new BetbrightDownloader()).descargarDeURLsAFicheros(carrera.urlDetalle, pathCarreraDetalle,
						guardarEnFicheros);
			} else {
				MY_LOGGER.info(
						"ATENCION: se supone que la carrera futura de BB se ha descargado mediante script (hack) externo en: "
								+ pathCarreraDetalle);
			}

			// Para cada carrera, extraigo toda la info que pueda y la meto en la instancia
			spdcf.ejecutar(pathCarreraDetalle, carrera);
		}

		desnormalizarSemillasYGuardarlasEnFicheros(fileGalgosIniciales);

		MY_LOGGER.info("BB-Carreras FUTURAS con sus galgos (semillas): OK");

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

		MY_LOGGER.info("La lista de URLs de detalle la metemos en este fichero: " + pathListaUrlsDetalles);
		if (Files.exists(Paths.get(pathListaUrlsDetalles))) {
			MY_LOGGER.debug("Borrando fichero de listaurlsdetalles preexistente...");
			Files.delete(Paths.get(pathListaUrlsDetalles));
		}

		boolean primero = true;
		for (String urlCarrera : urlsCarrerasFuturas) {

			String aux = primero ? "" : "\n";
			aux += urlCarrera;

			Files.write(Paths.get(pathListaUrlsDetalles), aux.getBytes(), StandardOpenOption.APPEND);

			primero = false;
		}
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
