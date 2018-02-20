package casa.galgos.betbright;

import utilidades.Constantes;

public class CarreraGalgoSemillaBetright {

	public String id;// dia#hora#estadio#galgo_nombre
	public String galgoNombre;
	public Integer trap;
	public String entrenador;
	public Float precioSp;

	CarreraSemillaBetright carrera;

	public CarreraGalgoSemillaBetright(String id, String galgoNombre, Integer trap, String entrenador, Float precioSp,
			CarreraSemillaBetright carrera) {
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
		out += id + Constantes.SEPARADOR_CAMPO;
		out += carrera.dia + Constantes.SEPARADOR_CAMPO;
		out += carrera.hora + Constantes.SEPARADOR_CAMPO;
		out += carrera.estadio + Constantes.SEPARADOR_CAMPO;
		out += galgoNombre + Constantes.SEPARADOR_CAMPO;
		out += trap + Constantes.SEPARADOR_CAMPO;
		out += entrenador + Constantes.SEPARADOR_CAMPO;
		out += precioSp;
		out += Constantes.SEPARADOR_FILA;
		return out;
	}

	public String generarSqlCreateTable(String subtipo) {

		String out = "CREATE TABLE IF NOT EXISTS datos_desa.tb_cg_semillas_betbright" + subtipo + " (";
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
