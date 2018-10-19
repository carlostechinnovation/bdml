package casa.galgos.gbgb;

import java.util.Calendar;

import org.junit.Before;
import org.junit.Test;

import junit.framework.Assert;

/**
 *
 */
public class GbgbCarreraTest {

	@Before
	public void iniciar() {
	}

	@Test
	public void calcularEdadGalgoEnDiasTest() throws Exception {

		int anio = 2018;
		int mes = 0;// 0=Enero...
		int dia = 4;
		int hora = 9;
		int minuto = 5;
		int segundo = 2;

		Calendar in = Calendar.getInstance();
		in.set(anio, mes, dia, hora, minuto, segundo);

		String out = GbgbCarrera.formatearFechaParaExportar(in);

		Assert.assertTrue(out.equals("2018|01|04|09|05"));

	}

	@Test
	public void generarSqlCreateTableTest() throws Exception {

		GbgbCarrera instancia = new GbgbCarrera(true);
		String out = instancia.generarSqlCreateTable("_pre");
		Assert.assertTrue(out != null && !out.isEmpty());
	}

}
