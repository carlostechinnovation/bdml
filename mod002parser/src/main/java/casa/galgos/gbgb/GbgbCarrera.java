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
	public String track;
	public String clase;
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
				+ "id_carrera BIGINT, id_campeonato BIGINT, track varchar(40), clase varchar(5), "
				+ "anio SMALLINT, mes SMALLINT, dia SMALLINT, hora SMALLINT, minuto SMALLINT, " + "distancia INT,"
				+ detalle.generarCamposSqlCreateTableDeDetalle() + ");";
	}

	@Override
	public String generarDatosParaExportarSql() {

		String SEP = Constantes.SEPARADOR_CAMPO;
		SimpleDateFormat sdf = new SimpleDateFormat("yyyy" + SEP + "MM" + SEP + "dd" + SEP + "hh" + SEP + "mm");

		String out = id_carrera + SEP + id_campeonato + SEP + track + SEP + clase + SEP;

		out += sdf.format(fechayhora.getTime()) + SEP;
		out += distancia + SEP;

		out += detalle.generarDatosParaExportarSql();
		return out;
	}

	@Override
	public String generarPath() {
		// TODO Auto-generated method stub
		return null;
	}

}
