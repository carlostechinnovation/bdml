/**
 * 
 */
package casa.mod002a.ine;

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
public class IneParserTest extends PadreTest {

	IneParser instancia;
	ResourceFile res;

	@Before
	public void iniciar() {
		instancia = new IneParser();
		res = new ResourceFile("/" + instancia.getPathEntrada(TAG_DIA_TEST));
	}

	@Test
	public void testParsear() throws Exception {
		String out = instancia.parsear(TAG_DIA_TEST, res.getContent());
		Assert.assertTrue(out.startsWith("IPC |2017M08|101.553|1.6\n" + "EPA"));
		Assert.assertTrue(out.contains("Población total (miles) |2017"));
	}

}
