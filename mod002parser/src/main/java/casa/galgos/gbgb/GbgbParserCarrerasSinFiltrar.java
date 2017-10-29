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
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.nodes.Node;
import org.jsoup.nodes.TextNode;

import utilidades.Constantes;

/**
 *
 */
public class GbgbParserCarrerasSinFiltrar implements Serializable {

	private static final long serialVersionUID = 1L;

	public GbgbParserCarrerasSinFiltrar() {
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
	public List<GbgbCarrera> ejecutar(String pathIn) {

		MY_LOGGER.info("GALGOS-GbgbParserCarreras: INICIO");

		String bruto = "";
		List<GbgbCarrera> out = null;

		try {
			bruto = GbgbParserCarrerasSinFiltrar.readFile(pathIn, Charset.forName("ISO-8859-1"));
			out = parsear(bruto);
			MY_LOGGER.info("GALGOS-GbgbParserCarreras: out=" + out);

		} catch (IOException e) {
			MY_LOGGER.log(Level.SEVERE, "Error:" + e.getMessage());
			e.printStackTrace();
		}

		MY_LOGGER.info("GALGOS-GbgbParserCarreras: FIN");
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
	public static List<GbgbCarrera> parsear(String in) {

		Document doc = Jsoup.parse(in);
		Element tablaCarreras = doc.getElementById("ctl00_ctl00_mainContent_cmscontent_TrackRaces_lvTrackRaces_ctl00");

		List<Node> listaCarrerasPre = tablaCarreras.childNode(4).childNodes();

		List<GbgbCarrera> listaCarreras = parsearCarreras(listaCarrerasPre);

		return listaCarreras;
	}

	/**
	 * @param listaCarrerasPre
	 * @return
	 */
	public static List<GbgbCarrera> parsearCarreras(List<Node> listaCarrerasPre) {

		List<GbgbCarrera> listaCarreras = new ArrayList<GbgbCarrera>();

		if (listaCarrerasPre != null) {

			for (Node fila : listaCarrerasPre) {

				if (fila instanceof Element) {
					Element filae = (Element) fila;

					if (filae instanceof Element) {

						String track = ((TextNode) filae.childNode(1).childNode(0)).text();
						String clase = ((TextNode) filae.childNode(2).childNode(0)).text();

						Calendar fechayhora = Constantes.parsearFechaHora(
								((TextNode) filae.childNode(3).childNode(0)).text(),
								((TextNode) filae.childNode(4).childNode(0)).text());

						Integer distancia = Integer.valueOf(((TextNode) filae.childNode(5).childNode(0)).text());

						Long id_carrera = Long
								.valueOf(filae.childNode(6).childNode(0).attr("href").split("=")[1].trim());
						Long id_campeonato = Long
								.valueOf(filae.childNode(7).childNode(0).attr("href").split("=")[1].trim());

						listaCarreras.add(
								new GbgbCarrera(id_carrera, id_campeonato, track, clase, fechayhora, distancia, null));
					}
				}

			}
		}

		return listaCarreras;
	}

}