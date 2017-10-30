/**
 * 
 */
package casa.galgos.gbgb;

import java.io.IOException;
import java.io.Serializable;
import java.nio.charset.Charset;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.Calendar;
import java.util.List;

import org.apache.log4j.Logger;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.nodes.Node;
import org.jsoup.nodes.TextNode;

import utilidades.Constantes;

/**
 * @author root
 *
 */
public class GbgbParserCarreraDetalle implements Serializable {

	private static final long serialVersionUID = 1L;

	static Logger MY_LOGGER = Logger.getLogger(GbgbParserCarreraDetalle.class);

	public GbgbParserCarreraDetalle() {
		super();
	}

	/**
	 * @param pathIn
	 *            Path absoluto al fichero HTML de la pagina del BOE almacenado en
	 *            sistema de ficheros local.
	 * @param pathOut
	 * @param borrarSiExiste
	 */
	public GbgbCarrera ejecutar(Long id_carrera, Long id_campeonato, String pathIn) {

		MY_LOGGER.info("GALGOS-GbgbParserCarreraDetalle: INICIO");
		MY_LOGGER.info("GALGOS-GbgbParserCarreraDetalle - pathIn=" + pathIn);

		String bruto = "";
		GbgbCarrera out = null;

		try {
			bruto = GbgbParserCarreraDetalle.readFile(pathIn, Charset.forName("ISO-8859-1"));
			out = parsear(id_carrera, id_campeonato, bruto);
			MY_LOGGER.info("GALGOS-GbgbParserCarreraDetalle: out=" + out);

		} catch (IOException e) {
			MY_LOGGER.error("Error:" + e.getMessage());
			e.printStackTrace();
		}

		MY_LOGGER.info("GALGOS-GbgbParserCarreraDetalle: FIN");
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
	 * @param id_carrera
	 * @param id_campeonato
	 * @param in
	 * @return
	 */
	public static GbgbCarrera parsear(Long id_carrera, Long id_campeonato, String in) {

		Document doc = Jsoup.parse(in);

		Element a = doc.getElementById("CMSContent");

		GbgbCarreraDetalle detalle = new GbgbCarreraDetalle();
		// --------------------------
		List<Node> infoArriba = a.childNode(0).childNode(2).childNodes();
		rellenarPremios(((TextNode) infoArriba.get(11).childNode(0)).text(), detalle);

		// --------------------------
		List<Node> infoPosiciones = a.childNode(0).childNode(4).childNodes();
		for (int i = 3; i <= 33; i += 6) {
			rellenarPosicion((Element) infoPosiciones.get(i), (Element) infoPosiciones.get(i + 2),
					(Element) infoPosiciones.get(i + 4), detalle);
		}
		// --------------------------
		MY_LOGGER.info("Sacando info abajo...");
		List<Node> infoAbajo = a.childNode(0).childNode(6).childNodes();

		if (infoAbajo.toString().contains("Allowance")) {
			String goingAllowanceStr = ((TextNode) ((Element) infoAbajo.get(1)).childNode(1)).text().trim();
			detalle.going_allowance = (goingAllowanceStr != null && "S".equalsIgnoreCase(goingAllowanceStr));
		}

		String fc = ((TextNode) infoAbajo.get(3).childNode(1)).text();// (2-1) £11.75 |
		String tc = ((TextNode) infoAbajo.get(3).childNode(3)).text();// (2-1-3) £23.19
		detalle.rellenarForecastyTricast(fc, tc);

		String track = ((TextNode) infoArriba.get(1).childNode(0)).text().split("&")[0].replace("|", "").trim();
		String clase = ((TextNode) infoArriba.get(7).childNode(0)).text().replace("|", "").trim();

		String f = ((TextNode) infoArriba.get(3).childNode(0)).text().replace("|", "").trim();
		String h = ((TextNode) infoArriba.get(5).childNode(0)).text().replace("|", "").trim();
		Calendar fechayhora = Constantes.parsearFechaHora(f, h, true);

		Integer distancia = Integer.valueOf(((TextNode) infoArriba.get(9).childNode(0)).text().split("m")[0]);

		GbgbCarrera carrera = new GbgbCarrera(id_carrera, id_campeonato, track, clase, fechayhora, distancia, detalle);

		return carrera;
	}

	/**
	 * @param premiosStr
	 *            Cadena con este formato: "1st £43, Others £30 Race Total £193 "
	 * @param out
	 */
	public static void rellenarPremios(String premiosStr, GbgbCarreraDetalle out) {

		MY_LOGGER.debug("rellenarPremios --> premiosStr=" + premiosStr);

		String[] partes = premiosStr.split("£");

		out.premio_primer_puesto = Integer.valueOf(partes[1].split("Others")[0].replace(",", "").trim());
		out.premio_otros = Integer.valueOf(partes[2].split("Race")[0].replace(",", "").trim());
		out.premio_total_carrera = Integer.valueOf(partes[3].split(" ")[0].trim());
	}

	/**
	 * @param e1
	 *            Fin Greyhound Trap SP Time/Sec. Time/Distance
	 * @param e2
	 *            Sobre el galgo
	 * @param e3
	 *            Comentarios
	 */
	public static void rellenarPosicion(Element e1, Element e2, Element e3, GbgbCarreraDetalle out) {

		Short posicion = Short.valueOf(((TextNode) e1.childNode(1).childNode(0)).text().trim());
		String galgo_nombre = ((TextNode) e1.childNode(3).childNode(1).childNode(0)).text().trim();
		String url_galgo_historico = Constantes.GALGOS_GBGB + e1.childNode(3).childNode(1).attr("href").trim();
		String trap = ((TextNode) e1.childNode(5).childNode(0)).text().trim();
		String sp = ((TextNode) e1.childNode(7).childNode(0)).text().trim();
		String time_sec = ((TextNode) e1.childNode(9).childNode(0)).text().trim();
		String time_distance = ((TextNode) e1.childNode(11).childNode(0)).text().trim();

		String padre_madre_nacimiento_peso = ((TextNode) e2.childNode(1).childNode(0)).text().trim();
		String entrenador_nombre = ((TextNode) e2.childNode(3).childNode(2)).text().replace(")", "").trim();

		String comment = ((TextNode) e3.childNode(1).childNode(1)).text().trim();

		// ----------------------------------

		String[] partes = padre_madre_nacimiento_peso.replace(")", "XXXDIVISORXXX").split("XXXDIVISORXXX");
		String season = "";
		String abcd = "";
		if (partes.length <= 2) {
			abcd = (partes[0].contains("eason")) ? partes[1] : partes[0];
		} else if (partes.length == 3) {

			MY_LOGGER.info("partes[0]=" + partes[0]);
			MY_LOGGER.info("partes[1]=" + partes[1]);

			season = partes[0].split("eason")[1].trim();
			abcd = partes[1].trim();
		}

		String galgo_padre = "";
		String galgo_madre = "";
		String nacimiento = "";

		MY_LOGGER.debug("padre_madre_nacimiento_peso-->" + padre_madre_nacimiento_peso);

		String peso_galgo = abcd.contains("eight") ? abcd.split("Weight")[1].replace(")", "").replace(":", "").trim()
				: null;

		// ----------------
		out.rellenarPuesto(posicion, galgo_nombre, trap != null ? Integer.valueOf(trap) : null, sp, time_sec,
				time_distance, peso_galgo != null ? Float.valueOf(peso_galgo) : null, entrenador_nombre, galgo_padre,
				galgo_madre, nacimiento, comment, url_galgo_historico);

	}

}