/**
 * 
 */
package casa.mod002a.bolsamadrid;

import utilidades.Constantes;

public class BM06Parser extends BM01Parser {

	@Override
	public String getPathEntrada(String tagDia) {
		return tagDia + Constantes.BM + "06";
	}

	@Override
	public String generarSqlCreateTable() {

		return "CREATE TABLE datos_desa.tb_bm06 (tag_dia varchar(15), isin varchar(15), precio_ultimo decimal(8,4), "
				+ "porcentaje_diferencia decimal(5,2), max decimal(8,4), min decimal(8,4),"
				+ "volumen varchar(12,0), efectivo_miles_euros decimal(10,2)" + ");";
	}

}