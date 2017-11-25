package casa.galgos.gbgb;

import java.io.Serializable;
import java.util.Calendar;

import utilidades.Constantes;

public class GbgbPosicionEnCarrera implements Serializable, GalgosGuardable {

	private static final long serialVersionUID = 1L;

	public Long id_carrera;
	public Long id_campeonato;

	public Short posicion;

	public String galgo_nombre;
	public Integer trap;
	public Float sp; // dinero apostado por la gente
	public String time_sec;
	public String time_distance;
	public Float peso_galgo;
	public String entrenador_nombre;
	public String galgo_padre;
	public String galgo_madre;
	public Integer nacimiento;
	public String comment;
	public Calendar fechaDeLaCarrera;
	public String url_galgo_historico;

	public GbgbPosicionEnCarrera(boolean todoNulos) {
		super();
	}

	public GbgbPosicionEnCarrera(Long id_carrera, Long id_campeonato, Short posicion, String galgo_nombre, Integer trap,
			Float sp, String time_sec, String time_distance, Float peso_galgo, String entrenador_nombre,
			String galgo_padre, String galgo_madre, Integer nacimiento, String comment, Calendar fechaDeLaCarrera,
			String url_galgo_historico) {
		super();
		this.id_carrera = id_carrera;
		this.id_campeonato = id_campeonato;
		this.posicion = posicion;
		this.galgo_nombre = galgo_nombre;
		this.trap = trap;
		this.sp = sp;
		this.time_sec = time_sec;
		this.time_distance = time_distance;
		this.peso_galgo = peso_galgo;
		this.entrenador_nombre = entrenador_nombre;
		this.galgo_padre = galgo_padre;
		this.galgo_madre = galgo_madre;
		this.nacimiento = nacimiento;
		this.comment = comment;
		this.fechaDeLaCarrera = fechaDeLaCarrera;
		this.url_galgo_historico = url_galgo_historico;
	}

	@Override
	public String generarSqlCreateTable(String sufijo) {

		String out = "CREATE TABLE IF NOT EXISTS datos_desa.tb_galgos_posiciones_en_carreras" + sufijo + " (";

		out += "id_carrera BIGINT NOT NULL,";
		out += "id_campeonato BIGINT NOT NULL,";
		out += "posicion SMALLINT,";

		out += "galgo_nombre varchar(30) NOT NULL,";
		out += "trap SMALLINT,";
		out += "sp decimal(6,2),";
		out += "time_sec decimal(6,2),";
		out += "time_distance varchar(15),";
		out += "peso_galgo decimal(4,2),";
		out += "entrenador_nombre varchar(30),";
		out += "galgo_padre varchar(50),";
		out += "galgo_madre varchar(30),";
		out += "nacimiento varchar(30),";
		out += "comment varchar(30),";
		out += "edad_en_dias INT";

		out += ");";

		return out;
	}

	@Override
	public String generarDatosParaExportarSql() {

		String SEP = Constantes.SEPARADOR_CAMPO;

		Integer edadEnDias = calcularEdadGalgoEnDias(nacimiento, fechaDeLaCarrera);

		String out = "";

		out += id_carrera != null ? id_carrera : "\\N";
		out += SEP;
		out += id_campeonato != null ? id_campeonato : "\\N";
		out += SEP;
		out += posicion != null ? posicion : "\\N";
		out += SEP;

		out += (galgo_nombre != null && !"".equals(galgo_nombre)) ? galgo_nombre : "\\N";
		out += SEP;
		out += trap != null ? trap : "\\N";
		out += SEP;
		out += (sp != null) ? sp : "\\N";
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

		out += Constantes.SEPARADOR_FILA;
		return out;

	}

	@Override
	public String generarPath(String pathDirBase) {
		return pathDirBase + "tb_galgos_posiciones_en_carreras_file";
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

}
