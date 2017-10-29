package casa.galgos;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.HashSet;
import java.util.List;
import java.util.logging.Logger;

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

	private static Logger MY_LOGGER = Logger.getLogger(Thread.currentThread().getStackTrace()[0].getClassName());

	public HashSet<String> idCarrerasCampeonatoPendientes = new HashSet<String>(); // ID_carrera-ID_campeonato
	// pendientes
	public List<GbgbCarrera> guardableCarreras = new ArrayList<GbgbCarrera>();
	public HashSet<String> urlsHistoricoGalgos = new HashSet<String>(); // URLs de historicos SIN DUPLICADOS
	public List<GbgbGalgoHistorico> guardableHistoricosGalgos = new ArrayList<GbgbGalgoHistorico>();

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
	 * @throws InterruptedException
	 */
	public void descargarYparsearCarrerasDeGalgos(String param2, String param3) throws InterruptedException {

		List<GbgbCarrera> carreras = null;
		carreras = descargarCarrerasSinFiltrarPorDia(param2, param3);

		if (carreras != null && !carreras.isEmpty()) {

			for (GbgbCarrera carrera : carreras) {
				idCarrerasCampeonatoPendientes.add(carrera.id_carrera + "-" + carrera.id_campeonato);
			}

			// ------ Procesar las carreras de las que conozco la URL
			// (embuclandose)-----------------------------------
			do {
				MY_LOGGER.info(
						"Carreras PENDIENTES de procesar (IDs acumulados): " + idCarrerasCampeonatoPendientes.size());

				String idCarreraIdcampeonatoAProcesar = idCarrerasCampeonatoPendientes.iterator().next();

				MY_LOGGER.info("Procesando carrera" + idCarreraIdcampeonatoAProcesar + " ...");

				String[] partes = idCarreraIdcampeonatoAProcesar.split("-");

				descargarYProcesarCarreraYAcumularUrlsHistoricos(Long.valueOf(partes[0]), Long.valueOf(partes[1]),
						param3);

				descargarTodosLosHistoricos(param3);

				idCarrerasCampeonatoPendientes.remove(idCarreraIdcampeonatoAProcesar);

				MY_LOGGER.info("Esperando " + Constantes.ESPERA_ENTRE_DESCARGA_CARRERAS_MSEC + " mseg...");
				Thread.sleep(Constantes.ESPERA_ENTRE_DESCARGA_CARRERAS_MSEC);

			} while (!idCarrerasCampeonatoPendientes.isEmpty()
					&& guardableCarreras.size() <= Constantes.MAX_NUM_CARRERAS_PROCESADAS);

			MY_LOGGER.info("El BUCLE ha TERMINADO: pendientes=" + idCarrerasCampeonatoPendientes.size()
					+ " carreras_guardadas=" + guardableCarreras.size());

			MY_LOGGER.info("Guardando FICHEROS FINALES...");// TODO pendiente
			// TODO carrerasDia --> Fichero bruto de carreras (de muchos dias) -->Unificar
			// todo lo que conozca de las carreras
			// (desde el detalle de carreras actuales o desde historico de carreras)

			// TODO historicosGalgos --> Fichero bruto de galgos (historico) -->Unificar
			// todo lo que conozca de los galgos

		} else {
			MY_LOGGER.severe("No hay carerras!!");
		}

	}

	/**
	 * @param param2
	 * @param param3
	 * @return
	 */
	public List<GbgbCarrera> descargarCarrerasSinFiltrarPorDia(String param2, String param3) {

		MY_LOGGER.info(
				"Descargando carreras SIN filtrar por dia... (sirve para extraer cookies y parametros ocultos...)");
		String SUFIJO_CARRERAS_SIN_FILTRAR = "_carreras_sin_filtrar";
		(new GbgbDownloader()).descargarCarreras(param3 + SUFIJO_CARRERAS_SIN_FILTRAR, true);

		MY_LOGGER.info("Parseando carreras SIN filtrar por dia...");
		List<GbgbCarrera> carreras = (new GbgbParserCarrerasSinFiltrar())
				.ejecutar(param3 + SUFIJO_CARRERAS_SIN_FILTRAR);

		MY_LOGGER.info("Cogemos la URL de carreras que queremos descargar...");
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

		MY_LOGGER.info("Descargando DETALLE de CARRERA con URL = " + urlCarrera);

		pathFileCarreraDetalleBruto = param3 + SUFIJO_CARRERA + idCarrera;

		MY_LOGGER.info("URL = " + urlCarrera);
		MY_LOGGER.info("Fichero carrera bruto = " + pathFileCarreraDetalleBruto);
		(new GbgbDownloader()).descargarCarreraDetalle(urlCarrera, pathFileCarreraDetalleBruto, true);

		MY_LOGGER.info("Parseando carrera...");
		carrera = (new GbgbParserCarreraDetalle()).ejecutar(idCarrera, idCampeonato, pathFileCarreraDetalleBruto);

		MY_LOGGER.info("GUARDABLE - Carrera (EVITANDO DUPLICADOS)");
		guardableCarreras.add(carrera);

		MY_LOGGER.info("GUARDABLE - URLs de historicos de galgos (EVITANDO DUPLICADOS)");
		urlsHistoricoGalgos.addAll(carrera.detalle.urlsGalgosHistorico);

	}

	/**
	 * @param param3
	 *            Prefijo de ficheros brutos
	 */
	public void descargarTodosLosHistoricos(String param3) {

		MY_LOGGER.info("------- HISTORICOS (" + urlsHistoricoGalgos.size() + " URLs) -------");
		String pathFileGalgoHistorico = "";

		Calendar fechaUmbral = Calendar.getInstance();
		fechaUmbral.setTimeInMillis(fechaUmbral.getTimeInMillis()
				- 1000 * 24 * 60 * 60 * Constantes.GALGOS_UMBRAL_DIAS_CARRERAS_ANTERIORES);

		for (String urlGalgo : urlsHistoricoGalgos) {

			String galgo_nombre = urlGalgo.split("=")[1];
			pathFileGalgoHistorico = param3 + "_galgohistorico_" + galgo_nombre;
			MY_LOGGER.info("URL Historico galgo = " + urlGalgo);
			MY_LOGGER.info("Galgo nombre = " + galgo_nombre);
			MY_LOGGER.info("Path historico = " + pathFileGalgoHistorico);

			MY_LOGGER.info("Descargando historico...");
			(new GbgbDownloader()).descargarHistoricoGalgo(urlGalgo, pathFileGalgoHistorico, true);

			MY_LOGGER.info("GUARDABLE - Historico de galgo (EVITANDO DUPLICADOS)");
			GbgbGalgoHistorico historico = (new GbgbParserGalgoHistorico()).ejecutar(pathFileGalgoHistorico,
					galgo_nombre);
			guardableHistoricosGalgos.add(historico);

			MY_LOGGER.info(
					"Del historico, cogemos la URL de carreras anteriores que queremos descargar (de los ultimos 6 meses)...");
			MY_LOGGER.info("Fecha umbral (hace 6 meses): " + fechaUmbral.toString());
			for (GbgbGalgoHistoricoCarrera fila : historico.carrerasHistorico) {
				if (fila.fecha != null && fila.fecha.after(fechaUmbral)) {
					idCarrerasCampeonatoPendientes.add(fila.id_carrera + "-" + fila.id_campeonato);
				}
			}
		}

	}

}
