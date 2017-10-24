/**
 * 
 */
package casa.galgos.gbgb;

import java.io.IOException;
import java.io.Serializable;
import java.nio.charset.Charset;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 *
 */
public class GbgbParserCarrerasSinFiltrar implements Serializable {

	private static final long serialVersionUID = 1L;

	public GbgbParserCarrerasSinFiltrar() {
		super();
	}

	private static Logger MY_LOGGER = Logger.getLogger(Thread.currentThread().getStackTrace()[0].getClassName());

	/**
	 * @param pathIn
	 *            Path absoluto al fichero HTML de la pagina del BOE almacenado en
	 *            sistema de ficheros local.
	 * @param pathOut
	 * @param borrarSiExiste
	 */
	public GbgbCarrerasInfoUtilHttp ejecutar(String pathIn) {

		MY_LOGGER.info("GALGOS-GbgbParserCarreras: INICIO");

		String bruto = "";
		GbgbCarrerasInfoUtilHttp out = null;

		try {
			bruto = GbgbParserCarrerasSinFiltrar.readFile(pathIn, Charset.forName("ISO-8859-1"));
			out = parsear(bruto);
			MY_LOGGER.info("GALGOS-GbgbParserCarreras: out=" + out);

		} catch (IOException e) {
			MY_LOGGER.log(Level.SEVERE, "Error:" + e.getMessage());
			e.printStackTrace();
		}

		MY_LOGGER.info("GALGOS-GbgbParserCarreras: FIN");
		return out;
	}

	/**
	 * Lee fichero desde Sistema de ficheros local.
	 * 
	 * @param path
	 * @param encoding
	 * @return
	 * @throws IOException
	 */
	public static String readFile(String path, Charset encoding) throws IOException {

		MY_LOGGER.info("Leyendo " + path + " ...");
		byte[] encoded = Files.readAllBytes(Paths.get(path));
		return new String(encoded, encoding);
	}

	/**
	 * Extrae info util
	 * 
	 * @param in
	 * @return
	 */
	public static GbgbCarrerasInfoUtilHttp parsear(String in) {

		// TODO rellenar
		GbgbCarrerasInfoUtilHttp out = new GbgbCarrerasInfoUtilHttp();

		return out;
	}

}