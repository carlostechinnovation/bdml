/**
 * 
 */
package casa.mod002a.bolsamadrid;

import java.util.List;

import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Node;

import utilidades.Constantes;

public class BM04Parser extends BM01Parser {

	@Override
	public String getPathEntrada(String tagDia) {
		return tagDia + Constantes.BM + "04";
	}

	@Override
	public String parsear(String tagDia, String in) {

		MY_LOGGER.info("Parseando...");

		Document doc = Jsoup.parse(in);
		List<Node> listaContenidos = doc.childNode(1).childNode(2).childNode(0).childNode(1).childNode(0).childNodes();

		String out = parsearTablaBM04(tagDia, listaContenidos);

		return out;
	}

	/**
	 * @param tagDia
	 * @param contenido2
	 * @return
	 */
	public String parsearTablaBM04(String tagDia, List<Node> contenido) {

		String out = "";

		return out;
	}

	@Override
	public String generarSqlCreateTable() {

		return "CREATE TABLE IF NOT EXISTS datos_desa.tb_bm04 (tag_dia varchar(15), isin varchar(15), precio_ultimo decimal(8,4), "
				+ "porcentaje_diferencia decimal(5,2), max decimal(8,4), min decimal(8,4),"
				+ "volumen varchar(12,0), efectivo_miles_euros decimal(10,2)" + ");";
	}

}