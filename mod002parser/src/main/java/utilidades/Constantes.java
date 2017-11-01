package utilidades;

import java.util.Calendar;

public class Constantes {

	public static final String PATH_DIR_DATOS_BRUTOS_BOLSA = "/home/carloslinux/Desktop/DATOS_BRUTO/bolsa/";
	public static final String PATH_DIR_DATOS_LIMPIOS_BOLSA = "/home/carloslinux/Desktop/DATOS_LIMPIO/bolsa/";

	public static final String BOE_IN = "BOE_in";
	public static final String BOE_OUT = "BOE_out";

	public static final String GF = "_GOOGLEFINANCE_";
	public static final String BM = "_BOLSAMADRID_";
	public static final String INE = "_INE_";
	public static final String DATOSMACRO = "_DATOSMACRO_";

	public static final String OUT = "_OUT";

	public static final String PATH_DIR_DATOS_BRUTOS_GALGOS = "/home/carloslinux/Desktop/DATOS_BRUTO/galgos/";
	public static final String PATH_DIR_DATOS_LIMPIOS_GALGOS = "/home/carloslinux/Desktop/DATOS_LIMPIO/galgos/";
	public static final String GALGOS_GBGB = "http://www.gbgb.org.uk";
	public static final String GALGOS_GBGB_CARRERAS = GALGOS_GBGB + "/Results.aspx";
	public static final String GALGOS_GBGB_CARRERA_DETALLE_PREFIJO = GALGOS_GBGB + "/resultsRace.aspx?id=";
	public static final Integer GALGOS_UMBRAL_DIAS_CARRERAS_ANTERIORES = 6 * 30; // Solo cogemos las carreras de los
																					// últimos 6 meses
	public static final Integer MAX_NUM_CARRERAS_PROCESADAS = 500;
	public static final Long ESPERA_ENTRE_DESCARGA_CARRERAS_MSEC = 1 * 1000L;

	public static final String SEPARADOR_CAMPO = "|";
	public static final String SEPARADOR_FILA = "\n";

	public static final String[] DM_PAISES_INTERESANTES = { "España", "Alemania", "Francia", "Zona Euro",
			"Estados Unidos", "Brasil", "Rusia" };

	public static final int BM03_LONGITUD_TRUNCATE = 255;

	/**
	 * @param in
	 * @param longitudMax
	 * @return
	 */
	public static String truncar(String in, int longitudMax) {
		int maxLength = (in.length() < longitudMax) ? in.length() : longitudMax;
		return in.substring(0, maxLength);
	}

	/**
	 * @param in
	 * @param tipo
	 *            1-String, 2-Decimal
	 * @return
	 */
	public static String tratar(String in, int tipo) {
		if (tipo == 1) {
			return in.replace(Constantes.SEPARADOR_CAMPO, "").replace(Constantes.SEPARADOR_FILA, "");
		} else if (tipo == 2) {
			return in.replace(".", "").replace(",", ".").replace(Constantes.SEPARADOR_CAMPO, "")
					.replace(Constantes.SEPARADOR_FILA, "");
		} else {
			return in.replace(Constantes.SEPARADOR_CAMPO, "").replace(Constantes.SEPARADOR_FILA, "");
		}
	}

	/**
	 * @param fechaSrt
	 *            22/10/17
	 * @param horaStr
	 *            19:54
	 * @return
	 */
	public static Calendar parsearFechaHora(String fechaStr, String horaStr, boolean anioIncompleto) {

		Integer dia = Integer.valueOf(fechaStr.trim().substring(0, 2));
		Integer mes = Integer.valueOf(fechaStr.trim().substring(3, 5));
		Integer anio = anioIncompleto ? (2000 + Integer.valueOf(fechaStr.trim().substring(6, 8)))
				: Integer.valueOf(fechaStr.trim().substring(6, 10));

		Integer hora = Integer.valueOf(horaStr.trim().substring(0, 2));
		Integer minuto = Integer.valueOf(horaStr.trim().substring(3, 5));

		Calendar fechayhora = Calendar.getInstance();
		fechayhora.clear();
		fechayhora.set(Calendar.YEAR, anio);
		fechayhora.set(Calendar.MONTH, mes);
		fechayhora.set(Calendar.DAY_OF_MONTH, dia);
		fechayhora.set(Calendar.HOUR_OF_DAY, hora);
		fechayhora.set(Calendar.MINUTE, minuto);

		return fechayhora;
	}

}