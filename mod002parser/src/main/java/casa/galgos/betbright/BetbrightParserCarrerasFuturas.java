/**
 * 
 */
package casa.galgos.betbright;

import java.io.IOException;
import java.io.Serializable;
import java.nio.charset.Charset;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;

import org.apache.log4j.Logger;

import utilidades.Constantes;

/**
 *
 */
public class BetbrightParserCarrerasFuturas implements Serializable {

	private static final long serialVersionUID = 1L;

	static Logger MY_LOGGER = Logger.getLogger(BetbrightParserCarrerasFuturas.class);

	public BetbrightParserCarrerasFuturas() {
		super();
	}

	/**
	 * @param pathIn
	 *            Path absoluto al fichero HTML de la pagina del BOE almacenado en
	 *            sistema de ficheros local.
	 * @return urlsCampeonatos
	 */
	public List<String> ejecutar(String pathIn) {

		MY_LOGGER.info("GALGOS-BetbrightParserCarrerasFuturas: INICIO");

		String bruto = "";
		List<String> out = new ArrayList<String>();

		try {
			bruto = BetbrightParserCarrerasFuturas.readFile(pathIn, Charset.forName("ISO-8859-1"));
			if (descargaBanned(bruto)) {
				MY_LOGGER.error(
						"BB-ERROR: La pagina descargada no contiene info útil. Han detectado que ejecutamos desde un robot!!!!");

			} else {
				out = parsear(bruto);
				// MY_LOGGER.debug("GALGOS-BetbrightParserCarrerasFuturas: out=" + out);
			}

		} catch (Exception e) {
			MY_LOGGER.error("Error:" + e.getMessage());
			e.printStackTrace();
		}

		MY_LOGGER.info("GALGOS-BetbrightParserCarrerasFuturas: FIN");
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

	public static boolean descargaBanned(String in) {
		return in.contains("noindex,nofollow");
	}

	/**
	 * Extrae info útil.
	 * 
	 * @param in
	 *            Contenido BRUTO de la pagina web.
	 * @return Info útil.
	 * @throws Exception
	 */
	public static List<String> parsear(String in) {
		// MY_LOGGER.debug("\n------ ENTRADA (antes de parsear)--------\n");
		// MY_LOGGER.debug(in.toString());
		// MY_LOGGER.debug("\n--------------\n");

		return extraerUrls(in);
	}

	/**
	 * @param in
	 *            Contenido BRUTO de la pagina web.
	 * @return Lista de URLs a detalle de carreras.
	 */
	public static List<String> extraerUrls(String in) {

		String BUSCADO = Constantes.GALGOS_FUTUROS_BETBRIGHT;

		String restante = in;

		List<String> urlsExtraidas = new ArrayList<String>();

		Boolean todaviaQuedan = contieneUrlBaseY3guiones(restante, BUSCADO);
		while (todaviaQuedan) {

			int indiceInicio = restante.indexOf(BUSCADO);
			restante = restante.substring(indiceInicio);

			int indiceFinal = restante.indexOf("\"");

			String urlExtraida = restante.substring(0, indiceFinal);
			if (urlExtraida != null && !urlExtraida.isEmpty() && !urlExtraida.contains(",")
					&& urlExtraida.split("-").length >= 4 && !urlExtraida.contains("<") && !urlExtraida.contains(">")) {
				urlsExtraidas.add(urlExtraida.trim());
				// MY_LOGGER.debug("#" + urlExtraida + "#");
			}

			restante = restante.substring(indiceFinal + 1);

			todaviaQuedan = contieneUrlBaseY3guiones(restante, BUSCADO);
		}

		MY_LOGGER.debug("GALGOS-BetbrightParserCarrerasFuturas - " + "URLs encontradas ==> " + urlsExtraidas.size());
		return urlsExtraidas;
	}

	/**
	 * @param in
	 * @param urlBase
	 * @return
	 */
	public static boolean contieneUrlBaseY3guiones(String in, String urlBase) {

		return in.contains(urlBase) && in.split("-").length >= 4;
	}

}
