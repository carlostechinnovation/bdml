package casa.mod002a.boe;

import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;

import casa.mod002a.boe.BoeParser;
import utilidades.Constantes;
import utilidades.ResourceFile;

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
		String out = BoeParser.parsear(res.getContent());
		assert (out.equals(TAG_DIA_TEST));
	}

}