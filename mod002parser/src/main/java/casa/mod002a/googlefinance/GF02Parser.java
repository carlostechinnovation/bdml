/**
 * 
 */
package casa.mod002a.googlefinance;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.json.simple.parser.ParseException;

import utilidades.Constantes;

public class GF02Parser extends GFComun {

	public GF02Parser() {
		super();
	}

	public String getPathEntrada(String tagDia) {
		return tagDia + Constantes.GF + "02";
	}



	public String generarSqlCreateTable() {

		return "CREATE TABLE datos_desa.tb_gf01 (tag_dia varchar(15), ticker varchar(10), is_active varchar(2), "
				+ "is_supported_exchange varchar(2), id varchar(20), title varchar(255), "
				+ "MarketCap decimal(5,2), PE decimal(5,2),ForwardPE1Year decimal(5,2), DividendRecentQuarter decimal(10,2), DividendNextQuarter decimal(10,2),"
				+ "DPSRecentYear varchar(10), IAD varchar(10), DividendPerShare varchar(10), DividendYield varchar(10), Dividend varchar(10)"
				+ ");";
	}

}