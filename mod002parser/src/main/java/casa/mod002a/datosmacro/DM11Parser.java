/**
 * 
 */
package casa.mod002a.datosmacro;

import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;

import casa.mod002.parser.ParserDeDia;
import utilidades.Constantes;

public class DM11Parser extends ParserDeDia {

	public DM11Parser() {
		super();
	}

	public String getPathEntrada(String tagDia) {
		return tagDia + Constantes.DATOSMACRO + "10";
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
