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
		return tagDia + Constantes.GF + "05";
	}

	public String generarSqlCreateTable() {

		// TODO
		return "CREATE TABLE datos_desa.tb_gf05 (" + ");";
	}

}