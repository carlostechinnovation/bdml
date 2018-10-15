/**
 * 
 */
package casa.galgos.weather;

import java.io.IOException;
import java.io.Serializable;
import java.nio.charset.Charset;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.Calendar;

import org.apache.log4j.Logger;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;

/**
 *
 */
public class AccuweatherParser implements Serializable {

	private static final long serialVersionUID = 1L;

	static Logger MY_LOGGER = Logger.getLogger(AccuweatherParser.class);

	public AccuweatherParser() {
		super();
	}

	/**
	 * 
	 * 
	 * @param pathBrutaIn
	 * @param carreraIn
	 * @return Instancia
	 */
	public AccuweatherParseado ejecutar(String pathBrutaIn) {

		MY_LOGGER.debug("GALGOS-AccuweatherParser: INICIO");

		AccuweatherParseado out = null;
		String contenidoBruto = "";

		try {
			contenidoBruto = AccuweatherParser.readFile(pathBrutaIn, Charset.forName("ISO-8859-15"));
			if (contenidoBruto == null || contenidoBruto.isEmpty()) {
				MY_LOGGER.error("GALGOS-WEATHER - Contenido vacio: " + pathBrutaIn);
			} else {
				out = parsear(contenidoBruto, pathBrutaIn);
			}

		} catch (Exception e) {
			MY_LOGGER.error("Error: " + e.getMessage());
			e.printStackTrace();
		}

		MY_LOGGER.debug("GALGOS-AccuweatherParser: FIN");
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
		MY_LOGGER.info("Bytes leidos: " + encoded.length);
		return new String(encoded, encoding);

//		BufferedReader br = new BufferedReader(new FileReader(path));
//		String st = "", out = "";
//		while ((st = br.readLine()) != null) {
//			out += st;
//		}
//		br.close();
//		MY_LOGGER.info("Fichero total leido tiene " + out.length() + " caracteres");
//		return out;
	}

	/**
	 * Extrae info util.
	 * 
	 * @param in
	 * @param pathBrutaIn
	 * @return Modelo de web bruta parseada (contiene dias parseados).
	 * @throws Exception
	 */
	protected static AccuweatherParseado parsear(String in, String pathBrutaIn) throws Exception {

		MY_LOGGER.info("AccuweatherParseado - parsear -> IN tiene " + in.length() + " caracteres");
		MY_LOGGER.info("AccuweatherParseado - parsear -> pathBrutaIn: " + pathBrutaIn);

		AccuweatherParseado out = new AccuweatherParseado();

		Document doc = Jsoup.parse(in);
		Elements tablaDeDias = doc.getElementsByClass("calendar calendar-block ");

		Elements semanas = tablaDeDias.get(0).children().get(1).children();

		for (Element semana : semanas) {
			for (Element dia : semana.children()) {
				parsearDia(dia, out, pathBrutaIn);
			}
		}

		// Anio y mes
		String[] partes = pathBrutaIn.split("/");
		String nombre_fichero = partes[partes.length - 1];
		out.anio = Integer.valueOf(nombre_fichero.split("_")[0]);
		out.mes = Integer.valueOf(nombre_fichero.split("_")[1]);
		out.estadio = (nombre_fichero.split("_")[2]).split("\\.")[0];

		MY_LOGGER.info("GALGOS-WEATHER - Numero de elementos EXTRAIDOS (dias parseados) de la web bruta: "
				+ out.diasParseados.size());
		return out;
	}

	/**
	 * @param dia
	 * @param out
	 * @param pathBrutaIn
	 * @throws Exception
	 */
	protected static void parsearDia(Element dia, AccuweatherParseado out, String pathBrutaIn) throws Exception {

		AccuweatherDiaParseado adp = new AccuweatherDiaParseado();
		Integer mesDelFicheroEntrada = -1;

		Elements fechayContenido = dia.children().get(0).children();

		for (Element item : fechayContenido) {

			if (item.hasClass("date")) {

				String str1 = item.text();

				if (str1.contains(" ")) {
					String mesDia = str1.split(" ")[1];
					String[] mesDiaArr = mesDia.split("/");
					String mesStr = mesDiaArr[0];
					String diaStr = mesDiaArr[1];

					String[] partes = pathBrutaIn.split("/");
					String nombre_fichero = partes[partes.length - 1];
					String anioStr = nombre_fichero.split("_")[0];
					mesDelFicheroEntrada = Integer.valueOf(nombre_fichero.split("_")[1]);

					adp.anio = Integer.valueOf(anioStr);
					adp.mes = Integer.valueOf(mesStr);
					adp.dia = Integer.valueOf(diaStr);

				} else {

					if (str1.equalsIgnoreCase("Yesterday")) {
						Calendar cal = Calendar.getInstance();
						cal.setTimeInMillis(cal.getTimeInMillis() - 1000 * 24 * 60 * 60);// Ayer: resto 1 dia

						adp.anio = cal.get(Calendar.YEAR);
						adp.mes = cal.get(Calendar.MONTH) + 1;
						adp.dia = cal.get(Calendar.DAY_OF_MONTH);
					}

				}

			} else if (item.hasClass("info")) {

				for (Element itemInfo : item.children()) {
					Elements itemsInfoCh = itemInfo.children();

					if (itemsInfoCh != null && !itemsInfoCh.isEmpty()) {

						// Temperatura predicha
						if (itemsInfoCh.toString().contains("Actual")) {
							adp.real = true; // pasada

							for (Element iice : itemsInfoCh) {

								String tempMaxStr = null;
								String tempMinStr = null;

								// Temperatura real
								if (iice.toString().contains("large-temp")) {

									for (Element realch : iice.children()) {
										if (realch.hasClass("large-temp")) {

											tempMaxStr = realch.text().replace("Â", "").replace("°", "");
											if (tempMaxStr != null && !tempMaxStr.isEmpty()) {
												adp.tempMax = Integer.valueOf(tempMaxStr);
											}

										} else if (realch.hasClass("small-temp")) {
											tempMinStr = realch.text().replace("/", "").replace("Â", "").replace("°",
													"");
											if (tempMinStr != null && !tempMinStr.isEmpty()) {
												adp.tempMin = Integer.valueOf(tempMinStr);
											}
										}
									}
								}

							}

						} else if (itemsInfoCh.size() == 1 && itemsInfoCh.toString().contains("large-temp")) { // FUTURA
																												// (cercana)
							adp.real = false; // futura
							String tempMaxStr = itemsInfoCh.text().replace("Â", "").replace("°", "");
							if (tempMaxStr != null && !tempMaxStr.isEmpty()) {
								adp.tempMax = Integer.valueOf(tempMaxStr);
							}
						} else if (itemsInfoCh.size() == 1 && itemsInfoCh.toString().contains("small-temp")) { // FUTURA
																												// (cercana)
							adp.real = false; // futura
							String tempMinStr = itemsInfoCh.text().replace("Â", "").replace("°", "");
							if (tempMinStr != null && !tempMinStr.isEmpty()) {
								adp.tempMin = Integer.valueOf(tempMinStr);
							}
						} else if (itemsInfoCh.size() == 2 && itemsInfoCh.toString().contains("large-temp")) { // FUTURA
																												// (cercana)
							adp.real = false; // futura

							for (Element realch : itemsInfoCh) {
								if (realch.hasClass("large-temp")) {

									String tempMaxStr = realch.text().replace("Â", "").replace("°", "");
									if (tempMaxStr != null && !tempMaxStr.isEmpty()) {
										adp.tempMax = Integer.valueOf(tempMaxStr);
									}

								} else if (realch.hasClass("small-temp")) {
									String tempMinStr = realch.text().replace("/", "").replace("Â", "").replace("°",
											"");
									if (tempMinStr != null && !tempMinStr.isEmpty()) {
										adp.tempMin = Integer.valueOf(tempMinStr);
									}
								}
							}
						}

						if (itemsInfoCh.toString().contains("cond")) {
							MY_LOGGER.warn("WEATHER - cond ->" + itemsInfoCh.toString() + " (Debo parsearlo!!)");
						}

						if (itemsInfoCh.toString().contains("Hist")) {

							for (Element iice : itemsInfoCh) {
								String histTempMaxStr = null;
								String histTempMinStr = null;

								if (iice.children().isEmpty() && iice.hasClass("temp")) {

									histTempMaxStr = iice.text().replace("Â", "").replace("°", "").trim();

									if (histTempMaxStr != null && !histTempMaxStr.isEmpty()) {
										adp.historicAvgMax = Integer.valueOf(histTempMaxStr);

									}

								} else if (iice.children().isEmpty() && iice.hasClass("lo")) {
									histTempMinStr = iice.text().replace("/", "").replace("Â", "").replace("°", "")
											.trim();

									if (histTempMinStr != null && !histTempMinStr.isEmpty()) {
										adp.historicAvgMin = Integer.valueOf(histTempMinStr);
									}

								} else if (iice.children().size() == 2 && iice.hasClass("temp")) {

									for (Element iicee : iice.children()) {
										histTempMaxStr = iice.children().get(0).text().replace("Â", "").replace("°", "")
												.trim();
										if (histTempMaxStr != null && !histTempMaxStr.isEmpty()) {
											adp.historicAvgMax = Integer.valueOf(histTempMaxStr);
										}

										histTempMinStr = iice.children().get(1).text().replace("/", "").replace("Â", "")
												.replace("°", "").trim();

										if (histTempMinStr != null && !histTempMinStr.isEmpty()) {
											adp.historicAvgMin = Integer.valueOf(histTempMinStr);
										}
									}

								}
							}

						}

					}

				}

			}

		}

		if (adp.minimoRelleno()) {
			if (mesDelFicheroEntrada.intValue() == adp.mes.intValue()) {
				out.diasParseados.add(adp);
			}

		} else {
			MY_LOGGER.error("GALGOS-WEATHER - Dia MAL parseado en: " + pathBrutaIn);
		}
	}

}
