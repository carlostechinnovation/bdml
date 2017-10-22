package casa.galgos.gbgb;

import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;

import junit.framework.Assert;
import utilidades.ResourceFile;

/**
 * @author root
 *
 */
public class GbgbParserCarrerasTest {

	@Before
	public void iniciar() {
	}

	@Rule
	public ResourceFile res = new ResourceFile("/" + "galgos_20171022_GBGB_bruto_carreras_sin_filtrar");

	@Test
	public void testParsear() throws Exception {

		GbgbCarrerasInfoUtil out = GbgbParserCarreras.parsear(res.getContent());

		// TODO rellenar
		Assert.assertTrue(out != null);
	}

}