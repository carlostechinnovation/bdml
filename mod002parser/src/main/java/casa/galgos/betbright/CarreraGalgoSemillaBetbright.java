package casa.galgos.betbright;

import utilidades.Constantes;

public class CarreraGalgoSemillaBetbright {

	public String id;// dia#hora#estadio#galgo_nombre
	public String galgoNombre;
	public Integer trap;
	public String entrenador;
	public Float precioSp;

	CarreraSemillaBetbright carrera;

	public CarreraGalgoSemillaBetbright(String id, String galgoNombre, Integer trap, String entrenador, Float precioSp,
			CarreraSemillaBetbright carrera) {
		super();
		this.id = id;
		this.galgoNombre = galgoNombre;
		this.trap = trap;
		this.entrenador = entrenador;
		this.precioSp = precioSp;
		this.carrera = carrera;
	}

	@Override
	public String toString() {
		String out = "";
		out += id;
		out += Constantes.SEPARADOR_CAMPO;
		out += carrera.dia != null ? carrera.dia : "null";
		out += Constantes.SEPARADOR_CAMPO;
		out += carrera.hora != null ? carrera.hora : "null";
		out += Constantes.SEPARADOR_CAMPO;
		out += carrera.estadio != null && !carrera.estadio.isEmpty() ? carrera.estadio : "";
		out += Constantes.SEPARADOR_CAMPO;
		out += galgoNombre != null && !galgoNombre.isEmpty() ? galgoNombre : "";
		out += Constantes.SEPARADOR_CAMPO;
		out += trap != null ? trap : "null";
		out += Constantes.SEPARADOR_CAMPO;
		out += (entrenador != null && !entrenador.isEmpty() ? entrenador : "");
		out += Constantes.SEPARADOR_CAMPO;
		out += precioSp != null ? precioSp : "null";
		out += Constantes.SEPARADOR_FILA;
		return out;
	}

	public String generarSqlCreateTable() {

		String out = "CREATE TABLE IF NOT EXISTS datos_desa.tb_cg_semillas_betbright" + " (";
		out += "id varchar(100) NOT NULL  PRIMARY KEY, ";
		out += "dia BIGINT NOT NULL, ";
		out += "hora BIGINT NOT NULL, ";
		out += "estadio varchar(100) NOT NULL, ";
		out += "galgo_nombre varchar(100) NOT NULL, ";
		out += "trap SMALLINT NOT NULL, ";
		out += "entrenador varchar(50) NOT NULL, ";
		out += "precio_sp decimal(10,2)";
		out += ");";

		return out;
	}
}
