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
public class BM03ParserTest extends PadreTest {

	BM03Parser instancia;
	ResourceFile res;

	@Before
	public void iniciar() {
		instancia = new BM03Parser();
		res = new ResourceFile("/" + instancia.getPathEntrada(TAG_DIA_TEST));
	}

	@Test
	public void testParsear() throws Exception {
		String out = instancia.parsear(TAG_DIA_TEST, res.getContent("ISO-8859-1"));
		Assert.assertTrue(out.startsWith(TAG_DIA_TEST
				+ "|INTERNATIONAL CONSOL|01/09/2017|Nº Reg.CNMV:| 256057|Programas de recompr|La Sociedad remite información sobre las operaciones efectuadas al amparo de su programa de recompra de acciones. \n"
				+ TAG_DIA_TEST + "|SOTOGRANDE"));

	}

	@Test
	public void generarSqlCreateTableTest() {
		String out = instancia.generarSqlCreateTable();
		Assert.assertTrue(out != null);
		Assert.assertTrue(out.contains("datos_desa.tb_bm03"));
	}
}