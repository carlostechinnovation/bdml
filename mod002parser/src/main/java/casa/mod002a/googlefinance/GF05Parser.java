/**
 * 
 */
package casa.mod002a.googlefinance;

import utilidades.Constantes;

public class GF05Parser extends GFComun {

	public GF05Parser() {
		super();
	}

	public String getPathEntrada(String tagDia) {
		return tagDia + Constantes.GF + "05";
	}

	public String generarSqlCreateTable() {

		return "CREATE TABLE IF NOT EXISTS datos_desa.tb_gf05 (tag_dia varchar(15), ticker varchar(10), is_active varchar(2),"
				+ "is_supported_exchange varchar(2), id varchar(20), title varchar(255),"
				+ "Beta varchar(20),Float varchar(20),InstitutionalPercentHeld varchar(20),Volume varchar(20),"
				+ "AverageVolume varchar(20),GrossMargin varchar(20),EBITDMargin varchar(20),OperatingMargin varchar(20),"
				+ "NetProfitMarginPercent varchar(20)" + ");";
	}

}