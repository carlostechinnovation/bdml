/**
 * 
 */
package casa.mod002a.datosmacro;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.nodes.Node;
import org.jsoup.nodes.TextNode;

import casa.mod002a.parser.ParserDeDia;
import utilidades.Constantes;

public class DM01Parser extends ParserDeDia {

	public DM01Parser() {
		super();
	}

	public String getPathEntrada(String tagDia) {
		return tagDia + Constantes.DATOSMACRO + "01";
	}

	public String parsear(String tagDia, String in) {

		MY_LOGGER.info("Parseando...");

		Document doc = Jsoup.parse(in);

		Element tablaConContenidos = doc.getElementById("myTabContent");

		Element paroPorPaises = tablaConContenidos.getElementById("lab");
		Element paroJuvenil = tablaConContenidos.getElementById("laby");
		Element paroPorSexo = tablaConContenidos.getElementById("labs");

		String out = extraerInfoSobreParo(tagDia, paroPorPaises, paroJuvenil, paroPorSexo);

		return out;
	}

	/**
	 * Genera una cadena de datos sobre PARO. Estructura:
	 * 
	 * @param paroPorPaises
	 * @param paroJuvenil
	 * @param paroPorSexo
	 * @return
	 */
	public String extraerInfoSobreParo(String tagDia, Element paroPorPaises, Element paroJuvenil, Element paroPorSexo) {

		// POR PAISES
		Node porpaisesCabecera = paroPorPaises.childNode(2).childNode(3).childNode(1);
		List<Node> porpaisesCuerpo = paroPorPaises.childNode(2).childNode(3).childNode(3).childNodes();
		Map<String, String> outPorPaises = extraerFilasDePaisesInteresantesPorPaises(porpaisesCuerpo);

		// JUVENIL
		Node juvenilCabecera = paroJuvenil.childNode(2).childNode(3).childNode(1);
		List<Node> juvenilCuerpo = paroJuvenil.childNode(2).childNode(3).childNode(3).childNodes();
		Map<String, String> outJuvenil = extraerFilasDePaisesInteresantesJuvenil(juvenilCuerpo);

		// POR SEXO
		Node porSexoCebecera = paroPorSexo.childNode(2).childNode(3).childNode(1);
		List<Node> porSexoCuerpo = paroPorSexo.childNode(2).childNode(3).childNode(3).childNodes();
		Map<String, String> outPorSexo = extraerFilasDePaisesInteresantesPorSexo(porSexoCuerpo);

		return joinPorIdPais(tagDia, outPorPaises, outJuvenil, outPorSexo);

	}

	/**
	 * @return
	 */
	public Map<String, String> extraerFilasDePaisesInteresantesPorPaises(List<Node> lista) {

		Map<String, String> out = new HashMap<String, String>();

		if (lista != null && !lista.isEmpty()) {
			for (Node nodePais : lista) {

				String paisExtraido = esPaisInteresante(
						((TextNode) nodePais.childNode(0).childNode(0).childNode(0)).toString());

				if (paisExtraido != null) {

					String datosDePais = "";
					datosDePais += nodePais.childNode(1).childNode(0).toString().replaceAll(",", ".").replaceAll("%",
							"") + Constantes.SEPARADOR_CAMPO;
					datosDePais += nodePais.childNode(3).childNode(0).toString().replaceAll(",", ".")
							+ Constantes.SEPARADOR_CAMPO;
					datosDePais += nodePais.childNode(4).childNode(0).toString().replaceAll(",", ".")
							+ Constantes.SEPARADOR_CAMPO;
					datosDePais += nodePais.childNode(5).attr("data-value").replaceAll("-", "|");

					// Pais -> "Tasa de paro | Variacion | Variacion anual | AAAA | MM | DD"
					out.put(paisExtraido, datosDePais);
				}

			}
		}

		// Para cada pais interesante, relleno dato o cadena de vacíos
		String cadenaVacios = "|||||";
		Map<String, String> out2 = new HashMap<String, String>();
		for (String pais : Constantes.DM_PAISES_INTERESANTES) {
			if (out.containsKey(pais)) {
				out2.put(pais, out.get(pais));
			} else {
				out2.put(pais, cadenaVacios);
			}

		}

		return out2;
	}

	/**
	 * @return
	 */
	public Map<String, String> extraerFilasDePaisesInteresantesJuvenil(List<Node> lista) {

		Map<String, String> out = new HashMap<String, String>();

		if (lista != null && !lista.isEmpty()) {
			for (Node nodePais : lista) {

				String paisExtraido = esPaisInteresante(
						((TextNode) nodePais.childNode(0).childNode(0).childNode(0)).toString());

				if (paisExtraido != null) {

					String datosDePais = "";

					datosDePais += nodePais.childNode(1).childNode(0).toString().replaceAll(",", ".").replaceAll("%",
							"") + Constantes.SEPARADOR_CAMPO;
					datosDePais += nodePais.childNode(3).childNode(0).toString().replaceAll(",", ".").replaceAll("%",
							"") + Constantes.SEPARADOR_CAMPO;
					datosDePais += nodePais.childNode(5).childNode(0).toString().replaceAll(",", ".").replaceAll("%",
							"") + Constantes.SEPARADOR_CAMPO;
					datosDePais += nodePais.childNode(7).attr("data-value").replaceAll("-", "|");

					// Pais -> "Tasa de paro | Variacion | Variacion anual | AAAA | MM | DD"
					out.put(paisExtraido, datosDePais);

				}

			}
		}

		// Para cada pais interesante, relleno dato o cadena de vacíos
		String cadenaVacios = "|||||";
		Map<String, String> out2 = new HashMap<String, String>();
		for (String pais : Constantes.DM_PAISES_INTERESANTES) {
			if (out.containsKey(pais)) {
				out2.put(pais, out.get(pais));
			} else {
				out2.put(pais, cadenaVacios);
			}

		}

		return out2;
	}

	/**
	 * @return
	 */
	public Map<String, String> extraerFilasDePaisesInteresantesPorSexo(List<Node> lista) {

		Map<String, String> out = new HashMap<String, String>();

		if (lista != null && !lista.isEmpty()) {
			for (Node nodePais : lista) {

				String paisExtraido = esPaisInteresante(
						((TextNode) nodePais.childNode(0).childNode(0).childNode(0)).toString());

				if (paisExtraido != null) {

					String datosDePais = "";

					datosDePais += nodePais.childNode(1).childNode(0).toString().replaceAll(",", ".").replaceAll("%",
							"") + Constantes.SEPARADOR_CAMPO;
					datosDePais += nodePais.childNode(3).childNode(0).toString().replaceAll(",", ".").replaceAll("%",
							"") + Constantes.SEPARADOR_CAMPO;
					datosDePais += nodePais.childNode(5).attr("data-value").replaceAll("-", "|");

					// Pais -> "Hombres | mujeres | AAAA | MM | DD"
					out.put(paisExtraido, datosDePais);

				}

			}
		}

		// Para cada pais interesante, relleno dato o cadena de vacíos
		String cadenaVacios = "||||";
		Map<String, String> out2 = new HashMap<String, String>();
		for (String pais : Constantes.DM_PAISES_INTERESANTES) {
			if (out.containsKey(pais)) {
				out2.put(pais, out.get(pais));
			} else {
				out2.put(pais, cadenaVacios);
			}

		}

		return out2;
	}

	/**
	 * @param texto
	 * @return Pais-interesante o NULL
	 */
	public static String esPaisInteresante(String texto) {

		for (String pais_interesante : Constantes.DM_PAISES_INTERESANTES) {
			if (texto.contains(pais_interesante)) {
				return pais_interesante;
			}
		}

		return null;
	}

	/**
	 * @param outPorPaises
	 * @param outJuvenil
	 * @param outPorSexo
	 * @return
	 */
	public String joinPorIdPais(String tagDia, Map<String, String> outPorPaises, Map<String, String> outJuvenil,
			Map<String, String> outPorSexo) {

		List<String> listaUnicidad = new ArrayList<String>();

		listaUnicidad.addAll(outPorPaises.keySet());
		listaUnicidad.addAll(outJuvenil.keySet());
		listaUnicidad.addAll(outPorSexo.keySet());

		// Recorrer paises
		String out = "";
		if (listaUnicidad != null && !listaUnicidad.isEmpty()) {
			for (String pais : listaUnicidad) {

				out += tagDia + Constantes.SEPARADOR_CAMPO;

				out += pais + Constantes.SEPARADOR_CAMPO;
				out += outPorPaises.get(pais) + Constantes.SEPARADOR_CAMPO;
				out += outJuvenil.get(pais) + Constantes.SEPARADOR_CAMPO;
				out += outPorSexo.get(pais);
				out += Constantes.SEPARADOR_FILA;
			}
		}

		return out;
	}

	public String generarSqlCreateTable() {
		// TODO Auto-generated method stub
		return null;
	}

}
