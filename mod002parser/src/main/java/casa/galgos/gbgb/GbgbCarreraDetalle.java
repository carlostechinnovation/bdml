package casa.galgos.gbgb;

import java.io.Serializable;
import java.util.HashSet;
import java.util.Set;

import utilidades.Constantes;

public class GbgbCarreraDetalle implements Serializable {

	private static final long serialVersionUID = 1L;

	public Integer premio_primero;
	public Integer premio_segundo;
	public Integer premio_otros;
	public Integer premio_total_carrera;

	public Boolean going_allowance;

	// FORECAST 2 puestos
	public String fc_1 = "";
	public String fc_2 = "";
	public String fc_pounds = "";

	// TRICAST 3 puestos
	public String tc_1 = "";
	public String tc_2 = "";
	public String tc_3 = "";
	public String tc_pounds = "";

	public String puesto1 = "";
	public String puesto2 = "";
	public String puesto3 = "";
	public String puesto4 = "";
	public String puesto5 = "";
	public String puesto6 = "";

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
	public void rellenarPuesto(Short posicion, String galgo_nombre, Integer trap, String sp, String time_sec,
			String time_distance, Float peso_galgo, String entrenador_nombre, String galgo_padre, String galgo_madre,
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
	private String crearCadenaPuesto(String galgo_nombre, Integer trap, String sp, String time_sec,
			String time_distance, Float peso_galgo, String entrenador_nombre, String galgo_padre, String galgo_madre,
			String nacimiento, String comment) {

		String SEP = Constantes.SEPARADOR_CAMPO;

		String out = "";

		out += galgo_nombre != null ? galgo_nombre : "";
		out += SEP;
		out += trap != null ? trap : "";
		out += SEP;
		out += sp != null ? sp : "";
		out += SEP;
		out += time_sec != null ? time_sec : "";
		out += SEP;
		out += time_distance != null ? time_distance : "";
		out += SEP;
		out += peso_galgo != null ? peso_galgo : "";
		out += SEP;
		out += entrenador_nombre != null ? entrenador_nombre : "";
		out += SEP;
		out += galgo_padre != null ? galgo_padre : "";
		out += SEP;
		out += galgo_madre != null ? galgo_madre : "";
		out += SEP;
		out += nacimiento != null ? nacimiento : "";
		out += SEP;
		out += comment != null ? comment : "";

		return out;

	}

	/**
	 * @param fc
	 *            " (2-1) £11.75 |"
	 * @param tc
	 *            " (2-1-3) £23.19"
	 */
	public void rellenarForecastyTricast(String fc, String tc) {

		String[] fca = fc.replace("Â", "").split("£");
		String[] fc_parte1 = fca[0].trim().replace("(", "").replace(")", "").split("-");
		fc_1 = fc_parte1[0];
		fc_2 = fc_parte1[1];
		fc_pounds = fca[1].replace("|", "").trim();

		String[] tca = tc.replace("Â", "").split("£");
		String[] tc_parte1 = tca[0].trim().replace("(", "").replace(")", "").split("-");
		tc_1 = tc_parte1[0];
		tc_2 = tc_parte1[1];
		tc_3 = tc_parte1[2];
		tc_pounds = tca[1].replace("|", "").trim();
	}

	/**
	 * @return
	 */
	public static String generarCamposSqlCreateTableDeDetalle() {
		String out = "premio_primero INT, premio_segundo INT, premio_otros INT, premio_total_carrera INT, going_allowance varchar(1),"
				+ "fc_1 SMALLINT, fc_2 SMALLINT, fc_pounds decimal(10,2),"
				+ "tc_1 SMALLINT, tc_2 SMALLINT, tc_3 SMALLINT, tc_pounds decimal(10,2)";

		for (int i = 1; i <= 6; i++) {
			out += ", ";
			out += "p" + i + "_" + "galgo_nombre varchar(30), ";
			out += "p" + i + "_" + "trap SMALLINT, ";
			out += "p" + i + "_" + "sp varchar(5), ";
			out += "p" + i + "_" + "time_sec decimal(6,2), ";
			out += "p" + i + "_" + "time_distance varchar(15), ";
			out += "p" + i + "_" + "peso_galgo decimal(4,2), ";
			out += "p" + i + "_" + "entrenador_nombre varchar(30), ";
			out += "p" + i + "_" + "galgo_padre varchar(50), ";
			out += "p" + i + "_" + "galgo_madre varchar(30), ";
			out += "p" + i + "_" + "nacimiento varchar(30), ";
			out += "p" + i + "_" + "comment varchar(20)";
		}

		return out;
	}

	/**
	 * @return
	 */
	public String generarDatosParaExportarSql() {

		String SEP = Constantes.SEPARADOR_CAMPO;

		String out = "";

		out += premio_primero != null ? premio_primero : "";
		out += SEP;

		out += premio_segundo != null ? premio_segundo : "";
		out += SEP;

		out += premio_otros != null ? premio_otros : "";
		out += SEP;

		out += premio_total_carrera != null ? premio_total_carrera : "";
		out += SEP;

		out += going_allowance != null ? going_allowance : "";
		out += SEP;

		out += fc_1 != null ? fc_1 : "";
		out += SEP;

		out += fc_2 != null ? fc_2 : "";
		out += SEP;

		out += fc_pounds != null ? fc_pounds : "";
		out += SEP;

		out += tc_1 != null ? tc_1 : "";
		out += SEP;

		out += tc_2 != null ? tc_2 : "";
		out += SEP;

		out += tc_3 != null ? tc_3 : "";
		out += SEP;

		out += tc_pounds != null ? tc_pounds : "";
		out += SEP;

		out += puesto1 != null ? puesto1 : "";
		out += SEP;

		out += puesto2 != null ? puesto2 : "";
		out += SEP;

		out += puesto3 != null ? puesto3 : "";
		out += SEP;

		out += puesto4 != null ? puesto4 : "";
		out += SEP;

		out += puesto5 != null ? puesto5 : "";
		out += SEP;

		out += puesto6 != null ? puesto6 : "";

		return out;
	}

}
