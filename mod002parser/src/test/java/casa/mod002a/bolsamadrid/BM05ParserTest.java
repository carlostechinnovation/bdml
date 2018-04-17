/**
 * 
 */
package casa.mod002a.bolsamadrid;

import org.junit.Before;
import org.junit.Ignore;
import org.junit.Test;

import junit.framework.Assert;
import utilidades.ResourceFile;
import utilidadestest.PadreTest;

/**
 * @author root
 *
 */
@Ignore
public class BM05ParserTest extends PadreTest {

	BM05Parser instancia;
	ResourceFile res;

	@Before
	public void iniciar() {
		instancia = new BM05Parser();
		res = new ResourceFile("/" + instancia.getPathEntrada(TAG_DIA_TEST));
	}

	@Test
	public void testParsear() throws Exception {
		String out = instancia.parsear(TAG_DIA_TEST, res.getContent("ISO-8859-1"));
		Assert.assertTrue(out.startsWith(TAG_DIA_TEST + "|ES0111845014|17.0650|-0.26|17.0800|17.0000|1060585|18065.77\n"
				+ TAG_DIA_TEST + "|ES0125220311"));
	}

	@Test
	public void generarSqlCreateTableTest() {
		String out = instancia.generarSqlCreateTable();
		Assert.assertTrue(out != null);
		Assert.assertTrue(out.contains("datos_desa.tb_bm05"));
	}
}