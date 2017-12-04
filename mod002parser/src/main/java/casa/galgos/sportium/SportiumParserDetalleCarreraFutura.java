/**
 * 
 */
package casa.galgos.sportium;

import java.io.IOException;
import java.io.Serializable;
import java.nio.charset.Charset;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;

import org.apache.log4j.Logger;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.nodes.Node;
import org.jsoup.nodes.TextNode;
import org.jsoup.select.Elements;

/**
 *
 */
public class SportiumParserDetalleCarreraFutura implements Serializable {

	private static final long serialVersionUID = 1L;

	static Logger MY_LOGGER = Logger.getLogger(SportiumParserDetalleCarreraFutura.class);

	public SportiumParserDetalleCarreraFutura() {
		super();
	}

	/**
	 * Dado un fichero de entrada con datos en bruto de una carrera futura (donde
	 * aparecen los GALGOS) y una instancia de CARRERA, extrae los galgos (de la web
	 * bruta) y los mete en la instancia.
	 * 
	 * @param pathIn
	 * @param carreraIn
	 * @return Instancia Carrera con los galgos ya rellenos
	 */
	public SportiumCarrera ejecutar(String pathIn, SportiumCarrera carreraIn) {

		MY_LOGGER.debug("GALGOS-SportiumParserDetalleCarreraFutura: INICIO");

		String bruto = "";

		try {
			bruto = SportiumParserDetalleCarreraFutura.readFile(pathIn, Charset.forName("ISO-8859-1"));
			carreraIn.galgosNombres = parsear(bruto);

		} catch (IOException e) {
			MY_LOGGER.error("Error:" + e.getMessage());
			e.printStackTrace();
		}

		MY_LOGGER.debug("GALGOS-SportiumParserDetalleCarreraFutura: FIN");
		return carreraIn;
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
	public static List<String> parsear(String in) {

		Document doc = Jsoup.parse(in);
		Elements tablaDeGalgos = doc.getElementsByClass("mkt racecard");

		List<String> galgoNombres = new ArrayList<String>();

		if (tablaDeGalgos.size() > 0 && tablaDeGalgos.get(0).childNodes().size() > 3) {

			List<Node> items = tablaDeGalgos.get(0).childNodes();
			List<Element> itemsSeleccionados = new ArrayList<Element>();
			for (Node item : items) {
				if (item instanceof Element) {
					itemsSeleccionados.add((Element) item);
				}
			}

			galgoNombres = parsearTablaDeGalgos(itemsSeleccionados);

		}

		MY_LOGGER.info("Sportium - Numero de galgos extraidos de la carrera futura: " + galgoNombres.size());
		return galgoNombres;
	}

	/**
	 * @param tablaDeGalgos
	 * @return
	 */
	public static List<String> parsearTablaDeGalgos(List<Element> itemsSeleccionados) {

		List<String> out = new ArrayList<String>();

		for (Element fila : itemsSeleccionados) {

			boolean esElCero = fila.childNode(0).toString().contains("\"number\"></td>");

			if (!esElCero) {

				TextNode galgoNombre = (TextNode) fila.childNode(0).childNode(1).childNode(0).childNode(0).childNode(0);

				String galgoNombreStr = galgoNombre.text().trim();
				galgoNombreStr = galgoNombreStr.contains(" N/R") ? galgoNombreStr.replace(" N/R", "").trim()
						: galgoNombreStr;
				galgoNombreStr = galgoNombreStr.contains("(") ? galgoNombreStr.split("\\(")[0].trim() : galgoNombreStr;

				out.add(galgoNombreStr);
			}
		}

		return out;
	}

}
