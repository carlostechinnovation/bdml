package casa.galgos;

import java.io.IOException;
import java.util.Calendar;

import org.junit.Before;
import org.junit.Test;

import casa.galgos.gbgb.GbgbGalgoHistoricoCarrera;
import casa.galgos.gbgb.GbgbParserGalgoHistorico;
import junit.framework.Assert;

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
	public void isHistoricoInsertable() {

		GalgosManager instancia = GalgosManager.getInstancia();
		Calendar fechaUmbralAnterior = Calendar.getInstance();
		fechaUmbralAnterior.set(Calendar.YEAR, 2015);

		Calendar fechaFutura = Calendar.getInstance();
		fechaFutura.set(Calendar.YEAR, 2050);

		GbgbGalgoHistoricoCarrera filaFutura = new GbgbGalgoHistoricoCarrera(null, null, fechaFutura, null, null, null,
				null, null, null, null, null, null, null, null, null, null, null, null, null);
		boolean outFutura = instancia.isHistoricoInsertable(filaFutura, fechaUmbralAnterior);
		Assert.assertTrue(outFutura == false);

		Calendar fechaMuyAntigua = Calendar.getInstance();
		fechaMuyAntigua.set(Calendar.YEAR, 2010);
		GbgbGalgoHistoricoCarrera filaMuyAntigua = new GbgbGalgoHistoricoCarrera(null, null, fechaMuyAntigua, null,
				null, null, null, null, null, null, null, null, null, null, null, null, null, null, null);
		boolean outMuyAntigua = instancia.isHistoricoInsertable(filaMuyAntigua, fechaUmbralAnterior);
		Assert.assertTrue(outMuyAntigua == false);
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
