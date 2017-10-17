/**
 * 
 */
package casa.mod002a.bolsamadrid;

import java.util.List;

import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.nodes.Node;
import org.jsoup.nodes.TextNode;

import casa.mod002a.parser.ParserDeDia;
import utilidades.Constantes;

public class BM01Parser extends ParserDeDia {

	public BM01Parser() {
		super();
	}

	public String getPathEntrada(String tagDia) {
		return tagDia + Constantes.BM + "01";
	}

	public String parsear(String tagDia, String in) {

		MY_LOGGER.info("Parseando...");

		Document doc = Jsoup.parse(in);
		Node contenido = doc.childNodes().get(1).childNodes().get(2).childNodes().get(0).childNodes().get(1);
		Node contenido2 = contenido.childNode(0).childNode(3).childNode(3).childNode(3);

		List<Node> hijos = contenido2.childNodes().get(0).childNodes();
		int contadorMax = 0;
		int indiceMax = -1;
		for (int i = 0; i < hijos.size(); i++) {
			if (contadorMax < hijos.get(i).childNodeSize() && hijos.get(i).childNodeSize() > 2
					&& hijos.get(i).childNode(1) instanceof Element) {
				contadorMax = hijos.get(i).childNode(1).childNodeSize();
				indiceMax = i;
			}
		}
		Node nodoConMuchosHijos = hijos.get(indiceMax);
		Node tablaBM = nodoConMuchosHijos.childNode(1);
		String out = parsearTablaBM(tagDia, tablaBM);

		return out;
	}

	/**
	 * @param tablaBM
	 * @return
	 */
	public String parsearTablaBM(String tagDia, Node tablaBM) {

		String out = "";

		List<Node> lista = tablaBM.childNode(1).childNodes();

		// ISIN|Últ.|% Dif.|Máx.|Mín.|Volumen|Efectivo (miles €)
		Node cabecera = lista.get(0);

		for (int i = 1; i < lista.size(); i++) {
			Node nodo = lista.get(i);

			if (nodo instanceof Element) {

				Node isin_nombre = nodo.childNode(1).childNode(0);
				String a = isin_nombre.attr("href");
				String isin = a.isEmpty() ? "" : a.substring(a.indexOf("ISIN=") + 5, a.length());

				out += tagDia + Constantes.SEPARADOR_CAMPO;
				out += isin + Constantes.SEPARADOR_CAMPO;
				out += ((TextNode) nodo.childNode(2).childNode(0)).toString().replace(".", "").replace(",", ".")
						+ Constantes.SEPARADOR_CAMPO;
				out += ((TextNode) nodo.childNode(3).childNode(0)).toString().replace(".", "").replace(",", ".")
						+ Constantes.SEPARADOR_CAMPO;
				out += ((TextNode) nodo.childNode(4).childNode(0)).toString().replace(".", "").replace(",", ".")
						+ Constantes.SEPARADOR_CAMPO;
				out += ((TextNode) nodo.childNode(5).childNode(0)).toString().replace(".", "").replace(",", ".")
						+ Constantes.SEPARADOR_CAMPO;
				out += ((TextNode) nodo.childNode(6).childNode(0)).toString().replace(".", "").replace(",", ".")
						+ Constantes.SEPARADOR_CAMPO;
				out += ((TextNode) nodo.childNode(7).childNode(0)).toString().replace(".", "").replace(",", ".");
				out += Constantes.SEPARADOR_FILA;
			}
		}

		return out;
	}

	public String generarSqlCreateTable() {

		return "CREATE TABLE IF NOT EXISTS datos_desa.tb_bm01 (tag_dia varchar(15), isin varchar(15), precio_ultimo decimal(8,4), "
				+ "porcentaje_diferencia decimal(5,2), max decimal(8,4), min decimal(8,4),"
				+ "volumen decimal(12,0), efectivo_miles_euros decimal(10,2)" + ");";
	}

}