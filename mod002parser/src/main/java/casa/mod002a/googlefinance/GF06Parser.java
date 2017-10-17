/**
 * 
 */
package casa.mod002a.googlefinance;

import utilidades.Constantes;

public class GF06Parser extends GFComun {

	public GF06Parser() {
		super();
	}

	public String getPathEntrada(String tagDia) {
		return tagDia + Constantes.GF + "06";
	}

	public String generarSqlCreateTable() {

		// TODO
		return "CREATE TABLE IF NOT EXISTS datos_desa.tb_gf06 (" + ");";
	}

}