package casa.galgos.weather;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

import org.apache.log4j.Logger;

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

			MY_LOGGER.info("[PBW] contiene " + pathBrutoWeather + " paginas web brutas");
			List<AccuweatherParseado> websParseadas = new ArrayList<AccuweatherParseado>();

			for (File pathWebBruta : directoryListing) {
				MY_LOGGER.info("Weather - Parseando: " + pathWebBruta.getAbsolutePath());
				websParseadas.add(parser.ejecutar(pathWebBruta.getAbsolutePath()));

			}

			boolean modoAppend = true;
			BufferedWriter writer = new BufferedWriter(new FileWriter(fileWeatherLimpioInsertInto, modoAppend));
			int numSentenciasSqlEscritas = 0;

			for (AccuweatherParseado webParseada : websParseadas) {
				for (AccuweatherDiaParseado adp : webParseada.diasParseados) {
					writer.append(adp.generarInsertorUpdate() + "\n");
					numSentenciasSqlEscritas++;
				}
			}

			MY_LOGGER.info("FWLII - Se han escrito " + numSentenciasSqlEscritas + " sentencias SQL en el fichero");

			// Cerrar fichero
			writer.close();

		} else {
			MY_LOGGER.error("[PBW] no es un directorio!!!");
		}
	}

}
