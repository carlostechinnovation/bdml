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
public class GF06ParserTest extends PadreTest {

	GF06Parser instancia;
	ResourceFile res;

	@Before
	public void iniciar() {
		instancia = new GF06Parser();
		res = new ResourceFile("/" + instancia.getPathEntrada(TAG_DIA_TEST));
	}

	@Test
	public void testParsear() throws Exception {
		String out = instancia.parsear(TAG_DIA_TEST, res.getContent());

		assert (out.startsWith(
				TAG_DIA_TEST + "|IKM|||707460621158239|1nkemia IUCT Group SA|-|-|-|-0.78|-\n" + TAG_DIA_TEST));
		assert (out.contains("\n" + TAG_DIA_TEST + "|ACS"));
	}

}
