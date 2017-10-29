package casa.galgos.gbgb;

import java.io.Serializable;
import java.text.SimpleDateFormat;
import java.util.Calendar;

public class GbgbCarrera implements Serializable {

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

}
