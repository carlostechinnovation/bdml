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

		MY_LOGGER.debug("Parseando id_carrera|id_campeonato=" + id_carrera + "|" + id_campeonato);
		MY_LOGGER.debug("pathIn=" + pathIn);

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

		GbgbCarrera carreraAux = new GbgbCarrera(true);
		carreraAux.id_carrera = id_carrera;
		carreraAux.id_campeonato = id_campeonato;

		// --------------------------
		String contenidoTotal = a.toString();
		if (!contenidoTotal.contains("resultsBlockHeader")) {
			return null;
		}

		List<Node> infoArriba = a.getElementsByClass("resultsBlockHeader").get(0).childNodes();

		if (infoArriba.get(11).childNodes().size() > 0) {

			rellenarPremios(((TextNode) infoArriba.get(11).childNode(0)).text(), carreraAux, id_carrera);
		}
		carreraAux.track = Constantes.limpiarTexto(((TextNode) infoArriba.get(1).childNode(0)).text()).split("&")[0]
				.trim();
		carreraAux.clase = Constantes.limpiarTexto(((TextNode) infoArriba.get(7).childNode(0)).text()).trim();

		String f = Constantes.limpiarTexto(((TextNode) infoArriba.get(3).childNode(0)).text());
		String h = Constantes.limpiarTexto(((TextNode) infoArriba.get(5).childNode(0)).text()).trim();
		Calendar fh = Constantes.parsearFechaHora(f, h, true);
		carreraAux.fechayhora = fh;

		carreraAux.distancia = Integer.valueOf(
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
			GbgbPosicionEnCarrera posicion = new GbgbPosicionEnCarrera(true);
			posicion.id_carrera = id_carrera;
			posicion.id_campeonato = id_campeonato;
			rellenarPosicion(t.linea1, t.linea2, t.linea3, posicion, fh);
			carreraAux.posiciones.add(posicion);
		}

		// --------------------------

		MY_LOGGER.debug("Sacando info abajo...");
		List<Node> infoAbajo = a.getElementsByClass("resultsBlockFooter").get(0).childNodes();

		if (infoAbajo.toString().contains("Allowance")) {
			String goingAllowanceStr = ((TextNode) ((Element) infoAbajo.get(1)).childNode(1)).text().trim();
			carreraAux.going_allowance_segundos = parsearGoingAllowance(goingAllowanceStr);
		}

		String fc = infoAbajo.toString().contains("Forecast") ? ((TextNode) infoAbajo.get(3).childNode(1)).text()
				: null;// (2-1) £11.75 |
		String tc = infoAbajo.toString().contains("Tricast") ? ((TextNode) infoAbajo.get(3).childNode(3)).text() : null;// (2-1-3)
		// £23.19
		carreraAux.rellenarForecastyTricast(fc, tc);

		short numGalgos = 0;
		for (GbgbPosicionEnCarrera posicion : carreraAux.posiciones) {
			if (posicion != null && posicion.galgo_nombre != null && !posicion.galgo_nombre.isEmpty()) {
				numGalgos++;
			}
		}
		carreraAux.numGalgos = Short.valueOf(numGalgos);

		GbgbCarrera carrera = new GbgbCarrera(carreraAux.id_carrera, carreraAux.id_campeonato, carreraAux.track,
				carreraAux.clase, carreraAux.fechayhora, carreraAux.distancia, carreraAux.numGalgos,
				carreraAux.premio_primero, carreraAux.premio_segundo, carreraAux.premio_otros,
				carreraAux.premio_total_carrera, carreraAux.going_allowance_segundos, carreraAux.fc_1, carreraAux.fc_2,
				carreraAux.fc_pounds, carreraAux.tc_1, carreraAux.tc_2, carreraAux.tc_3, carreraAux.tc_pounds,
				carreraAux.posiciones);

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
	 *            Cadena con este formato: "1st Â£175, 2nd Â£60, Others Â£50 Race
	 *            Total Â£435 "
	 * @param out
	 */
	public static void rellenarPremios(String premiosStr, GbgbCarrera carrera, Long id_carrera) {

		MY_LOGGER.debug("rellenarPremios --> premiosStr=" + premiosStr);

		try {
			String[] partes = premiosStr.replace("Â", "").split("£");

			carrera.premio_primero = premiosStr.contains("1st") ? Integer.valueOf(partes[1].split(",")[0].trim())
					: null;
			carrera.premio_segundo = premiosStr.contains("2nd") ? Integer.valueOf(partes[2].split(",")[0].trim())
					: null;
			if (!premiosStr.contains("3rd") && !premiosStr.contains("rainers")) {
				carrera.premio_otros = premiosStr.contains("2nd")
						? Integer.valueOf(partes[3].split("Race")[0].replace(",", "").trim())
						: Integer.valueOf(partes[2].split("Race")[0].replace(",", "").trim());
				carrera.premio_total_carrera = premiosStr.contains("2nd")
						? Integer.valueOf(partes[4].split(" ")[0].trim())
						: Integer.valueOf(partes[3].split(" ")[0].trim());
			}

		} catch (Exception e) {
			MY_LOGGER.error("Problema al parsear premios de carrera=" + id_carrera + " Da igual, seguimos...");
		}
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
	public static void rellenarPosicion(Element e1, Element e2, Element e3, GbgbPosicionEnCarrera out,
			Calendar fechayhoraDeLaCarrera) {

		boolean seguir = false;
		try {
			String posStr = ((TextNode) e1.childNode(1).childNode(0)).text().trim();
			Short.valueOf(posStr);
			seguir = true;
		} catch (Exception e) {
			// TODO: handle exception
		}

		if (seguir) { // posicion rellena

			out.posicion = Short.valueOf(((TextNode) e1.childNode(1).childNode(0)).text().trim());
			out.galgo_nombre = ((TextNode) e1.childNode(3).childNode(1).childNode(0)).text().trim();

			String aux = ((TextNode) e1.childNode(5).childNode(0)).text().trim();
			out.trap = aux != null ? Integer.valueOf(aux) : null;

			out.urlparteB_galgo_historico = e1.childNode(3).childNode(1).attr("href").split("=")[1].trim();

			parsearyRellenarSp(Constantes.limpiarTexto(((TextNode) e1.childNode(7).childNode(0)).text()), out);

			// TIME_SEC debe ser numerico (float), pero no texto. Es decir, debería contener
			// el punto separador de decimales
			String time_sec = Constantes.limpiarTexto(((TextNode) e1.childNode(9).childNode(0)).text());
			out.time_sec = (time_sec.contains(".")) ? time_sec : null;

			String time_distance = Constantes.limpiarTexto(((TextNode) e1.childNode(11).childNode(0)).text());
			out.time_distance = time_distance.contains("(")
					? time_distance.replace("(", "XXXDIVISORXXX").split("XXXDIVISORXXX")[0].trim()
					: time_distance;

			String season_padre_madre_nacimiento_peso = Constantes
					.limpiarTexto(((TextNode) e2.childNode(1).childNode(0)).text());
			out.entrenador_nombre = Constantes.limpiarTexto(((TextNode) e2.childNode(3).childNode(2)).text())
					.replace(")", "").trim();

			out.comment = Constantes.limpiarTexto(((TextNode) e3.childNode(1).childNode(1)).text());

			parsearyRellenarSeasonPadreMadreNacimientoPeso(season_padre_madre_nacimiento_peso, out);

			out.fechaDeLaCarrera = fechayhoraDeLaCarrera;
		}
	}

	/**
	 * @param spStr
	 * @param out
	 */
	public static void parsearyRellenarSp(String spStr, GbgbPosicionEnCarrera out) {

		if (spStr != null && !"".equals(spStr)) {
			String aux = spStr.replaceAll("[A-Za-z]", "").trim();
			if (aux.contains("/")) {
				String[] partes = aux.split("/");
				Float p1 = Float.valueOf(partes[0]);
				Float p2 = Float.valueOf(partes[1]);
				out.sp = Float.valueOf(p1 / p2);
			} else {
				out.sp = Float.valueOf(aux);
			}

		}
	}

	/**
	 * @param cadena
	 * @param out
	 */
	public static void parsearyRellenarSeasonPadreMadreNacimientoPeso(String cadena, GbgbPosicionEnCarrera out) {

		String[] partes = cadena.replace(")", "XXXDIVISORXXX").split("XXXDIVISORXXX");
		String season = "";
		String padre_madre_nacimiento_peso = "";

		if (partes.length == 1) {

			padre_madre_nacimiento_peso = partes[0];
		}
		if (partes.length == 2) {

			padre_madre_nacimiento_peso = (partes[0].contains("eason")) ? partes[1] : partes[0];

		} else if (partes.length == 3) {

			MY_LOGGER.debug("partes[0]=" + partes[0]);
			MY_LOGGER.debug("partes[1]=" + partes[1]);
			MY_LOGGER.debug("partes[2]=" + partes[2]);

			season = partes[0].split("eason")[1].trim();
			padre_madre_nacimiento_peso = partes[1].trim();
		}

		out.galgo_padre = extraerPadre(padre_madre_nacimiento_peso);
		out.galgo_madre = extraerMadre(padre_madre_nacimiento_peso);
		out.nacimiento = extraerFechaNacimiento(padre_madre_nacimiento_peso);

		MY_LOGGER.debug("padre_madre_nacimiento_peso-->" + padre_madre_nacimiento_peso);

		String aux = padre_madre_nacimiento_peso.contains("eight")
				? padre_madre_nacimiento_peso.split("Weight")[1].replace(")", "").replace(":", "").trim()
				: null;
		Float pesoParseado = aux != null ? Float.valueOf(aux) : null;
		out.peso_galgo = (pesoParseado != null && pesoParseado.intValue() >= Constantes.MIN_PESO_GALGO) ? pesoParseado
				: null;

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
