/**
 * 
 */
package casa.mod002.parser;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
//import java.nio.charset.Charset;
//import java.nio.file.Files;
//import java.nio.file.Paths;
import java.util.logging.Level;
import java.util.logging.Logger;

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
import utilidades.MiFormateador;

/**
 * @author root
 *
 */
public class Mod002Parser {

	private static Logger MY_LOGGER = Logger.getLogger(Thread.currentThread().getStackTrace()[0].getClassName());

	/**
	 * PARAM1 - Tipo de proceso: 01 (obtener tag del dia con BoeParser) 02 (Generar
	 * Sentencias Create table) 03 (Procesar datos de un dia)
	 * 
	 * PARAM2 - Path entrada: TAG del Día.
	 * 
	 * @param args
	 */
	public static void main(String[] args) {

		System.out.println("INICIO");
		MY_LOGGER.info("INICIO");

		String param1 = args[0];
		String param2 = null;

		if (args.length == 2) {
			param2 = args[1];
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

		} else {
			MY_LOGGER.severe("ERROR Los parametros de entrada a Mod001Parser no son correctos.");
		}

		MY_LOGGER.info("FIN");
	}

}