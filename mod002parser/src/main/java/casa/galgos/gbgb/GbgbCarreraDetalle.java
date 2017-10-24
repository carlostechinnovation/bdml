package casa.galgos.gbgb;

import java.io.Serializable;
import java.util.HashSet;
import java.util.Set;

public class GbgbCarreraDetalle implements Serializable {

	private static final long serialVersionUID = 1L;

	public Integer premio_primer_puesto;
	public Integer premio_otros;
	public Integer premio_total_carrera;

	public Boolean going_allowance;

	// FORECAST 2 puestos
	public String fc_1;
	public String fc_2;
	public String fc_pounds;

	// TRICAST 3 puestos
	public String tc_1;
	public String tc_2;
	public String tc_3;
	public String tc_pounds;

	public String puesto1;
	public String puesto2;
	public String puesto3;
	public String puesto4;
	public String puesto5;
	public String puesto6;

	public Set<String> urlsGalgosHistorico = new HashSet<String>();

	/**
	 * Rellenar atributos con los datos de la tabla:
	 * http://www.gbgb.org.uk/resultsRace.aspx?id=2029176
	 * 
	 * @param posicion
	 * @param galgo_nombre
	 * @param trap
	 * @param sp
	 * @param time_sec
	 * @param time_distance
	 * @param peso_galgo
	 * @param entrenador_nombre
	 * @param galgo_padre
	 *            Mas info: http://www.greyhound-data.com/sirepages.htm?id=1619771
	 * @param galgo_madre
	 * @param nacimiento
	 * @param comment
	 * @param url_galgo_historico
	 */
	public void rellenarPuesto(Short posicion, String galgo_nombre, String trap, String sp, String time_sec,
			String time_distance, String peso_galgo, String entrenador_nombre, String galgo_padre, String galgo_madre,
			String nacimiento, String comment, String url_galgo_historico) {

		switch (posicion) {
		case 1:
			puesto1 = crearCadenaPuesto(galgo_nombre, trap, sp, time_sec, time_distance, peso_galgo, entrenador_nombre,
					galgo_padre, galgo_madre, nacimiento, comment);
			break;
		case 2:
			puesto2 = crearCadenaPuesto(galgo_nombre, trap, sp, time_sec, time_distance, peso_galgo, entrenador_nombre,
					galgo_padre, galgo_madre, nacimiento, comment);
			break;
		case 3:
			puesto3 = crearCadenaPuesto(galgo_nombre, trap, sp, time_sec, time_distance, peso_galgo, entrenador_nombre,
					galgo_padre, galgo_madre, nacimiento, comment);
			break;
		case 4:
			puesto4 = crearCadenaPuesto(galgo_nombre, trap, sp, time_sec, time_distance, peso_galgo, entrenador_nombre,
					galgo_padre, galgo_madre, nacimiento, comment);
			break;
		case 5:
			puesto5 = crearCadenaPuesto(galgo_nombre, trap, sp, time_sec, time_distance, peso_galgo, entrenador_nombre,
					galgo_padre, galgo_madre, nacimiento, comment);
			break;
		case 6:
			puesto6 = crearCadenaPuesto(galgo_nombre, trap, sp, time_sec, time_distance, peso_galgo, entrenador_nombre,
					galgo_padre, galgo_madre, nacimiento, comment);
			break;

		default:
			break;
		}

		urlsGalgosHistorico.add(url_galgo_historico);

	}

	/**
	 * @param galgo_nombre
	 * @param trap
	 * @param sp
	 * @param time_sec
	 * @param time_distance
	 * @param peso_galgo
	 * @param entrenador_nombre
	 * @param galgo_padre
	 * @param galgo_madre
	 * @param nacimiento
	 * @param comment
	 * @return
	 */
	private String crearCadenaPuesto(String galgo_nombre, String trap, String sp, String time_sec, String time_distance,
			String peso_galgo, String entrenador_nombre, String galgo_padre, String galgo_madre, String nacimiento,
			String comment) {
		String SEP = "#";
		return galgo_nombre + SEP + trap + SEP + sp + SEP + time_sec + SEP + time_distance + SEP + peso_galgo + SEP
				+ entrenador_nombre + SEP + galgo_padre + SEP + galgo_madre + SEP + nacimiento + SEP + comment;
	}

	/**
	 * @param fc
	 *            " (2-1) £11.75 |"
	 * @param tc
	 *            " (2-1-3) £23.19"
	 */
	public void rellenarForecastyTricast(String fc, String tc) {

		String[] fca = fc.split("£");
		String[] fc_parte1 = fca[0].trim().replace("(", "").replace(")", "").split("-");
		fc_1 = fc_parte1[0];
		fc_2 = fc_parte1[1];
		fc_pounds = fca[1].replace("|", "").trim();

		String[] tca = tc.split("£");
		String[] tc_parte1 = tca[0].trim().replace("(", "").replace(")", "").split("-");
		tc_1 = tc_parte1[0];
		tc_2 = tc_parte1[1];
		tc_3 = tc_parte1[2];
		tc_pounds = tca[1].replace("|", "").trim();

	}

}
