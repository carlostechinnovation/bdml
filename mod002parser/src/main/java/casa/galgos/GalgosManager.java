package casa.galgos;

import java.io.IOException;
import java.io.Serializable;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.file.StandardOpenOption;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.HashSet;
import java.util.List;

import org.apache.log4j.Logger;

import casa.galgos.gbgb.GalgosGuardable;
import casa.galgos.gbgb.GbgbCarrera;
import casa.galgos.gbgb.GbgbDownloader;
import casa.galgos.gbgb.GbgbGalgoHistorico;
import casa.galgos.gbgb.GbgbGalgoHistoricoCarrera;
import casa.galgos.gbgb.GbgbParserCarreraDetalle;
import casa.galgos.gbgb.GbgbParserCarrerasSinFiltrar;
import casa.galgos.gbgb.GbgbParserGalgoHistorico;
import utilidades.Constantes;

public class GalgosManager implements Serializable {

	private static final long serialVersionUID = 1L;

	static Logger MY_LOGGER = Logger.getLogger(GalgosManager.class);

	public HashSet<String> idCarrerasCampeonatoPendientes = new HashSet<String>(); // ID_carrera-ID_campeonato
	// pendientes
	public List<GalgosGuardable> guardableCarreras = new ArrayList<GalgosGuardable>();
	public HashSet<String> urlsHistoricoGalgos = new HashSet<String>(); // URLs de historicos SIN DUPLICADOS
	public List<GalgosGuardable> guardableHistoricosGalgos = new ArrayList<GalgosGuardable>();

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
	 * @param param2
	 *            Dia de la descarga
	 * @param param3
	 *            Prefijo de ficheros brutos
	 * @param guardarEnFicheros
	 * @throws InterruptedException
	 */
	/**
	 * @param param2
	 * @param param3
	 * @param guardarEnFicheros
	 * @throws InterruptedException
	 */
	public void descargarYparsearCarrerasDeGalgos(String prefijoPathDatosBruto, boolean guardarEnFicheros)
			throws InterruptedException {

		List<GbgbCarrera> carreras = null;
		carreras = descargarCarrerasSinFiltrarPorDia(prefijoPathDatosBruto);

		if (carreras != null && !carreras.isEmpty()) {

			for (GbgbCarrera carrera : carreras) {
				idCarrerasCampeonatoPendientes.add(carrera.id_carrera + "-" + carrera.id_campeonato);
			}

			// ------ Procesar las carreras de las que conozco la URL
			// (embuclandose)-----------------------------------
			do {
				MY_LOGGER.debug(
						"Carreras PENDIENTES de procesar (IDs acumulados): " + idCarrerasCampeonatoPendientes.size());

				String idCarreraIdcampeonatoAProcesar = idCarrerasCampeonatoPendientes.iterator().next();

				MY_LOGGER.info("Procesando carrera " + idCarreraIdcampeonatoAProcesar + " ...");

				String[] partes = idCarreraIdcampeonatoAProcesar.split("-");

				descargarYProcesarCarreraYAcumularUrlsHistoricos(Long.valueOf(partes[0]), Long.valueOf(partes[1]),
						prefijoPathDatosBruto);

				descargarTodosLosHistoricos(prefijoPathDatosBruto);

				idCarrerasCampeonatoPendientes.remove(idCarreraIdcampeonatoAProcesar);

				MY_LOGGER.debug("Esperando " + Constantes.ESPERA_ENTRE_DESCARGA_CARRERAS_MSEC + " mseg...");
				Thread.sleep(Constantes.ESPERA_ENTRE_DESCARGA_CARRERAS_MSEC);

			} while (!idCarrerasCampeonatoPendientes.isEmpty()
					&& guardableCarreras.size() <= Constantes.MAX_NUM_CARRERAS_PROCESADAS);

			MY_LOGGER.info("El BUCLE ha TERMINADO: carreras_pendientes=" + idCarrerasCampeonatoPendientes.size()
					+ " carreras_guardadas=" + guardableCarreras.size() + " historicos_galgos="
					+ guardableHistoricosGalgos.size());

			if (guardarEnFicheros) {

				guardarEnFichero(guardableCarreras);
				guardarEnFichero(guardableHistoricosGalgos);
			}

		} else {
			MY_LOGGER.warn("No hay carerras!!");
		}

	}

	/**
	 * @param listaFilas
	 */
	public void guardarEnFichero(List<GalgosGuardable> listaFilas) {

		if (listaFilas != null && !listaFilas.isEmpty()) {

			String path = listaFilas.get(0).generarPath(Constantes.PATH_DIR_DATOS_LIMPIOS_GALGOS);

			MY_LOGGER.info("Guardando FICHEROS FINALES en: " + path);

			try {
				MY_LOGGER.debug("Borrando posible fichero preexistente...");
				Files.deleteIfExists(Paths.get(path));

				MY_LOGGER.debug("Escribiendo...");
				boolean primero = true;
				for (GalgosGuardable fila : listaFilas) {
					if (primero) {
						Files.write(Paths.get(path), fila.generarDatosParaExportarSql().getBytes(),
								StandardOpenOption.CREATE);
						primero = false;
					} else {
						Files.write(Paths.get(path), fila.generarDatosParaExportarSql().getBytes(),
								StandardOpenOption.APPEND);
					}

				}

			} catch (IOException e) {
				MY_LOGGER.error("Error:" + e.getMessage());
				e.printStackTrace();
			}

		} else {
			MY_LOGGER.error("Sin datos. No guardamos fichero!!!");
		}

	}

	/**
	 * @param param2
	 * @param param3
	 * @return
	 */
	public List<GbgbCarrera> descargarCarrerasSinFiltrarPorDia(String prefijoPathDatosBruto) {

		MY_LOGGER.info(
				"Descargando carreras SIN filtrar por dia... (sirve para extraer cookies y parametros ocultos...)");
		String SUFIJO_CARRERAS_SIN_FILTRAR = "_carreras_sin_filtrar";
		(new GbgbDownloader()).descargarCarreras(prefijoPathDatosBruto + SUFIJO_CARRERAS_SIN_FILTRAR, true);

		MY_LOGGER.debug("Parseando carreras SIN filtrar por dia...");
		List<GbgbCarrera> carreras = (new GbgbParserCarrerasSinFiltrar())
				.ejecutar(prefijoPathDatosBruto + SUFIJO_CARRERAS_SIN_FILTRAR);

		MY_LOGGER.debug("Cogemos la URL de carreras que queremos descargar...");
		for (GbgbCarrera carrera : carreras) {
			idCarrerasCampeonatoPendientes.add(carrera.id_carrera + "-" + carrera.id_campeonato);
		}

		return carreras;
	}

	/**
	 * @param idCarrera
	 * @param idCampeonato
	 * @param param3
	 *            Prefijo de ficheros brutos
	 */
	public void descargarYProcesarCarreraYAcumularUrlsHistoricos(Long idCarrera, Long idCampeonato, String param3) {

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

		MY_LOGGER.debug("GUARDABLE - Carrera (EVITANDO DUPLICADOS)");
		guardableCarreras.add(carrera);

		MY_LOGGER.debug("GUARDABLE - URLs de historicos de galgos (EVITANDO DUPLICADOS)");
		urlsHistoricoGalgos.addAll(carrera.detalle.urlsGalgosHistorico);

	}

	/**
	 * @param param3
	 *            Prefijo de ficheros brutos
	 */
	public void descargarTodosLosHistoricos(String param3) {

		MY_LOGGER.debug("Descargando HISTORICOS (tenemos " + urlsHistoricoGalgos.size() + " URLs)...");
		String pathFileGalgoHistorico = "";

		Calendar fechaUmbral = Calendar.getInstance();
		fechaUmbral.setTimeInMillis(fechaUmbral.getTimeInMillis()
				- 1000 * 24 * 60 * 60 * Constantes.GALGOS_UMBRAL_DIAS_CARRERAS_ANTERIORES);

		for (String urlGalgo : urlsHistoricoGalgos) {

			String galgo_nombre = urlGalgo.split("=")[1];
			pathFileGalgoHistorico = param3 + "_galgohistorico_" + galgo_nombre;
			MY_LOGGER.debug("URL Historico galgo = " + urlGalgo);
			MY_LOGGER.debug("Galgo nombre = " + galgo_nombre);
			MY_LOGGER.debug("Path historico = " + pathFileGalgoHistorico);

			MY_LOGGER.debug("Descargando historico...");
			(new GbgbDownloader()).descargarHistoricoGalgo(urlGalgo, pathFileGalgoHistorico, true);

			MY_LOGGER.debug("GUARDABLE - Historico de galgo (EVITANDO DUPLICADOS)");
			GbgbGalgoHistorico historico = (new GbgbParserGalgoHistorico()).ejecutar(pathFileGalgoHistorico,
					galgo_nombre);
			guardableHistoricosGalgos.add(historico);

			MY_LOGGER.debug(
					"Del historico, cogemos la URL de carreras anteriores que queremos descargar (de los ultimos X meses)...");
			MY_LOGGER.debug("Fecha umbral (hace X meses): " + GbgbCarrera.FORMATO.format(fechaUmbral.getTime()));
			for (GbgbGalgoHistoricoCarrera fila : historico.carrerasHistorico) {
				if (fila.fecha != null && fila.fecha.after(fechaUmbral)) {
					idCarrerasCampeonatoPendientes.add(fila.id_carrera + "-" + fila.id_campeonato);
				}
			}
		}

	}

}
