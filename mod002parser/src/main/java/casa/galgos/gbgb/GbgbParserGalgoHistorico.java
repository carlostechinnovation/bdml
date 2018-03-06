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
import utilidades.GalgosRemark;

/**
 * @author root
 *
 */
public class GbgbParserGalgoHistorico implements Serializable {

	private static final long serialVersionUID = 1L;

	static Logger MY_LOGGER = Logger.getLogger(GbgbParserGalgoHistorico.class);

	public static Map<String, Integer> remarksClavesSinTraduccion = new HashMap<String, Integer>();

	public GbgbParserGalgoHistorico() {
		super();
	}

	/**
	 * @param pathIn
	 * @param pathOut
	 * @param borrarSiExiste
	 */
	public GbgbGalgoHistorico ejecutar(String pathIn, String galgo_nombre) {

		MY_LOGGER.debug("GALGOS-GbgbDownloader - pathIn=" + pathIn);

		String bruto = "";
		GbgbGalgoHistorico out = null;

		try {
			bruto = GbgbParserGalgoHistorico.readFile(pathIn, Charset.forName("ISO-8859-1"));
			out = parsear(bruto, galgo_nombre);
			MY_LOGGER.debug("out=" + out);

		} catch (IOException e) {
			MY_LOGGER.error("Error: " + e.getMessage());
			e.printStackTrace();
		}

		MY_LOGGER.debug("FIN");
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
	 * @param in
	 * @param galgo_nombre
	 * @return
	 */
	public static GbgbGalgoHistorico parsear(String in, String galgo_nombre) {

		MY_LOGGER.debug("galgo_nombre=" + galgo_nombre);

		Document doc = Jsoup.parse(in);

		GbgbGalgoHistorico out = null;

		if (doc.toString().contains("Greyhound not found")) {
			out = new GbgbGalgoHistorico(-1);

		} else if (doc.toString().contains("No records to display.")) {
			out = new GbgbGalgoHistorico(-2);

		} else {

			Element tablaContenido = doc.getElementById("ctl00_ctl00_mainContent_cmscontent_DogRaceCard_lvDogRaceCard");

			List<Node> cabecera = doc.getElementById("inner-page-content").childNode(3).childNode(1).childNode(0)
					.childNode(0).childNodes();

			String entrenador = ((TextNode) cabecera.get(1).childNode(0)).text().split(":")[1].trim();
			String padre_madre_nacimiento = ((TextNode) cabecera.get(3).childNode(0)).text().trim();

			out = new GbgbGalgoHistorico(galgo_nombre, entrenador, padre_madre_nacimiento);

			List<Node> filas = null;

			boolean esel0 = tablaContenido.childNode(0).toString().contains("rgRow");
			boolean esel1 = tablaContenido.childNode(1).toString().contains("rgRow");
			Node conContenidos = tablaContenido.childNode(0).toString().contains("rgRow") ? tablaContenido.childNode(0)
					: tablaContenido.childNode(1);

			for (Node item : conContenidos.childNodes()) {
				if (item.toString().contains("rgRow")) {
					filas = item.childNodes();
				}
			}

			for (Node fila : filas) {
				if (fila instanceof Element) {
					rellenarFilaEnHistorico(out, (Element) fila, galgo_nombre);
				}
			}
		}

		return out;
	}

	/**
	 * @param modelo
	 * @param fila
	 */
	public static void rellenarFilaEnHistorico(GbgbGalgoHistorico modelo, Element fila, String galgo_nombre) {

		Long id_carrera = Long.valueOf(((Element) fila.childNode(15).childNode(0)).attr("href").split("=")[1]);
		Long id_campeonato = Long.valueOf(((Element) fila.childNode(16).childNode(0)).attr("href").split("=")[1]);

		String[] fechaStr = ((TextNode) fila.childNode(1).childNode(0)).text().split("/");
		Calendar fecha = Constantes.parsearFecha(fechaStr, true);

		Integer distancia = Integer
				.valueOf(Constantes.limpiarTexto(((TextNode) fila.childNode(2).childNode(0)).text().replace("m", "")));
		String trap = Constantes.limpiarTexto(((TextNode) fila.childNode(3).childNode(0)).text());
		String stmHcp = Constantes.limpiarTexto(((TextNode) fila.childNode(4).childNode(0)).text());
		String posicion = Constantes.limpiarTexto(((TextNode) fila.childNode(5).childNode(0)).text());
		String by = Constantes.limpiarTexto(((TextNode) fila.childNode(6).childNode(0)).text());
		String galgo_primero_o_segundo = Constantes.limpiarTexto(((TextNode) fila.childNode(7).childNode(0)).text());
		String venue = Constantes.limpiarTexto(((TextNode) fila.childNode(8).childNode(0)).text());
		String remarks = Constantes.limpiarTexto(((TextNode) fila.childNode(9).childNode(0)).text());
		String winTime = Constantes.limpiarTexto(((TextNode) fila.childNode(10).childNode(0)).text());
		String going = Constantes.limpiarTexto(((TextNode) fila.childNode(11).childNode(0)).text());
		String spStr = Constantes.limpiarTexto(((TextNode) fila.childNode(12).childNode(0)).text());
		String clase = Constantes.limpiarTexto(((TextNode) fila.childNode(13).childNode(0)).text());
		String calculatedTime = Constantes.limpiarTexto(((TextNode) fila.childNode(14).childNode(0)).text());

		// VELOCIDADES
		Float velocidadReal = calcularVelocidadReal(distancia, calculatedTime, going);
		Float velocidadConGoing = calcularVelocidadConGoing(distancia, calculatedTime);

		// SCORINGS
		Float scoringRemarks = calcularScoringRemarks(remarks);

		// APUESTAS (SP-Starting Price, ODDs)
		Float sp = null;
		if (spStr != null && !spStr.isEmpty()) {
			if (spStr.contains("/")) {
				String[] spPartes = spStr.split("/");
				sp = Float.valueOf(spPartes[0]) / Float.valueOf(spPartes[1]);
			} else {
				sp = Float.valueOf(spStr);
			}
		}

		GbgbGalgoHistoricoCarrera filaModelo = new GbgbGalgoHistoricoCarrera(id_carrera, id_campeonato, fecha,
				distancia, trap, stmHcp, posicion, by, galgo_primero_o_segundo, venue, remarks, winTime, going, sp,
				clase, calculatedTime, velocidadReal, velocidadConGoing, scoringRemarks);

		if (posicion == null || posicion.isEmpty()) {
			MY_LOGGER.warn("Historico de galgo='" + galgo_nombre + "' con posicion nula o vacia. No cogemos esa fila.");
		} else if ("0".equals(posicion)) {
			MY_LOGGER.warn("Historico de galgo='" + galgo_nombre + "' con posicion=0. No cogemos esa fila.");
		} else if (Integer.valueOf(posicion).intValue() >= 7) {
			MY_LOGGER.warn(
					"Historico de galgo='" + galgo_nombre + "' con posicion=" + posicion + ". No cogemos esa fila.");
		} else {
			modelo.carrerasHistorico.add(filaModelo);
		}

	}

	/**
	 * Velocidad REAL
	 * 
	 * @param distancia
	 * @param calculatedTime
	 *            Tiempo calculado = Real + going_allowance
	 * @param goingAllowance
	 * @return
	 */
	public static Float calcularVelocidadReal(Integer distancia, String calculatedTime,
			String goingAllowanceCentesimasSeg) {

		Float velocidadReal = null;

		if (distancia != null && calculatedTime != null && !calculatedTime.isEmpty()
				&& goingAllowanceCentesimasSeg != null && !goingAllowanceCentesimasSeg.isEmpty()) {

			// CENTESIMAS DE SEGUNDO
			Float goingAllowanceFloat = (goingAllowanceCentesimasSeg != null && goingAllowanceCentesimasSeg.equals("N"))
					? 0
					: (Float.valueOf(goingAllowanceCentesimasSeg) / 100.0F);

			velocidadReal = distancia / (Float.valueOf(calculatedTime) - goingAllowanceFloat);
		}
		return velocidadReal;
	}

	/**
	 * Velocidad CALCULADA
	 * 
	 * @param distancia
	 * @param calculatedTime
	 *            Tiempo calculado = Real + going_allowance
	 * @return
	 */
	public static Float calcularVelocidadConGoing(Integer distancia, String calculatedTime) {

		Float velocidadCalculada = null;

		if (distancia != null && calculatedTime != null && !calculatedTime.isEmpty()) {
			velocidadCalculada = distancia / Float.valueOf(calculatedTime);

		}

		return velocidadCalculada;
	}

	/**
	 * @param remarks
	 * @return
	 */
	public static Float calcularScoringRemarks(String remarks) {

		List<String> partes = new ArrayList<String>();

		String[] divididoPorComa = remarks.replaceAll("\\t", "").split(",");
		String[] divididoPorGuion;
		String[] divididoPorAmper;
		String[] divididoPorBarra;
		for (String cad : divididoPorComa) {
			divididoPorGuion = cad.trim().split("-");
			for (String cad2 : divididoPorGuion) {
				divididoPorAmper = cad2.trim().split("&");
				for (String cad3 : divididoPorAmper) {
					divididoPorBarra = cad3.trim().split("/");
					for (String cad4 : divididoPorBarra) {
						if (cad4.trim().length() > 0) {
							partes.add(cad4.trim());
						}
					}
				}
			}
		}

		Float out = 0F;
		// TODO descomentar cuando conozca bien los remarks
		// Map<String, GalgosRemark> mapa = Constantes.generarDiccionarioRemarks();
		Map<String, GalgosRemark> mapa = new HashMap<String, GalgosRemark>();

		for (String parte : partes) {

			// Si no lo encuentro a la primera, quito los numeros que tenga
			String clave = mapa.containsKey(parte) ? parte : parte.replaceAll("[\\d.]", "");

			if (mapa.containsKey(clave)) {
				out += mapa.get(clave).puntos;
			} else {

				if (!clave.trim().isEmpty()
						&& remarksClavesSinTraduccion.keySet().size() < Constantes.MAX_NUM_REMARKS_MEMORIZADAS) {

					if (remarksClavesSinTraduccion.containsKey(clave)) {
						remarksClavesSinTraduccion.replace(clave, remarksClavesSinTraduccion.get(clave) + 1);
					} else {
						remarksClavesSinTraduccion.put(clave, 1);
					}

				}

			}

		}

		return out;
	}

}