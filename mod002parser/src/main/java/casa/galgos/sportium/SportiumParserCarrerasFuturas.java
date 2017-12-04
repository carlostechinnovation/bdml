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
import java.util.Calendar;
import java.util.List;

import org.apache.log4j.Logger;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.nodes.Node;
import org.jsoup.nodes.TextNode;
import org.jsoup.select.Elements;

import utilidades.Constantes;

/**
 *
 */
public class SportiumParserCarrerasFuturas implements Serializable {

	private static final long serialVersionUID = 1L;

	static Logger MY_LOGGER = Logger.getLogger(SportiumParserCarrerasFuturas.class);

	public SportiumParserCarrerasFuturas() {
		super();
	}

	/**
	 * @param pathIn
	 *            Path absoluto al fichero HTML de la pagina del BOE almacenado en
	 *            sistema de ficheros local.
	 * @param pathOut
	 * @param borrarSiExiste
	 */
	public List<SportiumCarrera> ejecutar(String pathIn) {

		MY_LOGGER.info("GALGOS-SportiumParserCarrerasFuturas: INICIO");

		String bruto = "";
		List<SportiumCarrera> out = null;

		try {
			bruto = SportiumParserCarrerasFuturas.readFile(pathIn, Charset.forName("ISO-8859-1"));
			out = parsear(bruto);
			// MY_LOGGER.info("GALGOS-SportiumParserCarrerasFuturas: out=" + out);

		} catch (IOException e) {
			MY_LOGGER.error("Error:" + e.getMessage());
			e.printStackTrace();
		}

		MY_LOGGER.info("GALGOS-SportiumParserCarrerasFuturas: FIN");
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
	 * @param in
	 * @return
	 */
	public static List<SportiumCarrera> parsear(String in) {

		Document doc = Jsoup.parse(in);
		Elements tablasDeCarrerasDiarias = doc.getElementsByClass("racing-events-for-date");

		int numDias = tablasDeCarrerasDiarias.size();

		List<SportiumCarrera> listaCarreras = new ArrayList<SportiumCarrera>();

		if (tablasDeCarrerasDiarias != null) {

			int contador = 0;

			for (Element diaFila : tablasDeCarrerasDiarias) {
				contador++;
				listaCarreras.addAll(parsearTablaDia(diaFila));

			}
		}

		MY_LOGGER.info("Sportium - Parseadas " + listaCarreras.size() + " carreras FUTURAS");

		// LIMITAMOS SALIDA
		List<SportiumCarrera> out = new ArrayList<SportiumCarrera>();
		int anhadidas = 0;
		for (SportiumCarrera item : listaCarreras) {

			out.add(item);
			anhadidas++;

			if (anhadidas >= Constantes.MAX_NUM_CARRERAS_SEMILLA) {
				break;
			}
		}
		return out;
	}

	/**
	 * @param diaFila
	 * @return
	 */
	public static List<SportiumCarrera> parsearTablaDia(Element diaFila) {

		List<SportiumCarrera> out = new ArrayList<SportiumCarrera>();

		String diaStr = ((TextNode) diaFila.childNode(0).childNode(0).childNode(0)).text().trim();
		Long dia = parsearDiaStr(diaStr);

		List<Node> carrerasEnEstadios = diaFila.childNode(0).childNode(1).childNode(0).childNodes();

		if (carrerasEnEstadios != null && !carrerasEnEstadios.isEmpty()) {
			for (Node filaCarrerasEnEstadio : carrerasEnEstadios) {
				out.addAll(parsearCarrerasDeUnEstadio((Element) filaCarrerasEnEstadio, dia));
			}
		}

		return out;
	}

	/**
	 * @param in
	 * @return
	 */
	public static Long parsearDiaStr(String in) {

		Long out = null;

		Calendar ahora = Calendar.getInstance();
		int anio = ahora.get(Calendar.YEAR);
		int mes = ahora.get(Calendar.MONTH) + 1;
		int dia = ahora.get(Calendar.DAY_OF_MONTH);

		if (in != null && !in.isEmpty()) {

			if (in.equalsIgnoreCase("hoy")) {
				out = anio * 10000L + mes * 100 + dia;
			} else if (in.contains("ana")) { // mañana
				out = anio * 10000L + mes * 100 + dia + 1;
			} else {
				// TODO de momento no cojo carreras demasiado futuras
			}

		}

		return out;

	}

	/**
	 * @param filaCarrera
	 * @param dia
	 * @return
	 */
	public static List<SportiumCarrera> parsearCarrerasDeUnEstadio(Element filaCarrerasEnEstadio, Long dia) {

		List<SportiumCarrera> out = new ArrayList<SportiumCarrera>();

		List<String> galgosNombres = new ArrayList<String>();

		String estadio = ((TextNode) filaCarrerasEnEstadio.childNode(0).childNode(0)).text().trim();

		List<Node> filasCarreras = filaCarrerasEnEstadio.childNode(1).childNodes();
		if (filasCarreras != null && !filasCarreras.isEmpty()) {

			for (Node item : filasCarreras) {

				if (item instanceof Element) {
					Element fila = (Element) item.childNode(0);
					String contenidoFila = fila.toString();
					if (contenidoFila.contains("Completa")) {// TARJETA CARRERAS COMPLETA
						// No hacemos nada
					} else if (!contenidoFila.contains("RESULT") && contenidoFila.contains(":")) { // hora y minuto de
																									// una carrera
																									// (DESCARTO LAS
																									// TERMINADAS, con
																									// RESULTADO
																									// conocido)

						String urlDetalle = Constantes.GALGOS_SPORTIUM_PREFIJO + fila.attr("href");

						String[] trozos = urlDetalle.split("/");
						String ultimo = trozos[trozos.length - 1];
						Integer horaInglesa = Integer.valueOf(ultimo.split("-")[0].replace(".", ""));

						SportiumCarrera modelo = new SportiumCarrera(urlDetalle, estadio, dia, horaInglesa,
								galgosNombres);
						out.add(modelo);

					}

				}

			}
		}

		return out;

	}

}
