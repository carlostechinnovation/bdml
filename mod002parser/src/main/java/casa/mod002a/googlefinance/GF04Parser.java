/**
 * 
 */
package casa.mod002a.googlefinance;

import utilidades.Constantes;

public class GF04Parser extends GFComun {

	public GF04Parser() {
		super();
	}

	public String getPathEntrada(String tagDia) {
		return tagDia + Constantes.GF + "04";
	}

	public String generarSqlCreateTable() {

		return "CREATE TABLE datos_desa.tb_gf01 (tag_dia varchar(15), ticker varchar(10), is_active varchar(2), "
				+ "is_supported_exchange varchar(2), id varchar(20), title varchar(255), "

				+ "AINTCOV, ReturnOnInvestmentTTM, ReturnOnInvestment5Years, ReturnOnInvestmentYear, ReturnOnAssetsTTM, ReturnOnAssets5Years, ReturnOnAssetsYear, ReturnOnEquityTTM, ReturnOnEquity5Years, ReturnOnEquityYear"
				+ ");";
	}

}