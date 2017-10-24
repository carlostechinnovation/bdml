/**
 * 
 */
package casa.mod002a.bolsamadrid;

import org.junit.Before;
import org.junit.Test;

import junit.framework.Assert;
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

		for (int i = 1; i <= 2; i++) {

			res = new ResourceFile("/" + instancia.getPathEntrada(TAG_DIA_TEST) + "_0" + i);
			String out = instancia.parsear(TAG_DIA_TEST, res.getContent("ISO-8859-1"));

			if (i == 1) {
				Assert.assertTrue(out.startsWith(
						TAG_DIA_TEST + "|ES0105200002|ABENGOA, S.A.|Mat.Basicos, Industr| Ingeniería y Otros\n"
								+ TAG_DIA_TEST + "|ES0111845014"));
			}
		}

	}

	@Test
	public void generarSqlCreateTableTest() {
		String out = instancia.generarSqlCreateTable();
		Assert.assertTrue(out != null);
		Assert.assertTrue(out.contains("datos_desa.tb_bm02"));
	}

}