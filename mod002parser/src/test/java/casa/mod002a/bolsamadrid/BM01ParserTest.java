/**
 * 
 */
package casa.mod002a.bolsamadrid;

import org.junit.Before;
import org.junit.Test;

import utilidades.ResourceFile;
import utilidadestest.PadreTest;

/**
 * @author root
 *
 */
public class BM01ParserTest extends PadreTest {

	BM01Parser instancia;
	ResourceFile res;

	@Before
	public void iniciar() {
		instancia = new BM01Parser();
		res = new ResourceFile("/" + instancia.getPathEntrada(TAG_DIA_TEST));
	}

	@Test
	public void testParsear() throws Exception {
		String out = instancia.parsear(TAG_DIA_TEST, res.getContent());
		assert (out.startsWith("ES0105200416|0.0400|0.00|0.0400|0.0390|2269304|89.19\n" + "ES0"));
	}

}