/**
 * 
 */
package casa.galgos.sportium;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.file.Files;
import java.nio.file.Paths;

import org.apache.log4j.Logger;

/**
 *
 */
public class SportiumDownloader {

	static Logger MY_LOGGER = Logger.getLogger(SportiumDownloader.class);

	public SportiumDownloader() {
		super();
	}

	/**
	 * Dada una URL, descarga su contenido de Internet en una carpeta indicada.
	 * 
	 * @param urlCarrera
	 *            URL de la página web a descargar
	 * @param pathOut
	 *            Path absoluto del FICHERO (no carpeta) donde se van a GUARDAR los
	 *            DATOS BRUTOS.
	 * @param borrarSiExiste
	 *            BOOLEAN que indica si se quiere BORRAR el FICHERO (no la carpeta)
	 *            de donde se van a guardar los DATOS BRUTOS.
	 */
	public void descargarDeURLsAFicheros(String urlCarrera, String pathOut, Boolean borrarSiExiste) {

		MY_LOGGER.info(
				"[URL|pathOut|borrarSiExiste] --> [" + urlCarrera + " | " + pathOut + " | " + borrarSiExiste + " ]");

		try {
			if (Files.exists(Paths.get(pathOut)) && borrarSiExiste) {
				MY_LOGGER.debug("Borrando fichero de salida preexistente...");
				Files.delete(Paths.get(pathOut));
			}

			MY_LOGGER.debug("--- Peticion HTTP normal ---");
			// Request
			URL url = new URL(urlCarrera);
			HttpURLConnection.setFollowRedirects(true);
			HttpURLConnection con = (HttpURLConnection) url.openConnection();
			con.setRequestMethod("GET");
			con.setDoOutput(true); // Conexion usada para output

			// Request Headers
			con.setRequestProperty("Content-Type",
					"text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8");

			// TIMEOUTs
			con.setConnectTimeout(5000);
			con.setReadTimeout(5000);

			// Handling Redirects
			con.setInstanceFollowRedirects(false);

			// MY_LOGGER.info("--- Peticion HTTP con REDIRECTS ---");
			// HttpURLConnection.setFollowRedirects(true);
			// con = (HttpURLConnection) url.openConnection();
			// con.connect();// COMUNICACION

			// CODIGO de RESPUESTA
			int status = con.getResponseCode();
			if (status == HttpURLConnection.HTTP_MOVED_TEMP || status == HttpURLConnection.HTTP_MOVED_PERM) {
				MY_LOGGER.debug("--- Peticion HTTP escapando caracteres espacio en URL ---");
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

}