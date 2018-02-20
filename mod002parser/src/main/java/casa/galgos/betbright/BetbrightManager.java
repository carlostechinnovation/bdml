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
	 * @param prefijoPathDatosBruto
	 * @param guardarEnFicheros
	 * @param fileGalgosIniciales
	 *            SALIDA
	 * @throws InterruptedException
	 */
	public void descargarYParsearSemillas(String prefijoPathDatosBruto, boolean guardarEnFicheros,
			String fileGalgosIniciales) throws InterruptedException {

		MY_LOGGER.info("Descargando pagina de entrada en BETRIGHT con carreras FUTURAS --> TODAY...");
		(new BetbrightDownloader()).descargarDeURLsAFicheros(Constantes.GALGOS_FUTUROS_BETBRIGHT_TODAY,
				prefijoPathDatosBruto, guardarEnFicheros);
		MY_LOGGER.info("Descargando pagina de entrada en BETRIGHT con carreras FUTURAS --> TOMORROW...");
		(new BetbrightDownloader()).descargarDeURLsAFicheros(Constantes.GALGOS_FUTUROS_BETBRIGHT_TOMORROW,
				prefijoPathDatosBruto, guardarEnFicheros);

		MY_LOGGER.info("Extrayendo las URLs del detalle de cada carrera BETRIGHT-FUTURA...");
		List<String> urlsCarrerasFuturas = (new BetbrightParserCarrerasFuturas()).ejecutar(prefijoPathDatosBruto);

		MY_LOGGER.info("URLs obtenidas: " + urlsCarrerasFuturas.size());

		// LIMITAMOS numero de carreras procesadas
		int anhadidas = 0;
		for (String urlCarrera : urlsCarrerasFuturas) {
			carreras.add(new CarreraSemillaBetright(urlCarrera, null, null, null, null, null,
					new ArrayList<CarreraGalgoSemillaBetright>()));
			anhadidas++;
			if (anhadidas >= Constantes.MAX_NUM_CARRERAS_SEMILLA) {
				break;
			}
		}

		if (carreras != null && !carreras.isEmpty()) {

			String tag = "_BB_DET_";
			int contador = 0;
			BetbrightParserDetalleCarreraFutura spdcf = new BetbrightParserDetalleCarreraFutura();

			String pathCarreraDetalle = "";

			for (CarreraSemillaBetright carrera : carreras) {
				contador++;
				pathCarreraDetalle = prefijoPathDatosBruto + tag + contador;

				(new BetbrightDownloader()).descargarDeURLsAFicheros(carrera.urlDetalle, pathCarreraDetalle,
						guardarEnFicheros);

				// Para cada carrera, extraigo toda la info que pueda y la meto en la instancia
				spdcf.ejecutar(pathCarreraDetalle, carrera);
			}

			desnormalizarSemillasYGuardarlasEnFicheros(fileGalgosIniciales);

			MY_LOGGER.info("BB-Carreras FUTURAS con sus galgos (semillas): OK");

		} else {
			MY_LOGGER.info("BB-Carreras FUTURAS con sus galgos (semillas): ERROR!!!!");
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
