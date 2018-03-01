package casa.galgos.betbright;

import java.io.File;
import java.io.FileWriter;
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
		Set<String> urlsCarrerasFuturas = new HashSet<String>();// Quitamos repetidos
		urlsCarrerasFuturas.addAll(urlsCarrerasFuturasToday);
		urlsCarrerasFuturas.addAll(urlsCarrerasFuturasTomorrow);

		MY_LOGGER
				.info("NO LIMITAMOS numero de carreras procesadas porque las semillas IMPORTANTES son las de SPORTIUM. "
						+ "Estas semillas de Betbright solo nos sirven para extraer cierta info (distancia...) y pueden venir en otro orden de aparicion distinto de SPORTIUM."
						+ " Así que debemos descargar TODAS los DETALLES de las carreras FUTURAS de BETBRIGHT, sin poner limites.");

		if (urlsCarrerasFuturas == null || urlsCarrerasFuturas.isEmpty()) {
			MY_LOGGER.warn(
					"BB-WARN: No hemos descargado NINGUNA carrera FUTURA (semilla)!!!! --> Posible causa: que no haya carreras en la web (hoy o mañana): "
							+ urlsCarrerasFuturas);

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
	 * @throws Exception
	 */
	public void guardarListaEnFichero(Set<String> urlsCarrerasFuturas, String pathListaUrlsDetalles) throws Exception {

		MY_LOGGER.info("Lista de URLs de detalle - Guardando " + urlsCarrerasFuturas.size() + " URLs en = "
				+ pathListaUrlsDetalles);

		boolean primero = true;
		if (Files.exists(Paths.get(pathListaUrlsDetalles))) {
			primero = false; // si estamos descargando las carreras de tomorrow, ya tendremos las de today.
								// El script es el que se encarga de borrar el fichero preexistente si se
								// necesita.
		}

		for (String urlCarrera : urlsCarrerasFuturas) {

			String aux = urlCarrera + "\n";

			// StandardOpenOption opcion = primero ? StandardOpenOption.CREATE :
			// StandardOpenOption.APPEND;

			MY_LOGGER.info(pathListaUrlsDetalles + "<--" + aux + " (primero=" + primero + ")");
			// Files.write(Paths.get(pathListaUrlsDetalles), aux.getBytes(),
			// StandardOpenOption.CREATE);

			File file = new File(pathListaUrlsDetalles);
			FileWriter fileWriter = new FileWriter(file);
			fileWriter.write(aux);
			fileWriter.flush();
			fileWriter.close();

			primero = false;
		}

		List<String> lineas = Files.readAllLines(Paths.get(pathListaUrlsDetalles));

		if (Files.exists(Paths.get(pathListaUrlsDetalles)) && !urlsCarrerasFuturas.isEmpty() && !lineas.isEmpty()) {

			MY_LOGGER.info("Lista de URLs de detalle - Guardada OK.");
			MY_LOGGER.info("Lista de URLs de detalle - Contenido (ejemplo de 1 fila): \n" + lineas.get(0));

		} else {
			String msg = "Lista de URLs de detalle - Guardada ERROR: no existe!!!!!!";
			MY_LOGGER.error(msg);
			throw new Exception(msg);
		}

	}

	/**
	 * Descarga y parsea las carreras FUTURAS de BETBRIGHT.
	 * 
	 * @param prefijoPathDatosBruto
	 *            Path absoluto de la CARPETA+PREFIJO donde se van a GUARDAR los
	 *            DATOS BRUTOS de SALIDA. Luego los DATOS LIMPIOS de SALIDA
	 *            (cambiando BRUTO por LIMPIO).
	 * @param guardarEnFicheros
	 *            BOOLEAN que indica si se quieren GUARDAR los resultados en la
	 *            carpeta (o no, si son pruebas).
	 * @param pathListaUrlsDetalles
	 *            Path al FICHERO DE ENTRADA que contiene las URLs de detalle.
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

		List<CarreraSemillaBetbright> csbbLista = new ArrayList<CarreraSemillaBetbright>();

		if (urlsDetalles != null && !urlsDetalles.isEmpty()) {

			for (String urlCarreraDetalle : urlsDetalles) {
				contador++;
				pathCarreraDetalle = prefijoPathDatosBruto + tag + contador + ".html";// la terminacion HTML la añade el
																						// script externo

				boolean continuar = true;

				if (Constantes.GALGOS_FUTUROS_BETBRIGHT_DESCARGAR_DESDE_JAVA) {
					(new BetbrightDownloader()).descargarDeURLsAFicheros(urlCarreraDetalle, pathCarreraDetalle,
							guardarEnFicheros);
				} else {
					boolean existe = Files.exists(Paths.get(pathCarreraDetalle));
					String msg = "La carrera futura de BB ( " + urlCarreraDetalle
							+ " ) deberia estar ya descargada mediante script (hack) externo en: " + pathCarreraDetalle;
					msg += existe ? "" : " --> NO EXISTE!!";
					MY_LOGGER.info(msg);
					if (!existe) {
						// throw new Exception(msg);
						continuar = false;
					}
				}

				if (continuar) {

					// PARSEAR Para cada carrera, extraigo toda la info que pueda y la meto en la
					// instancia
					CarreraSemillaBetbright csbb = spdcf.ejecutar(pathCarreraDetalle, urlCarreraDetalle);

					if (csbb != null && csbb.distancia != null && csbb.tipoPista != null && csbb.listaCG != null
							&& !csbb.listaCG.isEmpty()) {
						csbbLista.add(csbb);
						MY_LOGGER.info(csbb.toString());

					} else {
						String msg = "BB-PARSEAR-DETALLE Mal parseado: URL=" + urlCarreraDetalle + " FICHERO="
								+ pathCarreraDetalle;
						MY_LOGGER.error(msg);
						throw new Exception(msg);
					}

					if (contador >= Constantes.GALGOS_FUTUROS_BETBRIGHT_CARRERAGALGOS_MAX) {
						break;
					}

				}
			}

			desnormalizarSemillasYGuardarlasEnFicheros(prefijoPathDatosBruto, csbbLista);

			MY_LOGGER.info("BB-Carreras FUTURAS con sus galgos (semillas): OK");
		} else {
			MY_LOGGER.error("BB-Carreras FUTURAS con sus galgos (semillas): No hay carreras futuras!!");
			throw new Exception("BB-Carreras FUTURAS con sus galgos (semillas): No hay carreras futuras!!");
		}

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
	 *            Path BRUTO y, cambiando la palabra BRUTO por LIMPIO, tengo el path
	 *            LIMPIO de SALIDA.
	 * @param csbbLista
	 */
	public void desnormalizarSemillasYGuardarlasEnFicheros(String fileGalgosIniciales,
			List<CarreraSemillaBetbright> csbbLista) {

		MY_LOGGER.info("desnormalizarSemillasYGuardarlasEnFicheros.fileGalgosIniciales = " + fileGalgosIniciales);
		MY_LOGGER.info("desnormalizarSemillasYGuardarlasEnFicheros.csbbLista.size = " + csbbLista.size());

		// *********************************************************************
		Set<String> galgosIniciales = new HashSet<String>();

		for (CarreraSemillaBetbright c : csbbLista) {
			for (CarreraGalgoSemillaBetbright cg : c.listaCG) {
				galgosIniciales.add(cg.galgoNombre);
			}

		}
		// *** ACUMULO TODOS los cg ******
		List<CarreraGalgoSemillaBetbright> carreraGalgos = new ArrayList<CarreraGalgoSemillaBetbright>();
		for (CarreraSemillaBetbright c : csbbLista) {
			carreraGalgos.addAll(c.listaCG);
		}

		// ******************************************************************

		if (carreraGalgos != null && !carreraGalgos.isEmpty()) {

			String path = fileGalgosIniciales.replace("DATOS_BRUTO", "DATOS_LIMPIO");
			String pathFull = path + "_full";

			MY_LOGGER.info("Guardando GALGOS BB-SEMILLA en: " + path);
			MY_LOGGER.info("Guardando CARRERA-GALGO BB-SEMILLA en: " + pathFull);

			try {

				MY_LOGGER.debug("Borrando posibles ficheros preexistentes...");
				Files.deleteIfExists(Paths.get(path));
				Files.deleteIfExists(Paths.get(pathFull));

				MY_LOGGER.debug("Escribiendo...");

				// ****************************
				boolean primero = true;
				for (String galgoNombre : galgosIniciales) {
					if (primero) {
						Files.write(Paths.get(path), (galgoNombre + Constantes.SEPARADOR_FILA).getBytes(),
								StandardOpenOption.CREATE);
						primero = false;
					} else {
						Files.write(Paths.get(path), (galgoNombre + Constantes.SEPARADOR_FILA).getBytes(),
								StandardOpenOption.APPEND);
					}
				}
				MY_LOGGER.info("Galgos iniciales: " + galgosIniciales.size());

				// ****************************
				primero = true;
				for (CarreraGalgoSemillaBetbright fila : carreraGalgos) {

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
				csbbLista.clear();
				carreraGalgos.clear();

			} catch (IOException e) {
				MY_LOGGER.error("Error:" + e.getMessage());
				e.printStackTrace();
			}

		} else {
			MY_LOGGER.error("Sin datos. No guardamos fichero!!!");
		}
	}

}
