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
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.nodes.Node;
import org.jsoup.nodes.TextNode;

/**
 *
 */
public class BetbrightParserDetalleCarreraFutura implements Serializable {

	private static final long serialVersionUID = 1L;

	static Logger MY_LOGGER = Logger.getLogger(BetbrightParserDetalleCarreraFutura.class);

	public BetbrightParserDetalleCarreraFutura() {
		super();
	}

	/**
	 * Dado un fichero de entrada con datos en bruto de una carrera futura (donde
	 * aparecen los GALGOS) y una instancia de CARRERA, extrae los galgos (de la web
	 * bruta) y los mete en la instancia.
	 * 
	 * @param pathCarreraDetalle
	 *            Path del FICHERO DE ENTRADA con los datos BRUTOS de detalle.
	 * @param urlCarreraDetalle
	 * @return Instancia Carrera con los galgos ya rellenos
	 * @throws Exception
	 */
	public CarreraSemillaBetbright ejecutar(String pathCarreraDetalle, String urlCarreraDetalle) throws Exception {

		MY_LOGGER.info("GALGOS-BetbrightParserDetalleCarreraFutura: INICIO");
		MY_LOGGER.info("pathIn=" + pathCarreraDetalle);
		MY_LOGGER.info("urlCarreraDetalle=" + urlCarreraDetalle);

		String bruto = "";
		CarreraSemillaBetbright out = new CarreraSemillaBetbright(urlCarreraDetalle, null, null, null, null, null,
				new ArrayList<CarreraGalgoSemillaBetbright>());

		try {

			bruto = BetbrightParserDetalleCarreraFutura.readFile(pathCarreraDetalle, Charset.forName("ISO-8859-1"));

			parsear(bruto, out);

		} catch (Exception e) {
			MY_LOGGER.error("ERROR --> " + e.getMessage());
			throw e;
		}

		MY_LOGGER.debug("GALGOS-BetbrightParserDetalleCarreraFutura: FIN");
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

		MY_LOGGER.debug("Leyendo " + path + " ...");
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
	public static void parsear(String in, CarreraSemillaBetbright modelo) throws Exception {

		Document doc = Jsoup.parse(in);

		String claseBuscada = "inner_container";

		// System.out.println("\n\n\n--------------------in-------------\n" +
		// in.toString());
		// System.out.println("\n\n\n--------------------doc-------------\n" +
		// doc.toString());

		// boolean inContiene = in.toString().contains(claseBuscada);
		// boolean docContiene = doc.toString().contains(claseBuscada);

		if (!doc.toString().contains(claseBuscada)) {
			MY_LOGGER.warn("Betbright - Carrera futura - Pagina sin contenido util (VERIFICAR a mano si es verdad): "
					+ modelo.urlDetalle);

		} else {

			Element innerContainer = doc.getElementsByClass(claseBuscada).get(0);

			if (innerContainer.toString().contains("racecard")) {

				Element contenido = innerContainer.getElementsByClass("racecard").get(0);
				Element cabeceraCarrera = contenido.getElementsByClass("racecard-header").get(0);
				Element filasGalgos = contenido.getElementsByClass("racecard-inner").get(0);

				// Parseamos el contenido y lo metemos en CarreraSemillaBetbright
				parsearCabecera(cabeceraCarrera, modelo);
				parsearFilasGalgos(filasGalgos, modelo);

				MY_LOGGER.info("Betbright - Carrera futura ==> " + modelo.dia + "|" + modelo.hora
						+ " --> Num. galgos = " + modelo.listaCG.size());
			}

		}
	}

	/**
	 * @param cabeceraCarrera
	 * @param carreraIn
	 * @throws Exception
	 */
	public static void parsearCabecera(Element cabeceraCarrera, CarreraSemillaBetbright carreraIn) throws Exception {

		String trackyHoraMinuto = cabeceraCarrera.getElementsByClass("event-name").get(0).childNode(0).toString()
				.trim();
		String[] trackyHoraMinutoArray = trackyHoraMinuto.split(" ");
		String track = trackyHoraMinutoArray[0];
		String[] horaMinutoArray = trackyHoraMinutoArray[1].split(":");
		String horaStr = horaMinutoArray[0];
		String minutoStr = horaMinutoArray[1];

		Element eventTiempos = cabeceraCarrera.getElementsByClass("event-countdown").get(0);
		String anioMesDiaHoraMinSeg = eventTiempos.attr("data-start-date-time");
		String[] anioMesDiaArray = anioMesDiaHoraMinSeg.split(" ")[0].split("-");

		Element eventDescription = cabeceraCarrera.getElementsByClass("event-description").get(0);
		String tipoPistaStr = eventDescription.childNode(0).childNode(0).toString().trim();
		String distanciaStr = eventDescription.childNode(1).childNode(0).toString().split(":")[1].trim();

		// Rellenamos la instancia
		carreraIn.estadio = track;
		carreraIn.dia = Long.valueOf(anioMesDiaArray[0] + anioMesDiaArray[1] + anioMesDiaArray[2]);
		carreraIn.hora = Integer.valueOf(horaStr + minutoStr);
		carreraIn.tipoPista = tipoPistaStr;
		carreraIn.distancia = Integer.valueOf(distanciaStr);
	}

	/**
	 * @param cabeceraCarrera
	 * @param carreraIn
	 * @throws Exception
	 */
	public static void parsearFilasGalgos(Element filasGalgos, CarreraSemillaBetbright carreraIn) throws Exception {

		Element a = filasGalgos.getElementsByClass("bb_tabs_content").get(0);
		List<Node> a_lista = a.childNode(3).childNodes();

		List<Element> galgoElements = new ArrayList<Element>();

		for (Node ai : a_lista) {
			if (ai instanceof Element) {
				galgoElements.add((Element) ai);
			}
		}

		for (Element galgoElement : galgoElements) {
			parsearFilaGalgo(galgoElement, carreraIn);
		}

	}

	/**
	 * @param cabeceraCarrera
	 * @param carreraIn
	 * @throws Exception
	 */
	public static void parsearFilaGalgo(Element galgoElement, CarreraSemillaBetbright carreraIn) throws Exception {

		Element a = galgoElement.getElementsByClass("horse-datafields").get(0);

		TextNode b = (TextNode) a.getElementsByClass("horse-information-name").get(0).childNode(0);
		String galgoNombre = b.text().trim();

		String id = carreraIn.dia + carreraIn.hora + carreraIn.estadio + galgoNombre;// dia#hora#estadio#galgo_nombre

		Element t = a.getElementsByClass("jockey-silk-container").get(0);
		boolean tieneTrap = t.toString().contains("/trap-");
		String tArr1 = t.toString().split("/trap-")[1];
		String tArr2 = tArr1.split("\\.")[0];
		Integer trap = tieneTrap ? Integer.valueOf(tArr2) : null;

		Element e = a.getElementsByClass("field-trainer").get(0);
		boolean tieneEntrenador = e.toString().contains("field-value");
		String entrenador = tieneEntrenador
				? ((TextNode) e.getElementsByClass("field-value").get(0).childNode(0)).text()
				: null;

		boolean eliminado = galgoElement.toString().contains("withdrawn");

		boolean tienePrecio = galgoElement.toString().contains("field-last-odds");
		Element precioElem = tienePrecio ? galgoElement.getElementsByClass("field-last-odds").get(0) : null;
		String precioSpStr = (precioElem != null) ? precioElem.childNode(0).toString().trim() : null;

		Float precioSp = null;
		if (precioSpStr != null && !precioSpStr.contains("><")) {

			String numDemStr = precioSpStr.split(">")[1].split("<")[0];
			String[] numDemArray = numDemStr.split("/");
			Float numerador = Float.valueOf(numDemArray[0].trim());
			Float denominador = Float.valueOf(numDemArray[1].trim());

			precioSp = Float.valueOf(numerador / denominador);
		}

		// Los galgos que no corren (por el motivo que sea) aparecen sin entrenador, en
		// la web. Asi que no les cogemos...
		// Tampoco cogemos la fila en la que pone "eliminado"
		if (eliminado == false && entrenador != null && !entrenador.isEmpty()) {
			CarreraGalgoSemillaBetbright cg = new CarreraGalgoSemillaBetbright(id, galgoNombre, trap, entrenador,
					precioSp, carreraIn);
			carreraIn.listaCG.add(cg);
		}
	}
}
