/**
 * 
 */
package casa.galgos.betbright;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.Charset;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.List;
import java.util.Map.Entry;

import org.apache.log4j.Logger;

/**
 *
 */
public class BetbrightDownloader {

	static Logger MY_LOGGER = Logger.getLogger(BetbrightDownloader.class);

	public BetbrightDownloader() {
		super();
	}

	/**
	 * Este metodo solo lo uso para DEBUG a mano. Para nada más.
	 * 
	 * @param args
	 * @throws IOException
	 */
	public static void main(String[] args) throws IOException {

		System.out.println("INICIO - Prueba local...");

		String urlCarrera = "https://www.betbright.com/greyhound-racing/tomorrow";
		String pathOut = "/home/carloslinux/git/bdml/mod002parser/src/test/resources/bb_temp";
		Boolean borrarSiExiste = true;

		BetbrightDownloader instancia = new BetbrightDownloader();
		instancia.descargarDeURLsAFicheros(urlCarrera, pathOut, borrarSiExiste);

		String bruto = BetbrightParserCarrerasFuturas.readFile(pathOut, Charset.forName("ISO-8859-1"));
		if (BetbrightParserCarrerasFuturas.descargaBanned(bruto)) {
			System.err.println(
					"BB-ERROR: La pagina descargada no contiene info útil. Han detectado que ejecutamos desde un robot!!!!");
			System.err.println("Contenido descargado:");
			System.err.println(bruto);

		} else {

		}
		System.out.println("FIN - Prueba local.");
	}

	/**
	 * Dada una URL, descarga su contenido de Internet en una carpeta indicada.
	 * 
	 * Utiliza este hack: https://github.com/abiyani/automate-save-page-as
	 * 
	 * @param urlCarrera     URL de la página web a descargar
	 * @param pathOut        Path absoluto del FICHERO (no carpeta) donde se van a
	 *                       GUARDAR los DATOS BRUTOS.
	 * @param borrarSiExiste BOOLEAN que indica si se quiere BORRAR el FICHERO (no
	 *                       la carpeta) de donde se van a guardar los DATOS BRUTOS.
	 */
	public void descargarDeURLsAFicheros(String urlCarrera, String pathOut, Boolean borrarSiExiste) {

		MY_LOGGER.info("[URL|pathOut|borrarSiExiste] --> " + urlCarrera + " | " + pathOut + " | " + borrarSiExiste);

		try {
			if (Files.exists(Paths.get(pathOut)) && borrarSiExiste) {
				MY_LOGGER.debug("Borrando fichero de salida preexistente...");
				Files.delete(Paths.get(pathOut));
			}

			System.out.println("--- Peticion HTTP para obtener COOKIE ---");
			String incapsulaCookie = getIncapsulaCookie(urlCarrera);
			System.out.println("incapsulaCookie = [ " + incapsulaCookie + " ]");
			String salida = readUrl(urlCarrera, incapsulaCookie);
			System.out.println("---------------");
			System.out.println(salida);
			System.out.println("---------------");

			MY_LOGGER.info("--- Peticion HTTP normal ---");
			// Request
			URL url = new URL(urlCarrera);
			// HttpURLConnection.setFollowRedirects(true);
			HttpURLConnection con = (HttpURLConnection) url.openConnection();
			// con.setRequestMethod("GET");
			// con.setDoOutput(true); // Conexion usada para output

			// Request Headers
			// con.setRequestProperty("pragma", "no-cache");
			// con.setRequestProperty("accept-encoding", "gzip, deflate, br");
			// con.setRequestProperty("accept-language", "es-ES,es;q=0.8");
			// con.setRequestProperty("upgrade-insecure-requests", "1");
			// con.setRequestProperty("user-agent",
			// "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko)
			// Chrome/61.0.3163.100 Safari/537.36");
			// con.setRequestProperty("accept",
			// "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8");
			// con.setRequestProperty("cache-control", "no-cache");
			// con.setRequestProperty("authority", "www.betbright.com");

			// TIMEOUTs
			// con.setConnectTimeout(5000);// mseg
			// con.setReadTimeout(5000);// mseg

			// Handling Redirects
			// con.setInstanceFollowRedirects(false);

			// MY_LOGGER.info("--- Peticion HTTP con REDIRECTS ---");
			// HttpURLConnection.setFollowRedirects(true);
			// con = (HttpURLConnection) url.openConnection();

			con.connect();// COMUNICACION

			// CODIGO de RESPUESTA
			int status = con.getResponseCode();
			if (status == HttpURLConnection.HTTP_MOVED_TEMP || status == HttpURLConnection.HTTP_MOVED_PERM) {
				MY_LOGGER.info("--- Peticion HTTP escapando caracteres espacio en URL ---");
				String location = con.getHeaderField("Location");
				URL newUrl = new URL(location.replace(" ", "%20"));
				con = (HttpURLConnection) newUrl.openConnection();
			}

			BufferedReader in = new BufferedReader(new InputStreamReader(con.getInputStream()));
			String inputLine;
			StringBuffer content = new StringBuffer();
			while ((inputLine = in.readLine()) != null) {
				content.append(inputLine);
			}
			in.close();

			// close the connection
			con.disconnect();

			// Escribir SALIDA
			MY_LOGGER.debug("Escribiendo a fichero...");
			MY_LOGGER.debug("StringBuffer con " + content.length() + " elementos de 16-bits)");
			Files.write(Paths.get(pathOut), content.toString().getBytes());

		} catch (IOException e) {
			MY_LOGGER.error("Error:" + e.getMessage());
			e.printStackTrace();
		}

		MY_LOGGER.debug("FIN");

	}

	public static String readUrl(String url, String incapsulaCookie) {
		StringBuilder response = new StringBuilder();
		String USER_AGENT = "Mozilla/5.0", inputLine;
		BufferedReader in = null;

		try {
			HttpURLConnection connection = (HttpURLConnection) new URL(url).openConnection();
			connection.setRequestMethod("GET");
			connection.setRequestProperty("Accept", "text/html; charset=UTF-8");
			connection.setRequestProperty("User-Agent", USER_AGENT);
			connection.setDoInput(true);
			connection.setDoOutput(true);
			connection.setRequestProperty("Cookie", incapsulaCookie); // Set the Incapsula cookie
			System.out.println(connection.getRequestProperty("Cookie"));

			in = new BufferedReader(new InputStreamReader(connection.getInputStream()));
			while ((inputLine = in.readLine()) != null) {
				response.append(inputLine + "\n");
			}
			in.close();

		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			try {
				if (in != null)
					in.close();
			} catch (Exception ex) {
				ex.printStackTrace();
			}
		}
		return response.toString();
	}

	/**
	 * TRUCO:
	 * https://stackoverflow.com/questions/40726427/how-to-read-html-content-from-this-page-with-java
	 * 
	 * @param url
	 * @return
	 */
	public static String getIncapsulaCookie(String url) {

		String USER_AGENT = "Mozilla/5.0";
		BufferedReader in = null;

		String incapsulaCookie = null;

		try {

			HttpURLConnection cookieConnection = (HttpURLConnection) new URL(url).openConnection();
			cookieConnection.setRequestMethod("GET");
			cookieConnection.setRequestProperty("Accept", "text/html; charset=UTF-8");
			cookieConnection.setRequestProperty("User-Agent", USER_AGENT);

			// Disable 'keep-alive'
			cookieConnection.setRequestProperty("Connection", "close");

			// Cookies for Incapsula, preserve order
			String visid = null;
			String incap = null;

			cookieConnection.connect();

			for (Entry<String, List<String>> header : cookieConnection.getHeaderFields().entrySet()) {

				// Incapsula gives you the required cookies
				if (header.getKey() != null && header.getKey().equals("Set-Cookie")) {

					// Search for the desired cookies
					for (String cookieValue : header.getValue()) {
						if (cookieValue.contains("visid")) {
							visid = cookieValue.substring(0, cookieValue.indexOf(";") + 1);
						}
						if (cookieValue.contains("incap_ses")) {
							incap = cookieValue.substring(0, cookieValue.indexOf(";"));
						}
					}
				}
			}

			incapsulaCookie = visid + " " + incap;

			// Explicitly disconnect, also essential in this method!
			cookieConnection.disconnect();

		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			try {
				if (in != null)
					in.close();
			} catch (Exception ex) {
				ex.printStackTrace();
			}
		}

		return incapsulaCookie;

	}

}