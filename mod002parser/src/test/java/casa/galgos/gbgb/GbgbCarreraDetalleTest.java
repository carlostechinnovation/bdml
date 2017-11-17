package casa.galgos.gbgb;

import java.util.Calendar;

import org.junit.Before;
import org.junit.Test;

import junit.framework.Assert;

/**
 * @author root
 *
 */
public class GbgbCarreraDetalleTest {

	@Before
	public void iniciar() {
	}

	@Test
	public void calcularEdadGalgoEnDiasTest() throws Exception {

		Integer nacimiento = 20150907;
		Calendar fechaNacimiento = Calendar.getInstance();
		fechaNacimiento.clear();
		fechaNacimiento.set(Calendar.YEAR, 2015);
		fechaNacimiento.set(Calendar.MONTH, 9);
		fechaNacimiento.set(Calendar.DAY_OF_MONTH, 7);

		Calendar fechaDeLaCarrera = Calendar.getInstance();
		fechaDeLaCarrera.clear();
		fechaDeLaCarrera.set(Calendar.YEAR, 2016);
		fechaDeLaCarrera.set(Calendar.MONTH, 1);
		fechaDeLaCarrera.set(Calendar.DAY_OF_MONTH, 9);

		Long diasEsperados = (fechaDeLaCarrera.getTimeInMillis() - fechaNacimiento.getTimeInMillis())
				/ (1000 * 60 * 60 * 24);

		Integer out = GbgbPosicionEnCarrera.calcularEdadGalgoEnDias(nacimiento, fechaDeLaCarrera);

		Assert.assertTrue(out.equals(diasEsperados.intValue()));

	}

}
