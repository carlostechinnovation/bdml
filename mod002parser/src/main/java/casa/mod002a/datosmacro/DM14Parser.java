/**
 * 
 */
package casa.mod002a.datosmacro;

import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;

import casa.mod002a.parser.ParserDeDia;
import utilidades.Constantes;

public class DM14Parser extends ParserDeDia {

	public DM14Parser() {
		super();
	}

	@Override
	public String getPathEntrada(String tagDia) {
		return tagDia + Constantes.DATOSMACRO + "14";
	}

	@Override
	public String parsear(String tagDia, String in) {

		MY_LOGGER.info("Parseando...");
		Document doc = Jsoup.parse(in);
		// TODO
		return null;
	}

	@Override
	public String generarSqlCreateTable() {

		return null;
	}

}
