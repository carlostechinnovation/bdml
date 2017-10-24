/**
 * 
 */
package casa.mod002a.datosmacro;

import org.junit.Before;
import org.junit.Test;

import junit.framework.Assert;
import utilidades.ResourceFile;
import utilidadestest.PadreTest;

/**
 * @author root
 *
 */
public class DM11ParserTest extends PadreTest {

	DM11Parser instancia;
	ResourceFile res;

	@Before
	public void iniciar() {
		instancia = new DM11Parser();
		res = new ResourceFile("/" + instancia.getPathEntrada(TAG_DIA_TEST));
	}

	@Test
	public void testParsear() throws Exception {
		String out = instancia.parsear(TAG_DIA_TEST, res.getContent("ISO-8859-1"));
		Assert.assertTrue(out.startsWith(
				"J20170914174424|Brasil|8.2|0.60|2.30|2016|02|01|||||||6.40|8.80|2015|08|01\n" + "J20170914174424"));
		Assert.assertTrue(out.contains("\nJ20170914174424|España"));
	}

}
