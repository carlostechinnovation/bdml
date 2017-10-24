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
public class GbgbParserGalgoHistoricoTest {

	String galgo_nombre = "Awesome Thing";

	@Before
	public void iniciar() {
	}

	@Rule
	public ResourceFile res = new ResourceFile("/" + "galgos_20171024_GBGB_bruto_galgohistorico_" + galgo_nombre);

	@Test
	public void testParsear() throws Exception {

		GbgbGalgoHistorico out = GbgbParserGalgoHistorico.parsear(res.getContent("ISO-8859-1"), galgo_nombre);

		Assert.assertTrue(out != null);
		Assert.assertTrue(out.galgo_nombre.equals(galgo_nombre));
		Assert.assertTrue(!out.carrerasHistorico.isEmpty());
		// TODO rellenar
	}

}