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
public class GF03ParserTest extends PadreTest {

	GF03Parser instancia;
	ResourceFile res;

	@Before
	public void iniciar() {
		instancia = new GF03Parser();
		res = new ResourceFile("/" + instancia.getPathEntrada(TAG_DIA_TEST));
	}

	@Test
	public void testParsear() throws Exception {
		String out = instancia.parsear(TAG_DIA_TEST, res.getContent());

		assert (out.startsWith("J20170914174424|IKM|||707460621158239|1nkemia IUCT Group SA|20.70|0.71|0.02|0.54|64.63|37.97|37.97|35.22|20.70|35.22|64.63\n" + 
				"J20170914174424"));
		assert (out.contains("\nJ20170914174424|ACS"));
	}

}
