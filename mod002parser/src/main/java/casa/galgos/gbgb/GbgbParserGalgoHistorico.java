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
import java.util.logging.Level;
import java.util.logging.Logger;

import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.nodes.Node;
import org.jsoup.nodes.TextNode;

/**
 * @author root
 *
 */
public class GbgbParserGalgoHistorico implements Serializable {

	private static final long serialVersionUID = 1L;

	public GbgbParserGalgoHistorico() {
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
	public GbgbGalgoHistorico ejecutar(String pathIn, String galgo_nombre) {

		MY_LOGGER.info("GALGOS-GbgbParserCarrerasDeUnDia: INICIO");
		MY_LOGGER.info("GALGOS-GbgbDownloader - pathIn=" + pathIn);

		String bruto = "";
		GbgbGalgoHistorico out = null;

		try {
			bruto = GbgbParserGalgoHistorico.readFile(pathIn, Charset.forName("ISO-8859-1"));
			out = parsear(bruto, galgo_nombre);
			MY_LOGGER.info("GALGOS-GbgbParserCarrerasDeUnDia: out=" + out);

		} catch (IOException e) {
			MY_LOGGER.log(Level.SEVERE, "Error:" + e.getMessage());
			e.printStackTrace();
		}

		MY_LOGGER.info("GALGOS-GbgbParserCarrerasDeUnDia: FIN");
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
	 * @param in
	 * @param galgo_nombre
	 * @return
	 */
	public static GbgbGalgoHistorico parsear(String in, String galgo_nombre) {

		Document doc = Jsoup.parse(in);
		Element tablaContenido = doc.getElementById("ctl00_ctl00_mainContent_cmscontent_DogRaceCard_lvDogRaceCard");

		List<Node> cabecera = doc.getElementById("inner-page-content").childNode(3).childNode(1).childNode(0)
				.childNode(0).childNodes();

		String entrenador = ((TextNode) cabecera.get(1).childNode(0)).text().split(":")[1].trim();
		String padre_madre_nacimiento = ((TextNode) cabecera.get(3).childNode(0)).text().trim();

		GbgbGalgoHistorico out = new GbgbGalgoHistorico(galgo_nombre, entrenador, padre_madre_nacimiento);

		List<Node> filas = tablaContenido.childNode(0).childNode(4).childNodes();

		for (Node fila : filas) {
			if (fila instanceof Element) {
				rellenarFilaEnHistorico(out, (Element) fila);
			}
		}

		return out;
	}

	/**
	 * @param modelo
	 * @param fila
	 */
	public static void rellenarFilaEnHistorico(GbgbGalgoHistorico modelo, Element fila) {

		Long id_carrera = Long.valueOf(((Element) fila.childNode(15).childNode(0)).attr("href").split("=")[1]);
		Long id_campeonato = Long.valueOf(((Element) fila.childNode(16).childNode(0)).attr("href").split("=")[1]);

		String[] fechaStr = ((TextNode) fila.childNode(1).childNode(0)).text().split("/");
		Calendar fecha = Calendar.getInstance();
		fecha.set(Calendar.DAY_OF_MONTH, Integer.valueOf(fechaStr[0]));
		fecha.set(Calendar.MONTH, Integer.valueOf(fechaStr[1]));
		fecha.set(Calendar.YEAR, 2000 + Integer.valueOf(fechaStr[2]));

		Integer distancia = Integer.valueOf(((TextNode) fila.childNode(2).childNode(0)).text());
		String trap = ((TextNode) fila.childNode(3).childNode(0)).text();
		String stmHcp = ((TextNode) fila.childNode(4).childNode(0)).text();
		String posicion = ((TextNode) fila.childNode(5).childNode(0)).text();
		String by = ((TextNode) fila.childNode(6).childNode(0)).text();
		String galgo_primero_o_segundo = ((TextNode) fila.childNode(7).childNode(0)).text();
		String venue = ((TextNode) fila.childNode(8).childNode(0)).text();
		String remarks = ((TextNode) fila.childNode(9).childNode(0)).text();
		String winTime = ((TextNode) fila.childNode(10).childNode(0)).text();
		String going = ((TextNode) fila.childNode(11).childNode(0)).text();
		String sp = ((TextNode) fila.childNode(12).childNode(0)).text();
		String clase = ((TextNode) fila.childNode(13).childNode(0)).text();
		String calculatedTime = ((TextNode) fila.childNode(14).childNode(0)).text();

		GbgbGalgoHistoricoCarrera filaModelo = new GbgbGalgoHistoricoCarrera(id_carrera, id_campeonato, fecha,
				distancia, trap, stmHcp, posicion, by, galgo_primero_o_segundo, venue, remarks, winTime, going, sp,
				clase, calculatedTime);
		modelo.carrerasHistorico.add(filaModelo);
		int x = 0;

	}

}