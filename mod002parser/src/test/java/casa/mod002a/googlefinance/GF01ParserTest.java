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
public class GF01ParserTest extends PadreTest {

	GF01Parser instancia;
	ResourceFile res;

	@Before
	public void iniciar() {
		instancia = new GF01Parser();
		res = new ResourceFile("/" + instancia.getPathEntrada(TAG_DIA_TEST));
	}

	@Test
	public void testParsear() throws Exception {
		String out = instancia.parsear(TAG_DIA_TEST, res.getContent());

		assert (out.startsWith(TAG_DIA_TEST
				+ "|IKM|||707460621158239|1nkemia IUCT Group SA|0.00|1.98|-2.33|2.36|-2.33|0.00|-5.32|2.10|2.07|2.14|2.15\n"
				+ TAG_DIA_TEST + "|ABB"));
		assert (out.contains("\n" + TAG_DIA_TEST + "|ACS"));
	}

}
