package casa.galgos;

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Calendar;

import org.junit.Before;
import org.junit.Test;

import casa.galgos.gbgb.GbgbGalgoHistoricoCarrera;
import casa.galgos.gbgb.GbgbParserGalgoHistorico;
import junit.framework.Assert;
import utilidades.Constantes;

public class GalgosManagerTest {

	@Before
	public void iniciar() {
	}

	// TODO @Test
	public void descargarYparsearCarrerasDeGalgosTest() throws Exception {

		String param3 = "/galgos_20171021_GBGB_bruto";

		GalgosManager.getInstancia().descargarYparsearCarrerasDeGalgos(param3, false);

		Assert.assertTrue(GalgosManager.getInstancia().idCarrerasCampeonatoProcesadas != null);

		// 0 carreras pendientes
		Assert.assertTrue(GalgosManager.getInstancia().extraerSoloCarrerasPendientes().size() == 0);
		Assert.assertTrue(GalgosManager.getInstancia().contarPendientes() == 0);

	}

	@Test
	public void descargarCarrerasSinFiltrarPorDiaTest() throws IOException {

		String param3 = "/galgos_20171021_GBGB_bruto";
		GalgosManager.getInstancia().descargarCarrerasSinFiltrarPorDia(param3);

		int x = 0;

	}

	// TODO @Test
	public void descargarYProcesarCarreraYAcumularUrlsHistoricosTest() throws IOException {

		String param3 = "/galgos_20171021_GBGB_bruto";

		GalgosManager.getInstancia().descargarYProcesarCarreraYAcumularUrlsHistoricos(2030316L, 151752L, param3);

		int x = 0;
	}

	// TODO @Test
	public void descargarTodosLosHistoricosTest() throws IOException {
		String param3 = "/galgos_20171021_GBGB_bruto";
		GbgbParserGalgoHistorico gpgh = new GbgbParserGalgoHistorico();
		GalgosManager.getInstancia().descargarTodosLosHistoricos(param3, gpgh);

		int x = 0;

	}

	@Test
	public void isHistoricoInsertableTest() {

		GalgosManager instancia = GalgosManager.getInstancia();
		Calendar fechaUmbralAnterior = Calendar.getInstance();
		fechaUmbralAnterior.set(Calendar.YEAR, 2015);

		Calendar fechaFutura = Calendar.getInstance();
		fechaFutura.set(Calendar.YEAR, 2050);
		GbgbGalgoHistoricoCarrera filaFutura = new GbgbGalgoHistoricoCarrera(101L, 201L, fechaFutura, null, null, null,
				null, null, null, null, null, null, null, null, null, null, null, null, null);
		boolean outFutura = instancia.isHistoricoInsertable(filaFutura, fechaUmbralAnterior);
		Assert.assertTrue(outFutura == false);

		Calendar fechaBien = Calendar.getInstance();
		fechaBien.set(Calendar.YEAR, 2017);
		GbgbGalgoHistoricoCarrera filaBien = new GbgbGalgoHistoricoCarrera(102L, 202L, fechaBien, null, null, null, "6",
				null, null, null, null, null, null, null, null, null, null, null, null);
		boolean outBien = instancia.isHistoricoInsertable(filaBien, fechaUmbralAnterior);
		Assert.assertTrue(outBien);

		Calendar fechaMuyAntigua = Calendar.getInstance();
		fechaMuyAntigua.set(Calendar.YEAR, 2010);
		GbgbGalgoHistoricoCarrera filaMuyAntigua = new GbgbGalgoHistoricoCarrera(103L, 203L, fechaMuyAntigua, null,
				null, null, null, null, null, null, null, null, null, null, null, null, null, null, null);
		boolean outMuyAntigua = instancia.isHistoricoInsertable(filaMuyAntigua, fechaUmbralAnterior);
		Assert.assertTrue(outMuyAntigua == false);
	}

	@Test
	public void getFechaUmbralAnteriorTest() {

		Calendar fechaUmbralAnterior = Calendar.getInstance();
		fechaUmbralAnterior.add(Calendar.DAY_OF_MONTH, -1 * Constantes.GALGOS_UMBRAL_DIAS_CARRERAS_ANTERIORES);
		SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSZ");
		System.out.println("-->fechaUmbralAnterior = " + sdf.format(fechaUmbralAnterior.getTime()));

		Long a = Calendar.getInstance().getTimeInMillis();
		Long b = fechaUmbralAnterior.getTimeInMillis();
		Long diferenciaObtenida = a - b;
		Long diferenciaEsperada = Long
				.valueOf(-1000 * 60 * 60 * 24 * Constantes.GALGOS_UMBRAL_DIAS_CARRERAS_ANTERIORES);

		// Assert.assertTrue(diferenciaObtenida.equals(diferenciaEsperada));

		Calendar out = GalgosManager.getFechaUmbralAnterior();

		// Assert.assertTrue((Calendar.getInstance().getTimeInMillis() -
		// out.getTimeInMillis()) == (1000 * 60 * 60 * 24
		// * Constantes.GALGOS_UMBRAL_DIAS_CARRERAS_ANTERIORES));

	}

	// TODO @Test
	public void calcularVelocidadRealMediaRecienteTest() {

	}

	// TODO @Test
	public void calcularVelocidadConGoingMediaRecienteTest() {

	}

	@Test
	public void mostrarRemarksSinTraducirTest() {

		GbgbParserGalgoHistorico gpgh = new GbgbParserGalgoHistorico();

		gpgh.remarksClavesSinTraduccion.add("clavePruebas");

		String out = GalgosManager.mostrarRemarksSinTraducir(gpgh);

		Assert.assertTrue(out.equals("clavePruebas"));
	}

}
