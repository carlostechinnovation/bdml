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

		} catch (Exception e) {
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
	 * Extrae info util \
	 * 
	 * @param in
	 * @return
	 * @throws Exception
	 */
	public static List<SportiumGalgoFuturoEnCarreraAux> parsear(String in) throws Exception {

		Document doc = Jsoup.parse(in);
		Elements tablaDeGalgos = doc.getElementsByClass("racecard");

		List<SportiumGalgoFuturoEnCarreraAux> galgos = new ArrayList<SportiumGalgoFuturoEnCarreraAux>();

		Element primeraPestania = null;
		for (Element pestania : tablaDeGalgos) {
			if (pestania.toString().contains("class=\"mkt_content racecard sortable\"")
					|| pestania.toString().contains("class=\"mkt racecard\"")) {
				primeraPestania = pestania;

				MY_LOGGER.debug("\n\n\nPESTANIA COGIDA:  " + pestania.toString() + "\n\n");
			}
		}

		if (primeraPestania == null) {
			MY_LOGGER.error(
					"Sportium - parsear: NO se ha podido parsear bien el detalle de una carrera futura de Sportium.");
			throw new Exception(
					"Sportium - parsear: NO se ha podido parsear bien el detalle de una carrera futura de Sportium.");
		}

		// Futura = si no contiene la cabecera "Posición"
		boolean futura = primeraPestania.childNode(1).toString().contains("osici") == false;
		MY_LOGGER.debug("Sportium - Si NO contiene 'posicion' es FUTURA --> = " + futura);

		int numElementosPrimeraPestania = primeraPestania.childNodes().size();
		MY_LOGGER.debug("Sportium - parsear - numElementosPrimeraPestania = " + numElementosPrimeraPestania);

		if (futura && numElementosPrimeraPestania > 3) {

			MY_LOGGER.debug(
					"Sportium - parsear - primeraPestania.childNodes() = \n" + primeraPestania.childNodes().toString());

			for (Node epp : primeraPestania.childNodes()) {
				parsearTbodyFila((Element) epp, galgos);
			}

		}

		MY_LOGGER.info("Sportium - Numero de galgos extraidos de la carrera futura: " + galgos.size());
		return galgos;
	}

	/**
	 * @param fila
	 * @param out
	 */
	public static void parsearTbodyFila(Element fila, List<SportiumGalgoFuturoEnCarreraAux> out) {

		boolean esElCero = fila.toString().contains("value=\"00\"");

		if (!esElCero) {

			List<Element> galgoElements = new ArrayList<Element>();
			for (Node nodo : fila.childNodes()) {
				if (nodo instanceof Element) {
					Element tr = (Element) nodo;

					for (Node trItem : tr.childNodes())
						if (trItem instanceof Element) {
							galgoElements.add((Element) trItem);
						}

				}

			}

			MY_LOGGER.debug("Sportium - parsearTablaDeGalgos-galgoElements =  " + galgoElements.size());

			if (galgoElements != null && !galgoElements.isEmpty()) {

				// TRAP
				TextNode tn_trap_pasado = (TextNode) galgoElements.get(0).childNode(0);
				String trapPasadoStr = tn_trap_pasado.text().trim();
				Integer trap = (trapPasadoStr != null && !trapPasadoStr.isEmpty())
						? Integer.valueOf(String.valueOf(trapPasadoStr.charAt(0)))
						: null;
				MY_LOGGER.debug("Sportium - parsearTablaDeGalgos-trap =  " + trap);

				// NOMBRE
				String galgoNombreStr = "";
				for (Element e : galgoElements) {
					if (e.toString().contains("class=\"name\"")) {

						for (Node e2 : e.childNodes()) {
							if (e2.toString().contains("class=\"name\"")) {

								for (Node e3 : e2.childNodes()) {
									if (!e3.toString().trim().isEmpty()) {

										TextNode galgoNombre = null;
										if (e3 instanceof TextNode) {
											galgoNombre = (TextNode) e3;
										} else {
											galgoNombre = (TextNode) e3.childNode(0);
										}
										galgoNombreStr = galgoNombre.text().replace("|", "").trim();
										break;
									}
								}

							}
						}
					}
				}
				MY_LOGGER.debug("Sportium - parsearTablaDeGalgos-galgoNombreStr =  " + galgoNombreStr);

				// PRICE HISTORY --> Vacio
				boolean contieneDatosHistoricos = galgoElements.toString().contains("price-history");
				MY_LOGGER
						.debug("Sportium - parsearTablaDeGalgos-contieneDatosHistoricos =  " + contieneDatosHistoricos);

				// SP
				Float sp = null;
				Node e_sp = galgoElements.get(galgoElements.size() - 1);
				if (e_sp != null && e_sp.childNodes() != null) {
					for (Node nodo : e_sp.childNodes()) {
						if (nodo.toString().contains("price-history") == false
								&& nodo.toString().contains("price dec") == true && nodo instanceof Element) {

							Element elem = (Element) nodo;
							if (elem.toString().contains("price dec")) {

								for (Node e : elem.childNodes()) {

									if (e.toString().contains("price dec") && e.toString().contains(".")) {

										MY_LOGGER.debug(
												"Sportium - parsearTablaDeGalgos- price_dec --> " + e.toString());

										String spStr = "";
										if (e instanceof TextNode) {
											spStr = ((TextNode) e).text().trim();
											if (spStr != null && spStr.contains(".")) {
												sp = Float.valueOf(spStr);
											}
										} else {
											MY_LOGGER.debug("Sportium - parsearTablaDeGalgos- price_dec OTRO --> "
													+ e.getClass());

											for (Node e2 : e.childNodes()) {
												if (e2.toString().contains("price dec")
														&& e2.toString().contains(".")) {

													for (Node e3 : e2.childNodes()) {

														MY_LOGGER.debug(
																"Sportium - parsearTablaDeGalgos- price_dec OTRO --> "
																		+ e3.getClass());
														spStr = ((TextNode) e3).text().trim();

														if (spStr != null && spStr.contains(".")) {
															sp = Float.valueOf(spStr);
															break;
														}

													}

												}
											}

										}

									}
								}

							}

						}
					}
				}

				// ------------

				if (galgoNombreStr.contains(" N/R")) {
					// Galgo no presentado (no corre por el motivo que sea)
					int x = 0;

					MY_LOGGER.debug("Sportium - parsearTbodyFila- guardar -->NO");

				} else {
					galgoNombreStr = galgoNombreStr.contains("(") ? galgoNombreStr.split("\\(")[0].trim()
							: galgoNombreStr;

					out.add(new SportiumGalgoFuturoEnCarreraAux(trap, galgoNombreStr, sp));
					MY_LOGGER.debug("Sportium - parsearTbodyFila- guardar -->SI");
				}

			}

		}

	}

	// /**
	// * @param itemsSeleccionados
	// * @return
	// */
	// public static List<SportiumGalgoFuturoEnCarreraAux>
	// parsearTablaDeGalgos(List<Element> itemsSeleccionados) {
	//
	// List<SportiumGalgoFuturoEnCarreraAux> out = new
	// ArrayList<SportiumGalgoFuturoEnCarreraAux>();
	//
	// MY_LOGGER.info("Sportium - parsearTablaDeGalgos-itemsSeleccionados = " +
	// itemsSeleccionados.size());
	//
	// for (Element fila : itemsSeleccionados) {
	// }
	//
	// return out;
	// }

}
