package casa.galgos.gbgb;

import java.io.Serializable;
import java.text.SimpleDateFormat;
import java.util.Calendar;

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

	// Datos DETALLE
	public GbgbCarreraDetalle detalle;

	public GbgbCarrera(Long id_carrera, Long id_campeonato, String track, String clase, Calendar fechayhora,
			Integer distancia, GbgbCarreraDetalle detalle) {
		super();
		this.id_carrera = id_carrera;
		this.id_campeonato = id_campeonato;
		this.track = track;
		this.clase = clase;
		this.fechayhora = fechayhora;
		this.distancia = distancia;
		this.detalle = detalle;
	}

	@Override
	public String toString() {
		return id_carrera + "|" + id_campeonato + "|" + track + "|" + clase + "|" + FORMATO.format(fechayhora.getTime())
				+ "|" + distancia;
	}

	public GbgbCarreraDetalle getDetalle() {
		return detalle;
	}

	public void setDetalle(GbgbCarreraDetalle detalle) {
		this.detalle = detalle;
	}

	@Override
	public String generarSqlCreateTable() {
		return "CREATE TABLE IF NOT EXISTS datos_desa.tb_galgos_carreras ("
				+ "id_carrera BIGINT NOT NULL PRIMARY KEY, id_campeonato BIGINT NOT NULL, track varchar(40), clase varchar(5), "
				+ "anio SMALLINT, mes SMALLINT, dia SMALLINT, hora SMALLINT, minuto SMALLINT, " + "distancia INT,"
				+ GbgbCarreraDetalle.generarCamposSqlCreateTableDeDetalle() + ");";
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

		out += detalle.generarDatosParaExportarSql(fechayhora) + Constantes.SEPARADOR_FILA;
		return out;
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
