package casa.galgos.sportium;

import utilidades.Constantes;

public class CarreraGalgoSemillaSportium {

	public String id = "\\N";// dia#hora#estadio#galgo_nombre
	public String galgoNombre = "\\N";
	public Integer trap = null;
	public CarreraSemillaSportium modelo;

	public CarreraGalgoSemillaSportium(String id, String galgoNombre, Integer trap, CarreraSemillaSportium modelo) {
		super();
		this.id = id;
		this.galgoNombre = galgoNombre;
		this.trap = trap;
		this.modelo = modelo;
	}

	@Override
	public String toString() {
		String out = "";

		if (id.contains("20180229")) {
			// JAVA BUG 29 febrero
			out += id.replace("20180229", "20180228");
			out += Constantes.SEPARADOR_CAMPO;
			out += modelo.dia.toString().replace("20180229", "20180228");
			out += Constantes.SEPARADOR_CAMPO;
			out += modelo.hora.toString().replace("20180229", "20180228");
			out += Constantes.SEPARADOR_CAMPO;
		} else {
			out += id;
			out += Constantes.SEPARADOR_CAMPO;
			out += modelo.dia;
			out += Constantes.SEPARADOR_CAMPO;
			out += modelo.hora;
			out += Constantes.SEPARADOR_CAMPO;
		}

		out += modelo.estadio != null && !modelo.estadio.isEmpty() ? modelo.estadio : "\\N";
		out += Constantes.SEPARADOR_CAMPO;
		out += galgoNombre != null && !galgoNombre.isEmpty() ? galgoNombre : "\\N";
		out += Constantes.SEPARADOR_CAMPO;
		out += trap != null ? trap : "\\N";
		out += Constantes.SEPARADOR_FILA;
		return out;
	}

	public String generarSqlCreateTable() {

		String out = "CREATE TABLE IF NOT EXISTS datos_desa.tb_cg_semillas_sportium" + " (";

		out += "id varchar(100) NOT NULL  PRIMARY KEY, ";
		out += "dia BIGINT NOT NULL, ";
		out += "hora BIGINT NOT NULL, ";
		out += "estadio varchar(100) NOT NULL, ";
		out += "galgo_nombre varchar(100) NOT NULL,";
		out += "trap SMALLINT NOT NULL";
		out += ");";

		return out;
	}
}
