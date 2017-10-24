package casa.mod002a.boe;

import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;

import junit.framework.Assert;
import utilidades.Constantes;
import utilidades.ResourceFile;
import utilidadestest.PadreTest;

/**
 * @author root
 *
 */
public class BoeParserTest extends PadreTest {

	@Before
	public void iniciar() {
	}

	@Rule
	public ResourceFile res = new ResourceFile("/" + Constantes.BOE_IN);

	@Test
	public void testParsear() throws Exception {
		String out = BoeParser.parsear(res.getContent("ISO-8859-1"));
		Assert.assertTrue(out.equals(TAG_DIA_TEST));
	}

}