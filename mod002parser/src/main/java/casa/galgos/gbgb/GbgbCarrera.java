package casa.galgos.gbgb;

import java.io.Serializable;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;

import utilidades.Constantes;

public class GbgbCarrera implements Serializable, GalgosGuardable {

	private static final long serialVersionUID = 1L;

	public static final SimpleDateFormat FORMATO = new SimpleDateFormat("yyyyMMddhhmm");

	public Long id_carrera = null; // Ej. http://www.gbgb.org.uk/resultsRace.aspx?id=2029176
	public Long id_campeonato = null; // Ej. http://www.gbgb.org.uk/resultsMeeting.aspx?id=151735

	// Datos BASICOS
	public String track = "\\N";
	public String clase = "\\N";
	public Calendar fechayhora = null;
	public Integer distancia = null;
	public Short numGalgos = null;// Hay carreras en las que corren menos de 6 galgos (porque alguno esta
	// lesionado...)

	public Integer premio_primero = null;
	public Integer premio_segundo = null;
	public Integer premio_otros = null;
	public Integer premio_total_carrera = null;

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

	// Datos DETALLE
	public List<GbgbPosicionEnCarrera> posiciones = new ArrayList<GbgbPosicionEnCarrera>();

	public GbgbCarrera(boolean todoNulos) {
		super();
	}

	public GbgbCarrera(Long id_carrera, Long id_campeonato, String track, String clase, Calendar fechayhora,
			Integer distancia, Short numGalgos, Integer premio_primero, Integer premio_segundo, Integer premio_otros,
			Integer premio_total_carrera, Float going_allowance_segundos, String fc_1, String fc_2, String fc_pounds,
			String tc_1, String tc_2, String tc_3, String tc_pounds, List<GbgbPosicionEnCarrera> posiciones) {
		super();
		this.id_carrera = id_carrera;
		this.id_campeonato = id_campeonato;
		this.track = track;
		this.clase = clase;
		this.fechayhora = fechayhora;
		this.distancia = distancia;
		this.numGalgos = numGalgos;
		this.premio_primero = premio_primero;
		this.premio_segundo = premio_segundo;
		this.premio_otros = premio_otros;
		this.premio_total_carrera = premio_total_carrera;
		this.going_allowance_segundos = going_allowance_segundos;
		this.fc_1 = fc_1;
		this.fc_2 = fc_2;
		this.fc_pounds = fc_pounds;
		this.tc_1 = tc_1;
		this.tc_2 = tc_2;
		this.tc_3 = tc_3;
		this.tc_pounds = tc_pounds;

		this.posiciones = posiciones;
	}

	@Override
	public String toString() {
		return id_carrera + Constantes.SEPARADOR_CAMPO + id_campeonato + Constantes.SEPARADOR_CAMPO + track
				+ Constantes.SEPARADOR_CAMPO + clase + Constantes.SEPARADOR_CAMPO + FORMATO.format(fechayhora.getTime())
				+ Constantes.SEPARADOR_CAMPO + distancia + Constantes.SEPARADOR_CAMPO + numGalgos;
	}

	@Override
	public String generarSqlCreateTable(String sufijo) {
		String out = "CREATE TABLE IF NOT EXISTS datos_desa.tb_galgos_carreras" + sufijo + " (";
		out += "id_carrera BIGINT NOT NULL PRIMARY KEY,";
		out += "id_campeonato BIGINT NOT NULL,";
		out += "track varchar(40),";
		out += "clase varchar(5), ";
		out += "anio SMALLINT,";
		out += "mes SMALLINT, ";
		out += "dia SMALLINT,";
		out += "hora SMALLINT,";
		out += "minuto SMALLINT, ";
		out += "distancia INT,";
		out += "num_galgos SMALLINT, ";

		out += "premio_primero INT, ";
		out += "premio_segundo INT, ";
		out += "premio_otros INT, ";
		out += "premio_total_carrera INT,";
		out += "going_allowance_segundos decimal(3,2), ";
		out += "fc_1 SMALLINT, ";
		out += "fc_2 SMALLINT,";
		out += " fc_pounds decimal(10,2), ";
		out += "tc_1 SMALLINT, ";
		out += "tc_2 SMALLINT, ";
		out += "tc_3 SMALLINT, ";
		out += "tc_pounds decimal(10,2), ";

		// DATOS del ESTADIO que rellenaremos a posteriori con un REPLACE y LEFT JOIN
		out += "pasada BOOLEAN, ";
		out += "tempMin INT, ";
		out += "tempMax INT, ";
		out += "tempSpan INT, ";
		out += "histAvgMin INT, ";
		out += "histAvgMax INT, ";
		out += "texto varchar(80), ";
		out += "rain BOOLEAN, ";
		out += "wind BOOLEAN, ";
		out += "cloud BOOLEAN, ";
		out += "sun BOOLEAN, ";
		out += "snow BOOLEAN ";

		out += ");";

		return out;
	}

	@Override
	public String generarDatosParaExportarSql() {

		String out = "";

		out += id_carrera != null ? id_carrera : "\\N";
		out += Constantes.SEPARADOR_CAMPO;
		out += id_campeonato != null ? id_campeonato : "\\N";
		out += Constantes.SEPARADOR_CAMPO;
		out += track != null ? track : "\\N";
		out += Constantes.SEPARADOR_CAMPO;
		out += clase != null ? clase : "\\N";
		out += Constantes.SEPARADOR_CAMPO;
		out += formatearFechaParaExportar(fechayhora);
		out += Constantes.SEPARADOR_CAMPO;
		out += distancia != null ? distancia : "\\N";
		out += Constantes.SEPARADOR_CAMPO;
		out += numGalgos != null ? numGalgos : "\\N";
		out += Constantes.SEPARADOR_CAMPO;

		out += (premio_primero != null && premio_primero.intValue() > 0) ? premio_primero : "\\N";
		out += Constantes.SEPARADOR_CAMPO;
		out += (premio_segundo != null && premio_segundo.intValue() > 0) ? premio_segundo : "\\N";
		out += Constantes.SEPARADOR_CAMPO;
		out += (premio_otros != null && premio_otros.intValue() > 0) ? premio_otros : "\\N";
		out += Constantes.SEPARADOR_CAMPO;
		out += (premio_total_carrera != null && premio_total_carrera.intValue() > 0) ? premio_total_carrera : "\\N";
		out += Constantes.SEPARADOR_CAMPO;
		out += going_allowance_segundos != null ? going_allowance_segundos : "0";// Por defecto 0 segundos
		out += Constantes.SEPARADOR_CAMPO;
		out += fc_1 != null ? fc_1 : "\\N";
		out += Constantes.SEPARADOR_CAMPO;
		out += fc_2 != null ? fc_2 : "\\N";
		out += Constantes.SEPARADOR_CAMPO;
		out += (fc_pounds != null && !"".equals(fc_pounds) && !"\\N".equals(fc_pounds))
				? Constantes.round2(Float.valueOf(fc_pounds), 2)
				: "\\N";
		out += Constantes.SEPARADOR_CAMPO;
		out += tc_1 != null ? tc_1 : "\\N";
		out += Constantes.SEPARADOR_CAMPO;
		out += tc_2 != null ? tc_2 : "\\N";
		out += Constantes.SEPARADOR_CAMPO;
		out += tc_3 != null ? tc_3 : "\\N";
		out += Constantes.SEPARADOR_CAMPO;
		out += (tc_pounds != null && !"".equals(tc_pounds) && !"\\N".equals(tc_pounds))
				? Constantes.round2(Float.valueOf(tc_pounds), 2)
				: "\\N";

		// DATOS DEL ESTADIO (rellenados despues)
		out += Constantes.SEPARADOR_CAMPO;
		out += "\\N"; // pasada
		out += Constantes.SEPARADOR_CAMPO;
		out += "\\N";// tempMin
		out += Constantes.SEPARADOR_CAMPO;
		out += "\\N";// tempMax
		out += Constantes.SEPARADOR_CAMPO;
		out += "\\N";// tempSpan
		out += Constantes.SEPARADOR_CAMPO;
		out += "\\N";// histAvgMin
		out += Constantes.SEPARADOR_CAMPO;
		out += "\\N";// histAvgMax
		out += Constantes.SEPARADOR_CAMPO;
		out += "\\N";// texto
		out += Constantes.SEPARADOR_CAMPO;
		out += "\\N";// rain
		out += Constantes.SEPARADOR_CAMPO;
		out += "\\N";// wind
		out += Constantes.SEPARADOR_CAMPO;
		out += "\\N";// cloud
		out += Constantes.SEPARADOR_CAMPO;
		out += "\\N";// sun
		out += Constantes.SEPARADOR_CAMPO;
		out += "\\N";// snow

		out += Constantes.SEPARADOR_FILA;
		return out;
	}

	/**
	 * @param fc " (2-1) £11.75 |"
	 * @param tc " (2-1-3) £23.19"
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
	 * @param in Calendar
	 * @return 2017|11|09|20|52
	 */
	public static String formatearFechaParaExportar(Calendar in) {

		String out = "";

		out += in.get(Calendar.YEAR) + Constantes.SEPARADOR_CAMPO;

		int mes = in.get(Calendar.MONTH) + 1;
		int dia = in.get(Calendar.DAY_OF_MONTH);

		if (mes == 2 && dia == 29) {
			// JAVA BUG 29 febrero
			out += "02" + Constantes.SEPARADOR_CAMPO;
			out += "28" + Constantes.SEPARADOR_CAMPO;
		} else {
			out += ((mes >= 10) ? mes : ("0" + mes)) + Constantes.SEPARADOR_CAMPO;
			out += ((dia >= 10) ? dia : ("0" + dia)) + Constantes.SEPARADOR_CAMPO;
		}

		int hora = in.get(Calendar.HOUR_OF_DAY);
		out += ((hora >= 10) ? hora : ("0" + hora)) + Constantes.SEPARADOR_CAMPO;

		int minuto = in.get(Calendar.MINUTE);
		out += (minuto >= 10) ? minuto : ("0" + minuto);

		return out;

	}

	@Override
	public String generarPath(String pathDirBase) {
		return pathDirBase + "tb_galgos_carreras_file";
	}

}
