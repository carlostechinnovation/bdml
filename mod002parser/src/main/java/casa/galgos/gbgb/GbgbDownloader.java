/**
 * 
 */
package casa.galgos.gbgb;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.file.Files;
import java.nio.file.Paths;

import org.apache.log4j.Logger;

import utilidades.Constantes;

/**
 *
 */
public class GbgbDownloader {

	static Logger MY_LOGGER = Logger.getLogger(GbgbDownloader.class);

	public GbgbDownloader() {
		super();
	}

	/**
	 * @param pathOut
	 *            Path absoluto donde guardar el fichero bruto descargado
	 * @param borrarSiExiste
	 *            Borrar fichero destino, si ya existe.
	 */
	public void descargarCarreras(String pathOut, Boolean borrarSiExiste) {

		MY_LOGGER.debug("INICIO");
		MY_LOGGER.debug("pathOut=" + pathOut);
		MY_LOGGER.debug("borrarSiExiste=" + borrarSiExiste);

		try {

			MY_LOGGER.debug("Borrando fichero de salida preexistente " + pathOut + " ...");
			if (Files.exists(Paths.get(pathOut))) {
				MY_LOGGER.debug("El fichero ya existe. Lo borramos para crear el nuevo: " + pathOut);
				if (borrarSiExiste) {
					Files.delete(Paths.get(pathOut));
				}
			}

			// Request
			URL url = new URL(Constantes.GALGOS_GBGB_CARRERAS);
			HttpURLConnection con = (HttpURLConnection) url.openConnection();
			con.setRequestMethod("GET");
			con.setDoOutput(true); // Conexion usada para output

			// Request Headers
			con.setRequestProperty("Content-Type",
					"text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8");
			String contentType = con.getHeaderField("Content-Type");

			// TIMEOUTs
			con.setConnectTimeout(5000);
			con.setReadTimeout(5000);

			// Handling Redirects
			con.setInstanceFollowRedirects(false);
			HttpURLConnection.setFollowRedirects(true);

			MY_LOGGER.info("HTTP GET " + url + " ...");
			con = (HttpURLConnection) url.openConnection();

			// CODIGO de RESPUESTA
			int status = con.getResponseCode();
			if (status == HttpURLConnection.HTTP_MOVED_TEMP || status == HttpURLConnection.HTTP_MOVED_PERM) {
				String location = con.getHeaderField("Location");
				URL newUrl = new URL(location);
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
			MY_LOGGER.debug("Path fichero salida: " + pathOut);
			Files.write(Paths.get(pathOut), content.toString().getBytes());

		} catch (IOException e) {
			MY_LOGGER.error("Error:" + e.getMessage());
			e.printStackTrace();
		}

		MY_LOGGER.debug("GALGOS-GbgbDownloader: FIN");

	}

	/**
	 * @param pathOut
	 * @param borrarSiExiste
	 */
	public void descargarCarreraDetalle(String urlCarrera, String pathOut, Boolean borrarSiExiste) {

		MY_LOGGER.debug("URL: " + urlCarrera);
		MY_LOGGER.debug("pathOut=" + pathOut);
		MY_LOGGER.debug("borrarSiExiste=" + borrarSiExiste);

		try {

			MY_LOGGER.debug("Borrando fichero de salida preexistente " + pathOut + " ...");
			if (Files.exists(Paths.get(pathOut))) {
				MY_LOGGER.debug("El fichero ya existe. Lo borramos para crear el nuevo: " + pathOut);
				if (borrarSiExiste) {
					Files.delete(Paths.get(pathOut));
				}
			}

			// Request
			URL url = new URL(urlCarrera.replace(" ", "%20"));
			HttpURLConnection con = (HttpURLConnection) url.openConnection();
			con.setRequestMethod("GET");
			con.setDoOutput(true); // Conexion usada para output

			// Request Headers
			con.setRequestProperty("Content-Type",
					"text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8");
			String contentType = con.getHeaderField("Content-Type");

			// TIMEOUTs
			con.setConnectTimeout(5000);
			con.setReadTimeout(5000);

			// Handling Redirects
			con.setInstanceFollowRedirects(false);
			HttpURLConnection.setFollowRedirects(true);

			MY_LOGGER.info("HTTP GET " + url + " ...");
			con = (HttpURLConnection) url.openConnection();

			// CODIGO de RESPUESTA
			int status = con.getResponseCode();
			if (status == HttpURLConnection.HTTP_MOVED_TEMP || status == HttpURLConnection.HTTP_MOVED_PERM) {
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
			MY_LOGGER.debug("Path fichero salida: " + pathOut);
			Files.write(Paths.get(pathOut), content.toString().getBytes());

		} catch (IOException e) {
			MY_LOGGER.error("Error:" + e.getMessage());
			e.printStackTrace();
		}

		MY_LOGGER.debug("FIN");

	}

	/**
	 * Descarga y guarda la WEB del historico de un galgo.
	 * 
	 * @param urlHistoricoGalgo
	 * @param pathOut
	 * @param borrarSiExiste
	 */
	public void descargarHistoricoGalgo(String urlHistoricoGalgo, String pathOut, Boolean borrarSiExiste) {

		MY_LOGGER.debug("DescargarHistoricoGalgo:  ");
		MY_LOGGER.debug("urlCarrera=" + urlHistoricoGalgo);
		MY_LOGGER.debug("pathOut=" + pathOut);
		MY_LOGGER.debug("borrarSiExiste=" + borrarSiExiste);

		try {

			MY_LOGGER.debug("Borrando fichero de salida preexistente " + pathOut + " ...");
			if (Files.exists(Paths.get(pathOut))) {
				MY_LOGGER.debug("El fichero ya existe. Lo borramos para crear el nuevo: " + pathOut);
				if (borrarSiExiste) {
					Files.delete(Paths.get(pathOut));
				}
			}

			// Request
			URL url = new URL(urlHistoricoGalgo.replace(" ", "%20"));
			HttpURLConnection con = (HttpURLConnection) url.openConnection();
			con.setRequestMethod("GET");
			con.setDoOutput(true); // Conexion usada para output

			// Request Headers
			con.setRequestProperty("Content-Type",
					"text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8");
			String contentType = con.getHeaderField("Content-Type");

			// TIMEOUTs
			con.setConnectTimeout(5000);
			con.setReadTimeout(5000);

			// Handling Redirects
			con.setInstanceFollowRedirects(false);
			HttpURLConnection.setFollowRedirects(true);

			MY_LOGGER.info("HTTP GET " + url + " ...");
			con = (HttpURLConnection) url.openConnection();

			// CODIGO de RESPUESTA
			int status = con.getResponseCode();
			if (status == HttpURLConnection.HTTP_MOVED_TEMP || status == HttpURLConnection.HTTP_MOVED_PERM) {
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
			MY_LOGGER.debug("Path fichero salida: " + pathOut);
			Files.write(Paths.get(pathOut), content.toString().getBytes());

		} catch (IOException e) {
			MY_LOGGER.error("Error:" + e.getMessage());
			e.printStackTrace();
		}

		MY_LOGGER.debug("FIN");

	}

	// public static void main(String[] args) {
	//
	// StringBuffer content = new StringBuffer();
	// content.append("cadena");
	//
	// MY_LOGGER.debug("GALGOS-GbgbDownloader: Escribiendo a fichero...");
	// MY_LOGGER.debug("StringBuffer con " + content.length() + " elementos de
	// 16-bits)");
	// MY_LOGGER.debug("Path fichero salida: "+pathOut);
	// Files.write(Paths.get(pathOut), content.toString().getBytes());
	//
	// }

}