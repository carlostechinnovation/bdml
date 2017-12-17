package casa.galgos.gbgb;

import java.io.Serializable;
import java.text.SimpleDateFormat;
import java.util.Calendar;

import org.apache.log4j.Logger;

import utilidades.Constantes;

public class GbgbGalgoHistoricoCarrera implements Serializable {

	private static final long serialVersionUID = 1L;

	static Logger MY_LOGGER = Logger.getLogger(GbgbGalgoHistoricoCarrera.class);

	public static final SimpleDateFormat FORMATO = new SimpleDateFormat("yyyyMMddhhmm");

	public Long id_carrera; // Ej. http://www.gbgb.org.uk/resultsRace.aspx?id=2029176
	public Long id_campeonato; // Ej. http://www.gbgb.org.uk/resultsMeeting.aspx?id=151735

	public Calendar fecha; // Solo dia, pero no hora
	public Integer distancia;
	public String trap = "\\N";
	public String stmHcp = "\\N"; // Equivale a "Time/Sec."
	public String posicion = "\\N";
	public String by = "\\N"; // NO equivale a SP
	public String galgo_primero_o_segundo = "\\N"; // Si el galgo de esta carrera quedo primero, este campo es el nombre
													// del
													// segundo. Si quedo segundo, es el nombre del primero. Si quedo 3o
													// o
													// siguientes, es el nombre del primero.
	public String venue = "\\N"; // Pista fisica donde se celebro
	public String remarks = "\\N"; // Equivale a comment (para ese galgo y esa carrera)
	public String winTime = "\\N"; // Tiempo que hizo el galgo que gano la carrera
	public String going = "\\N";
	public Float sp;// Starting Price (APUESTAS, odds)
	public String clase = "\\N";// Tipo de carrera
	public String calculatedTime = "\\N";// Tiempo de este galgo en la carrera (no del que gano)

	// VELOCIDADES en m/s (es mejor ver la velocidad que el tiempo, porque cada
	// carrera puede tener una longitud diferente)
	public Float velocidadReal;
	public Float velocidadConGoing;

	// SCORINGs extra
	public Float scoringRemarks;

	public GbgbGalgoHistoricoCarrera(Long id_carrera, Long id_campeonato, Calendar fecha, Integer distancia,
			String trap, String stmHcp, String posicion, String by, String galgo_primero_o_segundo, String venue,
			String remarks, String winTime, String going, Float sp, String clase, String calculatedTime,
			Float velocidadReal, Float velocidadConGoing, Float scoringRemarks) {
		super();
		this.id_carrera = id_carrera;
		this.id_campeonato = id_campeonato;
		this.fecha = fecha;
		this.distancia = distancia;
		this.trap = trap;
		this.stmHcp = stmHcp;
		this.posicion = posicion;
		this.by = by;
		this.galgo_primero_o_segundo = galgo_primero_o_segundo;
		this.venue = venue;
		this.remarks = remarks;
		this.winTime = winTime;
		this.going = going;
		this.sp = sp;
		this.clase = clase;
		this.calculatedTime = calculatedTime;
		this.velocidadReal = velocidadReal;
		this.velocidadConGoing = velocidadConGoing;
		this.scoringRemarks = scoringRemarks;
	}

	/**
	 * @return
	 */
	public static String generarCamposSqlCreateTableDeDetalle() {

		String out = "id_carrera BIGINT NOT NULL, id_campeonato BIGINT NOT NULL, ";
		out += "anio SMALLINT NOT NULL, mes SMALLINT NOT NULL, dia SMALLINT NOT NULL, ";
		out += "distancia SMALLINT, trap varchar(1), stmhcp varchar(10), ";
		out += "posicion varchar(1), by_dato varchar(15), galgo_primero_o_segundo varchar(30), ";
		out += "venue varchar(20), remarks varchar(30), win_time decimal(6,2), ";
		out += "going varchar(5), sp decimal(8,4), clase varchar(5), calculated_time decimal(6,2), ";
		out += "velocidad_real decimal(6,4), velocidad_con_going decimal(6,4)," + "scoring_remarks decimal(4,2)";

		return out;
	}

	public String generarDatosParaExportarSql() {
		String SEP = Constantes.SEPARADOR_CAMPO;
		SimpleDateFormat sdf = new SimpleDateFormat("yyyy" + SEP + "MM" + SEP + "dd");

		String out = "";

		out += id_carrera != null ? id_carrera : "\\N";
		out += SEP;
		out += id_campeonato != null ? id_campeonato : "\\N";
		out += SEP;
		out += sdf.format(fecha.getTime());
		out += SEP;
		out += distancia != null ? distancia : "\\N";
		out += SEP;
		out += (trap != null && !"".equals(trap)) ? trap : "\\N";
		out += SEP;
		out += (stmHcp != null && !"".equals(stmHcp)) ? stmHcp : "\\N";
		out += SEP;
		out += (posicion != null && !"".equals(posicion)) ? posicion : "\\N";
		out += SEP;
		out += (by != null && !"".equals(by)) ? by : "\\N";
		out += SEP;
		out += (galgo_primero_o_segundo != null && !"".equals(galgo_primero_o_segundo)) ? galgo_primero_o_segundo
				: "\\N";
		out += SEP;
		out += (venue != null && !"".equals(venue)) ? venue : "\\N";
		out += SEP;
		out += (remarks != null && !"".equals(remarks)) ? remarks : "\\N";
		out += SEP;
		out += (winTime != null && !"".equals(winTime)) ? Constantes.round2(Float.valueOf(winTime), 2) : "\\N";
		out += SEP;
		out += (going != null && !"".equals(going)) ? going : "\\N";
		out += SEP;
		out += sp != null ? Constantes.round2(sp, 4) : "\\N";
		out += SEP;
		out += (clase != null && !"".equals(clase)) ? clase : "\\N";
		out += SEP;
		out += (calculatedTime != null && !"".equals(calculatedTime))
				? Constantes.round2(Float.valueOf(calculatedTime), 2)
				: "\\N";

		out += SEP;
		out += velocidadReal != null ? Constantes.round2(velocidadReal, 4) : "\\N";
		out += SEP;
		out += velocidadConGoing != null ? Constantes.round2(velocidadConGoing, 4) : "\\N";
		out += SEP;
		out += (scoringRemarks != null) ? scoringRemarks : "\\N";

		return out;

	}

}
