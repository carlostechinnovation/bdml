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
public class BM06ParserTest extends PadreTest {

	BM06Parser instancia;
	ResourceFile res;

	@Before
	public void iniciar() {
		instancia = new BM06Parser();
		res = new ResourceFile("/" + instancia.getPathEntrada(TAG_DIA_TEST));
	}

	@Test
	public void testParsear() throws Exception {
		String out = instancia.parsear(TAG_DIA_TEST, res.getContent());
		assert (out.startsWith(TAG_DIA_TEST + "|ES0111845014|17.0650|-0.26|17.0800|17.0000|1060585|18065.77\n"
				+ TAG_DIA_TEST + "|ES0125220311"));
	}

}