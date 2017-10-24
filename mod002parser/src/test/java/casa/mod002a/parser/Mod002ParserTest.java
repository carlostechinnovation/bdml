package casa.mod002a.parser;

import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;

import junit.framework.Assert;
import utilidades.ResourceFile;
import utilidadestest.PadreTest;

/**
 * @author root
 *
 */
public class Mod002ParserTest extends PadreTest {

	@Before
	public void iniciar() {
	}

	@Rule
	public ResourceFile res = new ResourceFile("/");

	@Test
	public void descargarYparsearCarrerasDeGalgosTest() throws Exception {

		Mod002Parser.descargarYparsearCarrerasDeGalgos("20171021",
				res.getFile().getAbsolutePath() + "galgos_20171021_GBGB_bruto");

		Assert.assertTrue(Mod002Parser.gbgbCarrerasDia != null);
		Assert.assertTrue(Mod002Parser.gbgbCarrerasDia.carreras != null);
		Assert.assertTrue(!Mod002Parser.gbgbCarrerasDia.carreras.isEmpty());
		Assert.assertTrue(Mod002Parser.historicosGalgos != null);
		Assert.assertTrue(!Mod002Parser.historicosGalgos.isEmpty());
	}

}