package casa.galgos;

import java.io.IOException;
import java.io.Serializable;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.file.StandardOpenOption;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collection;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;

import org.apache.log4j.Logger;

import casa.galgos.gbgb.GalgoAgregados;
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

	public Map<String, Boolean> idCarrerasCampeonatoProcesadas = new HashMap<String, Boolean>(); // ID_carrera-ID_campeonato,
																									// procesada
																									// (boolean)
	// pendientes
	public List<GalgosGuardable> guardableCarreras = new ArrayList<GalgosGuardable>();
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

		MY_LOGGER.info("MAX_NUM_CARRERAS_PROCESADAS = " + Constantes.MAX_NUM_CARRERAS_PROCESADAS);

		boolean primeraEscritura = true;

		GbgbParserGalgoHistorico gpgh = new GbgbParserGalgoHistorico();

		List<GbgbCarrera> carreras = descargarCarrerasSinFiltrarPorDia(prefijoPathDatosBruto);

		if (carreras != null && !carreras.isEmpty()) {

			for (GbgbCarrera carrera : carreras) {
				idCarrerasCampeonatoProcesadas.put(carrera.id_carrera + "-" + carrera.id_campeonato, false);
			}

			// ------ Procesar las carreras de las que conozco la URL
			// (embuclandose)-----------------------------------

			do {

				MY_LOGGER.debug("Carreras PENDIENTES de procesar (IDs acumulados): " + contarPendientes());

				Map<String, Boolean> pendientes = extraerSoloCarrerasPendientes();

				String idCarreraIdcampeonatoAProcesar = pendientes.keySet().iterator().next();

				MY_LOGGER.info("Procesando carrera " + idCarreraIdcampeonatoAProcesar + " ...");

				String[] partes = idCarreraIdcampeonatoAProcesar.split("-");

				descargarYProcesarCarreraYAcumularUrlsHistoricos(Long.valueOf(partes[0]), Long.valueOf(partes[1]),
						prefijoPathDatosBruto);

				descargarTodosLosHistoricos(prefijoPathDatosBruto, gpgh);

				// lo marco como procesado
				idCarrerasCampeonatoProcesadas.replace(idCarreraIdcampeonatoAProcesar, true);

				if (guardarEnFicheros && guardableHistoricosGalgos
						.size() >= Constantes.MAX_NUM_FILAS_EN_MEMORIA_SIN_ESCRIBIR_EN_FICHERO) {

					guardarEnFicheroYLimpiarLista(guardableCarreras, primeraEscritura);
					guardarEnFicheroYLimpiarLista(guardableHistoricosGalgos, primeraEscritura);
					guardarEnFicheroYLimpiarLista(guardableGalgoAgregados.values(), primeraEscritura);

					primeraEscritura = false;
				}

				MY_LOGGER.debug("Esperando " + Constantes.ESPERA_ENTRE_DESCARGA_CARRERAS_MSEC + " mseg...");
				Thread.sleep(Constantes.ESPERA_ENTRE_DESCARGA_CARRERAS_MSEC);

			} while (contarPendientes() >= 1 && guardableCarreras.size() <= Constantes.MAX_NUM_CARRERAS_PROCESADAS);

			MY_LOGGER.info("El BUCLE ha TERMINADO: carreras_pendientes=" + contarPendientes() + " carreras_guardadas="
					+ guardableCarreras.size() + " historicos_galgos=" + guardableHistoricosGalgos.size());

			// RESTANTES: fuera del bucle while, guardo lo que ya tenga descargado, pero no
			// descargo nada mas para evitar que me baneen.
			if (guardarEnFicheros) {
				guardarEnFicheroYLimpiarLista(guardableCarreras, primeraEscritura);
				guardarEnFicheroYLimpiarLista(guardableHistoricosGalgos, primeraEscritura);
				guardarEnFicheroYLimpiarLista(guardableGalgoAgregados.values(), primeraEscritura);
			}

			// Mostrar las claves que no hemos podido traducir
			mostrarRemarksSinTraducir(gpgh);

		} else {
			MY_LOGGER.warn("No hay carreras!!");
		}

	}

	/**
	 * @return
	 */
	public static String mostrarRemarksSinTraducir(GbgbParserGalgoHistorico gpgh) {

		MY_LOGGER.info("Numero de remarks que no hemos podido traducir: " + gpgh.remarksClavesSinTraduccion.size());

		int num = 0;
		String clavesSinTraducir = "";
		for (String clave : gpgh.remarksClavesSinTraduccion) {
			if (num > 0) {
				clavesSinTraducir += "|";
			}
			clavesSinTraducir += clave;
			num++;
			if (num > 100) {
				break;
			}
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
				if (valor == false) {// pendiente (=false)
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

		for (String clave : idCarrerasCampeonatoProcesadas.keySet()) {

			if (idCarrerasCampeonatoProcesadas.get(clave) == false) {// pendiente
				soloPendientes.put(clave, idCarrerasCampeonatoProcesadas.get(clave));
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
				MY_LOGGER.info("Limpiando lista en memoria. Estado de la lista tras limpiar: " + listaFilas.size());

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

			// evitamos descargar carreras que ya tenemos
			if (idCarrerasCampeonatoProcesadas.containsKey(carrera.id_carrera + "-" + carrera.id_campeonato) == false) {
				idCarrerasCampeonatoProcesadas.put(carrera.id_carrera + "-" + carrera.id_campeonato, false);
			}

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
	 * @param gpgh
	 *            Parser de historicos
	 */
	public void descargarTodosLosHistoricos(String param3, GbgbParserGalgoHistorico gpgh) {

		MY_LOGGER.info("Descargando HISTORICOS (tenemos " + urlsHistoricoGalgos.size() + " URLs)...");
		String pathFileGalgoHistorico = "";

		Calendar fechaUmbralAnterior = Calendar.getInstance();
		fechaUmbralAnterior.setTimeInMillis(fechaUmbralAnterior.getTimeInMillis()
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
			GbgbGalgoHistorico historico = gpgh.ejecutar(pathFileGalgoHistorico, galgo_nombre);
			guardableHistoricosGalgos.add(historico);

			MY_LOGGER.debug("Con el historico, calculamos AGREGADOS estadisticos..");
			calcularAgregados(historico);

			MY_LOGGER.debug(
					"Del historico, cogemos la URL de carreras anteriores que queremos descargar (de los ultimos X meses)...");
			MY_LOGGER
					.debug("Fecha umbral (hace X meses): " + GbgbCarrera.FORMATO.format(fechaUmbralAnterior.getTime()));

			for (GbgbGalgoHistoricoCarrera fila : historico.carrerasHistorico) {
				if (isHistoricoInsertable(fila, fechaUmbralAnterior)) {
					idCarrerasCampeonatoProcesadas.put(fila.id_carrera + "-" + fila.id_campeonato, false);
				}
			}
		}

	}

	/**
	 * @param fila
	 * @param fechaUmbralAnterior
	 * @return TRUE si hay que insertar esta fila
	 */
	public boolean isHistoricoInsertable(GbgbGalgoHistoricoCarrera fila, Calendar fechaUmbralAnterior) {
		return
		// FECHA POSTERIOR AL UMBRAL
		fila.fecha != null && fila.fecha.after(fechaUmbralAnterior)

		// FECHA SIEMPRE ANTERIOR A AHORA (no coger futuras)
				&& fila.fecha.before(Calendar.getInstance())

				// evitamos descargar carreras que YA TENEMOS
				&& idCarrerasCampeonatoProcesadas.containsKey(fila.id_carrera + "-" + fila.id_campeonato) == false;
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
				!guardableGalgoAgregados.containsKey(historico.galgo_nombre)) {

			guardableGalgoAgregados.put(historico.galgo_nombre,
					new GalgoAgregados(historico.galgo_nombre,
							calcularVelocidadRealMediaReciente(historico.carrerasHistorico),
							calcularVelocidadConGoingMediaReciente(historico.carrerasHistorico)));

		}
	}

	/**
	 * @param carrerasHistorico
	 * @return
	 */
	public Float calcularVelocidadRealMediaReciente(List<GbgbGalgoHistoricoCarrera> carrerasHistorico) {

		Float out = null;

		Calendar fechaUmbralAnterior = Calendar.getInstance();
		fechaUmbralAnterior.setTimeInMillis(fechaUmbralAnterior.getTimeInMillis()
				- 1000 * 24 * 60 * 60 * Constantes.GALGOS_UMBRAL_DIAS_CARRERAS_ANTERIORES);

		Float acumuladoReal = 0.0F;
		Integer numeroFilas = 0;

		for (GbgbGalgoHistoricoCarrera fila : carrerasHistorico) {
			if (fila.fecha.after(fechaUmbralAnterior) && fila.velocidadReal != null) {
				numeroFilas++;
				acumuladoReal += fila.velocidadReal;
			}
		}

		if (acumuladoReal.intValue() > 0) {
			out = acumuladoReal / numeroFilas;
		}

		return out;
	}

	/**
	 * @param carrerasHistorico
	 * @return
	 */
	public Float calcularVelocidadConGoingMediaReciente(List<GbgbGalgoHistoricoCarrera> carrerasHistorico) {

		Float out = null;

		Calendar fechaUmbralAnterior = Calendar.getInstance();
		fechaUmbralAnterior.setTimeInMillis(fechaUmbralAnterior.getTimeInMillis()
				- 1000 * 24 * 60 * 60 * Constantes.GALGOS_UMBRAL_DIAS_CARRERAS_ANTERIORES);

		Float acumuladoConGoing = 0.0F;
		Integer numeroFilas = 0;

		for (GbgbGalgoHistoricoCarrera fila : carrerasHistorico) {
			if (fila.fecha.after(fechaUmbralAnterior) && fila.velocidadConGoing != null) {
				numeroFilas++;
				acumuladoConGoing += fila.velocidadConGoing;
			}
		}

		if (acumuladoConGoing.intValue() > 0) {
			out = acumuladoConGoing / numeroFilas;
		}

		return out;
	}

}
