package casa.mod002a.parser;

import org.junit.Before;
import org.junit.Test;

import junit.framework.Assert;
import utilidades.Constantes;

/**
 * @author root
 *
 */
public class Mod002ParserTest {

	@Before
	public void iniciar() {
	}

	@Test
	public void reandAndSetPosibleParamConfigTest() throws Exception {

		Mod002Parser.reandAndSetPosibleParamConfig("3&1&14&30");

		Assert.assertTrue(Constantes.MAX_NUM_CARRERAS_SEMILLA.intValue() == 3);
		Assert.assertTrue(Constantes.MAX_PROFUNDIDAD_PROCESADA.intValue() == 1);
		Assert.assertTrue(Constantes.GALGOS_UMBRAL_DIAS_CARRERAS_ANTERIORES.intValue() == 14);
		Assert.assertTrue(Constantes.MAX_NUM_CARRERAS_PROCESADAS.intValue() == 30);

	}

}