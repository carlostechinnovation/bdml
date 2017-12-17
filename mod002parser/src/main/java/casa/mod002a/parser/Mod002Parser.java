/**
 * 
 */
package casa.mod002a.parser;

import java.io.IOException;
import java.io.Serializable;
import java.nio.file.Files;
import java.nio.file.Paths;

import org.apache.log4j.BasicConfigurator;
import org.apache.log4j.Logger;

import casa.galgos.GalgosManager;
import casa.galgos.gbgb.GalgoAgregados;
import casa.galgos.gbgb.GbgbCarrera;
import casa.galgos.gbgb.GbgbGalgoHistorico;
import casa.galgos.gbgb.GbgbPosicionEnCarrera;
import casa.galgos.sportium.SportiumCarreraGalgo;
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
public class Mod002Parser implements Serializable {

	private static final long serialVersionUID = 1L;

	static Logger MY_LOGGER = Logger.getLogger(Mod002Parser.class);

	/**
	 * PARAM1 - Tipo de proceso: 01 (obtener tag del dia con BoeParser) 02 (Generar
	 * Sentencias Create table) 03 (Procesar datos de un dia)
	 * 04-galgos-Descargar_GBGB
	 * 
	 * PARAM2 - Path entrada: TAG del día.
	 * 
	 * @param args
	 */
	public static void main(String[] args) {

		// LOGS: Set up a simple configuration that logs on the console.
		BasicConfigurator.configure();

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

			(new BoeParser()).ejecutar(Constantes.PATH_DIR_DATOS_BRUTOS_BOLSA + Constantes.BOE_IN,
					Constantes.PATH_DIR_DATOS_BRUTOS_BOLSA + Constantes.BOE_OUT, false);

		} else if (param1 != null && param1.equals("02") && param2 != null) {

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

			MY_LOGGER.info("Escribiendo sentencias_create_table en: " + param2);

			try {

				// Forma nueva
				Files.write(Paths.get(param2), out.getBytes());

			} catch (IOException e) {
				MY_LOGGER.error("Error:" + e.getMessage());
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

		} else if (param1 != null && param1.equals("04") && param2 != null) {

			MY_LOGGER.info("Escribiendo sentencias_create_table en: " + param2);

			out += (new GbgbGalgoHistorico(true)).generarSqlCreateTable("");
			out += (new GbgbCarrera(true)).generarSqlCreateTable("");
			out += (new GbgbPosicionEnCarrera(true)).generarSqlCreateTable("");
			out += (new GalgoAgregados(null, null, null, null, null, null, null, null, null, null, null, null, null))
					.generarSqlCreateTable("");

			out += (new SportiumCarreraGalgo(null, null, null, null)).generarSqlCreateTable();

			try {

				// Forma nueva
				Files.write(Paths.get(param2), out.getBytes());

			} catch (IOException e) {
				MY_LOGGER.error("Error:" + e.getMessage());
				e.printStackTrace();
			}

		} else if (param1 != null && param1.equals("05") && param2 != null && !param2.isEmpty() && param3 != null
				&& !param3.isEmpty()) {

			try {
				GalgosManager.getInstancia().descargarYparsearCarrerasDeGalgos(param2, true, param3);

			} catch (InterruptedException e) {
				MY_LOGGER.error("ERROR Excepcion de galgos.");
				e.printStackTrace();
			}

		} else if (param1 != null && param1.equals("06") && param2 != null) {
			// GALGOS - Carreras futuras que queremos predecir
			MY_LOGGER.info("Escribiendo sentencias_create_table FUTURAS en: " + param2);

			out += (new GbgbCarrera(true)).generarSqlCreateTable("_fut");
			out += (new GbgbPosicionEnCarrera(true)).generarSqlCreateTable("_fut");

			try {

				// Forma nueva
				Files.write(Paths.get(param2), out.getBytes());

			} catch (IOException e) {
				MY_LOGGER.error("Error:" + e.getMessage());
				e.printStackTrace();
			}

		} else if (param1 != null && param1.equals("07") && param2 != null && !param2.isEmpty() && param3 != null
				&& !param3.isEmpty()) {

			try {
				GalgosManager.getInstancia().descargarYParsearSemillas(param2, true, param3);

			} catch (InterruptedException e) {
				MY_LOGGER.error("ERROR Excepcion de galgos.");
				e.printStackTrace();
			}

		} else {
			MY_LOGGER.error("ERROR Los parametros de entrada a Mod002Parser no son correctos.");
		}

		MY_LOGGER.info("FIN");
	}

}