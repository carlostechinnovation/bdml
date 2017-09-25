/**
 * 
 */
package casa.mod002a.datosmacro;

import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;

import casa.mod002a.parser.ParserDeDia;
import utilidades.Constantes;

public class DM03Parser extends ParserDeDia {

	public DM03Parser() {
		super();
	}

	public String getPathEntrada(String tagDia) {
		return tagDia + Constantes.DATOSMACRO + "03";
	}

	public String parsear(String tagDia, String in) {

		MY_LOGGER.info("Parseando...");
		Document doc = Jsoup.parse(in);
		// TODO
		return null;
	}

	public String generarSqlCreateTable() {
		// TODO Auto-generated method stub
		return null;
	}

}
