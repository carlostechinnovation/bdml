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

public class GF01Parser extends GFComun {

	public GF01Parser() {
		super();
	}

	public String getPathEntrada(String tagDia) {
		return tagDia + Constantes.GF + "01";
	}



	public String generarSqlCreateTable() {

		return "CREATE TABLE datos_desa.tb_gf01 (tag_dia varchar(15), ticker varchar(10), is_active varchar(2), "
				+ "is_supported_exchange varchar(2), " + "id varchar(20), " + "title varchar(255), "
				+ "QuoteLast decimal(5,2), " + "EPS decimal(5,2), QuotePercChange decimal(5,2), "
				+ "High52Week decimal(5,2), " + "Low52Week decimal(5,2), " + "Price52WeekPercChange decimal(5,2), "
				+ "Price50DayAverage decimal(5,2), Price150DayAverage decimal(5,2), "
				+ "Price200DayAverage decimal(5,2), Price13WeekPercChange decimal(5,2), "
				+ "Price26WeekPercChange decimal(5,2) " + ");";
	}

}