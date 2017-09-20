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
		String out = instancia.parsear(TAG_DIA_TEST, res.getContent());
		assert (out.startsWith(
				"J20170914174424|INTERNATIONAL CONSOLIDAT. AIRLINES GROUP|01/09/2017|Nº Reg.CNMV:| 256057|Programas de recompra de acciones, estabilización y autocartera|La Sociedad remite información sobre las operaciones efectuadas al amparo de su programa de recompra de acciones. \n"
						+ "J20170914174424|SOTOGRANDE"));

	}

}