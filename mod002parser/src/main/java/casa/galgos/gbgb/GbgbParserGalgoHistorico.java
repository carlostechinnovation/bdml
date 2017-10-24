/**
 * 
 */
package casa.galgos.gbgb;

import java.io.IOException;
import java.io.Serializable;
import java.nio.charset.Charset;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.nodes.Node;

/**
 * @author root
 *
 */
public class GbgbParserGalgoHistorico implements Serializable {

	private static final long serialVersionUID = 1L;

	public GbgbParserGalgoHistorico() {
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
	public GbgbGalgoHistorico ejecutar(String pathIn, String galgo_nombre) {

		MY_LOGGER.info("GALGOS-GbgbParserCarrerasDeUnDia: INICIO");
		MY_LOGGER.info("GALGOS-GbgbDownloader - pathIn=" + pathIn);

		String bruto = "";
		GbgbGalgoHistorico out = null;

		try {
			bruto = GbgbParserGalgoHistorico.readFile(pathIn, Charset.forName("ISO-8859-1"));
			out = parsear(bruto, galgo_nombre);
			MY_LOGGER.info("GALGOS-GbgbParserCarrerasDeUnDia: out=" + out);

		} catch (IOException e) {
			MY_LOGGER.log(Level.SEVERE, "Error:" + e.getMessage());
			e.printStackTrace();
		}

		MY_LOGGER.info("GALGOS-GbgbParserCarrerasDeUnDia: FIN");
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
	 * @param in
	 * @param galgo_nombre
	 * @return
	 */
	public static GbgbGalgoHistorico parsear(String in, String galgo_nombre) {

		Document doc = Jsoup.parse(in);
		Element tablaContenido = doc.getElementById("ctl00_ctl00_mainContent_cmscontent_DogRaceCard_lvDogRaceCard");
		List<Node> filas = tablaContenido.childNode(0).childNode(4).childNodes();

		GbgbGalgoHistorico out = new GbgbGalgoHistorico(galgo_nombre);

		for (Node fila : filas) {
			if (fila instanceof Element) {
				rellenarFilaEnHistorico(out, (Element) fila);
			}
		}

		return out;
	}

	/**
	 * @param modelo
	 * @param fila
	 */
	public static void rellenarFilaEnHistorico(GbgbGalgoHistorico modelo, Element fila) {
		int x = 0;
	}

}