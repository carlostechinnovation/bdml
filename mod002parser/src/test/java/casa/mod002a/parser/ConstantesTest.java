package casa.mod002a.parser;

import java.text.SimpleDateFormat;
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

		Calendar out = Constantes.parsearFechaHora("09/12/17", "20:52", true);
		SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
		String fechaDebug = sdf.format(out.getTime());
		Assert.assertEquals("20171209", fechaDebug);
		String outStr = GbgbCarrera.formatearFechaParaExportar(out);
		Assert.assertTrue(outStr.equals("2017|12|09|20|52"));

		Calendar out2 = Constantes.parsearFechaHora("07/01/19", "20:52", true);
		String fechaDebug2 = sdf.format(out2.getTime());
		Assert.assertEquals("20190107", fechaDebug2);
		String outStr2 = GbgbCarrera.formatearFechaParaExportar(out2);
		Assert.assertTrue(outStr2.equals("2019|01|07|20|52"));
	}

	@Test
	public void parsearFechaTest() throws Exception {

		String[] fechaArray = { "09", "12", "17" };
		Calendar out = Constantes.parsearFecha(fechaArray, true);
		SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
		String fechaDebug = sdf.format(out.getTime());
		Assert.assertEquals("20171209", fechaDebug);

		String[] fechaArray2 = { "05", "01", "19" };
		Calendar out2 = Constantes.parsearFecha(fechaArray2, true);
		String fechaDebug2 = sdf.format(out2.getTime());
		Assert.assertEquals("20190105", fechaDebug2);
	}

	@Test
	public void round2Test() {
		Assert.assertTrue(Constantes.round2(null, 2) == null);
		Assert.assertTrue(Constantes.round2(12.3456F, 2).equals(12.35F));
		Assert.assertTrue(Constantes.round2((12.34F / 0F), 2) == null);
		Assert.assertTrue(Constantes.round2((0F / 12.34F), 2).equals(0F));
		Assert.assertTrue(Constantes.round2(0F, 2).equals(0F));
	}

}