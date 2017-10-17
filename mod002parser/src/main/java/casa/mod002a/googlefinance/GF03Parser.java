/**
 * 
 */
package casa.mod002a.googlefinance;

import utilidades.Constantes;

public class GF03Parser extends GFComun {

	public GF03Parser() {
		super();
	}

	public String getPathEntrada(String tagDia) {
		return tagDia + Constantes.GF + "03";
	}

	public String generarSqlCreateTable() {

		return "CREATE TABLE IF NOT EXISTS datos_desa.tb_gf03 (tag_dia varchar(15), ticker varchar(10), is_active varchar(2), "
				+ "is_supported_exchange varchar(2), id varchar(20), title varchar(255), "
				+ "BookValuePerShareYear decimal(7,2), CashPerShareYear decimal(7,2),"
				+ "CurrentRatioYear decimal(7,2), LTDebtToAssetsYear decimal(7,2), LTDebtToAssetsQuarter decimal(7,2),"
				+ "TotalDebtToAssetsYear decimal(7,2), TotalDebtToAssetsQuarter decimal(7,2), LTDebtToEquityYear decimal(7,2),"
				+ "LTDebtToEquityQuarter decimal(7,2), TotalDebtToEquityYear decimal(7,2), TotalDebtToEquityQuarter decimal(7,2)"
				+ ");";
	}

}