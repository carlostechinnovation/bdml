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
	public static final Integer GALGOS_UMBRAL_DIAS_CARRERAS_ANTERIORES = 3 * 30; // Solo cogemos las carreras de los
																					// últimos 6 meses

	public static final Integer MAX_NUM_CARRERAS_PROCESADAS = 40;
	public static final Long ESPERA_ENTRE_DESCARGA_CARRERAS_MSEC = 1 * 200L;
	public static final Integer MAX_NUM_FILAS_EN_MEMORIA_SIN_ESCRIBIR_EN_FICHERO = 500;

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

	/**
	 * @param in
	 * @return
	 */
	public static String limpiarTexto(String in) {
		return in.replace(SEPARADOR_CAMPO, "").replace(SEPARADOR_FILA, "").replace("Â", "").replace("$nbsp", "")
				.replace(" ", "").trim();
	}

	// public static generarDiccionarioRemarks() {
	//
	//
	//
	// Aw – Away
	// Awk – Awkard
	// Ap – April
	// Au – August
	// B – Badly
	// b – Bitch
	// bd – Brindle
	// be – Blue
	// Blk – Black
	// Bmp – Bumped
	// Brk – Break
	// By – Won or lost by
	// Calc – Calculated
	// CalcTm – The time of victory on a standard track
	// ChL – Challenged
	// Clr – Clear
	// CmSg – Came Again
	// Crd – Crowded
	// cWinTm – The actual time taken to win the race
	// De – December
	// DH – Dead Heat
	// Dis – The race distance
	// Disp – Disputed
	// Disq – Disqualified
	// dk – Dark
	// DNF – Did not finish.
	// E – Early
	// EvCh – Every Chance
	// F – Favourite
	// f – Fawn
	// Fb – February
	// Fd – Faded
	// Fght – Fought
	// Fin – Finished
	// FlsHt – False Heat
	// Fr – From
	// G’ng – Track going
	// H – Hurdles
	// Hcp – Handicap
	// Hd – Head
	// HndTm – Had Timed
	// Imp – Impeded
	// Ir – Irish
	// J – Joint Favourite
	// Ja – January
	// Jn – June
	// Jy – July
	// Kilos – Weight of the greyhound
	// Ld – Led or Lead.
	// LN – Line
	// Lm – Lame
	// Lt – Light
	// (m) – Middle Runner
	// Mld – Middle
	// Mr – March
	// My – May
	// Msd – Missed
	// N – Normal
	// Nk – Neck
	// Nr – Near
	// Nv – November
	// Oc – October
	// O/C – Off Colour
	// Opcd – Outpaced
	// OR – Open race
	// P – Pace
	// Q – Quick
	// r – Red
	// Rec – Record
	// ReRn – Re Run
	// Rls – Rails
	// RnIn – Run In
	// RnOn – Run On
	// Rst – Rest
	// S – Stayers (Class)
	// schL – Schooling
	// Scr – Scratch
	// Sgh – Sough
	// Sh – Short Head
	// Sp – September
	// SP – Starting Price
	// SPI – Splits
	// Sn – Soon
	// Ssn – Season
	// SsnSup – Season Suppressed
	// S – Slow
	// Stb stumbled
	// STm – Split Time
	// Stt – Start
	// Styd – Stayed
	// WinTm – Winning Time
	// T – Trial
	// Th’out – Throughout
	// Tk – Track
	// Tkd – Ticked
	// Tm –Time
	// Tp – Trap
	// Unatt – Unattched
	// w – White
	// (w) – Wide Runner
	// WLL – Well
	//
	//
	// }

}