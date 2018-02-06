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
	public ResourceFile res = new ResourceFile("/" + "sportium_carrera_detalle_con_SP.html");

	@Test
	public void parsearTest() throws Exception {

		String contenidoWeb = res.getContent("ISO-8859-1");

		List<SportiumGalgoFuturoEnCarreraAux> out = SportiumParserDetalleCarreraFutura.parsear(contenidoWeb);

		Assert.assertTrue(out != null);
		Assert.assertTrue(!out.isEmpty());
		Assert.assertTrue(out.size() == 6);

		for (SportiumGalgoFuturoEnCarreraAux fila : out) {
			Assert.assertTrue(fila != null && fila.galgoNombre != null && !fila.galgoNombre.isEmpty());
		}

	}

	@After
	public void terminar() {
	}

}