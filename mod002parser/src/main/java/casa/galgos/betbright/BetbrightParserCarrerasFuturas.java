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
		List<String> out = null;

		try {
			bruto = BetbrightParserCarrerasFuturas.readFile(pathIn, Charset.forName("ISO-8859-1"));
			out = parsear(bruto);
			// MY_LOGGER.info("GALGOS-BetbrightParserCarrerasFuturas: out=" + out);

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

	/**
	 * Extrae info util \
	 * 
	 * @param in
	 * @return
	 * @throws Exception
	 */
	public static List<String> parsear(String in) {

		return extraerUrls(in);

	}

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
			if (!urlExtraida.contains(",") && urlExtraida.split("-").length >= 4) {
				urlsExtraidas.add(urlExtraida);
			}

			restante = restante.substring(indiceFinal + 1);

			todaviaQuedan = contieneUrlBaseY3guiones(restante, BUSCADO);
		}

		MY_LOGGER.debug("GALGOS-BetbrightParserCarrerasFuturas - " + "URLs encontradas ==> " + urlsExtraidas.size());

		for (String cad : urlsExtraidas) {
			MY_LOGGER.debug(cad);
		}

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
