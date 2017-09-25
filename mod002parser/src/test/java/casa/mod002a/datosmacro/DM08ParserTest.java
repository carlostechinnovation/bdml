/**
 * 
 */
package casa.mod002a.datosmacro;

import org.junit.Before;
import org.junit.Test;

import utilidades.ResourceFile;
import utilidadestest.PadreTest;

/**
 * @author root
 *
 */
public class DM08ParserTest extends PadreTest {

	DM08Parser instancia;
	ResourceFile res;

	@Before
	public void iniciar() {
		instancia = new DM08Parser();
		res = new ResourceFile("/" + instancia.getPathEntrada(TAG_DIA_TEST));
	}

	@Test
	public void testParsear() throws Exception {
		String out = instancia.parsear(TAG_DIA_TEST, res.getContent());
		assert (out.startsWith(
				"J20170914174424|Brasil|8.2|0.60|2.30|2016|02|01|||||||6.40|8.80|2015|08|01\n" + "J20170914174424"));
		assert (out.contains("\nJ20170914174424|España"));
	}

}
