/**
 * 
 */
package casa.mod002a.ine;

import org.junit.Before;
import org.junit.Test;

import utilidades.ResourceFile;
import utilidadestest.PadreTest;

/**
 * @author root
 *
 */
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
		assert (out.startsWith("IPC |2017M08|101.553|1.6\n" + 				"EPA"));
		assert (out.contains("Población total (miles) |2017"));
	}

}
