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
import java.util.logging.Level;
import java.util.logging.Logger;

import utilidades.Constantes;

/**
 *
 */
public class GbgbDownloader {

	public GbgbDownloader() {
		super();
	}

	private static Logger MY_LOGGER = Logger.getLogger(Thread.currentThread().getStackTrace()[0].getClassName());

	/**
	 * @param pathOut
	 *            Path absoluto donde guardar el fichero bruto descargado
	 * @param borrarSiExiste
	 *            Borrar fichero destino, si ya existe.
	 */
	public void descargarCarreras(String pathOut, Boolean borrarSiExiste) {

		MY_LOGGER.info("GALGOS-GbgbDownloader: INICIO");
		MY_LOGGER.info("GALGOS-GbgbDownloader - pathOut=" + pathOut);
		MY_LOGGER.info("GALGOS-GbgbDownloader - borrarSiExiste=" + borrarSiExiste);

		try {

			MY_LOGGER.info("Borrando fichero de salida preexistente " + pathOut + " ...");
			if (Files.exists(Paths.get(pathOut))) {
				MY_LOGGER.warning("El fichero ya existe. Lo borramos para crear el nuevo: " + pathOut);
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

			MY_LOGGER.info("GALGOS-GbgbDownloader: HTTP GET " + url + " ...");
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
			MY_LOGGER.info("GALGOS-GbgbDownloader: Escribiendo a fichero...");
			MY_LOGGER.info("StringBuffer con " + content.length() + " elementos de 16-bits)");
			MY_LOGGER.info("Path fichero salida: " + pathOut);
			Files.write(Paths.get(pathOut), content.toString().getBytes());

		} catch (IOException e) {
			MY_LOGGER.log(Level.SEVERE, "Error:" + e.getMessage());
			e.printStackTrace();
		}

		MY_LOGGER.info("GALGOS-GbgbDownloader: FIN");

	}

	// public class ParameterStringBuilder {
	//
	//
	// public static String getParamsString(Map<String, String> params) throws
	// UnsupportedEncodingException {
	// StringBuilder result = new StringBuilder();
	//
	// for (Map.Entry<String, String> entry : params.entrySet()) {
	// result.append(URLEncoder.encode(entry.getKey(), "UTF-8"));
	// result.append("=");
	// result.append(URLEncoder.encode(entry.getValue(), "UTF-8"));
	// result.append("&");
	// }
	//
	// String resultString = result.toString();
	// return resultString.length() > 0 ? resultString.substring(0,
	// resultString.length() - 1) : resultString;
	// }
	//
	//
	// }

	/**
	 * @param pathOut
	 * @param borrarSiExiste
	 */
	public void descargarCarreraDetalle(String urlCarrera, String pathOut, Boolean borrarSiExiste) {

		MY_LOGGER.info("GALGOS-GbgbDownloader.descargarCarreraDetalle:  " + urlCarrera);
		MY_LOGGER.info("GALGOS-GbgbDownloader - pathOut=" + pathOut);
		MY_LOGGER.info("GALGOS-GbgbDownloader - borrarSiExiste=" + borrarSiExiste);

		try {

			MY_LOGGER.info("Borrando fichero de salida preexistente " + pathOut + " ...");
			if (Files.exists(Paths.get(pathOut))) {
				MY_LOGGER.warning("El fichero ya existe. Lo borramos para crear el nuevo: " + pathOut);
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

			MY_LOGGER.info("GALGOS-GbgbDownloader: HTTP GET " + url + " ...");
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
			MY_LOGGER.info("GALGOS-GbgbDownloader: Escribiendo a fichero...");
			MY_LOGGER.info("StringBuffer con " + content.length() + " elementos de 16-bits)");
			MY_LOGGER.info("Path fichero salida: " + pathOut);
			Files.write(Paths.get(pathOut), content.toString().getBytes());

		} catch (IOException e) {
			MY_LOGGER.log(Level.SEVERE, "Error:" + e.getMessage());
			e.printStackTrace();
		}

		MY_LOGGER.info("GALGOS-GbgbDownloader: FIN");

	}

	/**
	 * Descarga y guarda la WEB del historico de un galgo.
	 * 
	 * @param urlHistoricoGalgo
	 * @param pathOut
	 * @param borrarSiExiste
	 */
	public void descargarHistoricoGalgo(String urlHistoricoGalgo, String pathOut, Boolean borrarSiExiste) {

		MY_LOGGER.info("GALGOS-GbgbDownloader.descargarHistoricoGalgo:  ");
		MY_LOGGER.info("GALGOS-GbgbDownloader - urlCarrera=" + urlHistoricoGalgo);
		MY_LOGGER.info("GALGOS-GbgbDownloader - pathOut=" + pathOut);
		MY_LOGGER.info("GALGOS-GbgbDownloader - borrarSiExiste=" + borrarSiExiste);

		try {

			MY_LOGGER.info("Borrando fichero de salida preexistente " + pathOut + " ...");
			if (Files.exists(Paths.get(pathOut))) {
				MY_LOGGER.warning("El fichero ya existe. Lo borramos para crear el nuevo: " + pathOut);
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

			MY_LOGGER.info("GALGOS-GbgbDownloader: HTTP GET " + url + " ...");
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
			MY_LOGGER.info("GALGOS-GbgbDownloader: Escribiendo a fichero...");
			MY_LOGGER.info("StringBuffer con " + content.length() + " elementos de 16-bits)");
			MY_LOGGER.info("Path fichero salida: " + pathOut);
			Files.write(Paths.get(pathOut), content.toString().getBytes());

		} catch (IOException e) {
			MY_LOGGER.log(Level.SEVERE, "Error:" + e.getMessage());
			e.printStackTrace();
		}

		MY_LOGGER.info("GALGOS-GbgbDownloader: FIN");

	}

	// public static void main(String[] args) {
	//
	// StringBuffer content = new StringBuffer();
	// content.append("cadena");
	//
	// MY_LOGGER.info("GALGOS-GbgbDownloader: Escribiendo a fichero...");
	// MY_LOGGER.info("StringBuffer con " + content.length() + " elementos de
	// 16-bits)");
	// MY_LOGGER.info("Path fichero salida: "+pathOut);
	// Files.write(Paths.get(pathOut), content.toString().getBytes());
	//
	// }

}