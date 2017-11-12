/**
 * 
 */
package casa.galgos.gbgb;

import java.io.IOException;
import java.io.Serializable;
import java.nio.charset.Charset;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

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

		MY_LOGGER.debug("GALGOS-GbgbParserCarreraDetalle: INICIO");
		MY_LOGGER.debug("GALGOS-GbgbParserCarreraDetalle - pathIn=" + pathIn);

		String bruto = "";
		GbgbCarrera out = null;

		try {
			bruto = GbgbParserCarreraDetalle.readFile(pathIn, Charset.forName("ISO-8859-1"));
			out = parsear(id_carrera, id_campeonato, bruto);
			MY_LOGGER.debug("GALGOS-GbgbParserCarreraDetalle: out=" + out);

		} catch (IOException e) {
			MY_LOGGER.error("Error:" + e.getMessage());
			e.printStackTrace();
		}

		MY_LOGGER.debug("GALGOS-GbgbParserCarreraDetalle: FIN");
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
	 * Clase Auxiliar
	 *
	 */
	public class Tripleta {
		public Element linea1;
		public Element linea2;
		public Element linea3;

		public Tripleta() {
			super();
		}

	}

	/**
	 * Extrae info util
	 * 
	 * @param id_carrera
	 * @param id_campeonato
	 * @param in
	 * @return
	 */
	public GbgbCarrera parsear(Long id_carrera, Long id_campeonato, String in) {

		Document doc = Jsoup.parse(in);

		Element a = doc.getElementById("CMSContent");

		GbgbCarreraDetalle detalle = new GbgbCarreraDetalle();
		// --------------------------

		List<Node> infoArriba = a.getElementsByClass("resultsBlockHeader").get(0).childNodes();
		rellenarPremios(((TextNode) infoArriba.get(11).childNode(0)).text(), detalle);

		String track = Constantes.limpiarTexto(((TextNode) infoArriba.get(1).childNode(0)).text()).split("&")[0].trim();
		String clase = Constantes.limpiarTexto(((TextNode) infoArriba.get(7).childNode(0)).text()).trim();

		String f = Constantes.limpiarTexto(((TextNode) infoArriba.get(3).childNode(0)).text());
		String h = Constantes.limpiarTexto(((TextNode) infoArriba.get(5).childNode(0)).text()).trim();
		Calendar fechayhoraDeLaCarrera = Constantes.parsearFechaHora(f, h, true);

		Integer distancia = Integer.valueOf(
				Constantes.limpiarTexto(((TextNode) infoArriba.get(9).childNode(0)).text()).split("m")[0].trim());

		// --------------------------
		List<Node> infoPosiciones = a.getElementsByClass("resultsBlock").get(0).childNodes();

		List<Element> infoPosicionesSoloConContents = new ArrayList<Element>();
		for (Node item : infoPosiciones) {
			if (item instanceof Element && ((Element) item).hasClass("contents")) {
				infoPosicionesSoloConContents.add((Element) item);
			}
		}

		List<Tripleta> tripletas = new ArrayList<Tripleta>();
		int j = -1;
		for (Element item : infoPosicionesSoloConContents) {

			if (item.toString().contains("line1")) {
				j++;
				tripletas.add(new GbgbParserCarreraDetalle.Tripleta()); // NUEVA
				tripletas.get(j).linea1 = item;
			} else if (item.toString().contains("line2")) {
				tripletas.get(j).linea2 = item;
			} else if (item.toString().contains("line3")) {
				tripletas.get(j).linea3 = item;
			}

		}

		for (Tripleta t : tripletas) {
			rellenarPosicion(t.linea1, t.linea2, t.linea3, detalle, fechayhoraDeLaCarrera);
		}

		// --------------------------

		MY_LOGGER.debug("Sacando info abajo...");
		List<Node> infoAbajo = a.getElementsByClass("resultsBlockFooter").get(0).childNodes();

		if (infoAbajo.toString().contains("Allowance")) {
			String goingAllowanceStr = ((TextNode) ((Element) infoAbajo.get(1)).childNode(1)).text().trim();
			detalle.going_allowance_segundos = parsearGoingAllowance(goingAllowanceStr);
		}

		String fc = infoAbajo.toString().contains("Forecast") ? ((TextNode) infoAbajo.get(3).childNode(1)).text()
				: null;// (2-1) £11.75 |
		String tc = infoAbajo.toString().contains("Tricast") ? ((TextNode) infoAbajo.get(3).childNode(3)).text() : null;// (2-1-3)
																														// £23.19
		detalle.rellenarForecastyTricast(fc, tc);

		GbgbCarrera carrera = new GbgbCarrera(id_carrera, id_campeonato, track, clase, fechayhoraDeLaCarrera, distancia,
				detalle);

		return carrera;
	}

	/**
	 * @param goingAllowanceStr
	 *            N, -20, +20, +60
	 * @return
	 */
	public static Float parsearGoingAllowance(String goingAllowanceStr) {

		Float out = 0.0F;

		if (goingAllowanceStr != null) {
			if (goingAllowanceStr.equalsIgnoreCase("N")) {
				out = 0.0F;
			} else {
				boolean negativo = goingAllowanceStr.contains("-");
				out = Float.valueOf(goingAllowanceStr.replace("-", "").replace("+", "").trim());
				out = negativo ? (-1 * out) : out;

				// centesimas de segundos --> Segundos
				out = out / 100.0F;
			}
		}

		return out;
	}

	/**
	 * @param premiosStr
	 *            Cadena con este formato: "1st Â£175, 2nd Â£60, Others Â£50
	 *            Race Total Â£435 "
	 * @param out
	 */
	public static void rellenarPremios(String premiosStr, GbgbCarreraDetalle out) {

		MY_LOGGER.debug("rellenarPremios --> premiosStr=" + premiosStr);

		String[] partes = premiosStr.replace("Â", "").split("£");

		out.premio_primero = premiosStr.contains("1st") ? Integer.valueOf(partes[1].split(",")[0].trim()) : null;
		out.premio_segundo = premiosStr.contains("2nd") ? Integer.valueOf(partes[2].split(",")[0].trim()) : null;
		out.premio_otros = premiosStr.contains("2nd")
				? Integer.valueOf(partes[3].split("Race")[0].replace(",", "").trim())
				: Integer.valueOf(partes[2].split("Race")[0].replace(",", "").trim());
		out.premio_total_carrera = premiosStr.contains("2nd") ? Integer.valueOf(partes[4].split(" ")[0].trim())
				: Integer.valueOf(partes[3].split(" ")[0].trim());
	}

	/**
	 * @param e1
	 *            Fin Greyhound Trap SP Time/Sec. Time/Distance
	 * @param e2
	 *            Sobre el galgo
	 * @param e3
	 *            Comentarios
	 * @param fechayhoraDeLaCarrera
	 */
	public static void rellenarPosicion(Element e1, Element e2, Element e3, GbgbCarreraDetalle out,
			Calendar fechayhoraDeLaCarrera) {

		Short posicion = Short.valueOf(((TextNode) e1.childNode(1).childNode(0)).text().trim());
		String galgo_nombre = ((TextNode) e1.childNode(3).childNode(1).childNode(0)).text().trim();
		String url_galgo_historico = Constantes.GALGOS_GBGB + e1.childNode(3).childNode(1).attr("href").trim();
		String trap = ((TextNode) e1.childNode(5).childNode(0)).text().trim();
		String sp = Constantes.limpiarTexto(((TextNode) e1.childNode(7).childNode(0)).text());
		String time_sec = Constantes.limpiarTexto(((TextNode) e1.childNode(9).childNode(0)).text());

		String time_distance = Constantes.limpiarTexto(((TextNode) e1.childNode(11).childNode(0)).text());
		time_distance = time_distance.contains("(")
				? time_distance.replace("(", "XXXDIVISORXXX").split("XXXDIVISORXXX")[0].trim()
				: time_distance;

		String season_padre_madre_nacimiento_peso = Constantes
				.limpiarTexto(((TextNode) e2.childNode(1).childNode(0)).text());
		String entrenador_nombre = Constantes.limpiarTexto(((TextNode) e2.childNode(3).childNode(2)).text())
				.replace(")", "").trim();

		String comment = Constantes.limpiarTexto(((TextNode) e3.childNode(1).childNode(1)).text());

		// ----------------------------------

		String[] partes = season_padre_madre_nacimiento_peso.replace(")", "XXXDIVISORXXX").split("XXXDIVISORXXX");
		String season = "";
		String padre_madre_nacimiento_peso = "";
		if (partes.length <= 2) {
			padre_madre_nacimiento_peso = (partes[0].contains("eason")) ? partes[1] : partes[0];
		} else if (partes.length == 3) {

			MY_LOGGER.debug("partes[0]=" + partes[0]);
			MY_LOGGER.debug("partes[1]=" + partes[1]);

			season = partes[0].split("eason")[1].trim();
			padre_madre_nacimiento_peso = partes[1].trim();
		}

		String galgo_padre = extraerPadre(padre_madre_nacimiento_peso);
		String galgo_madre = extraerMadre(padre_madre_nacimiento_peso);
		Integer nacimiento = extraerFechaNacimiento(padre_madre_nacimiento_peso);

		MY_LOGGER.debug("padre_madre_nacimiento_peso-->" + padre_madre_nacimiento_peso);

		String peso_galgo = padre_madre_nacimiento_peso.contains("eight")
				? padre_madre_nacimiento_peso.split("Weight")[1].replace(")", "").replace(":", "").trim()
				: null;

		// ----------------

		out.rellenarPuesto(posicion, galgo_nombre, trap != null ? Integer.valueOf(trap) : null, sp, time_sec,
				time_distance, peso_galgo != null ? Float.valueOf(peso_galgo) : null, entrenador_nombre, galgo_padre,
				galgo_madre, nacimiento, comment, url_galgo_historico, fechayhoraDeLaCarrera);

	}

	/**
	 * @param in
	 * @return
	 */
	public static String extraerPadre(String in) {
		String out = "";
		if (in != null && in.contains(" - ")) {
			String[] miArray = in.split(" - ")[0].trim().split(" ");
			if (miArray.length >= 2) {

				// No cojo nunca los 2 primeros elementos
				boolean primero = true;
				for (int i = 0; i < miArray.length; i++) {
					if (i >= 2) {
						if (!primero) {
							out += " ";
						}
						out += miArray[i];
						primero = false;
					}
				}
			}

		}

		return out.trim();
	}

	/**
	 * @param in
	 * @return
	 */
	public static String extraerMadre(String in) {

		String out = "";
		if (in != null && in.contains(" - ")) {
			String[] miArray = in.split(" - ")[1].trim().split(" ");

			boolean primero = true;
			for (String parte : miArray) {
				if (!primero) {
					out += " ";
				}

				if (parte.contains("-")// fecha de nacimiento
						|| parte.contains("(")// peso
				) {
					break;
				} else {
					out += parte;
				}
				primero = false;
			}

		}

		return out.trim();
	}

	/**
	 * @param in
	 * @return YYYYMMDD
	 */
	public static Integer extraerFechaNacimiento(String in) {

		Integer out = null;
		if (in != null) {
			String[] partes = in.split(" ");
			if (partes != null && partes.length > 0) {
				for (String parte : partes) {
					if (parte.contains("-") && parte.length() >= 3) {
						out = convertirFechaStrAFechaInt(parte);
					}
				}
			}

		}

		return out;
	}

	/**
	 * @param in
	 *            May-2015
	 * @return 20150501
	 */
	public static Integer convertirFechaStrAFechaInt(String in) {

		Map<String, String> GALGOS_MESES_NACIMIENTO = new HashMap<String, String>();
		GALGOS_MESES_NACIMIENTO.put("Jan", "01");
		GALGOS_MESES_NACIMIENTO.put("Feb", "02");
		GALGOS_MESES_NACIMIENTO.put("Mar", "03");
		GALGOS_MESES_NACIMIENTO.put("Apr", "04");
		GALGOS_MESES_NACIMIENTO.put("May", "05");
		GALGOS_MESES_NACIMIENTO.put("Jun", "06");
		GALGOS_MESES_NACIMIENTO.put("Jul", "07");
		GALGOS_MESES_NACIMIENTO.put("Aug", "08");
		GALGOS_MESES_NACIMIENTO.put("Sep", "09");
		GALGOS_MESES_NACIMIENTO.put("Oct", "10");
		GALGOS_MESES_NACIMIENTO.put("Nov", "11");
		GALGOS_MESES_NACIMIENTO.put("Dec", "12");

		String[] partes = in.split("-");
		String mes = GALGOS_MESES_NACIMIENTO.get(partes[0]);
		String anio = partes[1];
		return Integer.valueOf(anio + mes + "01");
	}

}
