
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
public class BM02ParserTest extends PadreTest {

	BM02Parser instancia;
	ResourceFile res;

	@Before
	public void iniciar() {
		instancia = new BM02Parser();

	}

	@Test
	public void testParsear() throws Exception {

		for (int i = 1; i <= 7; i++) {

			res = new ResourceFile("/" + instancia.getPathEntrada(TAG_DIA_TEST) + "_0" + i);
			String out = instancia.parsear(TAG_DIA_TEST, res.getContent());

			if (i == 1) {
				assert (out.startsWith(
						"J20170914174424|ES0105200002|ABENGOA, S.A.|Mat.Basicos, Industria y Construcción | Ingeniería y Otros\n" + 
						"J20170914174424|ES0111845014"));
			}
		}

	}

}
