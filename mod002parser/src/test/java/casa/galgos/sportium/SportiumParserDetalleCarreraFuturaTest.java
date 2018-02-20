package casa.galgos.sportium;

import java.util.ArrayList;
import java.util.List;

import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;
import org.junit.After;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;

import junit.framework.Assert;
import utilidades.ResourceFile;

/**
 * @author root
 *
 */
public class SportiumParserDetalleCarreraFuturaTest {

	@Before
	public void iniciar() {
	}

	@Rule
	public ResourceFile trozoPaginaFuturo = new ResourceFile("/" + "sportium_carrera_detalle_con_SP_filadetalle.html");

	@Test
	public void parsearTbodyFilaTest() throws Exception {

		String contenidoWeb = trozoPaginaFuturo.getContent("ISO-8859-1");

		Document doc = Jsoup.parse(contenidoWeb);

		Elements tablaDeGalgos = doc.getElementsByClass("racecard");
		Element tbody = (Element) tablaDeGalgos.get(0).childNode(1);

		List<SportiumGalgoFuturoEnCarreraAux> out = new ArrayList<SportiumGalgoFuturoEnCarreraAux>();

		SportiumParserDetalleCarreraFutura.parsearTbodyFila(tbody, out);

		Assert.assertTrue(out != null);
		Assert.assertTrue(out.size() == 1);

		for (SportiumGalgoFuturoEnCarreraAux fila : out) {
			Assert.assertTrue(fila != null && fila.galgoNombre != null && !fila.galgoNombre.isEmpty());
		}
	}

	@After
	public void terminar() {
	}

}