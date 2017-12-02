package casa.galgos.sportium;

import java.util.List;

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
	public ResourceFile res = new ResourceFile("/" + "sportium_carrera_detalle.html");

	@Test
	public void parsearTest() throws Exception {

		String contenidoWeb = res.getContent("ISO-8859-1");

		List<String> out = SportiumParserDetalleCarreraFutura.parsear(contenidoWeb);

		Assert.assertTrue(out != null);
		Assert.assertTrue(!out.isEmpty());
		Assert.assertTrue(out.size() == 6);

		for (String fila : out) {
			Assert.assertTrue(fila != null && !fila.isEmpty());
		}

	}

	@After
	public void terminar() {
	}

}