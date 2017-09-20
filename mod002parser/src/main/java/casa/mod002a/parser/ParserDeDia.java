package casa.mod002a.parser;

import java.io.IOException;
import java.nio.charset.Charset;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.logging.Level;
import java.util.logging.Logger;

import utilidades.Constantes;
import utilidades.MiFormateador;

public abstract class ParserDeDia implements ParserDeDiaAPI {

	public static Logger MY_LOGGER = Logger.getLogger(Thread.currentThread().getStackTrace()[0].getClassName());;


	/**
	 * @param TAG_DIA
	 */
	public void ejecutar(String TAG_DIA) {

		MY_LOGGER.info("Parser: INICIO");

		String bruto = "";
		String out = "";

		try {
			String pathEntrada = Constantes.PATH_DIR_DATOS_BRUTOS + getPathEntrada(TAG_DIA);
			bruto = readFile(pathEntrada, Charset.forName("ISO-8859-1"));
			out = parsear(TAG_DIA, bruto);
			// MY_LOGGER.info("ParserDeDia: out=" + out);

			String pathSalida = Constantes.PATH_DIR_DATOS_LIMPIOS + getPathEntrada(TAG_DIA) + Constantes.OUT;

			MY_LOGGER.info("Escribiendo hacia " + pathSalida + " ...");
			Files.write(Paths.get(pathSalida), out.getBytes());

		} catch (IOException e) {
			MY_LOGGER.log(Level.SEVERE, "Error:" + e.getMessage());
			e.printStackTrace();
		}

		MY_LOGGER.info("Parser: FIN");

	}

	/**
	 * Lee fichero desde Sistema de ficheros local.
	 * 
	 * @param path
	 * @param encoding
	 * @return
	 * @throws IOException
	 */
	public String readFile(String path, Charset encoding) throws IOException {

		MY_LOGGER.info("Leyendo " + path + " ...");
		byte[] encoded = Files.readAllBytes(Paths.get(path));
		return new String(encoded, encoding);
	}

}
