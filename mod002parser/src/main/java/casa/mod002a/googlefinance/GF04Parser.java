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

		return "CREATE TABLE datos_desa.tb_gf04 (tag_dia varchar(15), ticker varchar(10), is_active varchar(2), "
				+ "is_supported_exchange varchar(2), id varchar(20), title varchar(255), "

				+ "AINTCOV varchar(20), ReturnOnInvestmentTTM varchar(20), ReturnOnInvestment5Years varchar(20), ReturnOnInvestmentYear varchar(20),"
				+ " ReturnOnAssetsTTM varchar(20), ReturnOnAssets5Years varchar(20), ReturnOnAssetsYear varchar(20), ReturnOnEquityTTM varchar(20), ReturnOnEquity5Years varchar(20), ReturnOnEquityYear varchar(20)"
				+ ");";
	}

}