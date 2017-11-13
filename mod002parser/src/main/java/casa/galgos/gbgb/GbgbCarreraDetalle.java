package casa.galgos.gbgb;

import java.io.Serializable;
import java.util.Calendar;
import java.util.HashSet;
import java.util.Set;

import utilidades.Constantes;

public class GbgbCarreraDetalle implements Serializable {

	private static final long serialVersionUID = 1L;

	public Integer premio_primero;
	public Integer premio_segundo;
	public Integer premio_otros;
	public Integer premio_total_carrera;

	public Float going_allowance_segundos = 0.0F;// por defecto=NO

	// FORECAST 2 puestos
	public String fc_1 = "\\N";
	public String fc_2 = "\\N";
	public String fc_pounds = "\\N";

	// TRICAST 3 puestos
	public String tc_1 = "\\N";
	public String tc_2 = "\\N";
	public String tc_3 = "\\N";
	public String tc_pounds = "\\N";

	public String puesto1 = crearCadenaPuestoVacio();
	public String puesto2 = crearCadenaPuestoVacio();
	public String puesto3 = crearCadenaPuestoVacio();
	public String puesto4 = crearCadenaPuestoVacio();
	public String puesto5 = crearCadenaPuestoVacio();
	public String puesto6 = crearCadenaPuestoVacio();

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
	 * @param fechaDeLaCarrera
	 */
	public void rellenarPuesto(Short posicion, String galgo_nombre, Integer trap, String sp, String time_sec,
			String time_distance, Float peso_galgo, String entrenador_nombre, String galgo_padre, String galgo_madre,
			Integer nacimiento, String comment, String url_galgo_historico, Calendar fechaDeLaCarrera) {

		switch (posicion) {
		case 1:
			puesto1 = crearCadenaPuesto(galgo_nombre, trap, sp, time_sec, time_distance, peso_galgo, entrenador_nombre,
					galgo_padre, galgo_madre, nacimiento, comment, fechaDeLaCarrera);
			break;
		case 2:
			puesto2 = crearCadenaPuesto(galgo_nombre, trap, sp, time_sec, time_distance, peso_galgo, entrenador_nombre,
					galgo_padre, galgo_madre, nacimiento, comment, fechaDeLaCarrera);
			break;
		case 3:
			puesto3 = crearCadenaPuesto(galgo_nombre, trap, sp, time_sec, time_distance, peso_galgo, entrenador_nombre,
					galgo_padre, galgo_madre, nacimiento, comment, fechaDeLaCarrera);
			break;
		case 4:
			puesto4 = crearCadenaPuesto(galgo_nombre, trap, sp, time_sec, time_distance, peso_galgo, entrenador_nombre,
					galgo_padre, galgo_madre, nacimiento, comment, fechaDeLaCarrera);
			break;
		case 5:
			puesto5 = crearCadenaPuesto(galgo_nombre, trap, sp, time_sec, time_distance, peso_galgo, entrenador_nombre,
					galgo_padre, galgo_madre, nacimiento, comment, fechaDeLaCarrera);
			break;
		case 6:
			puesto6 = crearCadenaPuesto(galgo_nombre, trap, sp, time_sec, time_distance, peso_galgo, entrenador_nombre,
					galgo_padre, galgo_madre, nacimiento, comment, fechaDeLaCarrera);
			break;

		default:
			break;
		}

		urlsGalgosHistorico.add(url_galgo_historico);

	}

	/**
	 * @return
	 */
	private static String crearCadenaPuestoVacio() {
		return crearCadenaPuesto(null, null, null, null, null, null, null, null, null, null, null, null);
	}

	private static String crearCadenaPuesto(String galgo_nombre, Integer trap, String sp, String time_sec,
			String time_distance, Float peso_galgo, String entrenador_nombre, String galgo_padre, String galgo_madre,
			Integer nacimiento, String comment, Calendar fechaDeLaCarrera) {

		String SEP = Constantes.SEPARADOR_CAMPO;

		Integer edadEnDias = calcularEdadGalgoEnDias(nacimiento, fechaDeLaCarrera);

		String out = "";

		out += (galgo_nombre != null && !"".equals(galgo_nombre)) ? galgo_nombre : "\\N";
		out += SEP;
		out += trap != null ? trap : "\\N";
		out += SEP;
		out += (sp != null && !"".equals(sp)) ? sp : "\\N";
		out += SEP;
		out += (time_sec != null && !"".equals(time_sec)) ? time_sec : "\\N";
		out += SEP;
		out += (time_distance != null && !"".equals(time_distance)) ? time_distance : "\\N";
		out += SEP;
		out += peso_galgo != null ? peso_galgo : "\\N";
		out += SEP;
		out += (entrenador_nombre != null && !"".equals(entrenador_nombre)) ? entrenador_nombre : "\\N";
		out += SEP;
		out += (galgo_padre != null && !"".equals(galgo_padre)) ? galgo_padre : "\\N";
		out += SEP;
		out += (galgo_madre != null && !"".equals(galgo_madre)) ? galgo_madre : "\\N";
		out += SEP;
		out += (nacimiento != null) ? nacimiento.toString() : "\\N";
		out += SEP;
		out += (comment != null && !"".equals(comment)) ? comment : "\\N";
		out += SEP;
		out += (edadEnDias != null) ? edadEnDias : "\\N";

		return out;

	}

	/**
	 * @param nacimiento
	 *            20150501
	 * @param fechaDeLaCarrera
	 *            Calendar
	 * @return Edad del perro en dias = fechaDeLaCarrera - nacimiento (ojo, no
	 *         restar Integers, sin Calendar.subtract)
	 */
	public static Integer calcularEdadGalgoEnDias(Integer nacimiento, Calendar fechaDeLaCarrera) {

		Integer out = null;
		if (nacimiento != null && fechaDeLaCarrera != null) {

			int anio = Double.valueOf(nacimiento / 10000.0D).intValue();
			int mes = Double.valueOf((nacimiento - anio * 10000) / 100.0D).intValue();
			int dia = Double.valueOf(nacimiento - anio * 10000 - mes * 100).intValue();

			Calendar fechaNacimiento = Calendar.getInstance();
			fechaNacimiento.clear();
			fechaNacimiento.set(Calendar.YEAR, anio);
			fechaNacimiento.set(Calendar.MONTH, mes);
			fechaNacimiento.set(Calendar.DAY_OF_MONTH, dia);

			Long resta = fechaDeLaCarrera.getTimeInMillis() / (1000 * 60 * 60 * 24)
					- fechaNacimiento.getTimeInMillis() / (1000 * 60 * 60 * 24);

			out = resta.intValue();
		}
		return out;
	}

	/**
	 * @param fc
	 *            " (2-1) £11.75 |"
	 * @param tc
	 *            " (2-1-3) £23.19"
	 */
	public void rellenarForecastyTricast(String fc, String tc) {

		if (fc != null) {
			String[] fca = Constantes.limpiarTexto(fc).split("£");
			String[] fc_parte1 = fca[0].trim().replace("(", "").replace(")", "").split("-");
			fc_1 = fc_parte1[0];
			fc_2 = fc_parte1[1];
			fc_pounds = Constantes.limpiarTexto(fca[1]);
		}

		if (tc != null) {
			String[] tca = Constantes.limpiarTexto(tc).split("£");
			String[] tc_parte1 = tca[0].trim().replace("(", "").replace(")", "").split("-");
			tc_1 = tc_parte1[0];
			tc_2 = tc_parte1[1];
			tc_3 = tc_parte1[2];
			tc_pounds = Constantes.limpiarTexto(tca[1]);
		}
	}

	/**
	 * @return
	 */
	public static String generarCamposSqlCreateTableDeDetalle() {
		String out = "premio_primero INT, premio_segundo INT, premio_otros INT, premio_total_carrera INT, going_allowance_segundos decimal(3,2), "
				+ "fc_1 SMALLINT, fc_2 SMALLINT, fc_pounds decimal(10,2), "
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
			out += "p" + i + "_" + "comment varchar(20), ";
			out += "p" + i + "_" + "edad_en_dias INT";
		}

		return out;
	}

	/**
	 * @param fechaDeLaCarrera
	 *            Sirve para calcular la edad del perro (días) en el día de la
	 *            carrera.
	 * @return
	 */
	public String generarDatosParaExportarSql(Calendar fechaDeLaCarrera) {

		String SEP = Constantes.SEPARADOR_CAMPO;

		String puestoTodoVacio = crearCadenaPuestoVacio();

		String out = "";

		out += premio_primero != null ? premio_primero : "\\N";
		out += SEP;

		out += premio_segundo != null ? premio_segundo : "\\N";
		out += SEP;

		out += premio_otros != null ? premio_otros : "\\N";
		out += SEP;

		out += premio_total_carrera != null ? premio_total_carrera : "\\N";
		out += SEP;

		out += going_allowance_segundos != null ? going_allowance_segundos : "0";// Por defecto 0 segundos
		out += SEP;

		out += fc_1 != null ? fc_1 : "\\N";
		out += SEP;

		out += fc_2 != null ? fc_2 : "\\N";
		out += SEP;

		out += fc_pounds != null ? fc_pounds : "\\N";
		out += SEP;

		out += tc_1 != null ? tc_1 : "\\N";
		out += SEP;

		out += tc_2 != null ? tc_2 : "\\N";
		out += SEP;

		out += tc_3 != null ? tc_3 : "\\N";
		out += SEP;

		out += tc_pounds != null ? tc_pounds : "\\N";
		out += SEP;

		out += (puesto1 != null) ? puesto1 : puestoTodoVacio;
		out += SEP;

		out += (puesto2 != null) ? puesto2 : puestoTodoVacio;
		out += SEP;

		out += (puesto3 != null) ? puesto3 : puestoTodoVacio;
		out += SEP;

		out += (puesto4 != null) ? puesto4 : puestoTodoVacio;
		out += SEP;

		out += (puesto5 != null) ? puesto5 : puestoTodoVacio;
		out += SEP;

		out += (puesto6 != null) ? puesto6 : puestoTodoVacio;

		return out;
	}

}
