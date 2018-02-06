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

			List<SportiumGalgoFuturoEnCarreraAux> galgosExtraidos = parsear(bruto);

			if (galgosExtraidos != null) {
				for (SportiumGalgoFuturoEnCarreraAux item : galgosExtraidos) {
					carreraIn.galgosNombres.add(item.galgoNombre);
				}
			}

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
	public static List<SportiumGalgoFuturoEnCarreraAux> parsear(String in) {

		Document doc = Jsoup.parse(in);
		Elements tablaDeGalgos = doc.getElementsByClass("racecard");

		List<SportiumGalgoFuturoEnCarreraAux> galgos = new ArrayList<SportiumGalgoFuturoEnCarreraAux>();

		if (tablaDeGalgos.size() > 0 && tablaDeGalgos.get(0).childNodes().size() > 3) {

			List<Node> items = tablaDeGalgos.get(0).childNode(3).childNodes();
			List<Element> itemsSeleccionados = new ArrayList<Element>();
			for (Node item : items) {
				if (item instanceof Element) {
					itemsSeleccionados.add((Element) item);
				}
			}

			galgos = parsearTablaDeGalgos(itemsSeleccionados);

		}

		MY_LOGGER.info("Sportium - Numero de galgos extraidos de la carrera futura: " + galgos.size());
		return galgos;
	}

	/**
	 * @param tablaDeGalgos
	 * @return
	 */
	public static List<SportiumGalgoFuturoEnCarreraAux> parsearTablaDeGalgos(List<Element> itemsSeleccionados) {

		List<SportiumGalgoFuturoEnCarreraAux> out = new ArrayList<SportiumGalgoFuturoEnCarreraAux>();

		for (Element fila : itemsSeleccionados) {

			boolean esElCero = fila.childNode(0).toString().contains("value=\"00\"");

			if (!esElCero) {

				List<Element> galgoElements = new ArrayList<Element>();
				for (Node nodo : fila.childNodes()) {
					if (nodo instanceof Element) {
						galgoElements.add((Element) nodo);
					}

				}

				if (galgoElements != null && !galgoElements.isEmpty()) {

					// TRAP
					TextNode tn_trap = (TextNode) galgoElements.get(0).childNode(0);
					String trapStr = tn_trap.text().trim();
					Integer trap = (trapStr != null && !trapStr.isEmpty()) ? Integer.valueOf(trapStr) : null;

					if (trap != null && trap > 0) {

						// NOMBRE
						TextNode galgoNombre = (TextNode) galgoElements.get(1).childNode(1).childNode(1).childNode(0);

						// PRICE HISTORY --> Vacio

						// SP
						Float sp = null;
						Element e_sp = (Element) galgoElements.get(3).childNode(1).childNode(1);
						if (e_sp != null && e_sp.childNodes() != null) {
							for (Node nodo : e_sp.childNodes()) {
								if (nodo instanceof Element) {
									Element elem = (Element) nodo;
									if (elem.toString().contains("price dec")) {
										String spStr = ((TextNode) elem.childNode(0)).text();

										if (spStr != null && spStr.contains(".")) {
											sp = Float.valueOf(spStr);
										}

									}
								}
							}
						}

						// ------------

						String galgoNombreStr = galgoNombre.text().trim();

						if (galgoNombreStr.contains(" N/R")) {
							// Galgo no presentado (no corre por el motivo que sea)

						} else {
							galgoNombreStr = galgoNombreStr.contains("(") ? galgoNombreStr.split("\\(")[0].trim()
									: galgoNombreStr;

							out.add(new SportiumGalgoFuturoEnCarreraAux(trap, galgoNombreStr, sp));
						}

					}

				}

			}
		}

		return out;
	}

}
