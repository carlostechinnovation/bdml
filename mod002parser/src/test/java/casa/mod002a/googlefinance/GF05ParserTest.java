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
public class GF05ParserTest extends PadreTest {

	GF05Parser instancia;
	ResourceFile res;

	@Before
	public void iniciar() {
		instancia = new GF05Parser();
		res = new ResourceFile("/" + instancia.getPathEntrada(TAG_DIA_TEST));
	}

	@Test
	public void testParsear() throws Exception {
		String out = instancia.parsear(TAG_DIA_TEST, res.getContent());

		assert (out.startsWith(TAG_DIA_TEST
				+ "|IKM|||707460621158239|1nkemia IUCT Group SA|-|-5.08|26.69|140.55|1,000.00|6,034.00|-51.79|0.06|-33.73\n"
				+ TAG_DIA_TEST));
		assert (out.contains("\n" + TAG_DIA_TEST + "|ACS"));
	}

}
