package casa.galgos.gbgb;

import java.io.Serializable;
import java.text.SimpleDateFormat;
import java.util.Calendar;

import utilidades.Constantes;

public class GbgbGalgoHistoricoCarrera implements Serializable {

	private static final long serialVersionUID = 1L;

	public static final SimpleDateFormat FORMATO = new SimpleDateFormat("yyyyMMddhhmm");

	public Long id_carrera; // Ej. http://www.gbgb.org.uk/resultsRace.aspx?id=2029176
	public Long id_campeonato; // Ej. http://www.gbgb.org.uk/resultsMeeting.aspx?id=151735

	public Calendar fecha; // Solo dia, pero no hora
	public Integer distancia;
	public String trap = "";
	public String stmHcp = ""; // Equivale a "Time/Sec."
	public String posicion = "";
	public String by = ""; // NO equivale a SP
	public String galgo_primero_o_segundo = ""; // Si el galgo de esta carrera quedó primero, este campo es el nombre
												// del
												// segundo. Si quedó segundo, es el nombre del primero. Si quedó 3º o
												// siguientes, es el nombre del primero.
	public String venue = ""; // Pista física donde se celebró
	public String remarks = ""; // Equivale a comment (para ese galgo y esa carrera)
	public String winTime = ""; // Tiempo que hizo el galgo que ganó la carrera
	public String going = "";
	public String sp = "";
	public String clase = "";// Tipo de carrera
	public String calculatedTime = "";// Tiempo de este galgo en la carrera (no del que ganó)

	public GbgbGalgoHistoricoCarrera(Long id_carrera, Long id_campeonato, Calendar fecha, Integer distancia,
			String trap, String stmHcp, String posicion, String by, String galgo_primero_o_segundo, String venue,
			String remarks, String winTime, String going, String sp, String clase, String calculatedTime) {
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
	}

	/**
	 * @return
	 */
	public static String generarCamposSqlCreateTableDeDetalle() {

		String out = "id_carrera BIGINT NOT NULL, id_campeonato BIGINT NOT NULL, ";
		out += "anio SMALLINT, mes SMALLINT, dia SMALLINT, ";
		out += "distancia SMALLINT, trap varchar(1), stmhcp varchar(10), ";
		out += "posicion varchar(1), by_dato varchar(15), galgo_primero_o_segundo varchar(30), ";
		out += "venue varchar(20), remarks varchar(15), win_time decimal(6,2), ";
		out += "going varchar(5), sp varchar(5), clase varchar(5), calculated_time decimal(6,2)";

		return out;
	}

	public String generarDatosParaExportarSql() {
		String SEP = Constantes.SEPARADOR_CAMPO;
		SimpleDateFormat sdf = new SimpleDateFormat("yyyy" + SEP + "MM" + SEP + "dd");

		String out = "";

		out += id_carrera != null ? id_carrera : "";
		out += SEP;

		out += id_campeonato != null ? id_campeonato : "";
		out += SEP;

		out += sdf.format(fecha.getTime()) + SEP;

		out += distancia != null ? distancia : "";
		out += SEP;

		out += trap != null ? trap : "";
		out += SEP;

		out += stmHcp != null ? stmHcp : "";
		out += SEP;

		out += posicion != null ? posicion : "";
		out += SEP;

		out += by != null ? by : "";
		out += SEP;

		out += galgo_primero_o_segundo != null ? galgo_primero_o_segundo : "";
		out += SEP;

		out += venue != null ? venue : "";
		out += SEP;

		out += remarks != null ? remarks : "";
		out += SEP;

		out += winTime != null ? winTime : "";
		out += SEP;

		out += going != null ? going : "";
		out += SEP;

		out += sp != null ? sp : "";
		out += SEP;
		out += clase != null ? clase : "";
		out += SEP;
		out += calculatedTime != null ? calculatedTime : "";

		return out;

	}

}
