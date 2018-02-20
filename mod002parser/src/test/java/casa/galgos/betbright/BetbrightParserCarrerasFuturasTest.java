package casa.galgos.betbright;

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
public class BetbrightParserCarrerasFuturasTest {

	@Before
	public void iniciar() {
	}

	@Rule
	public ResourceFile res = new ResourceFile("/" + "betbright_carreras_futuras.html");

	@Test
	public void parsearTest() throws Exception {

		String contenidoWeb = res.getContent("ISO-8859-1");

		List<String> out = BetbrightParserCarrerasFuturas.parsear(contenidoWeb);

		// TODO rellenar
		Assert.assertTrue(out != null);
		Assert.assertTrue(!out.isEmpty());

		for (String fila : out) {
			Assert.assertTrue(fila != null && !fila.isEmpty());
		}

	}

	@After
	public void terminar() {
	}

}