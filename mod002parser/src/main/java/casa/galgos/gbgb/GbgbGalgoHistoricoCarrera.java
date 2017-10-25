package casa.galgos.gbgb;

import java.io.Serializable;
import java.text.SimpleDateFormat;
import java.util.Calendar;

public class GbgbGalgoHistoricoCarrera implements Serializable {

	private static final long serialVersionUID = 1L;

	public static final SimpleDateFormat FORMATO = new SimpleDateFormat("yyyyMMddhhmm");

	public Long id_carrera; // Ej. http://www.gbgb.org.uk/resultsRace.aspx?id=2029176
	public Long id_campeonato; // Ej. http://www.gbgb.org.uk/resultsMeeting.aspx?id=151735

	public Calendar fecha; // Solo dia, pero no hora
	public Integer distancia;
	public String trap;
	public String stmHcp; // Equivale a "Time/Sec."
	public String posicion;
	public String by; // NO equivale a SP
	public String galgo_primero_o_segundo; // Si el galgo de esta clase quedó primero, este campo es el nombre del
											// segundo. Si quedó segundo, es el nombre del primero. Si quedó 3º o
											// siguientes, es el nombre del primero.
	public String venue; // Pista física donde se celebró
	public String remarks; // Equivale a comment (para ese galgo y esa carrera)
	public String winTime; // Tiempo que hizo el galgo que ganó la carrera
	public String going;
	public String sp;
	public String clase;// Tipo de carrera
	public String calculatedTime;// Tiempo de este galgo en la carrera (no del que ganó)

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

}
