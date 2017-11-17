package casa.galgos.gbgb;

import java.io.Serializable;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import utilidades.Constantes;

public class GbgbCarrera implements Serializable, GalgosGuardable {

	private static final long serialVersionUID = 1L;

	public static final SimpleDateFormat FORMATO = new SimpleDateFormat("yyyyMMddhhmm");

	public Long id_carrera; // Ej. http://www.gbgb.org.uk/resultsRace.aspx?id=2029176
	public Long id_campeonato; // Ej. http://www.gbgb.org.uk/resultsMeeting.aspx?id=151735

	// Datos BASICOS
	public String track = "\\N";
	public String clase = "\\N";
	public Calendar fechayhora;
	public Integer distancia;
	public Short numGalgos;// Hay carreras en las que corren menos de 6 galgos (porque alguno esta
							// lesionado...)

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

	// Datos DETALLE
	public List<GbgbPosicionEnCarrera> posiciones = new ArrayList<GbgbPosicionEnCarrera>();

	public Set<String> urlsGalgosHistorico = new HashSet<String>();

	public GbgbCarrera(boolean todoNulos) {
		super();
	}

	public GbgbCarrera(Long id_carrera, Long id_campeonato, String track, String clase, Calendar fechayhora,
			Integer distancia, Short numGalgos, Integer premio_primero, Integer premio_segundo, Integer premio_otros,
			Integer premio_total_carrera, Float going_allowance_segundos, String fc_1, String fc_2, String fc_pounds,
			String tc_1, String tc_2, String tc_3, String tc_pounds, List<GbgbPosicionEnCarrera> posiciones,
			Set<String> urlsGalgosHistorico) {
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
		this.urlsGalgosHistorico = urlsGalgosHistorico;
	}

	@Override
	public String toString() {
		return id_carrera + Constantes.SEPARADOR_CAMPO + id_campeonato + Constantes.SEPARADOR_CAMPO + track
				+ Constantes.SEPARADOR_CAMPO + clase + Constantes.SEPARADOR_CAMPO + FORMATO.format(fechayhora.getTime())
				+ Constantes.SEPARADOR_CAMPO + distancia + Constantes.SEPARADOR_CAMPO + numGalgos;
	}

	@Override
	public String generarSqlCreateTable() {
		String out = "CREATE TABLE IF NOT EXISTS datos_desa.tb_galgos_carreras (";
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
		out += "num_galgos SMALLINT,";

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
		out += "tc_pounds decimal(10,2)";
		out += ");";

		return out;
	}

	@Override
	public String generarDatosParaExportarSql() {

		String SEP = Constantes.SEPARADOR_CAMPO;

		String out = "";

		out += id_carrera != null ? id_carrera : "\\N";
		out += SEP;
		out += id_campeonato != null ? id_campeonato : "\\N";
		out += SEP;
		out += track != null ? track : "";
		out += SEP;
		out += clase != null ? clase : "";
		out += SEP;
		out += formatearFechaParaExportar(fechayhora);
		out += SEP;
		out += distancia != null ? distancia : "\\N";
		out += SEP;

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

		out += Constantes.SEPARADOR_FILA;
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
	 * @param in
	 *            Calendar
	 * @return 2017|11|09|20|52
	 */
	public static String formatearFechaParaExportar(Calendar in) {

		String out = "";

		out += in.get(Calendar.YEAR) + Constantes.SEPARADOR_CAMPO;

		int mes = in.get(Calendar.MONTH);
		out += ((mes >= 10) ? mes : ("0" + mes)) + Constantes.SEPARADOR_CAMPO;

		int dia = in.get(Calendar.DAY_OF_MONTH);
		out += ((dia >= 10) ? dia : ("0" + dia)) + Constantes.SEPARADOR_CAMPO;

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
