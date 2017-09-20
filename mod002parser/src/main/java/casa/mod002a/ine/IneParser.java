/**
 * 
 */
package casa.mod002a.ine;

import java.util.ArrayList;
import java.util.List;

import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.nodes.Node;
import org.jsoup.nodes.TextNode;
import org.jsoup.select.Elements;

import casa.mod002a.parser.ParserDeDia;
import utilidades.Constantes;

public class IneParser extends ParserDeDia {

	public IneParser() {
		super();
	}

	public String getPathEntrada(String tagDia) {
		return tagDia + Constantes.INE + "01";
	}

	public String parsear(String tagDia, String in) {
		MY_LOGGER.info("Parseando...");
		Document doc = Jsoup.parse(in);
		Elements tabla = doc.getElementsByClass("tablaMini");
		return procesarTablaMiniDelIne(tagDia, tabla);
	}

	/**
	 * @param tagDia
	 * @param tabla
	 * @return
	 */
	public String procesarTablaMiniDelIne(String tagDia, Elements tabla) {
		Element item = tabla.get(0).getAllElements().get(0);
		List<Node> nodos = item.childNodes();
		List<Node> nodos2 = nodos.get(1).childNodes();

		// indicador|periodo|valor|variacion_porcentaje
		Node titulos = nodos2.get(1);

		List<TextNode> filaIPC = extraerNodesConDato(nodos2.get(3).childNodes(), false);
		List<TextNode> filaEPAOcupados = extraerNodesConDato(nodos2.get(5).childNodes(), true);
		List<TextNode> filaEPAParo = extraerNodesConDato(nodos2.get(7).childNodes(), true);
		List<TextNode> filaPIB = extraerNodesConDato(nodos2.get(9).childNodes(), true);
		List<TextNode> filaPoblacionTotal = extraerNodesConDato(nodos2.get(11).childNodes(), true);

		String out = pintar(filaIPC) + pintar(filaEPAOcupados) + pintar(filaEPAParo) + pintar(filaPIB)
				+ pintar(filaPoblacionTotal);

		return out;

	}

	/**
	 * @param listaIn
	 * @param quitarSegundoElemento
	 * @return
	 */
	public List<TextNode> extraerNodesConDato(List<Node> listaIn, Boolean quitarSegundoElemento) {

		List<TextNode> listaOut = new ArrayList<TextNode>();

		if (listaIn != null && !listaIn.isEmpty()) {
			for (Node it : listaIn) {

				if (it instanceof Element) {
					Node a = it.childNode(0);
					if (a instanceof Element) {
						List<Node> b = a.childNodes();
						Object c = b.get(0);
						if (c instanceof TextNode) {
							listaOut.add((TextNode) c);
						}
					} else if (a instanceof TextNode) {
						listaOut.add((TextNode) a);
					}
				}
			}

		}

		if (quitarSegundoElemento) {
			listaOut.remove(1);
		}

		return listaOut;
	}

	/**
	 * @param listaIn
	 * @return
	 */
	public String pintar(List<TextNode> listaIn) {
		String out = "";
		int i;
		if (!listaIn.isEmpty()) {
			for (i = 0; i < listaIn.size(); i++) {

				out += listaIn.get(i).toString().replaceAll(".", "").replaceAll(",", ".");

				if (i < (listaIn.size() - 1)) {
					out += Constantes.SEPARADOR_CAMPO;
				} else {
					out += Constantes.SEPARADOR_FILA;
				}

			}
		}
		return out;
	}

	public String generarSqlCreateTable() {
		return "CREATE TABLE datos_desa.tb_ine (tag_dia varchar(15), indicador varchar(30), "
				+ "periodo varchar(15), valor decimal(10,4), variacion_porcentaje decimal(10,4)" + ");";
	}

}
