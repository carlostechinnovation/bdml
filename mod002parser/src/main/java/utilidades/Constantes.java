package utilidades;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.Calendar;
import java.util.Collections;
import java.util.Comparator;
import java.util.GregorianCalendar;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

public class Constantes {

	// -------------- COMUNES --------
	public static final String SEPARADOR_CAMPO = "|";
	public static final String SEPARADOR_FILA = "\n";

	// -------------- GALGOS --------
	public static final String PATH_DIR_DATOS_BRUTOS_GALGOS = "/home/carloslinux/Desktop/DATOS_BRUTO/galgos/";
	public static final String PATH_DIR_DATOS_LIMPIOS_GALGOS = "/home/carloslinux/Desktop/DATOS_LIMPIO/galgos/";
	public static final String GALGOS_GBGB = "http://www.gbgb.org.uk";
	public static final String GALGOS_GBGB_CARRERAS = GALGOS_GBGB + "/Results.aspx";
	public static final String GALGOS_GBGB_CARRERA_DETALLE_PREFIJO = GALGOS_GBGB + "/resultsRace.aspx?id=";
	public static final String GALGOS_GBGB_HISTORICO_GALGO = GALGOS_GBGB + "/RaceCard.aspx?dogName=";
	public static final Integer GALGOS_UMBRAL_DIAS_CARRERAS_ANTERIORES = 20 * 7;// Ultimas X semanas
	public static final String GALGOS_SPORTIUM_PREFIJO = "https://sport-mobile.sportium.es";
	public static final String GALGOS_FUTUROS_SPORTIUM = GALGOS_SPORTIUM_PREFIJO + "/es/s/GREY/Galgos";
	public static final String GALGOS_BETBRIGHT_PREFIJO = "https://www.betbright.com";
	public static final String GALGOS_FUTUROS_BETBRIGHT = GALGOS_BETBRIGHT_PREFIJO + "/greyhound-racing";
	public static final String GALGOS_FUTUROS_BETBRIGHT_TODAY = GALGOS_FUTUROS_BETBRIGHT + "/today";
	public static final String GALGOS_FUTUROS_BETBRIGHT_TOMORROW = GALGOS_FUTUROS_BETBRIGHT + "/tomorrow";
	public static final boolean GALGOS_FUTUROS_BETBRIGHT_DESCARGAR_DESDE_JAVA = false; // como me banean, lo descargo
																						// desde fuera con un script

	public static final Integer GALGOS_FUTUROS_BETBRIGHT_CARRERAGALGOS_MAX = 10;// util para debuguear con pocos casos.
																				// Normalmente será 100000

	public static final Integer NUM_APARICION_REMARKS_RELEVANTES = 35;

	public static final Integer MAX_NUM_CARRERAS_SEMILLA = 50; // SOLO ESTUDIAMOS LOS GALGOS DE ESTAS CARRERAS (y las
																// derivadas)
	public static final Integer MAX_NUM_CARRERAS_PROCESADAS = 3000;
	public static final Integer MAX_PROFUNDIDAD_PROCESADA = 2;
	public static final Long ESPERA_ENTRE_DESCARGA_CARRERAS_MSEC = 1 * 50L;
	public static final Integer MAX_NUM_FILAS_EN_MEMORIA_SIN_ESCRIBIR_EN_FICHERO = 200;
	public static final Integer MAX_NUM_REMARKS_MEMORIZADAS = 100;
	public static final Integer MIN_PESO_GALGO = 15;// kg

	// -------------- BOLSA --------
	public static final String PATH_DIR_DATOS_BRUTOS_BOLSA = "/home/carloslinux/Desktop/DATOS_BRUTO/bolsa/";
	public static final String PATH_DIR_DATOS_LIMPIOS_BOLSA = "/home/carloslinux/Desktop/DATOS_LIMPIO/bolsa/";
	public static final String BOE_IN = "BOE_in";
	public static final String BOE_OUT = "BOE_out";
	public static final String GF = "_GOOGLEFINANCE_";
	public static final String BM = "_BOLSAMADRID_";
	public static final String INE = "_INE_";
	public static final String DATOSMACRO = "_DATOSMACRO_";
	public static final String OUT = "_OUT";

	public static final String[] DM_PAISES_INTERESANTES = { "España", "Alemania", "Francia", "Zona Euro",
			"Estados Unidos", "Brasil", "Rusia" };

	public static final int BM03_LONGITUD_TRUNCATE = 255;

	// --------------------------------------

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
		Integer mes = Integer.valueOf(fechaStr.trim().substring(3, 5)) - 1;
		Integer anio = anioIncompleto ? (2000 + Integer.valueOf(fechaStr.trim().substring(6, 8)))
				: Integer.valueOf(fechaStr.trim().substring(6, 10));

		Integer hora = Integer.valueOf(horaStr.trim().substring(0, 2));
		Integer minuto = Integer.valueOf(horaStr.trim().substring(3, 5));

		return new GregorianCalendar(anio, mes, dia, hora, minuto, 0);
	}

	/**
	 * @param fechaStr
	 * @param anioIncompleto
	 * @return
	 */
	public static Calendar parsearFecha(String[] fechaStr, boolean anioIncompleto) {

		Integer anio = anioIncompleto ? (2000 + Integer.valueOf(fechaStr[2])) : Integer.valueOf(fechaStr[2]);
		Integer mes = Integer.valueOf(fechaStr[1]) - 1;
		Integer dia = Integer.valueOf(fechaStr[0]);

		return new GregorianCalendar(anio, mes, dia, 10, 0, 0);
	}

	/**
	 * @param in
	 * @return
	 */
	public static String limpiarTexto(String in) {
		return in.replace(SEPARADOR_CAMPO, "").replace(SEPARADOR_FILA, "").replace("Â", "").replace("$nbsp", "")
				.replace(" ", "").trim();
	}

	/**
	 * Limpia el dato de entrada, que es el nombre de un entrenador.
	 * 
	 * @param in
	 * @return Nombre del entrenador en MAYUSCULAS. En caso de que la entrada sea
	 *         null, vacío o 'unknown', la salida es null.
	 */
	public static String limpiarEntrenador(String in) {
		String aux = (in != null) ? in.trim() : null;

		String out = null;
		if (aux != null && aux != "unknown") {
			out = aux.toUpperCase();
		}
		return out;
	}

	/**
	 * @param val
	 * @param decimales
	 *            Numero de decimales
	 * @return
	 */
	public static Float round2(Float val, int decimales) {

		Float out = null;
		if (val != null && !val.isInfinite()) {
			out = new BigDecimal(val.toString()).setScale(decimales, RoundingMode.HALF_UP).floatValue();
		}

		return out;
	}

	/**
	 * Ordena un mapa por VALORES.
	 * 
	 * Link:
	 * https://beginnersbook.com/2013/12/how-to-sort-hashmap-in-java-by-keys-and-values/
	 * 
	 * @param map
	 * @return
	 */
	public static Map sortByValues(Map map) {

		List list = new LinkedList(map.entrySet());
		// Defined Custom Comparator here
		Collections.sort(list, new Comparator() {
			@Override
			public int compare(Object o1, Object o2) {
				return ((Comparable) ((Map.Entry) (o1)).getValue()).compareTo(((Map.Entry) (o2)).getValue());
			}
		});

		// Here I am copying the sorted list in HashMap
		// using LinkedHashMap to preserve the insertion order
		HashMap sortedHashMap = new LinkedHashMap();
		for (Iterator it = list.iterator(); it.hasNext();) {
			Map.Entry entry = (Map.Entry) it.next();
			sortedHashMap.put(entry.getKey(), entry.getValue());
		}
		return sortedHashMap;
	}

	/**
	 * @return Mapa con las puntuaciones de los comentarios sobre un galgos en una
	 *         carrera. Son buenos (puntos>0) o neturos (puntos=0) o malos
	 *         (puntos<0).
	 */
	public static Map<String, GalgosRemark> generarDiccionarioRemarks() {

		Map<String, GalgosRemark> mapa = new HashMap<String, GalgosRemark>();

		mapa.put("Aw", new GalgosRemark("Aw", "Away", 0));
		mapa.put("Awk", new GalgosRemark("Awk", "Awkard", 0));
		mapa.put("Ap", new GalgosRemark("Ap", "April", 0));
		mapa.put("Au", new GalgosRemark("Au", "August", 0));
		mapa.put("B", new GalgosRemark("B", "Badly", 0));
		mapa.put("b", new GalgosRemark("b", "Bitch", 0));
		mapa.put("bd", new GalgosRemark("bd", "Brindle", 0));
		mapa.put("be", new GalgosRemark("be", "Blue", 0));
		mapa.put("Blk", new GalgosRemark("Blk", "Black", 0));
		mapa.put("Bmp", new GalgosRemark("Bmp", "Bumped", 0));
		mapa.put("Brk", new GalgosRemark("Brk", "Break", 0));
		mapa.put("By", new GalgosRemark("By", "Won or lost by", 0));
		mapa.put("Calc", new GalgosRemark("Calc", "Calculated", 0));
		mapa.put("CalcTm", new GalgosRemark("CalcTm", "The time of victory on a standard track", 0));
		mapa.put("ChL", new GalgosRemark("ChL", "Challenged", 0));
		mapa.put("Clr", new GalgosRemark("Clr", "Clear", 0));
		mapa.put("CmSg", new GalgosRemark("CmSg", "Came Again", 0));
		mapa.put("Crd", new GalgosRemark("Crd", "Crowded", 0));
		mapa.put("cWinTm", new GalgosRemark("cWinTm", "The actual time taken to win the race", 0));
		mapa.put("De", new GalgosRemark("De", "December", 0));
		mapa.put("DH", new GalgosRemark("DH", "Dead Heat", 0));
		mapa.put("Dis", new GalgosRemark("Dis", "The race distance", 0));
		mapa.put("Disp", new GalgosRemark("Disp", "Disputed", 0));
		mapa.put("Disq", new GalgosRemark("Disq", "Disqualified", 0));
		mapa.put("dk", new GalgosRemark("dk", "Dark", 0));
		mapa.put("DNF", new GalgosRemark("DNF", "Did not finish.", 0));
		mapa.put("E", new GalgosRemark("E", "Early", 0));
		mapa.put("EvCh", new GalgosRemark("EvCh", "Every Chance", 0));
		mapa.put("F", new GalgosRemark("F", "Favourite", 0));
		mapa.put("f", new GalgosRemark("f", "Fawn", 0));
		mapa.put("Fb", new GalgosRemark("Fb", "February", 0));
		mapa.put("Fd", new GalgosRemark("Fd", "Faded", 0));
		mapa.put("Fght", new GalgosRemark("Fght", "Fought", 0));
		mapa.put("Fin", new GalgosRemark("Fin", "Finished", 0));
		mapa.put("FlsHt", new GalgosRemark("FlsHt", "False Heat", 0));
		mapa.put("Fr", new GalgosRemark("Fr", "From", 0));
		mapa.put("G’ng", new GalgosRemark("G’ng", "Track going", 0));
		mapa.put("H", new GalgosRemark("H", "Hurdles", 0));
		mapa.put("Hcp", new GalgosRemark("Hcp", "Handicap", 0));
		mapa.put("Hd", new GalgosRemark("Hd", "Head", 0));
		mapa.put("HndTm", new GalgosRemark("HndTm", "Had Timed", 0));
		mapa.put("Imp", new GalgosRemark("Imp", "Impeded", 0));
		mapa.put("Ir", new GalgosRemark("Ir", "Irish", 0));
		mapa.put("J", new GalgosRemark("J", "Joint Favourite", 0));
		mapa.put("Ja", new GalgosRemark("Ja", "January", 0));
		mapa.put("Jn", new GalgosRemark("Jn", "June", 0));
		mapa.put("Jy", new GalgosRemark("Jy", "July", 0));
		mapa.put("Kilos", new GalgosRemark("Kilos", "Weight of the greyhound", 0));
		mapa.put("Ld", new GalgosRemark("Ld", "Led or Lead.", 0));
		mapa.put("LN", new GalgosRemark("LN", "Line", 0));
		mapa.put("Lm", new GalgosRemark("Lm", "Lame", 0));
		mapa.put("Lt", new GalgosRemark("Lt", "Light", 0));
		mapa.put("(m)", new GalgosRemark("(m)", "Middle Runner", 0));
		mapa.put("Mld", new GalgosRemark("Mld", "Middle", 0));
		mapa.put("Mr", new GalgosRemark("Mr", "March", 0));
		mapa.put("My", new GalgosRemark("My", "May", 0));
		mapa.put("Msd", new GalgosRemark("Msd", "Missed", 0));
		mapa.put("", new GalgosRemark("N", "Normal", 0));
		mapa.put("", new GalgosRemark("Nk", "Neck", 0));
		mapa.put("Nr", new GalgosRemark("Nr", "Near", 0));
		mapa.put("Nv", new GalgosRemark("Nv", "November", 0));
		mapa.put("Oc", new GalgosRemark("Oc", "October", 0));
		mapa.put("O/C", new GalgosRemark("O/C", "Off Colour", 0));
		mapa.put("Opcd", new GalgosRemark("Opcd", "Outpaced", 0));
		mapa.put("OR", new GalgosRemark("OR", "Open race", 0));
		mapa.put("P", new GalgosRemark("P", "Pace", 0));
		mapa.put("Q", new GalgosRemark("Q", "Quick", 0));
		mapa.put("r", new GalgosRemark("r", "Red", 0));
		mapa.put("Rec", new GalgosRemark("Rec", "Record", 0));
		mapa.put("ReRn", new GalgosRemark("ReRn", "Re Run", 0));
		mapa.put("Rls", new GalgosRemark("Rls", "Rails", 0));
		mapa.put("RnIn", new GalgosRemark("RnIn", "Run In", 0));
		mapa.put("RnOn", new GalgosRemark("RnOn", "Run On", 0));
		mapa.put("Rst", new GalgosRemark("Rst", "Rest", 0));
		mapa.put("S", new GalgosRemark("S", "Stayers (Class)", 0));
		mapa.put("schL", new GalgosRemark("schL", "Schooling", 0));
		mapa.put("Scr", new GalgosRemark("Scr", "Scratch", 0));
		mapa.put("Sgh", new GalgosRemark("Sgh", "Sough", 0));
		mapa.put("Sh", new GalgosRemark("Sh", "Short Head", 0));
		mapa.put("Sp", new GalgosRemark("Sp", "September", 0));
		mapa.put("SP", new GalgosRemark("SP", "Starting Price", 0));
		mapa.put("SPI", new GalgosRemark("SPI", "Splits", 0));
		mapa.put("Sn", new GalgosRemark("Sn", "Soon", 0));
		mapa.put("Ssn", new GalgosRemark("Ssn", "Season", 0));
		mapa.put("SsnSup", new GalgosRemark("SsnSup", "Season Suppressed", 0));
		mapa.put("S", new GalgosRemark("S", "Slow", 0));
		mapa.put("Stb", new GalgosRemark("Stb", "stumbled", 0));
		mapa.put("STm", new GalgosRemark("STm", "Split Time", 0));
		mapa.put("Stt", new GalgosRemark("Stt", "Start", 0));
		mapa.put("Styd", new GalgosRemark("Styd", "Stayed", 0));
		mapa.put("WinTm", new GalgosRemark("WinTm", "Winning Time", 0));
		mapa.put("T", new GalgosRemark("T", "Trial", 0));
		mapa.put("Th’out", new GalgosRemark("Th’out", "Throughout", 0));
		mapa.put("Tk", new GalgosRemark("Tk", "Track", 0));
		mapa.put("Tkd", new GalgosRemark("Tkd", "Ticked", 0));
		mapa.put("Tm", new GalgosRemark("Tm", "Time", 0));
		mapa.put("Tp", new GalgosRemark("Tp", "Trap", 0));
		mapa.put("Unatt", new GalgosRemark("Unatt", "Unattched", 0));
		mapa.put("w", new GalgosRemark("w", "White", 0));
		mapa.put("(w)", new GalgosRemark("(w)", "Wide Runner", 0));
		mapa.put("WLL", new GalgosRemark("WLL", "Well", 0));

		return mapa;

	}

}