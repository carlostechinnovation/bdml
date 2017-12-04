package casa.galgos.sportium;

import utilidades.Constantes;

public class SportiumCarreraGalgo {

	public String id;// dia#hora#estadio#galgo_nombre
	public String galgoNombre;
	public SportiumCarrera modelo;

	public SportiumCarreraGalgo(String id, String galgoNombre, SportiumCarrera modelo) {
		super();
		this.id = id;
		this.galgoNombre = galgoNombre;
		this.modelo = modelo;
	}

	@Override
	public String toString() {
		String out = "";
		out += id + Constantes.SEPARADOR_CAMPO;
		out += modelo.dia + Constantes.SEPARADOR_CAMPO;
		out += modelo.hora + Constantes.SEPARADOR_CAMPO;
		out += modelo.estadio + Constantes.SEPARADOR_CAMPO;
		out += galgoNombre;
		out += Constantes.SEPARADOR_FILA;
		return out;
	}

	public String generarSqlCreateTable() {

		String out = "CREATE TABLE IF NOT EXISTS datos_desa.tb_galgos_carreragalgo" + " (";

		out += "id varchar(100) NOT NULL  PRIMARY KEY, ";
		out += "dia BIGINT NOT NULL, ";
		out += "hora BIGINT NOT NULL, ";
		out += "estadio varchar(100) NOT NULL, ";
		out += "galgo_nombre varchar(100) NOT NULL";

		out += ");";

		return out;
	}
}
