/**
 * 
 */
package casa.mod002a.googlefinance;

import org.junit.Before;
import org.junit.Test;

import utilidades.ResourceFile;
import utilidadestest.PadreTest;

/**
 * @author root
 *
 */
public class GF02ParserTest extends PadreTest {

	GF02Parser instancia;
	ResourceFile res;

	@Before
	public void iniciar() {
		instancia = new GF02Parser();
		res = new ResourceFile("/" + instancia.getPathEntrada(TAG_DIA_TEST));
	}

	@Test
	public void testParsear() throws Exception {
		String out = instancia.parsear(TAG_DIA_TEST, res.getContent());

		assert (out.startsWith("J20170914174424|IKM|||707460621158239|1nkemia IUCT Group SA|-|-|-|-|-|-|0.00|-|56.66M|-\n" + 
				"J20170914174424"));
		assert (out.contains(
				"\nJ20170914174424|ACS"));
	}

}
