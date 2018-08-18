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
public class SportiumParserCarrerasFuturasTest {

	@Before
	public void iniciar() {
	}

	@Rule
	public ResourceFile res = new ResourceFile("/" + "sportium_carreras_futuras.html");

	// @Rule
	// public ResourceFile res = new ResourceFile("/" +
	// "sportium_carreras_futuras_2.html");

	@Test
	public void parsearTest() throws Exception {

		String contenidoWeb = res.getContent("ISO-8859-1");

		List<CarreraSemillaSportium> out = SportiumParserCarrerasFuturas.parsear(contenidoWeb);

		// TODO rellenar
		Assert.assertTrue(out != null);
		Assert.assertTrue(!out.isEmpty());

		for (CarreraSemillaSportium fila : out) {
			Assert.assertTrue(fila.dia != null);
			Assert.assertTrue(fila.estadio != null && !fila.estadio.isEmpty());
			Assert.assertTrue(fila.hora != null);
			Assert.assertTrue(fila.urlDetalle != null && !fila.urlDetalle.isEmpty());
		}

	}

	@After
	public void terminar() {
	}

}