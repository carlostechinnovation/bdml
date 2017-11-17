package casa.mod002a.parser;

import java.util.Calendar;

import org.junit.Before;
import org.junit.Test;

import casa.galgos.gbgb.GbgbCarrera;
import junit.framework.Assert;
import utilidades.Constantes;

/**
 * @author root
 *
 */
public class ConstantesTest {

	@Before
	public void iniciar() {
	}

	@Test
	public void parsearFechaHoraTest() throws Exception {

		Calendar out = Constantes.parsearFechaHora("09/11/17", "20:52", true);

		Assert.assertTrue(out.get(Calendar.YEAR) == 2017);
		Assert.assertTrue(out.get(Calendar.MONTH) == 11);
		Assert.assertTrue(out.get(Calendar.DAY_OF_MONTH) == 9);
		Assert.assertTrue(out.get(Calendar.HOUR_OF_DAY) == 20);
		Assert.assertTrue(out.get(Calendar.MINUTE) == 52);

		String outStr = GbgbCarrera.formatearFechaParaExportar(out);
		Assert.assertTrue(outStr.equals("2017|11|09|20|52"));

	}

}