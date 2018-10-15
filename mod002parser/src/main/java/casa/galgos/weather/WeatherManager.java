package casa.galgos.weather;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

import org.apache.log4j.Logger;

/**
 * Gestor de descarga y parseo de datos sobre WEATHER.
 *
 */
public class WeatherManager implements Serializable {

	private static final long serialVersionUID = 1L;

	static Logger MY_LOGGER = Logger.getLogger(WeatherManager.class);

	private AccuweatherParser parser;

	// --- SINGLETON
	private static WeatherManager instancia;

	private WeatherManager() {
	}

	public static WeatherManager getInstancia() {
		if (instancia == null) {
			instancia = new WeatherManager();
			instancia.parser = new AccuweatherParser();
		}
		return instancia;
	}

	/**
	 * Entrada: folder (contiene las paginas web en bruto)
	 * 
	 * Salida: fichero con sentencias INSERT INTO, separadas por ';' para //
	 * ejecutarlas secuencialmente
	 * 
	 * @param pathBrutoWeather
	 * @param fileWeatherLimpioInsertInto
	 * @throws Exception
	 */
	public void parsearWebBrutas(String pathBrutoWeather, String fileWeatherLimpioInsertInto) throws Exception {

		MY_LOGGER.info(
				"Parseando cada web de weather. Para cada web, el resultado son varios INSERT INTO en el fichero limpio...");
		MY_LOGGER.info("[PBW] --> " + pathBrutoWeather);
		MY_LOGGER.info("[FWLII] --> " + fileWeatherLimpioInsertInto);

		File dir = new File(pathBrutoWeather);
		File[] directoryListing = dir.listFiles();
		if (directoryListing != null && directoryListing.length > 0) {

			MY_LOGGER.info("[PBW] contiene " + directoryListing.length + " paginas web brutas");
			List<AccuweatherParseado> websParseadas = new ArrayList<AccuweatherParseado>();

			for (File pathWebBruta : directoryListing) {
				MY_LOGGER.info("Weather - Parseando: " + pathWebBruta.getAbsolutePath());
				AccuweatherParseado filaNueva = parser.ejecutar(pathWebBruta.getAbsolutePath());

				if (filaNueva == null) {
					MY_LOGGER.error("FWLII - Problema al parsear:" + pathWebBruta.getAbsolutePath());
				} else {
					websParseadas.add(filaNueva);
				}
			}

			boolean modoAppend = true;
			BufferedWriter writer = new BufferedWriter(new FileWriter(fileWeatherLimpioInsertInto, modoAppend));

			int numSentenciasSqlSobreDiasEscritas = 0;

			for (AccuweatherParseado webParseada : websParseadas) {

				if (webParseada == null || webParseada.diasParseados == null || webParseada.diasParseados.isEmpty()) {
					MY_LOGGER.error("FWLII - Web problematica en indice:" + websParseadas.indexOf(webParseada));

				} else {

					// Por cada DIA
					for (AccuweatherDiaParseado adp : webParseada.diasParseados) {
						writer.append(adp.generarInsertorUpdate(webParseada.estadio) + "\n");
						numSentenciasSqlSobreDiasEscritas++;
					}

					// SENTENCIA SQL que indica que el mes ENTERO es del pasado y lo he procesado
					// entero. Evito descargarlo en el futuro.
					if (webParseada.sonTodosCompletosYPasados()) {

						String consultaUpdateWeam = "REPLACE INTO datos_desa.tb_galgos_weam SELECT estadio,anio,mes,url_descarga_fecha, true AS descargado FROM datos_desa.tb_galgos_weam WHERE ";
						consultaUpdateWeam += "estadio='" + webParseada.estadio + "' ";
						consultaUpdateWeam += "AND anio=" + webParseada.anio + " ";
						consultaUpdateWeam += "AND mes=" + webParseada.mes + ";";

						MY_LOGGER.info("FWLII - El mes esta completo y pasado (" + webParseada.estadio
								+ webParseada.anio + "-" + webParseada.mes + "). Lo marcamos!!");
						writer.append(consultaUpdateWeam + "\n");

					} else {
						MY_LOGGER.info("FWLII - El mes todavia NO esta completo+pasado (" + webParseada.estadio
								+ webParseada.anio + "-" + webParseada.mes
								+ "). Lo dejamos como NO descargado completamente.");
					}
				}

			}

			MY_LOGGER.info(
					"FWLII - Se han escrito " + numSentenciasSqlSobreDiasEscritas + " sentencias SQL en el fichero");

			// Cerrar fichero
			writer.close();

		} else {
			MY_LOGGER.error("[PBW] no es un directorio!!!");
		}
	}

}
