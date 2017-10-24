/**
 * 
 */
package casa.mod002a.parser;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.HashSet;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

import casa.galgos.gbgb.GbgbCarrera;
import casa.galgos.gbgb.GbgbCarreraDetalle;
import casa.galgos.gbgb.GbgbCarrerasDeUnDia;
import casa.galgos.gbgb.GbgbDownloader;
import casa.galgos.gbgb.GbgbParserCarreraDetalle;
import casa.mod002a.boe.BoeParser;
import casa.mod002a.bolsamadrid.BM01Parser;
import casa.mod002a.bolsamadrid.BM02Parser;
import casa.mod002a.bolsamadrid.BM03Parser;
import casa.mod002a.bolsamadrid.BM04Parser;
import casa.mod002a.bolsamadrid.BM05Parser;
import casa.mod002a.bolsamadrid.BM06Parser;
import casa.mod002a.datosmacro.DM01Parser;
import casa.mod002a.datosmacro.DM02Parser;
import casa.mod002a.datosmacro.DM03Parser;
import casa.mod002a.datosmacro.DM04Parser;
import casa.mod002a.datosmacro.DM05Parser;
import casa.mod002a.datosmacro.DM06Parser;
import casa.mod002a.datosmacro.DM07Parser;
import casa.mod002a.datosmacro.DM08Parser;
import casa.mod002a.datosmacro.DM09Parser;
import casa.mod002a.datosmacro.DM10Parser;
import casa.mod002a.datosmacro.DM11Parser;
import casa.mod002a.datosmacro.DM12Parser;
import casa.mod002a.datosmacro.DM13Parser;
import casa.mod002a.datosmacro.DM14Parser;
import casa.mod002a.datosmacro.DM15Parser;
import casa.mod002a.googlefinance.GF01Parser;
import casa.mod002a.googlefinance.GF02Parser;
import casa.mod002a.googlefinance.GF03Parser;
import casa.mod002a.googlefinance.GF04Parser;
import casa.mod002a.googlefinance.GF05Parser;
import casa.mod002a.googlefinance.GF06Parser;
import casa.mod002a.ine.IneParser;
import utilidades.Constantes;

/**
 * @author root
 *
 */
public class Mod002Parser {

	private static Logger MY_LOGGER = Logger.getLogger(Thread.currentThread().getStackTrace()[0].getClassName());

	/**
	 * PARAM1 - Tipo de proceso: 01 (obtener tag del dia con BoeParser) 02 (Generar
	 * Sentencias Create table) 03 (Procesar datos de un dia)
	 * 04-galgos-Descargar_GBGB
	 * 
	 * PARAM2 - Path entrada: TAG del Día.
	 * 
	 * @param args
	 */
	public static void main(String[] args) {

		MY_LOGGER.info("INICIO");

		String param1 = args[0];
		MY_LOGGER.info("param1=" + param1);
		String param2 = null;
		String param3 = null;

		if (args.length >= 2) {
			param2 = args[1];
			MY_LOGGER.info("param2=" + param2);
		}
		if (args.length >= 3) {
			param3 = args[2];
			MY_LOGGER.info("param3=" + param3);
		}

		String out = "";

		if (param1 != null && param1.equals("01")) {

			(new BoeParser()).ejecutar(Constantes.PATH_DIR_DATOS_BRUTOS + Constantes.BOE_IN,
					Constantes.PATH_DIR_DATOS_BRUTOS + Constantes.BOE_OUT, false);

		} else if (param1 != null && param1.equals("02")) {

			out += (new GF01Parser()).generarSqlCreateTable();
			out += (new GF02Parser()).generarSqlCreateTable();
			out += (new GF03Parser()).generarSqlCreateTable();
			out += (new GF04Parser()).generarSqlCreateTable();
			out += (new GF05Parser()).generarSqlCreateTable();
			out += (new GF06Parser()).generarSqlCreateTable();

			out += (new BM01Parser()).generarSqlCreateTable();
			out += (new BM02Parser()).generarSqlCreateTable();
			out += (new BM03Parser()).generarSqlCreateTable();
			out += (new BM04Parser()).generarSqlCreateTable();
			out += (new BM05Parser()).generarSqlCreateTable();
			out += (new BM06Parser()).generarSqlCreateTable();

			out += (new IneParser()).generarSqlCreateTable();

			out += (new DM01Parser()).generarSqlCreateTable();
			out += (new DM02Parser()).generarSqlCreateTable();
			out += (new DM03Parser()).generarSqlCreateTable();
			out += (new DM04Parser()).generarSqlCreateTable();
			out += (new DM05Parser()).generarSqlCreateTable();
			out += (new DM06Parser()).generarSqlCreateTable();
			out += (new DM07Parser()).generarSqlCreateTable();
			out += (new DM08Parser()).generarSqlCreateTable();
			out += (new DM09Parser()).generarSqlCreateTable();
			out += (new DM10Parser()).generarSqlCreateTable();
			out += (new DM11Parser()).generarSqlCreateTable();
			out += (new DM12Parser()).generarSqlCreateTable();
			out += (new DM13Parser()).generarSqlCreateTable();
			out += (new DM14Parser()).generarSqlCreateTable();
			out += (new DM15Parser()).generarSqlCreateTable();

			MY_LOGGER.info(
					"Escribiendo hacia " + Constantes.PATH_DIR_DATOS_LIMPIOS + "sentencias_create_table" + " ...");

			try {

				// Forma nueva
				Files.write(Paths.get(Constantes.PATH_DIR_DATOS_LIMPIOS + "sentencias_create_table"), out.getBytes());

			} catch (IOException e) {
				MY_LOGGER.log(Level.SEVERE, "Error:" + e.getMessage());
				e.printStackTrace();
			}

		} else if (param1 != null && param1.equals("03") && param2 != null) {

			(new GF01Parser()).ejecutar(param2);
			(new GF02Parser()).ejecutar(param2);
			(new GF03Parser()).ejecutar(param2);
			(new GF04Parser()).ejecutar(param2);
			(new GF05Parser()).ejecutar(param2);
			(new GF06Parser()).ejecutar(param2);

			(new BM01Parser()).ejecutar(param2);
			(new BM02Parser()).ejecutar(param2);
			(new BM03Parser()).ejecutar(param2);
			(new BM04Parser()).ejecutar(param2);
			(new BM05Parser()).ejecutar(param2);
			(new BM06Parser()).ejecutar(param2);

			(new IneParser()).ejecutar(param2);

			(new DM01Parser()).ejecutar(param2);
			(new DM02Parser()).ejecutar(param2);
			(new DM03Parser()).ejecutar(param2);
			(new DM04Parser()).ejecutar(param2);
			(new DM05Parser()).ejecutar(param2);
			(new DM06Parser()).ejecutar(param2);
			(new DM07Parser()).ejecutar(param2);
			(new DM08Parser()).ejecutar(param2);
			(new DM09Parser()).ejecutar(param2);
			(new DM10Parser()).ejecutar(param2);
			(new DM11Parser()).ejecutar(param2);
			(new DM12Parser()).ejecutar(param2);
			(new DM13Parser()).ejecutar(param2);
			(new DM14Parser()).ejecutar(param2);
			(new DM15Parser()).ejecutar(param2);

		} else if (param1 != null && param1.equals("04") && param2 != null && param3 != null) {
			descargarYparsearCarrerasDeGalgos(param2, param3);

		} else {
			MY_LOGGER.severe("ERROR Los parametros de entrada a Mod001Parser no son correctos.");
		}

		MY_LOGGER.info("FIN");
	}

	/**
	 * @param param2
	 * @param param3
	 */
	public static void descargarYparsearCarrerasDeGalgos(String param2, String param3) {

		// String SUFIJO_CARRERAS_SIN_FILTRAR = "_carreras_sin_filtrar";// Sin filtrar
		// dia. Sirve para extraer
		// cookies y parametros ocultos...

		// TODO DESCOMENTAR
		// (new GbgbDownloader()).descargarCarreras(param3
		// +SUFIJO_CARRERAS_SIN_FILTRAR, true);

		// TODO DESCOMENTAR
		// GbgbCarrerasInfoUtilHttp infoUtil = (new
		// GbgbParserCarrerasSinFiltrar()).ejecutar(param3 +
		// SUFIJO_CARRERAS_SIN_FILTRAR);

		// String SUFIJO_CARRERAS_FILTRADAS = "_carreras_sin_filtrar_limpio";

		// TODO Descargar todas las carreras de un dia
		// (new GbgbDownloader()).descargarCarrerasDeUnDia(infoUtil, param2, pathOut,
		// true);

		// GbgbCarrerasInfoUtil infoUtil = (new GbgbParserCarreras()).ejecutar(param3 +
		// SUFIJO_CARRERAS_SIN_FILTRAR);

		// TODO Quitar esto
		GbgbCarrerasDeUnDia carrerasDia = generarCarrerasDePrueba(2030316L, 151752L);

		HashSet<String> urlsHistoricoGalgos = new HashSet<String>(); // Lista de URLs de los historicos de los
																		// galgos, SIN DUPLICADOS

		if (carrerasDia != null) {

			if (carrerasDia.carreras != null && !carrerasDia.carreras.isEmpty()) {

				String SUFIJO_CARRERA = "_GBGB_bruto_carrera_";
				String urlCarrera = "";
				String pathFileCarreraDetalleBruto = "";
				GbgbCarreraDetalle carreraDetalle = null;

				for (GbgbCarrera carrera : carrerasDia.carreras) {

					urlCarrera = Constantes.GALGOS_GBGB_CARRERA_DETALLE_PREFIJO + carrera.id_carrera;
					pathFileCarreraDetalleBruto = "galgos_" + param3 + SUFIJO_CARRERA + carrera.id_carrera;

					(new GbgbDownloader()).descargarCarreraDetalle(urlCarrera, pathFileCarreraDetalleBruto, true);

					// TODO Parsear cada pagina de carrera, extrayendo todo
					carreraDetalle = (new GbgbParserCarreraDetalle()).ejecutar(pathFileCarreraDetalleBruto);

					// TODO En cada carrera-detalle, tenemos una lista con 6 URLs de los historicos
					// de los galgos. Las vamos acumulando SIN DUPLICADOS.
					urlsHistoricoGalgos.addAll(carreraDetalle.urlsGalgosHistorico);
				}

				// TODO Conocidas las URLs,Extraer todos los historicos de cada galgo

			} else {
				MY_LOGGER.warning("WARNING Este dia no ha habido carreras!!!");
			}

		} else {
			MY_LOGGER.severe(
					"ERROR Esta vacio el objeto de info util (extraido de la pagina de carreras sin filtrar por dia)");
		}

		// TODO SALIDA:
		// - Fichero bruto de carreras -->Unificar todo lo que conozca de las carreras
		// (desde el detalle de carreras actuales o desde historico de carreras)
		// - Fichero bruto de galgos (historico) --->Unificar todo lo que conozca de los
		// galgos

	}

	/**
	 * @return
	 */
	public static GbgbCarrerasDeUnDia generarCarrerasDePrueba(Long id_gbgb, Long id_campeonato) {

		Calendar fechayhora = Calendar.getInstance();
		fechayhora.set(Calendar.YEAR, 2017);
		fechayhora.set(Calendar.MONTH, 10);
		fechayhora.set(Calendar.DAY_OF_MONTH, 22);
		fechayhora.set(Calendar.HOUR_OF_DAY, 19);
		fechayhora.set(Calendar.MINUTE, 54);

		List<GbgbCarrera> carreras = new ArrayList<GbgbCarrera>();
		carreras.add(new GbgbCarrera(id_gbgb, id_campeonato, "Central Park", "D3", fechayhora, 265, null));

		return new GbgbCarrerasDeUnDia(fechayhora, carreras);
	}

}