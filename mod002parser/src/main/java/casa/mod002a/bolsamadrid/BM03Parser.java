/**
 * 
 */
package casa.mod002a.bolsamadrid;

import java.util.Iterator;
import java.util.List;

import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.nodes.Node;
import org.jsoup.nodes.TextNode;

import casa.mod002a.parser.ParserDeDia;
import utilidades.Constantes;

public class BM03Parser extends ParserDeDia {

	public BM03Parser() {
		super();
	}

	public String getPathEntrada(String tagDia) {
		return tagDia + Constantes.BM + "03";
	}

	public String parsear(String tagDia, String in) {

		MY_LOGGER.info("Parseando...");

		Document doc = Jsoup.parse(in);
		List<Node> contenido = doc.childNode(1).childNode(2).childNode(0).childNode(1).childNode(0).childNode(3)
				.childNodes();

		List<Node> contenido2 = contenido.get(3).childNode(4).childNode(0).childNode(26).childNodes().get(0)
				.childNodes();

		String out = parsearTablaBM03(tagDia, contenido2);

		return out;
	}

	/**
	 * @param tagDia
	 * @param contenido2
	 * @return
	 */
	public String parsearTablaBM03(String tagDia, List<Node> contenido2) {

		String out = "";

		Iterator<Node> it = contenido2.iterator();
		while (it.hasNext()) {

			out += tagDia + Constantes.SEPARADOR_CAMPO;

			List<Node> datosEmpresa = it.next().childNodes();
			for (Node a : datosEmpresa) {
				if (a instanceof Element) {
					Element aa = (Element) a;
					
					for(Node aaa:aa.childNodes()) {

					if (aaa instanceof Element) {
						Node aaaa = aaa.childNodes().get(0);
						out += Constantes.tratar(aaaa.toString(), 1) + Constantes.SEPARADOR_CAMPO;

					} else if (aaa instanceof TextNode) {
						out += Constantes.tratar(aaa.toString(), 1) + Constantes.SEPARADOR_CAMPO;
					}
					
					}
					
					

				}
			}

			List<Node> datosDescripcion = it.next().childNodes();
			for (Node b : datosDescripcion) {
				if (b instanceof Element) {
					Element bb = (Element) b;
					List<Node> bbb = bb.childNodes().get(0).childNodes();

					Node titulo = bbb.get(0);
					if (titulo.childNodeSize() > 0) {
						out += Constantes.tratar(titulo.childNode(0).toString(), 1) + Constantes.SEPARADOR_CAMPO;
					} else {
						out += "" + Constantes.SEPARADOR_CAMPO;
					}

					if (bbb.size() > 3) {
						out += Constantes.tratar(
								Constantes.truncar(bbb.get(3).toString(), Constantes.BM03_LONGITUD_TRUNCATE), 1);
					} else {
						out += "" + Constantes.SEPARADOR_CAMPO;
					}

				}
			}

			out += Constantes.SEPARADOR_FILA;
		}

		return out;
	}

	public String generarSqlCreateTable() {

		return "CREATE TABLE datos_desa.tb_bm03 (tag_dia varchar(15), empresa varchar(50), "
				+ "dia varchar(15), num_registro_cnmv varchar(10), descripcion varchar(255)" + ");";
	}

}