/**
 * 
 */
package casa.mod002a.boe;

import java.io.IOException;
import java.nio.charset.Charset;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.HashMap;

import org.apache.log4j.Logger;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.nodes.Node;
import org.jsoup.select.Elements;

/**
 * Fecha y hora del BOE. URL:
 * https://www.boe.es/sede_electronica/informacion/hora_oficial.php
 *
 */
public class BoeParser {

	public BoeParser() {
		super();
	}

	static Logger MY_LOGGER = Logger.getLogger(BoeParser.class);

	/**
	 * @param pathIn
	 *            Path absoluto al fichero HTML de la pagina del BOE almacenado en
	 *            sistema de ficheros local.
	 * @param pathOut
	 * @param borrarSiExiste
	 */
	public void ejecutar(String pathIn, String pathOut, Boolean borrarSiExiste) {

		MY_LOGGER.info("BOE-Parser: INICIO");

		String bruto = "";
		String out = "";

		try {
			bruto = BoeParser.readFile(pathIn, Charset.forName("ISO-8859-1"));
			out = parsear(bruto);
			MY_LOGGER.info("BOE-Parser: out=" + out);

			MY_LOGGER.info("Escribiendo hacia " + pathOut + " ...");
			if (Files.exists(Paths.get(pathOut))) {
				MY_LOGGER.warn("El fichero ya existe. Lo borramos para crear el nuevo: " + pathOut);
				if (borrarSiExiste) {
					Files.delete(Paths.get(pathOut));
				}
			}

			Files.write(Paths.get(pathOut), out.getBytes());

		} catch (IOException e) {
			MY_LOGGER.error("Error:" + e.getMessage());
			e.printStackTrace();
		}

		MY_LOGGER.info("BOE-Parser: FIN");

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
	 * Extrae info de fecha y hora de la pÃ¡gina del BOE. Usa JSOUP:
	 * https://jsoup.org/cookbook/input/parse-document-from-string Manual:
	 * https://jsoup.org/cookbook/
	 * 
	 * @param in
	 * @return AAAAMMDD_HHmmss
	 */
	public static String parsear(String in) {

		// HTML
		Document doc = Jsoup.parse(in);

		Elements cajaHora = doc.getElementsByClass("cajaHora");
		Element contenido = cajaHora.get(0);
		Node nodo = contenido.childNode(1);

		// INFO BUENA: [lunes, 4 de septiembre de 2017, 09:23:24]
		String[] trozos = nodo.childNode(0).toString().split(",");
		String brutoDiaDeLaSemana = trozos[0];
		String brutoDiaMesAnio = trozos[1];
		String brutoHoraMinSeg = trozos[2];

		String out = parsearDiaDeLaSemana(brutoDiaDeLaSemana.trim()) + parsearDiaMesAnio(brutoDiaMesAnio.trim())
				+ parsearHoraMinSeg(brutoHoraMinSeg.trim());

		return out;
	}

	/**
	 * @param in.
	 *            Ej: lunes
	 * @return L,M,X..
	 */
	public static String parsearDiaDeLaSemana(String in) {

		HashMap<String, String> mapa = new HashMap<String, String>(7);

		mapa.put("lunes", "L");
		mapa.put("martes", "M");
		mapa.put("miércoles", "X");
		mapa.put("jueves", "J");
		mapa.put("viernes", "V");
		mapa.put("sábado", "S");
		mapa.put("domingo", "D");

		return mapa.get(in);

	}

	/**
	 * @param in.
	 *            Ej: 4 de septiembre de 2017
	 * @return 20170904
	 */
	public static String parsearDiaMesAnio(String in) {

		HashMap<String, String> mapa = new HashMap<String, String>(7);

		mapa.put("enero", "01");
		mapa.put("febrero", "02");
		mapa.put("marzo", "03");
		mapa.put("abril", "04");
		mapa.put("mayo", "05");
		mapa.put("junio", "06");
		mapa.put("julio", "07");
		mapa.put("agosto", "08");
		mapa.put("septiembre", "09");
		mapa.put("octubre", "10");
		mapa.put("noviembre", "11");
		mapa.put("diciembre", "12");

		String[] trozos = in.split(" ");
		String dia = trozos[0];
		String mes = mapa.get(trozos[2]);
		String anio = trozos[4];

		if (dia.length() == 1) {
			dia = "0" + dia;
		}

		return anio + mes + dia;

	}

	/**
	 * @param in.
	 *            Ej: 09:23:24
	 * @return 092324
	 */
	public static String parsearHoraMinSeg(String in) {

		return in.replaceAll(":", "");

	}

}