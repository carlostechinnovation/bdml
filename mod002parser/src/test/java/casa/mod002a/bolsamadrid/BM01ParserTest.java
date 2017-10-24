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
public class BM01ParserTest extends PadreTest {

	BM01Parser instancia;
	ResourceFile res;

	@Before
	public void iniciar() {
		instancia = new BM01Parser();
		res = new ResourceFile("/" + instancia.getPathEntrada(TAG_DIA_TEST));
	}

	@Test
	public void testParsear() throws Exception {
		String out = instancia.parsear(TAG_DIA_TEST, res.getContent("ISO-8859-1"));
		Assert.assertTrue(out.startsWith(
				TAG_DIA_TEST + "|ES0111845014|17.0200|-0.58|17.1650|17.0200|4391193|74894.80\n" + TAG_DIA_TEST));
	}

	@Test
	public void generarSqlCreateTableTest() {
		String out = instancia.generarSqlCreateTable();
		Assert.assertTrue(out != null);
		Assert.assertTrue(out.contains("datos_desa.tb_bm01"));
	}

}